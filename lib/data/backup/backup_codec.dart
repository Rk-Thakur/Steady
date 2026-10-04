import '../../core/local_date.dart';
import '../../domain/models/models.dart';
import '../db/budget_repository.dart';

/// Converts a [BudgetSnapshot] to and from plain JSON for backup files.
///
/// Same conventions as the database: money in cents, calendar dates as
/// `YYYY-MM-DD`, instants as UTC ISO-8601, enums by name. The App lock PIN is
/// never included.
abstract final class BackupCodec {
  static Map<String, Object?> encode(BudgetSnapshot s) => {
    'settings': s.settings == null ? null : _settings(s.settings!),
    'plan': s.plan == null
        ? null
        : {
            'startDate': s.plan!.startDate.toIso(),
            'openingBalanceCents': s.plan!.openingBalanceCents,
            'goalSetAsideCents': s.plan!.goalSetAsideCents,
          },
    'categories': [
      for (final c in s.categories)
        {
          'id': c.id,
          'name': c.name,
          'tone': c.tone.name,
          'monthlyLimitCents': c.monthlyLimitCents,
        },
    ],
    'entries': [for (final e in s.entries) _entry(e)],
    'bills': [for (final b in s.bills) _bill(b)],
    'goals': [for (final g in s.goals) _goal(g)],
    'vault': s.vault == null
        ? null
        : {
            'openingBalanceCents': s.vault!.openingBalanceCents,
            'steadyPayWeeklyCents': s.vault!.steadyPayWeeklyCents,
            'targetWeeks': s.vault!.targetWeeks,
            'lastReleaseDate': s.vault!.lastReleaseDate?.toIso(),
          },
    'split': s.split == null
        ? null
        : {
            'id': s.split!.id,
            'personName': s.split!.personName,
            'yourSharePercent': s.split!.yourSharePercent,
            'method': s.split!.method.name,
            'lastSettled': s.split!.lastSettled?.toIso(),
          },
    'sharedExpenses': [
      for (final e in s.sharedExpenses)
        {
          'id': e.id,
          'name': e.name,
          'amountCents': e.amountCents,
          'date': e.date.toIso(),
          'paidByYou': e.paidByYou,
        },
    ],
    'overspendDecisions': {
      for (final d in s.overspendDecisions.entries) d.key.toIso(): d.value.name,
    },
  };

  /// Throws [FormatException] if anything is missing or malformed.
  static BudgetSnapshot decode(Map<String, Object?> j) {
    try {
      final plan = j['plan'] as Map<String, Object?>?;
      final vault = j['vault'] as Map<String, Object?>?;
      final split = j['split'] as Map<String, Object?>?;
      return BudgetSnapshot(
        settings: j['settings'] == null
            ? null
            : _settingsFrom(j['settings']! as Map<String, Object?>),
        plan: plan == null
            ? null
            : CyclePlan(
                startDate: _date(plan['startDate']),
                openingBalanceCents: plan['openingBalanceCents']! as int,
                goalSetAsideCents: plan['goalSetAsideCents']! as int,
              ),
        categories: [
          for (final c in _list(j['categories']))
            BudgetCategory(
              id: c['id']! as String,
              name: c['name']! as String,
              tone: CategoryTone.values.byName(c['tone']! as String),
              monthlyLimitCents: c['monthlyLimitCents'] as int?,
            ),
        ],
        entries: [for (final e in _list(j['entries'])) _entryFrom(e)],
        bills: [for (final b in _list(j['bills'])) _billFrom(b)],
        goals: [for (final g in _list(j['goals'])) _goalFrom(g)],
        vault: vault == null
            ? null
            : Vault(
                openingBalanceCents: vault['openingBalanceCents']! as int,
                steadyPayWeeklyCents: vault['steadyPayWeeklyCents']! as int,
                targetWeeks: vault['targetWeeks']! as int,
                lastReleaseDate: _dateOrNull(vault['lastReleaseDate']),
              ),
        split: split == null
            ? null
            : ExpenseSplit(
                id: split['id']! as String,
                personName: split['personName']! as String,
                yourSharePercent: split['yourSharePercent']! as int,
                method: SplitMethod.values.byName(split['method']! as String),
                lastSettled: _dateOrNull(split['lastSettled']),
              ),
        sharedExpenses: [
          for (final e in _list(j['sharedExpenses']))
            SharedExpense(
              id: e['id']! as String,
              name: e['name']! as String,
              amountCents: e['amountCents']! as int,
              date: _date(e['date']),
              paidByYou: e['paidByYou']! as bool,
            ),
        ],
        overspendDecisions: {
          for (final d
              in ((j['overspendDecisions'] ?? const <String, Object?>{})
                      as Map<String, Object?>)
                  .entries)
            LocalDate.parse(d.key): OverspendStrategy.values.byName(
              d.value! as String,
            ),
        },
      );
    } on FormatException {
      rethrow;
    } catch (e) {
      // Wrong types, missing fields, unknown enum names, failed asserts.
      throw FormatException('Backup data is malformed: $e');
    }
  }

  // ─── Pieces ──────────────────────────────────────────────────────────────

  static Map<String, Object?> _settings(AppSettings s) => {
    'currency': s.currency.name,
    'payFrequency': s.payFrequency.name,
    'nextPayday': s.nextPayday.toIso(),
    'incomeType': s.incomeType.name,
    'displayName': s.displayName,
    'hourlyRateCents': s.hourlyRateCents,
    'weekStartsOn': s.weekStartsOn,
    'theme': s.theme.name,
    'overspendStrategy': s.overspendStrategy.name,
    'onboarded': s.onboarded,
    'lastBackupOn': s.lastBackupOn?.toIso(),
  };

  // App lock is never restored: the PIN isn't in the file.
  static AppSettings _settingsFrom(Map<String, Object?> s) => AppSettings(
    currency: Currency.values.byName(s['currency']! as String),
    payFrequency: PayFrequency.values.byName(s['payFrequency']! as String),
    nextPayday: _date(s['nextPayday']),
    incomeType: IncomeType.values.byName(s['incomeType']! as String),
    displayName: s['displayName'] as String?,
    hourlyRateCents: s['hourlyRateCents'] as int?,
    weekStartsOn: s['weekStartsOn']! as int,
    theme: ThemePreference.values.byName(s['theme']! as String),
    overspendStrategy: OverspendStrategy.values.byName(
      s['overspendStrategy']! as String,
    ),
    onboarded: s['onboarded']! as bool,
    lastBackupOn: _dateOrNull(s['lastBackupOn']),
  );

  static Map<String, Object?> _entry(Entry e) => {
    'id': e.id,
    'type': e.type.name,
    'amountCents': e.amountCents,
    'localDate': e.localDate.toIso(),
    'createdAtUtc': e.createdAtUtc.toUtc().toIso8601String(),
    'timeZoneId': e.timeZoneId,
    'merchant': e.merchant,
    'categoryId': e.categoryId,
    'mood': e.mood?.name,
    'planned': e.planned,
    'note': e.note,
    'splitId': e.splitId,
    'toVault': e.toVault,
    'fromVault': e.fromVault,
    'billId': e.billId,
  };

  static Entry _entryFrom(Map<String, Object?> e) => Entry(
    id: e['id']! as String,
    type: EntryType.values.byName(e['type']! as String),
    amountCents: e['amountCents']! as int,
    localDate: _date(e['localDate']),
    createdAtUtc: DateTime.parse(e['createdAtUtc']! as String).toUtc(),
    timeZoneId: e['timeZoneId']! as String,
    merchant: e['merchant'] as String?,
    categoryId: e['categoryId'] as String?,
    mood: e['mood'] == null ? null : Mood.values.byName(e['mood']! as String),
    planned: e['planned'] as bool?,
    note: e['note'] as String?,
    splitId: e['splitId'] as String?,
    toVault: e['toVault']! as bool,
    fromVault: (e['fromVault'] ?? false) as bool,
    billId: e['billId'] as String?,
  );

  static Map<String, Object?> _bill(Bill b) => {
    'id': b.id,
    'name': b.name,
    'amountCents': b.amountCents,
    'recurrence': b.recurrence.name,
    'dueDate': b.dueDate.toIso(),
    'isEstimate': b.isEstimate,
    'isSubscription': b.isSubscription,
    'needsReview': b.needsReview,
    'lastPaidOn': b.lastPaidOn?.toIso(),
    'previousAmountCents': b.previousAmountCents,
  };

  static Bill _billFrom(Map<String, Object?> b) => Bill(
    id: b['id']! as String,
    name: b['name']! as String,
    amountCents: b['amountCents']! as int,
    recurrence: Recurrence.values.byName(b['recurrence']! as String),
    dueDate: _date(b['dueDate']),
    isEstimate: b['isEstimate']! as bool,
    isSubscription: b['isSubscription']! as bool,
    needsReview: b['needsReview']! as bool,
    lastPaidOn: _dateOrNull(b['lastPaidOn']),
    previousAmountCents: b['previousAmountCents'] as int?,
  );

  static Map<String, Object?> _goal(Goal g) => {
    'id': g.id,
    'name': g.name,
    'kind': g.kind.name,
    'targetCents': g.targetCents,
    'savedCents': g.savedCents,
    'dailySetAsideCents': g.dailySetAsideCents,
    'targetDate': g.targetDate?.toIso(),
    'paused': g.paused,
  };

  static Goal _goalFrom(Map<String, Object?> g) => Goal(
    id: g['id']! as String,
    name: g['name']! as String,
    kind: GoalKind.values.byName(g['kind']! as String),
    targetCents: g['targetCents']! as int,
    savedCents: g['savedCents']! as int,
    dailySetAsideCents: g['dailySetAsideCents']! as int,
    targetDate: _dateOrNull(g['targetDate']),
    paused: g['paused']! as bool,
  );

  static List<Map<String, Object?>> _list(Object? v) => [
    for (final x in (v ?? const <Object?>[]) as List<Object?>)
      x! as Map<String, Object?>,
  ];

  static LocalDate _date(Object? v) {
    final s = v! as String;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
      throw FormatException('Bad date "$s"');
    }
    return LocalDate.parse(s);
  }

  static LocalDate? _dateOrNull(Object? v) => v == null ? null : _date(v);
}
