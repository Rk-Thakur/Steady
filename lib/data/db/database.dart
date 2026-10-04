// Drift column check constraints refer to the column's own getter, which the
// analyzer reads as recursion; it is evaluated by the code generator instead.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../../core/local_date.dart';
import '../../domain/models/models.dart';
import '../../domain/schedule.dart';
import 'database.steps.dart';

part 'database.g.dart';

/// Steady's on-device database (Handoff 4 · Storage).
///
/// Conventions:
/// - Money is integer minor units (cents).
/// - Calendar dates are `YYYY-MM-DD` text ([LocalDateConverter]); instants
///   are UTC.
/// - Enums are stored by name, never by index, so reordering an enum can't
///   corrupt data.
/// - Singletons (settings, cycle plan, vault, split) are one-row tables with
///   `id = 1`.
@DriftDatabase(
  tables: [
    SettingsRows,
    CyclePlans,
    Categories,
    Entries,
    Bills,
    Goals,
    Vaults,
    Splits,
    SharedExpenses,
    OverspendDecisions,
    DailyNumbers,
  ],
)
class SteadyDatabase extends _$SteadyDatabase {
  SteadyDatabase(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        // Bills: "this occurrence is paid" becomes "last paid on", and a paid
        // bill's due date moves to its next (unpaid) occurrence.
        await m.renameColumn(schema.bills, 'paid_on', schema.bills.lastPaidOn);
        final paid = await customSelect(
          'SELECT id, due_date, recurrence FROM bills WHERE last_paid_on IS NOT NULL',
        ).get();
        for (final row in paid) {
          final next = nextOccurrence(
            LocalDate.parse(row.read<String>('due_date')),
            Recurrence.values.byName(row.read<String>('recurrence')),
          );
          await customUpdate(
            'UPDATE bills SET due_date = ? WHERE id = ?',
            variables: [
              Variable.withString(next.toIso()),
              Variable.withString(row.read<String>('id')),
            ],
          );
        }
        // Paycheck Vault weekly releases.
        await m.addColumn(schema.entries, schema.entries.fromVault);
        await m.addColumn(schema.entries, schema.entries.billId);
        await m.addColumn(schema.vaults, schema.vaults.lastReleaseDate);
      },
      from2To3: (m, schema) async {
        await m.addColumn(
          schema.settingsRows,
          schema.settingsRows.lastBackupOn,
        );
      },
      from3To4: (m, schema) async {
        await m.createTable(schema.dailyNumbers);
        await m.addColumn(schema.goals, schema.goals.createdOn);
      },
      from4To5: (m, schema) async {
        // Development builds briefly had a v4 without goals.created_on.
        final goalColumns = await customSelect(
          'PRAGMA table_info(goals)',
        ).map((r) => r.read<String>('name')).get();
        if (!goalColumns.contains('created_on')) {
          await m.addColumn(schema.goals, schema.goals.createdOn);
        }
        final s = schema.settingsRows;
        for (final column in [
          s.remindLogSpends,
          s.remindLogAt,
          s.remindBills,
          s.remindLatePause,
          s.remindRecaps,
          s.remindBackup,
          s.quietFrom,
        ]) {
          await m.addColumn(s, column);
        }
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

class LocalDateConverter extends TypeConverter<LocalDate, String> {
  const LocalDateConverter();

  @override
  LocalDate fromSql(String fromDb) => LocalDate.parse(fromDb);

  @override
  String toSql(LocalDate value) => value.toIso();
}

// ─── Singletons ────────────────────────────────────────────────────────────

@DataClassName('SettingsRow')
class SettingsRows extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get currency => textEnum<Currency>()();
  TextColumn get payFrequency => textEnum<PayFrequency>()();
  TextColumn get nextPayday => text().map(const LocalDateConverter())();
  TextColumn get incomeType => textEnum<IncomeType>()();
  TextColumn get displayName => text().nullable()();
  IntColumn get hourlyRateCents => integer().nullable()();
  IntColumn get weekStartsOn =>
      integer().withDefault(const Constant(DateTime.sunday))();
  TextColumn get theme => textEnum<ThemePreference>()();
  BoolColumn get appLockEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get overspendStrategy => textEnum<OverspendStrategy>()();
  BoolColumn get onboarded => boolean().withDefault(const Constant(false))();

  /// v3: when the user last created a .steady backup file.
  TextColumn get lastBackupOn =>
      text().map(const LocalDateConverter()).nullable()();

  /// v5: Reminders (see ReminderSettings for meanings and defaults).
  BoolColumn get remindLogSpends =>
      boolean().withDefault(const Constant(true))();
  IntColumn get remindLogAt => integer().withDefault(const Constant(1230))();
  BoolColumn get remindBills => boolean().withDefault(const Constant(true))();
  BoolColumn get remindLatePause =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get remindRecaps => boolean().withDefault(const Constant(false))();
  BoolColumn get remindBackup => boolean().withDefault(const Constant(true))();
  IntColumn get quietFrom => integer().withDefault(const Constant(1380))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CyclePlanRow')
class CyclePlans extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get startDate => text().map(const LocalDateConverter())();
  IntColumn get openingBalanceCents => integer()();
  IntColumn get goalSetAsideCents => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VaultRow')
class Vaults extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get openingBalanceCents => integer()();
  IntColumn get steadyPayWeeklyCents => integer()();
  IntColumn get targetWeeks => integer().withDefault(const Constant(4))();

  /// v2: Monday of the latest steady-pay release.
  TextColumn get lastReleaseDate =>
      text().map(const LocalDateConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SplitRow')
class Splits extends Table {
  TextColumn get id => text()();
  TextColumn get personName => text()();
  IntColumn get yourSharePercent =>
      integer().check(yourSharePercent.isBetweenValues(0, 100))();
  TextColumn get method => textEnum<SplitMethod>()();
  TextColumn get lastSettled =>
      text().map(const LocalDateConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Collections ───────────────────────────────────────────────────────────

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get tone => textEnum<CategoryTone>()();
  IntColumn get monthlyLimitCents => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EntryRow')
class Entries extends Table {
  TextColumn get id => text()();
  TextColumn get type => textEnum<EntryType>()();
  IntColumn get amountCents =>
      integer().check(amountCents.isBiggerThanValue(0))();

  /// The local calendar day the entry belongs to; never re-derived from the
  /// timestamp, so travel and clock changes don't move it (Handoff 4).
  TextColumn get localDate => text().map(const LocalDateConverter())();
  DateTimeColumn get createdAtUtc => dateTime()();
  TextColumn get timeZoneId => text()();
  TextColumn get merchant =>
      text().withLength(max: Entry.maxMerchantLength).nullable()();

  /// No foreign key: deleting a category keeps its entries (they just lose
  /// the category), as the Edit category screen promises.
  TextColumn get categoryId => text().nullable()();
  TextColumn get mood => textEnum<Mood>().nullable()();
  BoolColumn get planned => boolean().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get splitId => text().nullable()();
  BoolColumn get toVault => boolean().withDefault(const Constant(false))();

  /// v2: a weekly Paycheck Vault release into the daily number.
  BoolColumn get fromVault => boolean().withDefault(const Constant(false))();

  /// v2: the bill this spend paid (bill payments don't count against
  /// today's allowance).
  TextColumn get billId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BillRow')
class Bills extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get amountCents => integer()();
  TextColumn get recurrence => textEnum<Recurrence>()();
  TextColumn get dueDate => text().map(const LocalDateConverter())();
  BoolColumn get isEstimate => boolean().withDefault(const Constant(false))();
  BoolColumn get isSubscription =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get needsReview => boolean().withDefault(const Constant(false))();

  /// v2: was `paid_on` ("this occurrence is paid"); now when the most
  /// recent occurrence was paid, with [dueDate] the next unpaid one.
  TextColumn get lastPaidOn =>
      text().map(const LocalDateConverter()).nullable()();
  IntColumn get previousAmountCents => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GoalRow')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<GoalKind>()();
  IntColumn get targetCents => integer()();
  IntColumn get savedCents => integer()();
  IntColumn get dailySetAsideCents => integer()();
  TextColumn get targetDate =>
      text().map(const LocalDateConverter()).nullable()();
  BoolColumn get paused => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get createdOn =>
      text().map(const LocalDateConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SharedExpenseRow')
class SharedExpenses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get amountCents => integer()();
  TextColumn get date => text().map(const LocalDateConverter())();
  BoolColumn get paidByYou => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

/// S4: how a given day's overspend was handled.
@DataClassName('OverspendDecisionRow')
class OverspendDecisions extends Table {
  TextColumn get localDate => text().map(const LocalDateConverter())();
  TextColumn get strategy => textEnum<OverspendStrategy>()();

  @override
  Set<Column> get primaryKey => {localDate};
}

/// Each day's number as last shown, for "Days under your number" in the
/// summaries. Past numbers can't be recomputed (bills and plans move on), so
/// they are recorded as they happen.
@DataClassName('DailyNumberRow')
class DailyNumbers extends Table {
  TextColumn get localDate => text().map(const LocalDateConverter())();
  IntColumn get allowanceCents => integer()();

  @override
  Set<Column> get primaryKey => {localDate};
}
