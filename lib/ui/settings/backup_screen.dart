import 'package:flutter/material.dart';

import '../../data/store_scope.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';

/// P4 Backup & export. File creation is not wired yet; actions show what
/// will happen (Handoff 4: .steady file, CSV and PDF, user-initiated only).
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _monthly = true;
  String _last = 'Never';
  String? _toast;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final today = store.today;

    Future<void> deleteAll() async {
      final ok = await confirmSheet(
        context,
        title: 'Delete everything?',
        body:
            'All entries, bills and goals on this phone will be erased. '
            "Backup files you saved elsewhere are not touched. This can't be undone.",
        confirmLabel: 'Delete all data',
      );
      if (!ok || !context.mounted) return;
      store.deleteAll();
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.welcome, (_) => false);
    }

    Widget exportRow(String title, String subtitle, String toast) => NavRow(
      label: title,
      subtitle: subtitle,
      onTap: () => setState(() => _toast = toast),
    );

    return SteadyPage(
      title: 'Backup & export',
      bottom: SteadyButton(
        'Delete all my data',
        kind: ButtonKind.dangerLink,
        height: 48,
        onPressed: deleteAll,
      ),
      children: [
        const SoftBanner(
          icon: Icons.lock_outline_rounded,
          child: LeadText(
            lead: 'Your data lives only on this phone.',
            body:
                'Steady has no account and no cloud. A backup file is the only way to keep your '
                'history if you lose or replace your phone.',
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Backup file',
                style: SteadyType.heading.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'One encrypted file, locked with a password you choose. Save it to Files, a USB drive, or anywhere you trust.',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.muted,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.check_rounded, size: 16, color: c.positive),
                  const SizedBox(width: SteadySpace.s2),
                  Text(
                    'Last backup file: $_last',
                    style: SteadyType.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: c.positive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SteadyButton(
                'Create backup file',
                height: 48,
                onPressed: () async {
                  final ok = await _askPassword(context);
                  if (!ok || !mounted) return;
                  setState(() {
                    _last = 'today';
                    _toast =
                        'Saved steady-backup-${today.toIso()}.steady. Keep it somewhere safe.';
                  });
                },
              ),
              const SizedBox(height: SteadySpace.s3),
              SwitchRow(
                title: 'Monthly reminder',
                subtitle: 'A local notification on the 1st',
                value: _monthly,
                onChanged: (v) => setState(() => _monthly = v),
              ),
            ],
          ),
        ),
        GroupedList(
          children: [
            exportRow(
              'Export spreadsheet (CSV)',
              'Every entry, readable in any spreadsheet app',
              'steady-entries.csv created. Choose where to save it.',
            ),
            exportRow(
              'Export monthly report (PDF)',
              'Summary, categories and bills',
              'Monthly report (PDF) created. Choose where to save it.',
            ),
            NavRow(
              label: 'Restore from backup file',
              subtitle: 'Replaces what is on this phone',
              onTap: () async {
                final ok = await confirmSheet(
                  context,
                  title: 'Restore from a backup file?',
                  body:
                      'Everything on this phone is replaced by what is in the file. '
                      'You will need the password the file was locked with.',
                  confirmLabel: 'Choose a .steady file',
                );
                if (!ok || !mounted) return;
                // File picking and decryption arrive with the database work.
                setState(
                  () =>
                      _toast = 'Pick a .steady file, then enter its password.',
                );
              },
            ),
          ],
        ),
        StatusToast(message: _toast),
      ],
    );
  }
}

/// Handoff 4: the backup file is locked with a password the user chooses.
/// Returns true when a valid password was entered twice.
Future<bool> _askPassword(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _PasswordSheet(),
  );
  return result ?? false;
}

class _PasswordSheet extends StatefulWidget {
  const _PasswordSheet();

  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
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
    final tooShort = _pw.text.isNotEmpty && _pw.text.length < 8;
    final mismatch = _again.text.isNotEmpty && _again.text != _pw.text;
    final ok = _pw.text.length >= 8 && _again.text == _pw.text;
    return Padding(
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
          Text(
            'Lock your backup',
            style: SteadyType.title.copyWith(fontSize: 24),
          ),
          const SizedBox(height: SteadySpace.s2),
          Text(
            "Choose a password for this file. We can't recover it for you, so keep it somewhere safe.",
            style: SteadyType.body.copyWith(fontSize: 14, color: c.muted),
          ),
          const SizedBox(height: SteadySpace.s4),
          SteadyField(
            label: 'Password (8+ characters)',
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
          SizedBox(
            height: 28,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tooShort
                    ? 'Use at least 8 characters.'
                    : mismatch
                    ? "Passwords don't match."
                    : '',
                style: SteadyType.caption.copyWith(color: c.dangerFg),
              ),
            ),
          ),
          SteadyButton(
            'Create backup file',
            onPressed: ok ? () => Navigator.of(context).pop(true) : null,
          ),
        ],
      ),
    );
  }
}
