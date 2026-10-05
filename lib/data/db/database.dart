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
    SplitPeople,
    SplitGroups,
    SplitGroupMembers,
    GroupExpenses,
    GroupExpenseShares,
    SplitSettlements,
    OverspendDecisions,
    DailyNumbers,
  ],
)
class SteadyDatabase extends _$SteadyDatabase {
  SteadyDatabase(super.executor);

  @override
  int get schemaVersion => 9;

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
        // Development builds briefly had two different v4s: one without
        // goals.created_on, one that already had the reminder columns. Add
        // only what's missing so both upgrade.
        Future<Set<String>> columnsOf(String table) async => {
          ...await customSelect('PRAGMA table_info($table)')
              .map((r) => r.read<String>('name'))
              .get(),
        };
        final goals = await columnsOf('goals');
        if (!goals.contains('created_on')) {
          await m.addColumn(schema.goals, schema.goals.createdOn);
        }
        final s = schema.settingsRows;
        final existing = await columnsOf('settings_rows');
        for (final column in [
          s.remindLogSpends,
          s.remindLogAt,
          s.remindBills,
          s.remindLatePause,
          s.remindRecaps,
          s.remindBackup,
          s.quietFrom,
        ]) {
          if (!existing.contains(column.name)) await m.addColumn(s, column);
        }
      },
      from5To6: (m, schema) async {
        final d = schema.overspendDecisions;
        await m.addColumn(d, d.categoryId);
        await m.addColumn(d, d.amountCents);
      },
      from6To7: (m, schema) async {
        await m.addColumn(
          schema.settingsRows,
          schema.settingsRows.biometricUnlock,
        );
      },
      from7To8: (m, schema) async {
        final s = schema.settingsRows;
        await m.addColumn(s, s.remindPayday);
        await m.addColumn(s, s.remindPaydayAt);
        // Until now the payday reminder came with "Log your spends": keep it
        // off for anyone who had turned that off.
        await customStatement(
          'UPDATE settings_rows SET remind_payday = remind_log_spends',
        );
      },
      from8To9: (m, schema) async {
        // One-person split → split groups, keeping every shared expense.
        for (final t in [
          schema.splitPeople,
          schema.splitGroups,
          schema.splitGroupMembers,
          schema.groupExpenses,
          schema.groupExpenseShares,
          schema.splitSettlements,
        ]) {
          await m.createTable(t);
        }
        final st = schema.settingsRows;
        await m.addColumn(st, st.remindDebtsOwed);
        await m.addColumn(st, st.remindDebtsYouOwe);

        final old = await customSelect('SELECT * FROM splits').get();
        if (old.isNotEmpty) {
          final split = old.first;
          final shared = await customSelect('SELECT * FROM shared_expenses')
              .get();
          final book = SplitBook.fromLegacy(
            splitId: split.read<String>('id'),
            personName: split.read<String>('person_name'),
            yourSharePercent: split.read<int>('your_share_percent'),
            legacyMethod: split.read<String>('method'),
            expenses: [
              for (final e in shared)
                (
                  id: e.read<String>('id'),
                  name: e.read<String>('name'),
                  amountCents: e.read<int>('amount_cents'),
                  date: LocalDate.parse(e.read<String>('date')),
                  paidByYou: e.read<bool>('paid_by_you'),
                ),
            ],
          );
          await _insertSplitBookV9(this, book);
        }
        await m.deleteTable('splits');
        await m.deleteTable('shared_expenses');
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

  /// v8: the payday reminder has its own switch and time.
  BoolColumn get remindPayday => boolean().withDefault(const Constant(true))();
  IntColumn get remindPaydayAt => integer().withDefault(const Constant(540))();

  /// v9: debt reminders (someone owes you / you owe someone).
  BoolColumn get remindDebtsOwed =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get remindDebtsYouOwe =>
      boolean().withDefault(const Constant(false))();

  /// v7: App lock also opens with Face ID / fingerprint.
  BoolColumn get biometricUnlock =>
      boolean().withDefault(const Constant(false))();

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

/// S4: how a given day's overspend was handled.
@DataClassName('OverspendDecisionRow')
class OverspendDecisions extends Table {
  TextColumn get localDate => text().map(const LocalDateConverter())();
  TextColumn get strategy => textEnum<OverspendStrategy>()();

  /// v6: "Take it from Fun money" — which category covered how much.
  TextColumn get categoryId => text().nullable()();
  IntColumn get amountCents => integer().withDefault(const Constant(0))();

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

// ─── Split groups (v9) ─────────────────────────────────────────────────────

/// Someone you split with. Their name is all Steady knows.
@DataClassName('SplitPersonRow')
class SplitPeople extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get remindMuted => boolean().withDefault(const Constant(false))();
  TextColumn get remindSnoozedUntil =>
      text().map(const LocalDateConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SplitGroupRow')
class SplitGroups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get method => textEnum<SplitMethod>()();
  BoolColumn get simplifyDebts => boolean().withDefault(const Constant(true))();
  TextColumn get createdOn =>
      text().map(const LocalDateConverter()).nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Who's in a group; [weight] is their by-income percentage. "me" (you) has
/// a row too when the group splits by income.
@DataClassName('SplitGroupMemberRow')
class SplitGroupMembers extends Table {
  TextColumn get groupId => text()();
  TextColumn get personId => text()();
  IntColumn get weight => integer().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {groupId, personId};
}

@DataClassName('GroupExpenseRow')
class GroupExpenses extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text()();
  TextColumn get name => text()();
  IntColumn get amountCents => integer()();
  TextColumn get date => text().map(const LocalDateConverter())();
  TextColumn get paidBy => text()();
  TextColumn get entryId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Each person's exact share of an expense (they add up to the amount).
@DataClassName('GroupExpenseShareRow')
class GroupExpenseShares extends Table {
  TextColumn get expenseId => text()();
  TextColumn get personId => text()();
  IntColumn get shareCents => integer()();

  @override
  Set<Column> get primaryKey => {expenseId, personId};
}

@DataClassName('SplitSettlementRow')
class SplitSettlements extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text()();
  TextColumn get fromId => text()();
  TextColumn get toId => text()();
  IntColumn get amountCents => integer()();
  TextColumn get date => text().map(const LocalDateConverter())();
  TextColumn get entryId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Writes [book] into the v9 split tables with plain SQL, so this migration
/// step keeps working even if the tables change in a later version.
Future<void> _insertSplitBookV9(GeneratedDatabase db, SplitBook book) async {
  Future<void> run(String sql, List<Object?> args) =>
      db.customStatement(sql, args);
  for (final p in book.people) {
    await run('INSERT INTO split_people (id, name) VALUES (?, ?)', [
      p.id,
      p.name,
    ]);
  }
  for (final g in book.groups) {
    await run(
      'INSERT INTO split_groups (id, name, method, simplify_debts) '
      'VALUES (?, ?, ?, 1)',
      [g.id, g.name, g.method.name],
    );
    for (final (i, id) in g.everyone.indexed) {
      await run(
        'INSERT INTO split_group_members (group_id, person_id, weight, '
        'sort_order) VALUES (?, ?, ?, ?)',
        [g.id, id, g.weights[id] ?? 0, i],
      );
    }
  }
  for (final e in book.expenses) {
    await run(
      'INSERT INTO group_expenses (id, group_id, name, amount_cents, date, '
      'paid_by) VALUES (?, ?, ?, ?, ?, ?)',
      [e.id, e.groupId, e.name, e.amountCents, e.date.toIso(), e.paidBy],
    );
    for (final share in e.shares.entries) {
      await run(
        'INSERT INTO group_expense_shares (expense_id, person_id, '
        'share_cents) VALUES (?, ?, ?)',
        [e.id, share.key, share.value],
      );
    }
  }
}
