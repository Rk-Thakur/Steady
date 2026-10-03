import 'package:flutter/foundation.dart';

import '../../core/local_date.dart';

enum EntryType { spend, income }

/// Moods offered when logging a spend (Log spend screen).
enum Mood {
  tired('Tired'),
  stressed('Stressed'),
  bored('Bored'),
  happy('Happy'),
  neutral('Neutral');

  const Mood(this.label);
  final String label;
}

/// One money movement the user logged by hand.
///
/// Time is stored three ways (Handoff 4): a UTC timestamp, the local calendar
/// date it belongs to, and the time-zone id at logging time. Entries keep
/// their original [localDate] when the user travels or the clock changes.
@immutable
class Entry {
  const Entry({
    required this.id,
    required this.type,
    required this.amountCents,
    required this.localDate,
    required this.createdAtUtc,
    required this.timeZoneId,
    this.merchant,
    this.categoryId,
    this.mood,
    this.planned,
    this.note,
    this.splitId,
    this.toVault = false,
    this.fromVault = false,
    this.billId,
  }) : assert(
         amountCents > 0,
         'amountCents is always positive; type gives direction',
       );

  final String id;
  final EntryType type;

  /// Always positive; [type] says whether money went out or came in.
  final int amountCents;
  final LocalDate localDate;
  final DateTime createdAtUtc;
  final String timeZoneId;

  /// "Where" on the Log spend screen. Stored max 40 chars.
  final String? merchant;
  final String? categoryId;
  final Mood? mood;
  final bool? planned;
  final String? note;

  /// Set when this is a shared expense.
  final String? splitId;

  /// Income only: deposited into the Paycheck Vault instead of today's number.
  final bool toVault;

  /// Income only: a weekly steady-pay release out of the Paycheck Vault into
  /// the daily number (created by the app, not typed by the user).
  final bool fromVault;

  /// Spend only: this entry paid an occurrence of that bill. It moves money
  /// out of the reservation, not out of today's allowance.
  final String? billId;

  bool get isBillPayment => isSpend && billId != null;

  static const maxMerchantLength = 40;

  bool get isSpend => type == EntryType.spend;
  bool get isIncome => type == EntryType.income;

  /// Signed effect on spendable money: spends negative, income positive,
  /// vault deposits zero (they never touch the daily number).
  int get spendableDeltaCents {
    if (isSpend) return -amountCents;
    return toVault ? 0 : amountCents;
  }

  Entry copyWith({
    EntryType? type,
    int? amountCents,
    LocalDate? localDate,
    String? merchant,
    String? categoryId,
    Mood? mood,
    bool? planned,
    String? note,
    String? splitId,
    bool? toVault,
    bool? fromVault,
    String? billId,
  }) {
    return Entry(
      id: id,
      type: type ?? this.type,
      amountCents: amountCents ?? this.amountCents,
      localDate: localDate ?? this.localDate,
      createdAtUtc: createdAtUtc,
      timeZoneId: timeZoneId,
      merchant: merchant ?? this.merchant,
      categoryId: categoryId ?? this.categoryId,
      mood: mood ?? this.mood,
      planned: planned ?? this.planned,
      note: note ?? this.note,
      splitId: splitId ?? this.splitId,
      toVault: toVault ?? this.toVault,
      fromVault: fromVault ?? this.fromVault,
      billId: billId ?? this.billId,
    );
  }
}
