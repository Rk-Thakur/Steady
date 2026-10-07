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
    'splits': _splitsJson(s.splits),
    'overspendDecisions': {
      for (final d in s.overspendDecisions.entries)
        d.key.toIso(): {
          'strategy': d.value.strategy.name,
          'categoryId': d.value.categoryId,
          'amountCents': d.value.amountCents,
        },
    },
    'dailyNumbers': {
      for (final d in s.dailyNumbers.entries) d.key.toIso(): d.value,
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
        splits: j.containsKey('splits')
            ? _splitsFrom(j['splits']! as Map<String, Object?>)
            : _legacySplit(split, j['sharedExpenses']),
        overspendDecisions: {
          for (final d
              in ((j['overspendDecisions'] ?? const <String, Object?>{})
                      as Map<String, Object?>)
                  .entries)
            LocalDate.parse(d.key): _decisionFrom(d.value),
        },
        // Absent in backups made before Stage 7.
        dailyNumbers: {
          for (final d
              in ((j['dailyNumbers'] ?? const <String, Object?>{})
                      as Map<String, Object?>)
                  .entries)
            LocalDate.parse(d.key): d.value! as int,
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
    'caughtUpThrough': s.caughtUpThrough?.toIso(),
    'reminders': {
      'logSpends': s.reminders.logSpends,
      'logAtMinutes': s.reminders.logAtMinutes,
      'payday': s.reminders.payday,
      'paydayAtMinutes': s.reminders.paydayAtMinutes,
      'billsDue': s.reminders.billsDue,
      'latePause': s.reminders.latePause,
      'recaps': s.reminders.recaps,
      'backupMonthly': s.reminders.backupMonthly,
      'quietFromMinutes': s.reminders.quietFromMinutes,
      'debtsOwedToYou': s.reminders.debtsOwedToYou,
      'debtsYouOwe': s.reminders.debtsYouOwe,
    },
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
    caughtUpThrough: _dateOrNull(s['caughtUpThrough']),
    reminders: _remindersFrom(s['reminders'] as Map<String, Object?>?),
  );

  // Backups made before Stage 7 store just the strategy name.
  static OverspendDecision _decisionFrom(Object? v) {
    if (v is String) {
      return OverspendDecision(OverspendStrategy.values.byName(v));
    }
    final d = v! as Map<String, Object?>;
    return OverspendDecision(
      OverspendStrategy.values.byName(d['strategy']! as String),
      categoryId: d['categoryId'] as String?,
      amountCents: d['amountCents'] as int? ?? 0,
    );
  }

  // Absent in backups made before Stage 7: the defaults apply.
  static ReminderSettings _remindersFrom(Map<String, Object?>? r) {
    const d = ReminderSettings();
    if (r == null) return d;
    return ReminderSettings(
      logSpends: r['logSpends'] as bool? ?? d.logSpends,
      logAtMinutes: r['logAtMinutes'] as int? ?? d.logAtMinutes,
      payday: r['payday'] as bool? ?? r['logSpends'] as bool? ?? d.payday,
      paydayAtMinutes: r['paydayAtMinutes'] as int? ?? d.paydayAtMinutes,
      billsDue: r['billsDue'] as bool? ?? d.billsDue,
      latePause: r['latePause'] as bool? ?? d.latePause,
      recaps: r['recaps'] as bool? ?? d.recaps,
      backupMonthly: r['backupMonthly'] as bool? ?? d.backupMonthly,
      quietFromMinutes: r['quietFromMinutes'] as int? ?? d.quietFromMinutes,
      debtsOwedToYou: r['debtsOwedToYou'] as bool? ?? d.debtsOwedToYou,
      debtsYouOwe: r['debtsYouOwe'] as bool? ?? d.debtsYouOwe,
    );
  }

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
    'createdOn': g.createdOn?.toIso(),
    'cycleSetAsideCents': g.cycleSetAsideCents,
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
    createdOn: _dateOrNull(g['createdOn']),
    // Older backups: the store gives the goal its share of the cycle.
    cycleSetAsideCents: g['cycleSetAsideCents'] as int?,
  );

  static Map<String, Object?> _splitsJson(SplitBook b) => {
    'people': [
      for (final p in b.people)
        {
          'id': p.id,
          'name': p.name,
          'remindMuted': p.remindMuted,
          'remindSnoozedUntil': p.remindSnoozedUntil?.toIso(),
        },
    ],
    'groups': [
      for (final g in b.groups)
        {
          'id': g.id,
          'name': g.name,
          'memberIds': g.memberIds,
          'method': g.method.name,
          'weights': g.weights,
          'simplifyDebts': g.simplifyDebts,
          'createdOn': g.createdOn?.toIso(),
        },
    ],
    'expenses': [
      for (final e in b.expenses)
        {
          'id': e.id,
          'groupId': e.groupId,
          'name': e.name,
          'amountCents': e.amountCents,
          'date': e.date.toIso(),
          'paidBy': e.paidBy,
          'shares': e.shares,
          'entryId': e.entryId,
        },
    ],
    'settlements': [
      for (final s in b.settlements)
        {
          'id': s.id,
          'groupId': s.groupId,
          'fromId': s.fromId,
          'toId': s.toId,
          'amountCents': s.amountCents,
          'date': s.date.toIso(),
          'entryId': s.entryId,
        },
    ],
  };

  static Map<String, int> _intMap(Object? v) => {
    for (final e
        in ((v ?? const <String, Object?>{}) as Map<String, Object?>).entries)
      e.key: e.value! as int,
  };

  static SplitBook _splitsFrom(Map<String, Object?> j) => SplitBook(
    people: [
      for (final p in _list(j['people']))
        SplitPerson(
          id: p['id']! as String,
          name: p['name']! as String,
          remindMuted: p['remindMuted'] as bool? ?? false,
          remindSnoozedUntil: _dateOrNull(p['remindSnoozedUntil']),
        ),
    ],
    groups: [
      for (final g in _list(j['groups']))
        SplitGroup(
          id: g['id']! as String,
          name: g['name']! as String,
          memberIds: [
            for (final m in g['memberIds']! as List<Object?>) m! as String,
          ],
          method: SplitMethod.values.byName(g['method']! as String),
          weights: _intMap(g['weights']),
          simplifyDebts: g['simplifyDebts'] as bool? ?? true,
          createdOn: _dateOrNull(g['createdOn']),
        ),
    ],
    expenses: [
      for (final e in _list(j['expenses']))
        GroupExpense(
          id: e['id']! as String,
          groupId: e['groupId']! as String,
          name: e['name']! as String,
          amountCents: e['amountCents']! as int,
          date: _date(e['date']),
          paidBy: e['paidBy']! as String,
          shares: _intMap(e['shares']),
          entryId: e['entryId'] as String?,
        ),
    ],
    settlements: [
      for (final s in _list(j['settlements']))
        Settlement(
          id: s['id']! as String,
          groupId: s['groupId']! as String,
          fromId: s['fromId']! as String,
          toId: s['toId']! as String,
          amountCents: s['amountCents']! as int,
          date: _date(s['date']),
          entryId: s['entryId'] as String?,
        ),
    ],
  );

  /// Backups made before split groups: one partner + shared expenses.
  static SplitBook _legacySplit(
    Map<String, Object?>? split,
    Object? sharedExpenses,
  ) {
    if (split == null) return SplitBook.empty;
    return SplitBook.fromLegacy(
      splitId: split['id']! as String,
      personName: split['personName']! as String,
      yourSharePercent: split['yourSharePercent']! as int,
      legacyMethod: split['method']! as String,
      expenses: [
        for (final e in _list(sharedExpenses))
          (
            id: e['id']! as String,
            name: e['name']! as String,
            amountCents: e['amountCents']! as int,
            date: _date(e['date']),
            paidByYou: e['paidByYou']! as bool,
          ),
      ],
    );
  }

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
