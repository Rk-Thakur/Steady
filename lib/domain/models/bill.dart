import 'package:flutter/foundation.dart';

import '../../core/local_date.dart';
import '../schedule.dart';

enum Recurrence { weekly, everyTwoWeeks, monthly, yearly }

/// A recurring bill or subscription.
///
/// [dueDate] is always the next *unpaid* occurrence. Paying moves it to the
/// following occurrence and stamps [lastPaidOn].
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
    this.lastPaidOn,
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

  /// When the most recent occurrence was paid.
  final LocalDate? lastPaidOn;

  /// Set when the last logged amount went up (Bills radar "price went up").
  final int? previousAmountCents;

  bool get priceWentUp =>
      previousAmountCents != null && amountCents > previousAmountCents!;

  bool paidSince(LocalDate date) =>
      lastPaidOn != null && !lastPaidOn!.isBefore(date);

  bool isOverdueOn(LocalDate today) => dueDate.isBefore(today);

  /// Every unpaid occurrence due before [payday], overdue ones included.
  /// A weekly bill can fall due more than once in a pay cycle.
  List<LocalDate> occurrencesBefore(LocalDate payday) {
    final dates = <LocalDate>[];
    for (
      var d = dueDate;
      d.isBefore(payday);
      d = nextOccurrence(d, recurrence)
    ) {
      dates.add(d);
    }
    return dates;
  }

  /// Reserved out of the daily number before [payday].
  int reservedBefore(LocalDate payday) =>
      amountCents * occurrencesBefore(payday).length;

  bool isReservedBefore(LocalDate payday) => dueDate.isBefore(payday);

  /// The bill after paying its current occurrence on [paidOn] for
  /// [paidCents]: moved to the next due date. An estimate takes the real
  /// amount as its next estimate; a fixed bill that came in higher is flagged
  /// for review ("price went up").
  Bill paid({required LocalDate paidOn, required int paidCents}) {
    final wentUp = !isEstimate && paidCents > amountCents;
    return Bill(
      id: id,
      name: name,
      amountCents: paidCents,
      recurrence: recurrence,
      dueDate: nextOccurrence(dueDate, recurrence),
      isEstimate: isEstimate,
      isSubscription: isSubscription,
      needsReview: needsReview || wentUp,
      lastPaidOn: paidOn,
      previousAmountCents: wentUp ? amountCents : previousAmountCents,
    );
  }

  Bill copyWith({
    String? name,
    int? amountCents,
    Recurrence? recurrence,
    LocalDate? dueDate,
    bool? isEstimate,
    bool? isSubscription,
    bool? needsReview,
    LocalDate? Function()? lastPaidOn,
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
      lastPaidOn: lastPaidOn != null ? lastPaidOn() : this.lastPaidOn,
      previousAmountCents: previousAmountCents,
    );
  }
}
