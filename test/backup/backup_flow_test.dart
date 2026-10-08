import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';
import 'package:steady/ui/settings/backup_flows.dart';

/// Stands in for the system Save / Open dialogs.
class _FakeFileIo implements BackupFileIo {
  final saved = <String, Uint8List>{};
  Uint8List? toPick;

  @override
  Future<bool> save({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    saved[fileName] = bytes;
    return true;
  }

  @override
  Future<Uint8List?> pick() async => toPick;
}

void main() {
  const oct2 = LocalDate(2026, 10, 2);
  late _FakeFileIo io;

  setUp(() => BackupFileIo.instance = io = _FakeFileIo());

  Future<BudgetStore> openBackupScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = BudgetStore.sample(clock: () => oct2);
    await tester.pumpWidget(SteadyApp(store: store, initialRoute: Routes.home));
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.backup);
    await tester.pumpAndSettle();
    return store;
  }

  /// Lets the encryption isolate (real time) run until [until] shows, up to
  /// 20 seconds, so a busy machine doesn't fail the test.
  Future<void> letCryptoRun(WidgetTester tester, Finder until) async {
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      // One frame at a time: a progress spinner is on screen meanwhile, so
      // pumpAndSettle would grind through its 10-minute limit.
      await tester.pump();
      if (until.evaluate().isNotEmpty) break;
    }
    await tester.pumpAndSettle();
  }

  testWidgets('create a backup, then restore it over changed data', (
    tester,
  ) async {
    final store = await openBackupScreen(tester);
    expect(find.text('No backup file yet'), findsOneWidget);

    // Create: password twice, then the (fake) Save sheet receives the file.
    await tester.tap(find.text('Create backup file'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'correct horse');
    await tester.enterText(fields.at(1), 'correct horse');
    await tester.pump();
    await tester.tap(find.text('Create backup file').last);
    await letCryptoRun(
      tester,
      find.textContaining('Last backup file', skipOffstage: false),
    );

    expect(io.saved.keys, ['steady-backup-2026-10-02.steady']);
    expect(store.settings.lastBackupOn, oct2);
    expect(
      find.textContaining('Last backup file: Fri, Oct 2', skipOffstage: false),
      findsOneWidget,
    );

    // Change something after the backup.
    store.addEntry(
      Entry(
        id: 'after',
        type: EntryType.spend,
        amountCents: 1000,
        localDate: oct2,
        createdAtUtc: DateTime.utc(2026),
        timeZoneId: 'UTC',
        merchant: 'After backup',
      ),
    );

    // Restore: confirm, pick the file, wrong password first, then the right one.
    io.toPick = io.saved.values.single;
    await tester.ensureVisible(find.text('Restore from backup file'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore from backup file'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a .steady file'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'wrong password');
    await tester.pump();
    await tester.tap(find.text('Unlock'));
    await letCryptoRun(
      tester,
      find.text(
        "That password doesn't open this file. Check it and try again.",
      ),
    );
    expect(
      find.text(
        "That password doesn't open this file. Check it and try again.",
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField).last, 'correct horse');
    await tester.pump();
    await tester.tap(find.text('Unlock'));
    await letCryptoRun(tester, find.textContaining('Backup from'));

    // The preview names the backup's real creation date and what's in it.
    expect(find.textContaining('Backup from'), findsOneWidget);
    expect(find.textContaining('9 bills, 3 goals'), findsOneWidget);
    await tester.tap(find.text('Replace everything'));
    await letCryptoRun(
      tester,
      find.text('Backup restored. Your daily number is up to date.'),
    );

    expect(store.entries.any((e) => e.id == 'after'), isFalse);
    expect(store.dailyNumber.safeToSpendCents, 4620);
    expect(
      find.text('Backup restored. Your daily number is up to date.'),
      findsOneWidget,
    );
  });

  testWidgets('a mismatched password can\'t create a backup', (tester) async {
    await openBackupScreen(tester);
    await tester.tap(find.text('Create backup file'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'correct horse');
    await tester.enterText(fields.at(1), 'correct house');
    await tester.pump();
    expect(find.text("Passwords don't match."), findsOneWidget);
    await tester.tap(find.text('Create backup file').last);
    await tester.pump();
    expect(io.saved, isEmpty);
  });

  testWidgets('export CSV hands a spreadsheet to the Save sheet', (
    tester,
  ) async {
    await openBackupScreen(tester);
    await tester.tap(find.text('Export spreadsheet (CSV)'));
    await tester.pumpAndSettle();
    final csv = io.saved['steady-entries-2026-10-02.csv']!;
    expect(csv.sublist(0, 3), [0xEF, 0xBB, 0xBF]); // UTF-8 BOM for Excel
    expect(
      String.fromCharCodes(csv.sublist(3, 20)),
      startsWith('Date,Type,Amount'),
    );
    expect(
      find.text('Saved steady-entries-2026-10-02.csv.', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('Backup: export the monthly report as a PDF', (tester) async {
    await openBackupScreen(tester);
    await tester.ensureVisible(find.text('Export monthly report (PDF)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export monthly report (PDF)'));
    // Font loading and PDF building are async.
    await letCryptoRun(
      tester,
      find.textContaining('Saved steady-month-', skipOffstage: false),
    );
    final name = io.saved.keys.single;
    expect(name, startsWith('steady-month-2026-'));
    expect(String.fromCharCodes(io.saved[name]!.take(5)), '%PDF-');
    expect(find.text('Saved $name.', skipOffstage: false), findsOneWidget);
  });

  testWidgets('Weekly summary: Save as PDF', (tester) async {
    await openBackupScreen(tester);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(Routes.summaryWeek);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Save as PDF'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save as PDF'));
    await letCryptoRun(
      tester,
      find.textContaining('Saved steady-week-', skipOffstage: false),
    );
    final name = io.saved.keys.single;
    expect(name, startsWith('steady-week-'));
    expect(find.text('Saved $name.', skipOffstage: false), findsOneWidget);
  });
}
