import 'package:flutter/foundation.dart';

import '../core/local_date.dart';
import '../domain/daily_number.dart';
import '../domain/models/models.dart';
import 'db/budget_repository.dart';

/// In-memory app state. Swap the backing lists for the encrypted local
/// database later; screens only depend on the getters and methods below.
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
    LocalDate Function()? clock,
  }) : _categories = List.of(categories),
       _entries = List.of(entries),
       _bills = List.of(bills),
       _goals = List.of(goals),
       _shared = List.of(sharedExpenses),
       _clock = clock ?? LocalDate.today;

  AppSettings _settings;
  CyclePlan _plan;
  final List<BudgetCategory> _categories;
  final List<Entry> _entries;
  final List<Bill> _bills;
  final List<Goal> _goals;
  Vault _vault;
  ExpenseSplit? _split;
  final List<SharedExpense> _shared;
  final LocalDate Function() _clock;
  var _nextId = 0;

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

  /// Bills in this pay cycle: paid since the cycle started, plus everything
  /// still reserved before payday. Sorted paid first, then by due date.
  List<Bill> get billsThisCycle {
    final list =
        _bills.where((b) {
          if (b.isPaid) return !b.paidOn!.isBefore(_plan.startDate);
          return b.isReservedBefore(nextPayday);
        }).toList()..sort((a, b) {
          if (a.isPaid != b.isPaid) return a.isPaid ? -1 : 1;
          return a.dueDate.compareTo(b.dueDate);
        });
    return list;
  }

  /// Unpaid bills before payday, by due date.
  List<Bill> get upcomingBills =>
      _bills.where((b) => b.isReservedBefore(nextPayday)).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  int get reservedBillsCents => _bills
      .where((b) => b.isReservedBefore(nextPayday))
      .fold(0, (sum, b) => sum + b.amountCents);

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

  /// How each day's overspend was handled (S4), by local date.
  final Map<LocalDate, OverspendStrategy> _overspendHandled = {};

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
    notifyListeners();
  }

  void updateEntry(Entry entry) {
    final i = _entries.indexWhere((e) => e.id == entry.id);
    if (i >= 0) _entries[i] = entry;
    notifyListeners();
  }

  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void updateSettings(AppSettings settings) {
    _settings = settings;
    notifyListeners();
  }

  void addBill(Bill bill) {
    _bills.add(bill);
    notifyListeners();
  }

  void updateBill(Bill bill) {
    final i = _bills.indexWhere((b) => b.id == bill.id);
    if (i >= 0) _bills[i] = bill;
    notifyListeners();
  }

  void upsertCategory(BudgetCategory category) {
    final i = _categories.indexWhere((c) => c.id == category.id);
    if (i >= 0) {
      _categories[i] = category;
    } else {
      _categories.add(category);
    }
    notifyListeners();
  }

  void removeCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void addGoal(Goal goal) {
    _goals.add(goal);
    notifyListeners();
  }

  void updateGoal(Goal goal) {
    final i = _goals.indexWhere((g) => g.id == goal.id);
    if (i >= 0) _goals[i] = goal;
    notifyListeners();
  }

  void updateVault(Vault vault) {
    _vault = vault;
    notifyListeners();
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
    _overspendHandled[today] = strategy;
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
  }

  void setSplit(ExpenseSplit split) {
    _split = split;
    notifyListeners();
  }

  /// Records a settle-up: clears shared expenses, balance back to zero.
  void settleUp() {
    final s = _split;
    if (s == null) return;
    _shared.clear();
    _split = ExpenseSplit(
      id: s.id,
      personName: s.personName,
      yourSharePercent: s.yourSharePercent,
      method: s.method,
      lastSettled: today,
    );
    notifyListeners();
  }

  /// Onboarding "Set up your money": starts a pay cycle today from the money
  /// the user has now. Today's entries are kept and count against today.
  void startCycle({required int balanceCents, required LocalDate payday}) {
    final todaysDelta = _entries
        .where((e) => e.localDate == today)
        .fold<int>(0, (s, e) => s + e.spendableDeltaCents);
    _plan = CyclePlan(
      startDate: today,
      // Money "now" already includes today's entries, so add them back.
      openingBalanceCents: balanceCents - todaysDelta,
      goalSetAsideCents: _plan.goalSetAsideCents,
    );
    _settings = _settings.copyWith(nextPayday: payday);
    notifyListeners();
  }

  /// "Delete all my data": wipes everything and returns to onboarding.
  void deleteAll() {
    _entries.clear();
    _bills.clear();
    _goals.clear();
    _shared.clear();
    _split = null;
    _vault = _vault.copyWith(openingBalanceCents: 0);
    _plan = CyclePlan(
      startDate: today,
      openingBalanceCents: 0,
      goalSetAsideCents: 0,
    );
    _settings = _settings.copyWith(onboarded: false, displayName: () => null);
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
      dueDate: today.addDays(dueInDays),
      paidOn: paid ? cycleStart : null,
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
        spend('paid-${b.id}', b.name, b.amountCents, 2, 'bills', hoursAgo: 3),
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
      vault: const Vault(
        openingBalanceCents: 130000,
        steadyPayWeeklyCents: 78000,
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
