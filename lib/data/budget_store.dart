import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/local_date.dart';
import '../domain/cycle.dart';
import '../domain/daily_number.dart';
import '../domain/models/models.dart';
import '../domain/schedule.dart';
import 'db/budget_repository.dart';
import 'db/database_key.dart';

/// App state for every screen.
///
/// The store is the single source of truth the UI reads synchronously. When a
/// [BudgetRepository] is attached, every change is also written to the
/// encrypted database: the UI updates immediately, and writes run one after
/// another in the background (so they land in the order they happened).
/// Without a repository (tests, previews) the store is in-memory only.
class BudgetStore extends ChangeNotifier {
  BudgetStore({
    required this._settings,
    required this._plan,
    required List<BudgetCategory> categories,
    required List<Entry> entries,
    required List<Bill> bills,
    required List<Goal> goals,
    required this._vault,
    this._split,
    List<SharedExpense> sharedExpenses = const [],
    Map<LocalDate, OverspendStrategy> overspendDecisions = const {},
    LocalDate Function()? clock,
    BudgetRepository? repository,
    this._pinVault,
  }) : _categories = List.of(categories),
       _entries = List.of(entries),
       _bills = List.of(bills),
       _goals = List.of(goals),
       _shared = List.of(sharedExpenses),
       _overspendHandled = Map.of(overspendDecisions),
       _clock = clock ?? LocalDate.today,
       _repo = repository;

  /// Builds the store from what the database holds. A fresh install gets
  /// [defaultSnapshot] (and it is saved straight away).
  factory BudgetStore.fromSnapshot(
    BudgetSnapshot snapshot, {
    LocalDate Function()? clock,
    BudgetRepository? repository,
    KeyVault? pinVault,
    String? pin,
  }) {
    final today = (clock ?? LocalDate.today)();
    final s = snapshot.isFresh ? defaultSnapshot(today) : snapshot;
    var settings = s.settings!;
    // The PIN lives in secure storage, not the database. App lock without a
    // PIN can't work, so treat it as off.
    settings = settings.copyWith(
      pin: () => pin,
      appLockEnabled: settings.appLockEnabled && pin != null,
    );
    final store = BudgetStore(
      settings: settings,
      plan: s.plan!,
      categories: s.categories,
      entries: s.entries,
      bills: s.bills,
      goals: s.goals,
      vault: s.vault!,
      split: s.split,
      sharedExpenses: s.sharedExpenses,
      overspendDecisions: s.overspendDecisions,
      clock: clock,
      repository: repository,
      pinVault: pinVault,
    );
    if (snapshot.isFresh) store._save((r) => r.replaceAll(store.toSnapshot()));
    // Catch up on Vault releases and automatic cycles since the last launch.
    store.refreshDay();
    return store;
  }

  /// What a brand-new install starts with: nothing logged, default
  /// categories, onboarding not done.
  static BudgetSnapshot defaultSnapshot(LocalDate today) => BudgetSnapshot(
    settings: AppSettings(
      currency: Currency.usd,
      payFrequency: PayFrequency.monthly,
      nextPayday: today.addDays(14),
      onboarded: false,
    ),
    plan: CyclePlan(
      startDate: today,
      openingBalanceCents: 0,
      goalSetAsideCents: 0,
    ),
    categories: const [
      BudgetCategory(id: 'food', name: 'Food', tone: CategoryTone.warning),
      BudgetCategory(
        id: 'transport',
        name: 'Transport',
        tone: CategoryTone.info,
      ),
      BudgetCategory(
        id: 'shopping',
        name: 'Shopping',
        tone: CategoryTone.danger,
      ),
      BudgetCategory(id: 'fun', name: 'Fun', tone: CategoryTone.primary),
      BudgetCategory(id: 'health', name: 'Health', tone: CategoryTone.neutral),
      BudgetCategory(
        id: 'bills',
        name: 'Bills & subs',
        tone: CategoryTone.info,
      ),
    ],
    entries: const [],
    bills: const [],
    goals: const [],
    vault: const Vault(openingBalanceCents: 0, steadyPayWeeklyCents: 0),
    split: null,
    sharedExpenses: const [],
    overspendDecisions: const {},
  );

  AppSettings _settings;
  CyclePlan _plan;
  final List<BudgetCategory> _categories;
  final List<Entry> _entries;
  final List<Bill> _bills;
  final List<Goal> _goals;
  Vault _vault;
  ExpenseSplit? _split;
  final List<SharedExpense> _shared;

  /// How each day's overspend was handled (S4), by local date.
  final Map<LocalDate, OverspendStrategy> _overspendHandled;
  final LocalDate Function() _clock;
  final BudgetRepository? _repo;
  final KeyVault? _pinVault;
  var _nextId = 0;

  // ─── Persistence ─────────────────────────────────────────────────────────

  Future<void> _pending = Future.value();

  /// The last save that failed, if any (shown as a banner).
  Object? get saveError => _saveError;
  Object? _saveError;

  /// Queues [op] after earlier writes. Failures are kept in [saveError]
  /// rather than lost; the in-memory state stays as the user sees it.
  void _save(Future<void> Function(BudgetRepository repo) op) {
    final repo = _repo;
    if (repo == null) return;
    _pending = _pending
        .then((_) => op(repo))
        .then(
          (_) {
            if (_saveError != null) {
              _saveError = null;
              notifyListeners();
            }
          },
          onError: (Object e, StackTrace st) {
            _saveError = e;
            debugPrint('Steady: save failed: $e\n$st');
            notifyListeners();
          },
        );
  }

  /// Completes when every queued write has finished.
  Future<void> flush() => _pending;

  int _orderOf<T>(List<T> list, T item) => list.indexOf(item);

  // ─── Reads ───────────────────────────────────────────────────────────────

  AppSettings get settings => _settings;
  CyclePlan get plan => _plan;
  List<BudgetCategory> get categories => List.unmodifiable(_categories);
  List<Entry> get entries => List.unmodifiable(_entries);
  List<Bill> get bills => List.unmodifiable(_bills);
  List<Goal> get goals => List.unmodifiable(_goals);
  Vault get vault => _vault;
  ExpenseSplit? get split => _split;
  List<SharedExpense> get sharedExpenses => List.unmodifiable(_shared);

  LocalDate get today => _clock();
  LocalDate get nextPayday => _settings.nextPayday;
  String get symbol => _settings.currencySymbol;

  BudgetCategory? categoryById(String? id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Entry? entryById(String id) {
    for (final e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  Goal? goalById(String id) {
    for (final g in _goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  DailyNumber get dailyNumber => DailyNumberCalculator.calculate(dailyInput);

  DailyNumberInput get dailyInput => DailyNumberCalculator.inputFromLedger(
    today: today,
    nextPayday: nextPayday,
    plan: _plan,
    entries: _entries,
    bills: _bills,
  );

  /// The daily number if [entry] were logged now (live previews on forms).
  DailyNumber previewWith(Entry entry) => DailyNumberCalculator.calculate(
    DailyNumberCalculator.inputFromLedger(
      today: today,
      nextPayday: nextPayday,
      plan: _plan,
      entries: [..._entries, entry],
      bills: _bills,
    ),
  );

  /// Today's entries, newest first.
  List<Entry> get todayEntries {
    final t = today;
    return _entries.where((e) => e.localDate == t).toList()
      ..sort((a, b) => b.createdAtUtc.compareTo(a.createdAtUtc));
  }

  /// Every entry, newest first.
  List<Entry> get history => List.of(_entries)
    ..sort((a, b) {
      final byDate = b.localDate.compareTo(a.localDate);
      return byDate != 0 ? byDate : b.createdAtUtc.compareTo(a.createdAtUtc);
    });

  /// Most recent day with any entry, or null if nothing was ever logged.
  LocalDate? get lastLoggedDate {
    LocalDate? last;
    for (final e in _entries) {
      if (last == null || e.localDate.isAfter(last)) last = e.localDate;
    }
    return last;
  }

  /// Days before today with nothing logged since the last entry (S3 catch-up).
  List<LocalDate> get missedDays {
    final last = lastLoggedDate;
    if (last == null) return const [];
    final t = today;
    return [for (var d = last.addDays(1); d.isBefore(t); d = d.addDays(1)) d];
  }

  bool get isNewUser => _entries.isEmpty && _bills.isEmpty;

  /// Bill payments in this pay cycle: one slot per occurrence, paid ones
  /// (since the cycle started) first, then everything still reserved before
  /// payday. A weekly bill can appear more than once.
  List<CycleBill> get billsThisCycle {
    final paid = [
      for (final b in _bills)
        if (b.paidSince(_plan.startDate))
          CycleBill(b, b.lastPaidOn!, paid: true),
    ]..sort((a, b) => a.date.compareTo(b.date));
    final due = [
      for (final b in _bills)
        for (final d in b.occurrencesBefore(nextPayday))
          CycleBill(b, d, paid: false),
    ]..sort((a, b) => a.date.compareTo(b.date));
    return [...paid, ...due];
  }

  /// Unpaid bills before payday, by due date.
  List<Bill> get upcomingBills =>
      _bills.where((b) => b.isReservedBefore(nextPayday)).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  int get reservedBillsCents =>
      _bills.fold(0, (sum, b) => sum + b.reservedBefore(nextPayday));

  /// Payday has arrived for a regular earner and no pay is logged yet (V2),
  /// unless they said "Not yet" today.
  bool get isAwaitingPay =>
      _payPromptSnoozedOn != today &&
      awaitingPay(
        today: today,
        nextPayday: nextPayday,
        frequency: _settings.payFrequency,
      );
  LocalDate? _payPromptSnoozedOn;

  /// V2 "Not yet": ask again tomorrow; the number stays the same.
  void snoozePayPrompt() {
    _payPromptSnoozedOn = today;
    notifyListeners();
  }

  /// The day the current cycle started automatically or from logged pay, so
  /// Today can say so once. Null after it's dismissed or on another day.
  LocalDate? get newCycleStartedOn => _newCycleOn == today ? _newCycleOn : null;
  LocalDate? _newCycleOn;

  void dismissNewCycle() {
    _newCycleOn = null;
    notifyListeners();
  }

  int get billsNeedingReview => _bills.where((b) => b.needsReview).length;

  int get vaultBalanceCents => _vault.balanceCents(_entries);

  int get goalsDailyCents => _goals
      .where((g) => !g.paused && !g.isReached)
      .fold(0, (sum, g) => sum + g.dailySetAsideCents);

  /// Positive = the other person owes you.
  int get splitBalanceCents {
    final s = _split;
    if (s == null) return 0;
    return _shared.fold(0, (sum, e) => sum + e.balanceEffectCents(s));
  }

  OverspendStrategy? overspendHandledOn(LocalDate day) =>
      _overspendHandled[day];

  /// Everything in the store, for saving to the database.
  BudgetSnapshot toSnapshot() => BudgetSnapshot(
    settings: _settings,
    plan: _plan,
    categories: List.of(_categories),
    entries: List.of(_entries),
    bills: List.of(_bills),
    goals: List.of(_goals),
    vault: _vault,
    split: _split,
    sharedExpenses: List.of(_shared),
    overspendDecisions: Map.of(_overspendHandled),
  );

  // ─── Writes ──────────────────────────────────────────────────────────────

  String newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_nextId++}';

  void addEntry(Entry entry) {
    _entries.add(entry);
    _save((r) => r.upsertEntry(entry));
    if (incomeStartsCycle(
      entry: entry,
      today: today,
      nextPayday: nextPayday,
      frequency: _settings.payFrequency,
    )) {
      _startNewCycle(today, lastPayday: nextPayday);
    }
    notifyListeners();
  }

  /// "Mark as paid": logs the payment as a spend and moves the bill to its
  /// next due date (estimates take the real amount; a fixed bill that came in
  /// higher is flagged).
  void payBill(Bill bill, {required int amountCents}) {
    final now = DateTime.now();
    addEntry(
      Entry(
        id: newId('bill-payment'),
        type: EntryType.spend,
        amountCents: amountCents,
        localDate: today,
        createdAtUtc: now.toUtc(),
        timeZoneId: now.timeZoneName,
        merchant: bill.name,
        categoryId: categoryById('bills') != null ? 'bills' : null,
        planned: true,
        billId: bill.id,
      ),
    );
    updateBill(bill.paid(paidOn: today, paidCents: amountCents));
  }

  /// V2 "It won't come": the expected pay isn't coming; start the next cycle
  /// with the money there is.
  void payWontCome() {
    _startNewCycle(today, lastPayday: nextPayday);
    notifyListeners();
  }

  /// Brings the store up to today: Paycheck Vault releases for each Monday
  /// that passed, and automatic cycles for pay that varies, applied in date
  /// order (so a long absence is caught up correctly). Called at launch, when
  /// the app returns to the foreground, and at midnight.
  void refreshDay() {
    final t = today;
    var changed = false;
    if (_vault.isActive && _vault.lastReleaseDate == null) {
      // A Vault from before release tracking (schema v1): start counting
      // from this week, without a back-dated release.
      _vault = _vault.copyWith(lastReleaseDate: () => mondayOnOrBefore(t));
      final vault = _vault;
      _save((r) => r.saveVault(vault));
      changed = true;
    }
    // Safety bound: a couple of years of weekly events.
    for (var guard = 0; guard < 120; guard++) {
      final release = releasesDue(_vault, t).firstOrNull;
      final autoCycle =
          _settings.payFrequency == PayFrequency.varies &&
              !t.isBefore(nextPayday)
          ? nextPayday
          : null;
      if (release == null && autoCycle == null) break;
      if (release != null &&
          (autoCycle == null || !autoCycle.isBefore(release))) {
        _releaseFromVault(release);
      } else {
        _startNewCycle(autoCycle!);
      }
      changed = true;
    }
    if (changed) notifyListeners();
  }

  /// The clock moved on (midnight, or the app came back to the foreground):
  /// catch up and redraw, since every daily figure depends on today's date.
  void onClockTick() {
    refreshDay();
    notifyListeners();
  }

  void _releaseFromVault(LocalDate monday) {
    final amount = math.min(
      _vault.steadyPayWeeklyCents,
      math.max(0, vaultBalanceCents),
    );
    if (amount > 0) {
      final entry = Entry(
        id: newId('vault-release'),
        type: EntryType.income,
        amountCents: amount,
        localDate: monday,
        createdAtUtc: DateTime.utc(monday.year, monday.month, monday.day, 6),
        timeZoneId: DateTime.now().timeZoneName,
        merchant: 'Paycheck Vault',
        fromVault: true,
      );
      _entries.add(entry);
      _save((r) => r.upsertEntry(entry));
    }
    _vault = _vault.copyWith(lastReleaseDate: () => monday);
    final vault = _vault;
    _save((r) => r.saveVault(vault));
  }

  void _startNewCycle(LocalDate start, {LocalDate? lastPayday}) {
    final next = startNewCycle(
      start: start,
      current: _plan,
      entries: _entries,
      goals: _goals,
      frequency: _settings.payFrequency,
      lastPayday: lastPayday,
    );
    _plan = next.plan;
    _settings = _settings.copyWith(nextPayday: next.nextPayday);
    _goals
      ..clear()
      ..addAll(next.goals);
    _newCycleOn = start;
    final plan = _plan;
    final settings = _settings;
    final goals = List.of(_goals);
    _save((r) async {
      await r.savePlan(plan);
      await r.saveSettings(settings);
      for (var i = 0; i < goals.length; i++) {
        await r.upsertGoal(goals[i], sortOrder: i);
      }
    });
  }

  void updateEntry(Entry entry) {
    final i = _entries.indexWhere((e) => e.id == entry.id);
    if (i < 0) return;
    _entries[i] = entry;
    notifyListeners();
    _save((r) => r.upsertEntry(entry));
  }

  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    _save((r) => r.deleteEntry(id));
  }

  void updateSettings(AppSettings settings) {
    final pinChanged = settings.pin != _settings.pin;
    _settings = settings;
    notifyListeners();
    _save((r) => r.saveSettings(settings));
    final vault = _pinVault;
    if (pinChanged && vault != null) {
      final pin = settings.pin;
      _save((_) => pin == null ? vault.delete() : vault.write(pin));
    }
  }

  void addBill(Bill bill) {
    _bills.add(bill);
    notifyListeners();
    _save((r) => r.upsertBill(bill));
  }

  void updateBill(Bill bill) {
    final i = _bills.indexWhere((b) => b.id == bill.id);
    if (i < 0) return;
    _bills[i] = bill;
    notifyListeners();
    _save((r) => r.upsertBill(bill));
  }

  void upsertCategory(BudgetCategory category) {
    final i = _categories.indexWhere((c) => c.id == category.id);
    if (i >= 0) {
      _categories[i] = category;
    } else {
      _categories.add(category);
    }
    notifyListeners();
    final order = _orderOf(_categories, category);
    _save((r) => r.upsertCategory(category, sortOrder: order));
  }

  void removeCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
    _save((r) => r.deleteCategory(id));
  }

  void addGoal(Goal goal) {
    _goals.add(goal);
    notifyListeners();
    final order = _orderOf(_goals, goal);
    _save((r) => r.upsertGoal(goal, sortOrder: order));
  }

  void updateGoal(Goal goal) {
    final i = _goals.indexWhere((g) => g.id == goal.id);
    if (i < 0) return;
    _goals[i] = goal;
    notifyListeners();
    _save((r) => r.upsertGoal(goal, sortOrder: i));
  }

  void updateVault(Vault vault) {
    if (vault.isActive && vault.lastReleaseDate == null) {
      // First release is next Monday, not one for this week already.
      vault = vault.copyWith(lastReleaseDate: () => mondayOnOrBefore(today));
    }
    _vault = vault;
    notifyListeners();
    _save((r) => r.saveVault(vault));
  }

  /// S4: the user chose how to absorb today's overspend.
  ///
  /// Spreading is what the daily-number rule already does. Taking it from a
  /// category lowers that category's monthly limit by [overCents]; category
  /// envelopes are not part of the daily-number engine yet, so tomorrow's
  /// number is still re-spread.
  void handleOverspend(
    OverspendStrategy strategy, {
    String? categoryId,
    int overCents = 0,
  }) {
    final day = today;
    _overspendHandled[day] = strategy;
    _save((r) => r.saveOverspendDecision(day, strategy));
    if (strategy == OverspendStrategy.takeFromCategory && categoryId != null) {
      final cat = categoryById(categoryId);
      final limit = cat?.monthlyLimitCents;
      if (cat != null && limit != null) {
        upsertCategory(
          cat.copyWith(
            monthlyLimitCents: () => (limit - overCents).clamp(0, limit),
          ),
        );
      }
    }
    notifyListeners();
  }

  void addSharedExpense(SharedExpense expense) {
    _shared.add(expense);
    notifyListeners();
    _save((r) => r.addSharedExpense(expense));
  }

  void setSplit(ExpenseSplit split) {
    _split = split;
    notifyListeners();
    _save((r) => r.saveSplit(split));
  }

  /// Records a settle-up: clears shared expenses, balance back to zero.
  void settleUp() {
    final s = _split;
    if (s == null) return;
    _shared.clear();
    final settled = ExpenseSplit(
      id: s.id,
      personName: s.personName,
      yourSharePercent: s.yourSharePercent,
      method: s.method,
      lastSettled: today,
    );
    _split = settled;
    notifyListeners();
    _save((r) => r.settleUp(settled));
  }

  /// Onboarding "Set up your money": starts a pay cycle today from the money
  /// the user has now. Today's entries are kept and count against today.
  void startCycle({required int balanceCents, required LocalDate payday}) {
    final todaysDelta = _entries
        .where((e) => e.localDate == today)
        .fold<int>(0, (s, e) => s + e.spendableDeltaCents);
    final setAside = goalSetAsides(
      _goals,
      today.daysUntil(payday),
    ).values.fold(0, (a, b) => a + b);
    final plan = CyclePlan(
      startDate: today,
      // Money "now" already includes today's entries, so add them back.
      openingBalanceCents: balanceCents - todaysDelta,
      goalSetAsideCents: setAside,
    );
    _plan = plan;
    _settings = _settings.copyWith(nextPayday: payday);
    final settings = _settings;
    notifyListeners();
    _save((r) => r.savePlan(plan));
    _save((r) => r.saveSettings(settings));
  }

  /// "Delete all my data": wipes everything (including the PIN) and returns
  /// to onboarding with a fresh default setup.
  void deleteAll() {
    _replaceWith(defaultSnapshot(today));
    _save((r) => r.replaceAll(toSnapshot()));
    final vault = _pinVault;
    if (vault != null) _save((_) => vault.delete());
  }

  /// A backup file was created and saved.
  void markBackedUp() =>
      updateSettings(_settings.copyWith(lastBackupOn: () => today));

  /// Restore from a backup file: replaces everything on this phone. App lock
  /// is turned off (the PIN is never in a backup); then catch up to today.
  void restoreFrom(BudgetSnapshot snapshot) {
    _replaceWith(snapshot);
    _save((r) => r.replaceAll(toSnapshot()));
    final vault = _pinVault;
    if (vault != null) _save((_) => vault.delete());
    refreshDay();
  }

  /// Debug: swap everything for the design's demo data.
  void loadSample() {
    final sample = BudgetStore.sample(clock: _clock).toSnapshot();
    _replaceWith(sample);
    _save((r) => r.replaceAll(sample));
  }

  void _replaceWith(BudgetSnapshot s) {
    _settings = s.settings!.copyWith(appLockEnabled: false, pin: () => null);
    _plan = s.plan!;
    _categories
      ..clear()
      ..addAll(s.categories);
    _entries
      ..clear()
      ..addAll(s.entries);
    _bills
      ..clear()
      ..addAll(s.bills);
    _goals
      ..clear()
      ..addAll(s.goals);
    _vault = s.vault!;
    _split = s.split;
    _shared
      ..clear()
      ..addAll(s.sharedExpenses);
    _overspendHandled
      ..clear()
      ..addAll(s.overspendDecisions);
    notifyListeners();
  }

  // ─── Sample data ─────────────────────────────────────────────────────────

  /// Demo data matching the design: $46.20 safe to spend, $17.80 spent of
  /// $64.00, 13 days to payday, plus a few days of history.
  factory BudgetStore.sample({LocalDate Function()? clock}) {
    final today = (clock ?? LocalDate.today)();
    final cycleStart = today.addDays(-2);
    final now = DateTime.now().toUtc();
    final tz = DateTime.now().timeZoneName;

    Entry spend(
      String id,
      String merchant,
      int cents,
      int daysAgo,
      String category, {
      bool planned = true,
      Mood? mood,
      int hoursAgo = 0,
      String? splitId,
      String? billId,
    }) => Entry(
      id: id,
      type: EntryType.spend,
      amountCents: cents,
      localDate: today.addDays(-daysAgo),
      createdAtUtc: now.subtract(Duration(days: daysAgo, hours: hoursAgo)),
      timeZoneId: tz,
      merchant: merchant,
      categoryId: category,
      planned: planned,
      mood: mood,
      splitId: splitId,
      billId: billId,
    );

    Bill bill(
      String id,
      String name,
      int cents,
      int dueInDays, {
      bool paid = false,
      bool estimate = false,
      bool sub = false,
      bool review = false,
      int? previous,
    }) => Bill(
      id: id,
      name: name,
      amountCents: cents,
      recurrence: Recurrence.monthly,
      // A paid bill's due date is already its next occurrence.
      dueDate: paid
          ? addMonths(today.addDays(dueInDays), 1)
          : today.addDays(dueInDays),
      lastPaidOn: paid ? cycleStart : null,
      isEstimate: estimate,
      isSubscription: sub,
      needsReview: review,
      previousAmountCents: previous,
    );

    final paidBills = [
      bill('rent', 'Rent', 145000, -2, paid: true),
      bill('phone', 'Phone plan', 4500, -2, paid: true),
      bill('music', 'Music', 1099, -2, paid: true, sub: true),
    ];

    final entries = <Entry>[
      for (final b in paidBills)
        spend(
          'paid-${b.id}',
          b.name,
          b.amountCents,
          2,
          'bills',
          hoursAgo: 3,
          billId: b.id,
        ),
      spend('groceries', 'Groceries', 11240, 2, 'food', splitId: 'split'),
      spend(
        'taco',
        'Taco place',
        2340,
        1,
        'food',
        planned: false,
        mood: Mood.tired,
      ),
      Entry(
        id: 'client',
        type: EntryType.income,
        amountCents: 64000,
        localDate: today.addDays(-1),
        createdAtUtc: now.subtract(const Duration(days: 1, hours: 4)),
        timeZoneId: tz,
        merchant: 'Client payment',
        toVault: true,
      ),
      spend('gas', 'Gas station', 1240, 0, 'transport', hoursAgo: 2),
      spend('coffee', 'Corner coffee', 540, 0, 'food', mood: Mood.tired),
    ];

    // Opening balance at the cycle start so that money at the start of today
    // is exactly $1,392.00 after the earlier days' entries.
    final before = entries.where((e) => e.localDate.isBefore(today));
    final earlierDelta = before.fold<int>(
      0,
      (s, e) => s + e.spendableDeltaCents,
    );

    return BudgetStore(
      clock: clock,
      settings: AppSettings(
        currency: Currency.usd,
        payFrequency: PayFrequency.varies,
        nextPayday: today.addDays(13),
        hourlyRateCents: 2400,
      ),
      plan: CyclePlan(
        startDate: cycleStart,
        openingBalanceCents: 139200 - earlierDelta,
        goalSetAsideCents: 20000,
      ),
      categories: const [
        BudgetCategory(
          id: 'food',
          name: 'Food',
          tone: CategoryTone.warning,
          monthlyLimitCents: 42000,
        ),
        BudgetCategory(
          id: 'transport',
          name: 'Transport',
          tone: CategoryTone.info,
          monthlyLimitCents: 16000,
        ),
        BudgetCategory(
          id: 'shopping',
          name: 'Shopping',
          tone: CategoryTone.danger,
          monthlyLimitCents: 12000,
        ),
        BudgetCategory(
          id: 'fun',
          name: 'Fun',
          tone: CategoryTone.primary,
          monthlyLimitCents: 9000,
        ),
        BudgetCategory(
          id: 'health',
          name: 'Health',
          tone: CategoryTone.neutral,
        ),
        BudgetCategory(
          id: 'bills',
          name: 'Bills & subs',
          tone: CategoryTone.info,
        ),
      ],
      entries: entries,
      bills: [
        ...paidBills,
        bill(
          'streamly',
          'Streamly',
          1799,
          5,
          sub: true,
          review: true,
          previous: 1599,
        ),
        bill('car', 'Car insurance', 12800, 6),
        bill('electric', 'Electric', 9600, 9, estimate: true),
        bill('internet', 'Internet', 6000, 10),
        bill('water', 'Water', 4500, 11),
        bill('fitpro', 'FitPro app', 1299, 12, sub: true, review: true),
      ],
      goals: [
        Goal(
          id: 'emergency',
          name: 'Emergency fund',
          kind: GoalKind.safety,
          targetCents: 300000,
          savedCents: 186000,
          dailySetAsideCents: 1538,
        ),
        Goal(
          id: 'laptop',
          name: 'New laptop',
          targetCents: 120000,
          savedCents: 24000,
          dailySetAsideCents: 800,
          targetDate: LocalDate(today.year + 1, 1, 30),
        ),
        Goal(
          id: 'trip',
          name: 'Weekend trip',
          kind: GoalKind.trip,
          targetCents: 90000,
          savedCents: 41000,
          dailySetAsideCents: 762,
          targetDate: today.addDays(64),
        ),
      ],
      vault: Vault(
        openingBalanceCents: 130000,
        steadyPayWeeklyCents: 78000,
        lastReleaseDate: mondayOnOrBefore(today),
      ),
      split: ExpenseSplit(
        id: 'split',
        personName: 'Alex',
        yourSharePercent: 60,
        lastSettled: today.addDays(-17),
      ),
      sharedExpenses: [
        SharedExpense(
          id: 's1',
          name: 'Groceries',
          amountCents: 11240,
          date: today.addDays(-2),
          paidByYou: true,
        ),
        SharedExpense(
          id: 's2',
          name: 'Dinner out',
          amountCents: 6800,
          date: today.addDays(-4),
          paidByYou: true,
        ),
        SharedExpense(
          id: 's3',
          name: 'Home supplies',
          amountCents: 11810,
          date: today.addDays(-5),
          paidByYou: true,
        ),
        SharedExpense(
          id: 's4',
          name: 'Electric (last month)',
          amountCents: 9150,
          date: today.addDays(-6),
          paidByYou: false,
        ),
      ],
    );
  }
}

/// One bill occurrence in the current cycle (Today's bills card).
@immutable
class CycleBill {
  const CycleBill(this.bill, this.date, {required this.paid});
  final Bill bill;
  final LocalDate date;
  final bool paid;
}
