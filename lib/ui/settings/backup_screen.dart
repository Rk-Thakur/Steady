import 'package:flutter/material.dart';

import '../../app/notifications.dart';
import '../../core/date_format.dart';
import '../../data/store_scope.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';
import 'backup_flows.dart';

/// P4 Backup & export (Handoff 4: .steady file, CSV; user-initiated only).
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  String? _toast;

  void _show(String? message) {
    if (mounted) setState(() => _toast = message);
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final last = store.settings.lastBackupOn;

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

    Future<void> restore() async {
      final ok = await confirmSheet(
        context,
        title: 'Restore from a backup file?',
        body:
            'Everything on this phone is replaced by what is in the file. '
            'You will need the password the file was locked with.',
        confirmLabel: 'Choose a .steady file',
      );
      if (!ok || !context.mounted) return;
      final restored = await restoreFlow(
        context,
        apply: (snapshot) async => store.restoreFrom(snapshot),
      );
      if (!restored || !context.mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup restored. Your daily number is up to date.'),
        ),
      );
    }

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
                  Icon(
                    last == null
                        ? Icons.info_outline_rounded
                        : Icons.check_rounded,
                    size: 16,
                    color: last == null ? c.warningFg : c.positive,
                  ),
                  const SizedBox(width: SteadySpace.s2),
                  Expanded(
                    child: Text(
                      last == null
                          ? 'No backup file yet'
                          : 'Last backup file: ${formatShortDay(last)}',
                      style: SteadyType.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: last == null ? c.warningFg : c.positive,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SteadyButton(
                'Create backup file',
                height: 48,
                onPressed: () async {
                  final name = await createBackupFlow(context, store);
                  _show(
                    name == null
                        ? null
                        : 'Saved $name. Keep it somewhere safe.',
                  );
                },
              ),
              const SizedBox(height: SteadySpace.s3),
              SwitchRow(
                title: 'Monthly reminder',
                subtitle: 'A local notification on the 1st',
                value: store.settings.reminders.backupMonthly,
                onChanged: (v) {
                  store.updateSettings(
                    store.settings.copyWith(
                      reminders: store.settings.reminders.copyWith(
                        backupMonthly: v,
                      ),
                    ),
                  );
                  if (v) Notifications.instance.requestPermission();
                },
              ),
            ],
          ),
        ),
        GroupedList(
          children: [
            NavRow(
              label: 'Export spreadsheet (CSV)',
              subtitle: 'Every entry, readable in any spreadsheet app',
              onTap: () async {
                final name = await exportCsvFlow(store);
                _show(name == null ? null : 'Saved $name.');
              },
            ),
            const NavRow(
              label: 'Export monthly report (PDF)',
              subtitle: 'Summary, categories and bills',
              value: 'Coming soon',
            ),
            NavRow(
              label: 'Restore from backup file',
              subtitle: 'Replaces what is on this phone',
              onTap: restore,
            ),
          ],
        ),
        StatusToast(message: _toast),
      ],
    );
  }
}
