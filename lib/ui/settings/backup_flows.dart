import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/local_date.dart';
import '../../data/backup/backup_file.dart';
import '../../data/backup/csv_export.dart';
import '../../data/budget_store.dart';
import '../../data/db/budget_repository.dart';
import '../../theme/tokens.dart';
import '../insights/summary_pdf.dart';
import '../insights/summary_report.dart';
import '../widgets/kit.dart';

/// The system Save and Open dialogs. Only ever opened by the user (Handoff 4:
/// "Never written anywhere automatically"). Replaceable in tests.
abstract class BackupFileIo {
  static BackupFileIo instance = const _SystemFileIo();

  /// Shows the system "Save to Files" UI. False if the user cancelled.
  Future<bool> save({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  });

  /// Shows the system file picker. Null if the user cancelled.
  Future<Uint8List?> pick();
}

class _SystemFileIo implements BackupFileIo {
  const _SystemFileIo();

  @override
  Future<bool> save({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async =>
      await FilePicker.saveFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: mimeType,
      ) !=
      null;

  @override
  Future<Uint8List?> pick() async {
    final files = await FilePicker.pickFiles();
    return files.firstOrNull?.readAsBytes();
  }
}

// ─── Create ────────────────────────────────────────────────────────────────

/// Password → encrypt → system Save sheet. Returns the saved file name, or
/// null if the user stopped at any step.
Future<String?> createBackupFlow(
  BuildContext context,
  BudgetStore store,
) async {
  final password = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _NewPasswordSheet(),
  );
  if (password == null || !context.mounted) return null;

  final bytes = await _withProgress(
    context,
    'Locking your backup…',
    BackupFile.create(
      store.toSnapshot(),
      password: password,
      createdAt: DateTime.now(),
    ),
  );
  if (bytes == null || !context.mounted) return null;

  final name = 'steady-backup-${store.today.toIso()}.${BackupFile.extension}';
  final saved = await BackupFileIo.instance.save(
    fileName: name,
    bytes: bytes,
    mimeType: 'application/octet-stream',
  );
  if (!saved) return null;
  store.markBackedUp();
  return name;
}

// ─── CSV ───────────────────────────────────────────────────────────────────

Future<String?> exportCsvFlow(BudgetStore store) async {
  final name = 'steady-entries-${store.today.toIso()}.csv';
  // UTF-8 with a byte-order mark so Excel reads accents and symbols correctly.
  final bytes = Uint8List.fromList([
    0xEF,
    0xBB,
    0xBF,
    ...utf8.encode(entriesToCsv(store.toSnapshot())),
  ]);
  final saved = await BackupFileIo.instance.save(
    fileName: name,
    bytes: bytes,
    mimeType: 'text/csv',
  );
  return saved ? name : null;
}

// ─── PDF report ────────────────────────────────────────────────────────────

/// The weekly or monthly summary as a PDF, made on this phone, then the
/// system Save sheet. Returns the file name, or null if the user cancelled.
Future<String?> exportPdfFlow(BudgetStore store, {required bool month}) async {
  final report = SummaryReport.fromStore(store, month: month);
  final bytes = await buildSummaryPdf(report, await ReportFonts.load());
  final saved = await BackupFileIo.instance.save(
    fileName: report.pdfFileName,
    bytes: bytes,
    mimeType: 'application/pdf',
  );
  return saved ? report.pdfFileName : null;
}

// ─── Restore ───────────────────────────────────────────────────────────────

/// Pick a .steady file → password → preview → confirm → [apply].
/// Returns true when the backup was applied.
Future<bool> restoreFlow(
  BuildContext context, {
  required Future<void> Function(BudgetSnapshot snapshot) apply,
}) async {
  final bytes = await BackupFileIo.instance.pick();
  if (bytes == null || !context.mounted) return false;

  final contents = await showModalBottomSheet<BackupContents>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _UnlockSheet(bytes: bytes),
  );
  if (contents == null || !context.mounted) return false;

  final s = contents.snapshot;
  final created = LocalDate.fromDateTime(contents.createdAt.toLocal());
  final ok = await confirmSheet(
    context,
    title: 'Restore this backup?',
    body:
        'Backup from ${formatShortDay(created)}, ${created.year}: ${s.entries.length} entries, '
        '${s.bills.length} bills, ${s.goals.length} goals. Everything on this phone is replaced. '
        'App lock is turned off; set it again in Settings.',
    confirmLabel: 'Replace everything',
  );
  if (!ok || !context.mounted) return false;
  await _withProgress(context, 'Restoring…', apply(s));
  return true;
}

// ─── Pieces ────────────────────────────────────────────────────────────────

/// Runs [work] behind a small blocking spinner. Null if it failed (the error
/// is shown).
Future<T?> _withProgress<T>(
  BuildContext context,
  String label,
  Future<T> work,
) async {
  final nav = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(SteadySpace.s6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(width: SteadySpace.s4),
              Text(
                label,
                style: SteadyType.body.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  try {
    return await work;
  } catch (e) {
    debugPrint('Steady: $label failed: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Nothing was changed.'),
        ),
      );
    }
    return null;
  } finally {
    nav.pop();
  }
}

/// Handoff 4: the backup file is locked with a password the user chooses.
class _NewPasswordSheet extends StatefulWidget {
  const _NewPasswordSheet();

  @override
  State<_NewPasswordSheet> createState() => _NewPasswordSheetState();
}

class _NewPasswordSheetState extends State<_NewPasswordSheet> {
  final _pw = TextEditingController();
  final _again = TextEditingController();

  @override
  void dispose() {
    _pw.dispose();
    _again.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const min = BackupFile.minPasswordLength;
    final tooShort = _pw.text.isNotEmpty && _pw.text.length < min;
    final mismatch = _again.text.isNotEmpty && _again.text != _pw.text;
    final ok = _pw.text.length >= min && _again.text == _pw.text;
    return _SheetBody(
      title: 'Lock your backup',
      body: "Choose a password for this file. We can't recover it for you, so keep it somewhere safe.",
      children: [
        SteadyField(
          label: 'Password ($min+ characters)',
          controller: _pw,
          obscure: true,
          autofocus: true,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: SteadySpace.s3),
        SteadyField(
          label: 'Type it again',
          controller: _again,
          obscure: true,
          onChanged: (_) => setState(() {}),
        ),
        _ErrorLine(
          tooShort
              ? 'Use at least $min characters.'
              : mismatch
              ? "Passwords don't match."
              : null,
          color: c.dangerFg,
        ),
        SteadyButton(
          'Create backup file',
          onPressed: ok ? () => Navigator.of(context).pop(_pw.text) : null,
        ),
      ],
    );
  }
}

/// Password for an existing file; decrypts in place so a wrong password can
/// be retried without picking the file again.
class _UnlockSheet extends StatefulWidget {
  const _UnlockSheet({required this.bytes});
  final Uint8List bytes;

  @override
  State<_UnlockSheet> createState() => _UnlockSheetState();
}

class _UnlockSheetState extends State<_UnlockSheet> {
  final _pw = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _pw.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final contents = await BackupFile.open(widget.bytes, password: _pw.text);
      if (mounted) Navigator.of(context).pop(contents);
    } on BackupException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _SheetBody(
      title: 'Unlock backup',
      body: 'Enter the password this file was locked with.',
      children: [
        SteadyField(
          label: 'Password',
          controller: _pw,
          obscure: true,
          autofocus: true,
          onChanged: (_) => setState(() {}),
        ),
        _ErrorLine(_error, color: c.dangerFg),
        SteadyButton(
          _busy ? 'Unlocking…' : 'Unlock',
          onPressed: _busy || _pw.text.isEmpty ? null : _unlock,
        ),
      ],
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.title,
    required this.body,
    required this.children,
  });
  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      SteadySpace.s5,
      0,
      SteadySpace.s5,
      MediaQuery.viewInsetsOf(context).bottom + SteadySpace.s6,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: SteadyType.title.copyWith(fontSize: 24)),
        const SizedBox(height: SteadySpace.s2),
        Text(
          body,
          style: SteadyType.body.copyWith(
            fontSize: 14,
            color: context.colors.muted,
          ),
        ),
        const SizedBox(height: SteadySpace.s4),
        ...children,
      ],
    ),
  );
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine(this.text, {required this.color});
  final String? text;
  final Color color;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 28),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SteadySpace.s1),
        child: Text(
          text ?? '',
          style: SteadyType.caption.copyWith(color: color),
        ),
      ),
    ),
  );
}
