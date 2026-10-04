import 'package:flutter/foundation.dart';

import '../../core/local_date.dart';

enum PayFrequency {
  weekly('Weekly'),
  everyTwoWeeks('Every 2 weeks'),
  twiceAMonth('Twice a month'),
  monthly('Monthly'),
  varies('Varies');

  const PayFrequency(this.label);
  final String label;
}

enum IncomeType {
  salary('Fixed salary', 'Same amount on a regular schedule'),
  irregular('It changes', 'Freelance, gig work, tips or commission'),
  mix('A mix of both', 'A base paycheck plus side income');

  const IncomeType(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

enum ThemePreference { light, dark, system }

/// What happens when today goes over the daily number.
enum OverspendStrategy { spreadEvenly, takeFromCategory }

/// Currencies offered in Profile. One per install, no exchange rates.
enum Currency {
  usd('USD', r'$'),
  eur('EUR', '€'),
  gbp('GBP', '£'),
  inr('INR', '₹');

  const Currency(this.code, this.symbol);
  final String code;
  final String symbol;
}

/// P2 Reminders: local notifications, scheduled on the phone.
@immutable
class ReminderSettings {
  const ReminderSettings({
    this.logSpends = true,
    this.logAtMinutes = 20 * 60 + 30,
    this.billsDue = true,
    this.latePause = true,
    this.recaps = false,
    this.backupMonthly = true,
    this.quietFromMinutes = 23 * 60,
  });

  /// "Log your spends": a nudge at [logAtMinutes] if nothing is logged.
  final bool logSpends;

  /// Minutes after midnight, e.g. 1230 = 8:30 PM.
  final int logAtMinutes;
  final bool billsDue;
  final bool latePause;
  final bool recaps;

  /// Backup & export: "A local notification on the 1st".
  final bool backupMonthly;

  /// Quiet hours run from here to 7 AM. 0 = midnight.
  final int quietFromMinutes;

  static const quietEndMinutes = 7 * 60;

  bool get anyOn =>
      logSpends || billsDue || latePause || recaps || backupMonthly;

  ReminderSettings copyWith({
    bool? logSpends,
    int? logAtMinutes,
    bool? billsDue,
    bool? latePause,
    bool? recaps,
    bool? backupMonthly,
    int? quietFromMinutes,
  }) => ReminderSettings(
    logSpends: logSpends ?? this.logSpends,
    logAtMinutes: logAtMinutes ?? this.logAtMinutes,
    billsDue: billsDue ?? this.billsDue,
    latePause: latePause ?? this.latePause,
    recaps: recaps ?? this.recaps,
    backupMonthly: backupMonthly ?? this.backupMonthly,
    quietFromMinutes: quietFromMinutes ?? this.quietFromMinutes,
  );

  static const off = ReminderSettings(
    logSpends: false,
    billsDue: false,
    latePause: false,
    recaps: false,
    backupMonthly: false,
  );
}

@immutable
class AppSettings {
  const AppSettings({
    required this.currency,
    required this.payFrequency,
    required this.nextPayday,
    this.incomeType = IncomeType.irregular,
    this.displayName,
    this.hourlyRateCents,
    this.weekStartsOn = DateTime.sunday,
    this.theme = ThemePreference.system,
    this.appLockEnabled = false,
    this.pin,
    this.lastBackupOn,
    this.overspendStrategy = OverspendStrategy.spreadEvenly,
    this.onboarded = true,
    this.reminders = const ReminderSettings(),
  });

  final Currency currency;
  final PayFrequency payFrequency;
  final LocalDate nextPayday;
  final IncomeType incomeType;
  final String? displayName;

  /// Optional; shows "hours of work" in Can I afford it?.
  final int? hourlyRateCents;

  /// 1 = Monday … 7 = Sunday.
  final int weekStartsOn;
  final ThemePreference theme;
  final bool appLockEnabled;

  /// App lock PIN. Kept in memory for now; moves to the Keychain / Keystore
  /// with the encrypted database.
  final String? pin;

  /// When the user last created a backup file.
  final LocalDate? lastBackupOn;
  final OverspendStrategy overspendStrategy;
  final bool onboarded;
  final ReminderSettings reminders;

  String get currencySymbol => currency.symbol;

  AppSettings copyWith({
    Currency? currency,
    PayFrequency? payFrequency,
    LocalDate? nextPayday,
    IncomeType? incomeType,
    String? Function()? displayName,
    int? Function()? hourlyRateCents,
    int? weekStartsOn,
    ThemePreference? theme,
    bool? appLockEnabled,
    String? Function()? pin,
    LocalDate? Function()? lastBackupOn,
    OverspendStrategy? overspendStrategy,
    bool? onboarded,
    ReminderSettings? reminders,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      payFrequency: payFrequency ?? this.payFrequency,
      nextPayday: nextPayday ?? this.nextPayday,
      incomeType: incomeType ?? this.incomeType,
      displayName: displayName != null ? displayName() : this.displayName,
      hourlyRateCents: hourlyRateCents != null
          ? hourlyRateCents()
          : this.hourlyRateCents,
      weekStartsOn: weekStartsOn ?? this.weekStartsOn,
      theme: theme ?? this.theme,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      pin: pin != null ? pin() : this.pin,
      lastBackupOn: lastBackupOn != null ? lastBackupOn() : this.lastBackupOn,
      overspendStrategy: overspendStrategy ?? this.overspendStrategy,
      onboarded: onboarded ?? this.onboarded,
      reminders: reminders ?? this.reminders,
    );
  }
}

/// The money picture fixed at the start of a pay cycle.
@immutable
class CyclePlan {
  const CyclePlan({
    required this.startDate,
    required this.openingBalanceCents,
    required this.goalSetAsideCents,
  });

  /// First day of this cycle; [openingBalanceCents] is the money at the start of it.
  final LocalDate startDate;
  final int openingBalanceCents;

  /// Total moved to goals this cycle, reserved out of the daily number.
  final int goalSetAsideCents;
}
