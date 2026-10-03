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
    required this.split,
    required this.sharedExpenses,
    required this.overspendDecisions,
  });

  /// Null until onboarding has saved settings (a fresh install).
  final AppSettings? settings;
  final CyclePlan? plan;
  final List<BudgetCategory> categories;
  final List<Entry> entries;
  final List<Bill> bills;
  final List<Goal> goals;
  final Vault? vault;
  final ExpenseSplit? split;
  final List<SharedExpense> sharedExpenses;
  final Map<LocalDate, OverspendStrategy> overspendDecisions;

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
    final split = await _db.select(_db.splits).getSingleOrNull();
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
    final shared = await (_db.select(
      _db.sharedExpenses,
    )..orderBy([(t) => OrderingTerm(expression: t.date)])).get();
    final decisions = await _db.select(_db.overspendDecisions).get();

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
            ),
      split: split == null
          ? null
          : ExpenseSplit(
              id: split.id,
              personName: split.personName,
              yourSharePercent: split.yourSharePercent,
              method: split.method,
              lastSettled: split.lastSettled,
            ),
      sharedExpenses: [
        for (final r in shared)
          SharedExpense(
            id: r.id,
            name: r.name,
            amountCents: r.amountCents,
            date: r.date,
            paidByYou: r.paidByYou,
          ),
      ],
      overspendDecisions: {for (final r in decisions) r.localDate: r.strategy},
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
          overspendStrategy: s.overspendStrategy,
          onboarded: Value(s.onboarded),
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
        ),
      );

  /// One split partner at a time: replaces any previous one.
  Future<void> saveSplit(ExpenseSplit s) => _db.transaction(() async {
    await (_db.delete(_db.splits)..where((t) => t.id.equals(s.id).not())).go();
    await _db
        .into(_db.splits)
        .insertOnConflictUpdate(
          SplitsCompanion.insert(
            id: s.id,
            personName: s.personName,
            yourSharePercent: s.yourSharePercent,
            method: s.method,
            lastSettled: Value(s.lastSettled),
          ),
        );
  });

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
          merchant: Value(e.merchant),
          categoryId: Value(e.categoryId),
          mood: Value(e.mood),
          planned: Value(e.planned),
          note: Value(e.note),
          splitId: Value(e.splitId),
          toVault: Value(e.toVault),
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
          paidOn: Value(b.paidOn),
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
          sortOrder: sortOrder == null
              ? const Value.absent()
              : Value(sortOrder),
        ),
      );

  Future<void> deleteGoal(String id) =>
      (_db.delete(_db.goals)..where((t) => t.id.equals(id))).go();

  // ─── Splits ──────────────────────────────────────────────────────────────

  Future<void> addSharedExpense(SharedExpense e) => _db
      .into(_db.sharedExpenses)
      .insertOnConflictUpdate(
        SharedExpensesCompanion.insert(
          id: e.id,
          name: e.name,
          amountCents: e.amountCents,
          date: e.date,
          paidByYou: e.paidByYou,
        ),
      );

  /// Settle up: clear shared expenses and stamp the settle date, atomically.
  Future<void> settleUp(ExpenseSplit settled) => _db.transaction(() async {
    await _db.delete(_db.sharedExpenses).go();
    await saveSplit(settled);
  });

  // ─── Overspend ───────────────────────────────────────────────────────────

  Future<void> saveOverspendDecision(LocalDate day, OverspendStrategy s) => _db
      .into(_db.overspendDecisions)
      .insertOnConflictUpdate(
        OverspendDecisionsCompanion.insert(localDate: day, strategy: s),
      );

  // ─── Bulk ────────────────────────────────────────────────────────────────

  /// Writes a whole snapshot (first run with demo data, restore from backup).
  Future<void> replaceAll(BudgetSnapshot s) => _db.transaction(() async {
    await deleteEverything();
    if (s.settings != null) await saveSettings(s.settings!);
    if (s.plan != null) await savePlan(s.plan!);
    if (s.vault != null) await saveVault(s.vault!);
    if (s.split != null) await saveSplit(s.split!);
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
    for (final e in s.sharedExpenses) {
      await addSharedExpense(e);
    }
    for (final d in s.overspendDecisions.entries) {
      await saveOverspendDecision(d.key, d.value);
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
    overspendStrategy: r.overspendStrategy,
    onboarded: r.onboarded,
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
    paidOn: r.paidOn,
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
  );
}
