import 'package:flutter/foundation.dart';

import '../../core/local_date.dart';

/// Split expenses with other people, in groups (a partner, flatmates, a
/// trip). Everything lives on this phone: the people are just names, they
/// don't need the app, and you're the group's bookkeeper.

/// The phone's owner in every group, as a member id.
const youId = 'me';

/// A group's default way of sharing an expense.
enum SplitMethod {
  /// Everyone included pays the same.
  equal,

  /// Each member has a percentage (e.g. by income: you 60, Alex 40).
  byIncome,

  /// Amounts typed per expense.
  exact,
}

/// Someone you split with. One person can be in several groups; Steady adds
/// up what they owe you across all of them.
@immutable
class SplitPerson {
  const SplitPerson({
    required this.id,
    required this.name,
    this.remindMuted = false,
    this.remindSnoozedUntil,
  });

  final String id;
  final String name;

  /// "Don't remind me about Sam."
  final bool remindMuted;

  /// No debt reminders about them before this day.
  final LocalDate? remindSnoozedUntil;

  SplitPerson copyWith({
    String? name,
    bool? remindMuted,
    LocalDate? Function()? remindSnoozedUntil,
  }) => SplitPerson(
    id: id,
    name: name ?? this.name,
    remindMuted: remindMuted ?? this.remindMuted,
    remindSnoozedUntil: remindSnoozedUntil != null
        ? remindSnoozedUntil()
        : this.remindSnoozedUntil,
  );

  @override
  bool operator ==(Object other) =>
      other is SplitPerson &&
      other.id == id &&
      other.name == name &&
      other.remindMuted == remindMuted &&
      other.remindSnoozedUntil == remindSnoozedUntil;

  @override
  int get hashCode => Object.hash(id, name, remindMuted, remindSnoozedUntil);
}

@immutable
class SplitGroup {
  const SplitGroup({
    required this.id,
    required this.name,
    required this.memberIds,
    this.method = SplitMethod.equal,
    this.weights = const {},
    this.simplifyDebts = true,
    this.createdOn,
  });

  final String id;
  final String name;

  /// The other people in the group ([youId] is always a member, implicitly).
  final List<String> memberIds;
  final SplitMethod method;

  /// [SplitMethod.byIncome] percentages by member id, [youId] included.
  final Map<String, int> weights;

  /// Show the fewest payments that settle the group instead of every IOU.
  final bool simplifyDebts;
  final LocalDate? createdOn;

  /// Everyone, you first.
  List<String> get everyone => [youId, ...memberIds];

  SplitGroup copyWith({
    String? name,
    List<String>? memberIds,
    SplitMethod? method,
    Map<String, int>? weights,
    bool? simplifyDebts,
  }) => SplitGroup(
    id: id,
    name: name ?? this.name,
    memberIds: memberIds ?? this.memberIds,
    method: method ?? this.method,
    weights: weights ?? this.weights,
    simplifyDebts: simplifyDebts ?? this.simplifyDebts,
    createdOn: createdOn,
  );
}

/// One shared expense: who paid, and exactly how much each person's share
/// is (the shares always add up to the amount).
@immutable
class GroupExpense {
  const GroupExpense({
    required this.id,
    required this.groupId,
    required this.name,
    required this.amountCents,
    required this.date,
    required this.paidBy,
    required this.shares,
    this.entryId,
  });

  final String id;
  final String groupId;
  final String name;
  final int amountCents;
  final LocalDate date;

  /// A member id, or [youId].
  final String paidBy;

  /// Member id → share in cents. Only the people it was split between.
  final Map<String, int> shares;

  /// The spend logged in your entries when you paid (so it counts against
  /// your daily number).
  final String? entryId;
}

/// Money that changed hands to settle up ("Sam paid you $30").
@immutable
class Settlement {
  const Settlement({
    required this.id,
    required this.groupId,
    required this.fromId,
    required this.toId,
    required this.amountCents,
    required this.date,
    this.entryId,
  });

  final String id;
  final String groupId;
  final String fromId;
  final String toId;
  final int amountCents;
  final LocalDate date;

  /// The income (they paid you) or spend (you paid them) logged for it.
  final String? entryId;
}

/// Everything about splitting, as one value (the store, database and
/// backups pass it around whole).
@immutable
class SplitBook {
  const SplitBook({
    this.people = const [],
    this.groups = const [],
    this.expenses = const [],
    this.settlements = const [],
  });

  static const empty = SplitBook();

  final List<SplitPerson> people;
  final List<SplitGroup> groups;
  final List<GroupExpense> expenses;
  final List<Settlement> settlements;

  bool get isEmpty => groups.isEmpty && people.isEmpty;

  SplitPerson? person(String id) {
    for (final p in people) {
      if (p.id == id) return p;
    }
    return null;
  }

  SplitGroup? group(String id) {
    for (final g in groups) {
      if (g.id == id) return g;
    }
    return null;
  }

  /// "You", or the person's name.
  String nameOf(String id) => id == youId ? 'You' : person(id)?.name ?? '?';

  /// Converts the single "split with one person" from before split groups
  /// (database v8 and older backups) into a group with that person.
  /// [paidByYou] per expense; shares follow the old rule exactly.
  static SplitBook fromLegacy({
    required String splitId,
    required String personName,
    required int yourSharePercent,
    required String legacyMethod,
    required List<
      ({
        String id,
        String name,
        int amountCents,
        LocalDate date,
        bool paidByYou,
      })
    >
    expenses,
  }) {
    final personId = 'person-$splitId';
    final yours = legacyMethod == 'even' ? 50 : yourSharePercent;
    final theirs = 100 - yours;
    return SplitBook(
      people: [SplitPerson(id: personId, name: personName)],
      groups: [
        SplitGroup(
          id: splitId,
          name: 'You & $personName',
          memberIds: [personId],
          method: legacyMethod == 'byIncome'
              ? SplitMethod.byIncome
              : SplitMethod.equal,
          weights: {youId: yours, personId: theirs},
        ),
      ],
      expenses: [
        for (final e in expenses)
          () {
            // The old rule: the other side's share rounds down.
            if (e.paidByYou) {
              final theirShare = e.amountCents * theirs ~/ 100;
              return GroupExpense(
                id: e.id,
                groupId: splitId,
                name: e.name,
                amountCents: e.amountCents,
                date: e.date,
                paidBy: youId,
                shares: {
                  youId: e.amountCents - theirShare,
                  personId: theirShare,
                },
              );
            }
            final yourShare = e.amountCents * yours ~/ 100;
            return GroupExpense(
              id: e.id,
              groupId: splitId,
              name: e.name,
              amountCents: e.amountCents,
              date: e.date,
              paidBy: personId,
              shares: {youId: yourShare, personId: e.amountCents - yourShare},
            );
          }(),
      ],
    );
  }
}
