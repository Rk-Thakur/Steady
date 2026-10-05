import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/local_date.dart';
import '../../domain/models/models.dart';
import 'database.dart';

/// Everything the app needs at launch, read in one go.
@immutable
class BudgetSnapshot {
  const BudgetSnapshot({
    required this.settings,
    required this.plan,
    required this.categories,
    required this.entries,
    required this.bills,
    required this.goals,
    required this.vault,
    this.splits = SplitBook.empty,
    required this.overspendDecisions,
    this.dailyNumbers = const {},
  });

  /// Null until onboarding has saved settings (a fresh install).
  final AppSettings? settings;
  final CyclePlan? plan;
  final List<BudgetCategory> categories;
  final List<Entry> entries;
  final List<Bill> bills;
  final List<Goal> goals;
  final Vault? vault;
  final SplitBook splits;
  final Map<LocalDate, OverspendDecision> overspendDecisions;

  /// Each past day's number (its allowance before spending), as recorded.
  final Map<LocalDate, int> dailyNumbers;

  bool get isFresh => settings == null;
}

/// Reads and writes domain models. The only place that knows about rows.
class BudgetRepository {
  BudgetRepository(this._db);

  final SteadyDatabase _db;

  Future<void> close() => _db.close();

  // ─── Read ────────────────────────────────────────────────────────────────

  Future<BudgetSnapshot> load() => _db.transaction(() async {
    final settings = await _db.select(_db.settingsRows).getSingleOrNull();
    final plan = await _db.select(_db.cyclePlans).getSingleOrNull();
    final vault = await _db.select(_db.vaults).getSingleOrNull();
    final categories =
        await (_db.select(_db.categories)..orderBy([
              (t) => OrderingTerm(expression: t.sortOrder),
              (t) => OrderingTerm(expression: t.name),
            ]))
            .get();
    final entries =
        await (_db.select(_db.entries)..orderBy([
              (t) => OrderingTerm(expression: t.localDate),
              (t) => OrderingTerm(expression: t.createdAtUtc),
            ]))
            .get();
    final bills = await (_db.select(
      _db.bills,
    )..orderBy([(t) => OrderingTerm(expression: t.dueDate)])).get();
    final goals = await (_db.select(
      _db.goals,
    )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();
    final splits = await _loadSplits();
    final decisions = await _db.select(_db.overspendDecisions).get();
    final numbers = await _db.select(_db.dailyNumbers).get();

    return BudgetSnapshot(
      settings: settings == null ? null : _settingsFrom(settings),
      plan: plan == null
          ? null
          : CyclePlan(
              startDate: plan.startDate,
              openingBalanceCents: plan.openingBalanceCents,
              goalSetAsideCents: plan.goalSetAsideCents,
            ),
      categories: [for (final r in categories) _categoryFrom(r)],
      entries: [for (final r in entries) _entryFrom(r)],
      bills: [for (final r in bills) _billFrom(r)],
      goals: [for (final r in goals) _goalFrom(r)],
      vault: vault == null
          ? null
          : Vault(
              openingBalanceCents: vault.openingBalanceCents,
              steadyPayWeeklyCents: vault.steadyPayWeeklyCents,
              targetWeeks: vault.targetWeeks,
              lastReleaseDate: vault.lastReleaseDate,
            ),
      splits: splits,
      overspendDecisions: {
        for (final r in decisions)
          r.localDate: OverspendDecision(
            r.strategy,
            categoryId: r.categoryId,
            amountCents: r.amountCents,
          ),
      },
      dailyNumbers: {for (final r in numbers) r.localDate: r.allowanceCents},
    );
  });

  // ─── Singletons ──────────────────────────────────────────────────────────

  /// The PIN is not stored here; it lives in secure storage (Keychain /
  /// Keystore), separate from the database.
  Future<void> saveSettings(AppSettings s) => _db
      .into(_db.settingsRows)
      .insertOnConflictUpdate(
        SettingsRowsCompanion.insert(
          id: const Value(1),
          currency: s.currency,
          payFrequency: s.payFrequency,
          nextPayday: s.nextPayday,
          incomeType: s.incomeType,
          displayName: Value(s.displayName),
          hourlyRateCents: Value(s.hourlyRateCents),
          weekStartsOn: Value(s.weekStartsOn),
          theme: s.theme,
          appLockEnabled: Value(s.appLockEnabled),
          biometricUnlock: Value(s.biometricUnlock),
          overspendStrategy: s.overspendStrategy,
          onboarded: Value(s.onboarded),
          lastBackupOn: Value(s.lastBackupOn),
          remindLogSpends: Value(s.reminders.logSpends),
          remindLogAt: Value(s.reminders.logAtMinutes),
          remindPayday: Value(s.reminders.payday),
          remindPaydayAt: Value(s.reminders.paydayAtMinutes),
          remindDebtsOwed: Value(s.reminders.debtsOwedToYou),
          remindDebtsYouOwe: Value(s.reminders.debtsYouOwe),
          remindBills: Value(s.reminders.billsDue),
          remindLatePause: Value(s.reminders.latePause),
          remindRecaps: Value(s.reminders.recaps),
          remindBackup: Value(s.reminders.backupMonthly),
          quietFrom: Value(s.reminders.quietFromMinutes),
        ),
      );

  Future<void> savePlan(CyclePlan p) => _db
      .into(_db.cyclePlans)
      .insertOnConflictUpdate(
        CyclePlansCompanion.insert(
          id: const Value(1),
          startDate: p.startDate,
          openingBalanceCents: p.openingBalanceCents,
          goalSetAsideCents: p.goalSetAsideCents,
        ),
      );

  Future<void> saveVault(Vault v) => _db
      .into(_db.vaults)
      .insertOnConflictUpdate(
        VaultsCompanion.insert(
          id: const Value(1),
          openingBalanceCents: v.openingBalanceCents,
          steadyPayWeeklyCents: v.steadyPayWeeklyCents,
          targetWeeks: Value(v.targetWeeks),
          lastReleaseDate: Value(v.lastReleaseDate),
        ),
      );

  // ─── Entries ─────────────────────────────────────────────────────────────

  Future<void> upsertEntry(Entry e) => _db
      .into(_db.entries)
      .insertOnConflictUpdate(
        EntriesCompanion.insert(
          id: e.id,
          type: e.type,
          amountCents: e.amountCents,
          localDate: e.localDate,
          createdAtUtc: e.createdAtUtc,
          timeZoneId: e.timeZoneId,
          merchant: Value(
            e.merchant == null || e.merchant!.length <= Entry.maxMerchantLength
                ? e.merchant
                : e.merchant!.substring(0, Entry.maxMerchantLength),
          ),
          categoryId: Value(e.categoryId),
          mood: Value(e.mood),
          planned: Value(e.planned),
          note: Value(e.note),
          splitId: Value(e.splitId),
          toVault: Value(e.toVault),
          fromVault: Value(e.fromVault),
          billId: Value(e.billId),
        ),
      );

  Future<void> deleteEntry(String id) =>
      (_db.delete(_db.entries)..where((t) => t.id.equals(id))).go();

  // ─── Categories ──────────────────────────────────────────────────────────

  Future<void> upsertCategory(BudgetCategory c, {int? sortOrder}) => _db
      .into(_db.categories)
      .insertOnConflictUpdate(
        CategoriesCompanion.insert(
          id: c.id,
          name: c.name,
          tone: c.tone,
          monthlyLimitCents: Value(c.monthlyLimitCents),
          sortOrder: sortOrder == null
              ? const Value.absent()
              : Value(sortOrder),
        ),
      );

  Future<void> deleteCategory(String id) =>
      (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();

  // ─── Bills ───────────────────────────────────────────────────────────────

  Future<void> upsertBill(Bill b) => _db
      .into(_db.bills)
      .insertOnConflictUpdate(
        BillsCompanion.insert(
          id: b.id,
          name: b.name,
          amountCents: b.amountCents,
          recurrence: b.recurrence,
          dueDate: b.dueDate,
          isEstimate: Value(b.isEstimate),
          isSubscription: Value(b.isSubscription),
          needsReview: Value(b.needsReview),
          lastPaidOn: Value(b.lastPaidOn),
          previousAmountCents: Value(b.previousAmountCents),
        ),
      );

  Future<void> deleteBill(String id) =>
      (_db.delete(_db.bills)..where((t) => t.id.equals(id))).go();

  // ─── Goals ───────────────────────────────────────────────────────────────

  Future<void> upsertGoal(Goal g, {int? sortOrder}) => _db
      .into(_db.goals)
      .insertOnConflictUpdate(
        GoalsCompanion.insert(
          id: g.id,
          name: g.name,
          kind: g.kind,
          targetCents: g.targetCents,
          savedCents: g.savedCents,
          dailySetAsideCents: g.dailySetAsideCents,
          targetDate: Value(g.targetDate),
          paused: Value(g.paused),
          createdOn: Value(g.createdOn),
          sortOrder: sortOrder == null
              ? const Value.absent()
              : Value(sortOrder),
        ),
      );

  Future<void> deleteGoal(String id) =>
      (_db.delete(_db.goals)..where((t) => t.id.equals(id))).go();

  // ─── Splits ──────────────────────────────────────────────────────────────

  Future<SplitBook> _loadSplits() async {
    final people = await _db.select(_db.splitPeople).get();
    final groups = await (_db.select(
      _db.splitGroups,
    )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();
    final members = await (_db.select(
      _db.splitGroupMembers,
    )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();
    final expenses =
        await (_db.select(_db.groupExpenses)..orderBy([
              (t) => OrderingTerm(expression: t.date),
              (t) => OrderingTerm(expression: t.id),
            ]))
            .get();
    final shares = await _db.select(_db.groupExpenseShares).get();
    final settlements = await (_db.select(
      _db.splitSettlements,
    )..orderBy([(t) => OrderingTerm(expression: t.date)])).get();

    return SplitBook(
      people: [
        for (final p in people)
          SplitPerson(
            id: p.id,
            name: p.name,
            remindMuted: p.remindMuted,
            remindSnoozedUntil: p.remindSnoozedUntil,
          ),
      ],
      groups: [
        for (final g in groups)
          SplitGroup(
            id: g.id,
            name: g.name,
            method: g.method,
            simplifyDebts: g.simplifyDebts,
            createdOn: g.createdOn,
            memberIds: [
              for (final m in members)
                if (m.groupId == g.id && m.personId != youId) m.personId,
            ],
            weights: {
              for (final m in members)
                if (m.groupId == g.id && m.weight > 0) m.personId: m.weight,
            },
          ),
      ],
      expenses: [
        for (final e in expenses)
          GroupExpense(
            id: e.id,
            groupId: e.groupId,
            name: e.name,
            amountCents: e.amountCents,
            date: e.date,
            paidBy: e.paidBy,
            entryId: e.entryId,
            shares: {
              for (final s in shares)
                if (s.expenseId == e.id) s.personId: s.shareCents,
            },
          ),
      ],
      settlements: [
        for (final s in settlements)
          Settlement(
            id: s.id,
            groupId: s.groupId,
            fromId: s.fromId,
            toId: s.toId,
            amountCents: s.amountCents,
            date: s.date,
            entryId: s.entryId,
          ),
      ],
    );
  }

  Future<void> upsertSplitPerson(SplitPerson p) => _db
      .into(_db.splitPeople)
      .insertOnConflictUpdate(
        SplitPeopleCompanion.insert(
          id: p.id,
          name: p.name,
          remindMuted: Value(p.remindMuted),
          remindSnoozedUntil: Value(p.remindSnoozedUntil),
        ),
      );

  /// The group and its member list (replaced whole).
  Future<void> upsertSplitGroup(SplitGroup g, {int? sortOrder}) =>
      _db.transaction(() async {
        await _db
            .into(_db.splitGroups)
            .insertOnConflictUpdate(
              SplitGroupsCompanion.insert(
                id: g.id,
                name: g.name,
                method: g.method,
                simplifyDebts: Value(g.simplifyDebts),
                createdOn: Value(g.createdOn),
                sortOrder: sortOrder == null
                    ? const Value.absent()
                    : Value(sortOrder),
              ),
            );
        await (_db.delete(
          _db.splitGroupMembers,
        )..where((t) => t.groupId.equals(g.id))).go();
        for (final (i, id) in g.everyone.indexed) {
          await _db
              .into(_db.splitGroupMembers)
              .insert(
                SplitGroupMembersCompanion.insert(
                  groupId: g.id,
                  personId: id,
                  weight: Value(g.weights[id] ?? 0),
                  sortOrder: Value(i),
                ),
              );
        }
      });

  /// A group with everything in it.
  Future<void> deleteSplitGroup(String id) => _db.transaction(() async {
    final expenseIds =
        await (_db.selectOnly(_db.groupExpenses)
              ..addColumns([_db.groupExpenses.id])
              ..where(_db.groupExpenses.groupId.equals(id)))
            .map((r) => r.read(_db.groupExpenses.id)!)
            .get();
    await (_db.delete(
      _db.groupExpenseShares,
    )..where((t) => t.expenseId.isIn(expenseIds))).go();
    await (_db.delete(
      _db.groupExpenses,
    )..where((t) => t.groupId.equals(id))).go();
    await (_db.delete(
      _db.splitSettlements,
    )..where((t) => t.groupId.equals(id))).go();
    await (_db.delete(
      _db.splitGroupMembers,
    )..where((t) => t.groupId.equals(id))).go();
    await (_db.delete(_db.splitGroups)..where((t) => t.id.equals(id))).go();
  });

  Future<void> upsertGroupExpense(GroupExpense e) => _db.transaction(() async {
    await _db
        .into(_db.groupExpenses)
        .insertOnConflictUpdate(
          GroupExpensesCompanion.insert(
            id: e.id,
            groupId: e.groupId,
            name: e.name,
            amountCents: e.amountCents,
            date: e.date,
            paidBy: e.paidBy,
            entryId: Value(e.entryId),
          ),
        );
    await (_db.delete(
      _db.groupExpenseShares,
    )..where((t) => t.expenseId.equals(e.id))).go();
    for (final s in e.shares.entries) {
      await _db
          .into(_db.groupExpenseShares)
          .insert(
            GroupExpenseSharesCompanion.insert(
              expenseId: e.id,
              personId: s.key,
              shareCents: s.value,
            ),
          );
    }
  });

  Future<void> deleteGroupExpense(String id) => _db.transaction(() async {
    await (_db.delete(
      _db.groupExpenseShares,
    )..where((t) => t.expenseId.equals(id))).go();
    await (_db.delete(_db.groupExpenses)..where((t) => t.id.equals(id))).go();
  });

  Future<void> addSettlement(Settlement s) => _db
      .into(_db.splitSettlements)
      .insertOnConflictUpdate(
        SplitSettlementsCompanion.insert(
          id: s.id,
          groupId: s.groupId,
          fromId: s.fromId,
          toId: s.toId,
          amountCents: s.amountCents,
          date: s.date,
          entryId: Value(s.entryId),
        ),
      );

  Future<void> deleteSettlement(String id) =>
      (_db.delete(_db.splitSettlements)..where((t) => t.id.equals(id))).go();

  Future<void> _saveSplitBook(SplitBook b) async {
    for (final p in b.people) {
      await upsertSplitPerson(p);
    }
    for (var i = 0; i < b.groups.length; i++) {
      await upsertSplitGroup(b.groups[i], sortOrder: i);
    }
    for (final e in b.expenses) {
      await upsertGroupExpense(e);
    }
    for (final s in b.settlements) {
      await addSettlement(s);
    }
  }

  // ─── Overspend ───────────────────────────────────────────────────────────

  Future<void> saveOverspendDecision(LocalDate day, OverspendDecision d) => _db
      .into(_db.overspendDecisions)
      .insertOnConflictUpdate(
        OverspendDecisionsCompanion.insert(
          localDate: day,
          strategy: d.strategy,
          categoryId: Value(d.categoryId),
          amountCents: Value(d.amountCents),
        ),
      );

  Future<void> saveDailyNumber(LocalDate day, int allowanceCents) => _db
      .into(_db.dailyNumbers)
      .insertOnConflictUpdate(
        DailyNumbersCompanion.insert(
          localDate: day,
          allowanceCents: allowanceCents,
        ),
      );

  // ─── Bulk ────────────────────────────────────────────────────────────────

  /// Writes a whole snapshot (first run with demo data, restore from backup).
  Future<void> replaceAll(BudgetSnapshot s) => _db.transaction(() async {
    await deleteEverything();
    if (s.settings != null) await saveSettings(s.settings!);
    if (s.plan != null) await savePlan(s.plan!);
    if (s.vault != null) await saveVault(s.vault!);
    for (var i = 0; i < s.categories.length; i++) {
      await upsertCategory(s.categories[i], sortOrder: i);
    }
    for (final e in s.entries) {
      await upsertEntry(e);
    }
    for (final b in s.bills) {
      await upsertBill(b);
    }
    for (var i = 0; i < s.goals.length; i++) {
      await upsertGoal(s.goals[i], sortOrder: i);
    }
    await _saveSplitBook(s.splits);
    for (final d in s.overspendDecisions.entries) {
      await saveOverspendDecision(d.key, d.value);
    }
    for (final d in s.dailyNumbers.entries) {
      await saveDailyNumber(d.key, d.value);
    }
  });

  /// "Delete all my data".
  Future<void> deleteEverything() => _db.transaction(() async {
    for (final table in _db.allTables) {
      await _db.delete(table).go();
    }
  });

  // ─── Row → model ─────────────────────────────────────────────────────────

  static AppSettings _settingsFrom(SettingsRow r) => AppSettings(
    currency: r.currency,
    payFrequency: r.payFrequency,
    nextPayday: r.nextPayday,
    incomeType: r.incomeType,
    displayName: r.displayName,
    hourlyRateCents: r.hourlyRateCents,
    weekStartsOn: r.weekStartsOn,
    theme: r.theme,
    appLockEnabled: r.appLockEnabled,
    biometricUnlock: r.biometricUnlock,
    overspendStrategy: r.overspendStrategy,
    onboarded: r.onboarded,
    lastBackupOn: r.lastBackupOn,
    reminders: ReminderSettings(
      logSpends: r.remindLogSpends,
      logAtMinutes: r.remindLogAt,
      payday: r.remindPayday,
      paydayAtMinutes: r.remindPaydayAt,
      debtsOwedToYou: r.remindDebtsOwed,
      debtsYouOwe: r.remindDebtsYouOwe,
      billsDue: r.remindBills,
      latePause: r.remindLatePause,
      recaps: r.remindRecaps,
      backupMonthly: r.remindBackup,
      quietFromMinutes: r.quietFrom,
    ),
  );

  static BudgetCategory _categoryFrom(CategoryRow r) => BudgetCategory(
    id: r.id,
    name: r.name,
    tone: r.tone,
    monthlyLimitCents: r.monthlyLimitCents,
  );

  static Entry _entryFrom(EntryRow r) => Entry(
    id: r.id,
    type: r.type,
    amountCents: r.amountCents,
    localDate: r.localDate,
    createdAtUtc: r.createdAtUtc.toUtc(),
    timeZoneId: r.timeZoneId,
    merchant: r.merchant,
    categoryId: r.categoryId,
    mood: r.mood,
    planned: r.planned,
    note: r.note,
    splitId: r.splitId,
    toVault: r.toVault,
    fromVault: r.fromVault,
    billId: r.billId,
  );

  static Bill _billFrom(BillRow r) => Bill(
    id: r.id,
    name: r.name,
    amountCents: r.amountCents,
    recurrence: r.recurrence,
    dueDate: r.dueDate,
    isEstimate: r.isEstimate,
    isSubscription: r.isSubscription,
    needsReview: r.needsReview,
    lastPaidOn: r.lastPaidOn,
    previousAmountCents: r.previousAmountCents,
  );

  static Goal _goalFrom(GoalRow r) => Goal(
    id: r.id,
    name: r.name,
    kind: r.kind,
    targetCents: r.targetCents,
    savedCents: r.savedCents,
    dailySetAsideCents: r.dailySetAsideCents,
    targetDate: r.targetDate,
    paused: r.paused,
    createdOn: r.createdOn,
  );
}
