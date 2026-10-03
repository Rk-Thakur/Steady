import 'package:flutter/foundation.dart';

import '../../core/local_date.dart';

enum Recurrence { weekly, everyTwoWeeks, monthly, yearly }

/// A recurring bill or subscription.
///
/// [dueDate] is the current occurrence. When it is paid, [paidOn] is set (and
/// a spend entry is logged); rolling to the next occurrence clears [paidOn].
@immutable
class Bill {
  const Bill({
    required this.id,
    required this.name,
    required this.amountCents,
    required this.recurrence,
    required this.dueDate,
    this.isEstimate = false,
    this.isSubscription = false,
    this.needsReview = false,
    this.paidOn,
    this.previousAmountCents,
  });

  final String id;
  final String name;
  final int amountCents;
  final Recurrence recurrence;
  final LocalDate dueDate;

  /// Shown with a `~` prefix until the real amount is logged.
  final bool isEstimate;
  final bool isSubscription;

  /// Price went up or looks unused ("needs a look" on Bills radar).
  final bool needsReview;
  final LocalDate? paidOn;

  /// Set when the last logged amount went up (Bills radar "price went up").
  final int? previousAmountCents;

  bool get priceWentUp =>
      previousAmountCents != null && amountCents > previousAmountCents!;

  bool get isPaid => paidOn != null;

  /// Unpaid and due before [payday] (overdue bills included): reserved out of
  /// the daily number.
  bool isReservedBefore(LocalDate payday) =>
      !isPaid && dueDate.isBefore(payday);

  Bill copyWith({
    String? name,
    int? amountCents,
    Recurrence? recurrence,
    LocalDate? dueDate,
    bool? isEstimate,
    bool? isSubscription,
    bool? needsReview,
    LocalDate? Function()? paidOn,
  }) {
    return Bill(
      id: id,
      name: name ?? this.name,
      amountCents: amountCents ?? this.amountCents,
      recurrence: recurrence ?? this.recurrence,
      dueDate: dueDate ?? this.dueDate,
      isEstimate: isEstimate ?? this.isEstimate,
      isSubscription: isSubscription ?? this.isSubscription,
      needsReview: needsReview ?? this.needsReview,
      paidOn: paidOn != null ? paidOn() : this.paidOn,
      previousAmountCents: previousAmountCents,
    );
  }
}
