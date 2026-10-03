import 'package:flutter/foundation.dart';

import '../../core/local_date.dart';

enum GoalKind {
  safety('Safety net'),
  thing('Something to buy'),
  trip('A trip'),
  debt('Pay off debt');

  const GoalKind(this.label);
  final String label;
}

@immutable
class Goal {
  const Goal({
    required this.id,
    required this.name,
    required this.targetCents,
    required this.savedCents,
    required this.dailySetAsideCents,
    this.kind = GoalKind.thing,
    this.targetDate,
    this.paused = false,
  });

  final String id;
  final String name;
  final GoalKind kind;
  final int targetCents;
  final int savedCents;

  /// Taken out of the daily number every day until the goal is reached.
  final int dailySetAsideCents;
  final LocalDate? targetDate;
  final bool paused;

  bool get isReached => savedCents >= targetCents;
  double get progress =>
      targetCents == 0 ? 1 : (savedCents / targetCents).clamp(0, 1);
  int get percent => (progress * 100).floor();

  /// Days of set-asides still needed, or null when paused or no set-aside.
  int? get daysToGo {
    if (paused || dailySetAsideCents <= 0) return null;
    final left = targetCents - savedCents;
    if (left <= 0) return 0;
    return (left + dailySetAsideCents - 1) ~/ dailySetAsideCents;
  }

  Goal copyWith({int? savedCents, bool? paused, int? dailySetAsideCents}) {
    return Goal(
      id: id,
      name: name,
      kind: kind,
      targetCents: targetCents,
      savedCents: savedCents ?? this.savedCents,
      dailySetAsideCents: dailySetAsideCents ?? this.dailySetAsideCents,
      targetDate: targetDate,
      paused: paused ?? this.paused,
    );
  }
}
