import 'package:flutter/foundation.dart';

import '../core/local_date.dart';
import 'models/split.dart';

/// The arithmetic of split groups: shares, balances, who pays whom, and
/// debt simplification. Pure functions over cents; nothing is ever lost or
/// invented (every result adds up exactly).

/// "[fromId] pays [toId] [amountCents]" within [groupId].
@immutable
class Transfer {
  const Transfer(this.fromId, this.toId, this.amountCents, {this.groupId});

  final String fromId;
  final String toId;
  final int amountCents;
  final String? groupId;

  @override
  bool operator ==(Object other) =>
      other is Transfer &&
      other.fromId == fromId &&
      other.toId == toId &&
      other.amountCents == amountCents &&
      other.groupId == groupId;

  @override
  int get hashCode => Object.hash(fromId, toId, amountCents, groupId);

  @override
  String toString() => '$fromId→$toId $amountCents';
}

/// Splits [amountCents] among [participants] (in order).
///
/// - [SplitMethod.equal]: the same for everyone.
/// - [SplitMethod.byIncome]: by [weights] (percentages; only the included
///   people's weights count, so they're rescaled).
/// - [SplitMethod.exact]: [exact] as given (must add up to the amount).
///
/// Leftover cents from rounding go to the payer when they're included, so
/// the app never overstates what someone owes them; otherwise to the first
/// people in order.
Map<String, int> splitShares({
  required int amountCents,
  required List<String> participants,
  required String paidBy,
  SplitMethod method = SplitMethod.equal,
  Map<String, int> weights = const {},
  Map<String, int> exact = const {},
}) {
  assert(participants.isNotEmpty, 'split between at least one person');
  if (method == SplitMethod.exact) {
    final total = exact.values.fold<int>(0, (a, b) => a + b);
    if (total != amountCents) {
      throw ArgumentError('Exact shares add up to $total, not $amountCents');
    }
    return {
      for (final p in participants)
        if ((exact[p] ?? 0) > 0) p: exact[p]!,
    };
  }

  final w = {
    for (final p in participants)
      p: method == SplitMethod.byIncome ? (weights[p] ?? 0) : 1,
  };
  var totalWeight = w.values.fold<int>(0, (a, b) => a + b);
  if (totalWeight == 0) {
    // Nobody included has a weight: fall back to equal.
    for (final p in participants) {
      w[p] = 1;
    }
    totalWeight = participants.length;
  }

  final shares = {
    for (final p in participants) p: amountCents * w[p]! ~/ totalWeight,
  };
  var left = amountCents - shares.values.fold<int>(0, (a, b) => a + b);
  final order = participants.contains(paidBy)
      ? [paidBy, ...participants.where((p) => p != paidBy)]
      : participants;
  if (participants.contains(paidBy)) {
    shares[paidBy] = shares[paidBy]! + left;
    left = 0;
  }
  for (var i = 0; left > 0; i = (i + 1) % order.length) {
    shares[order[i]] = shares[order[i]]! + 1;
    left--;
  }
  return shares;
}

/// Each person's position in a group: positive = the group owes them,
/// negative = they owe the group. Always adds up to zero.
Map<String, int> netBalances(
  Iterable<GroupExpense> expenses,
  Iterable<Settlement> settlements,
) {
  final net = <String, int>{};
  void add(String id, int cents) => net[id] = (net[id] ?? 0) + cents;
  for (final e in expenses) {
    add(e.paidBy, e.amountCents);
    for (final s in e.shares.entries) {
      add(s.key, -s.value);
    }
  }
  for (final s in settlements) {
    add(s.fromId, s.amountCents);
    add(s.toId, -s.amountCents);
  }
  net.removeWhere((_, v) => v == 0);
  return net;
}

/// Who owes whom without simplifying: each IOU between two people, netted
/// per pair ("Sam owes Priya", "Priya owes you").
List<Transfer> pairwiseDebts(
  Iterable<GroupExpense> expenses,
  Iterable<Settlement> settlements, {
  String? groupId,
}) {
  // debt[(a, b)] > 0: a owes b. Keyed with a < b so each pair nets once.
  final debt = <(String, String), int>{};
  void owe(String from, String to, int cents) {
    if (from == to || cents == 0) return;
    if (from.compareTo(to) < 0) {
      debt[(from, to)] = (debt[(from, to)] ?? 0) + cents;
    } else {
      debt[(to, from)] = (debt[(to, from)] ?? 0) - cents;
    }
  }

  for (final e in expenses) {
    for (final s in e.shares.entries) {
      owe(s.key, e.paidBy, s.value);
    }
  }
  for (final s in settlements) {
    owe(s.toId, s.fromId, s.amountCents); // paying back reduces what you owe
  }
  final out = [
    for (final d in debt.entries)
      if (d.value > 0)
        Transfer(d.key.$1, d.key.$2, d.value, groupId: groupId)
      else if (d.value < 0)
        Transfer(d.key.$2, d.key.$1, -d.value, groupId: groupId),
  ]..sort(_byAmount);
  return out;
}

/// The fewest payments that settle everyone's [net] position: the largest
/// debtor pays the largest creditor, repeatedly. Totals never change; at
/// most (people − 1) payments; same input, same answer.
List<Transfer> simplifyDebts(Map<String, int> net, {String? groupId}) {
  final creditors = [
    for (final e in net.entries)
      if (e.value > 0) (e.key, e.value),
  ];
  final debtors = [
    for (final e in net.entries)
      if (e.value < 0) (e.key, -e.value),
  ];
  int order((String, int) a, (String, int) b) {
    final byAmount = b.$2.compareTo(a.$2);
    return byAmount != 0 ? byAmount : a.$1.compareTo(b.$1);
  }

  final out = <Transfer>[];
  while (creditors.isNotEmpty && debtors.isNotEmpty) {
    creditors.sort(order);
    debtors.sort(order);
    final (to, owed) = creditors.first;
    final (from, owes) = debtors.first;
    final pay = owes < owed ? owes : owed;
    out.add(Transfer(from, to, pay, groupId: groupId));
    creditors[0] = (to, owed - pay);
    debtors[0] = (from, owes - pay);
    creditors.removeWhere((c) => c.$2 == 0);
    debtors.removeWhere((d) => d.$2 == 0);
  }
  return out..sort(_byAmount);
}

int _byAmount(Transfer a, Transfer b) {
  final byAmount = b.amountCents.compareTo(a.amountCents);
  if (byAmount != 0) return byAmount;
  final byFrom = a.fromId.compareTo(b.fromId);
  return byFrom != 0 ? byFrom : a.toId.compareTo(b.toId);
}

/// What's outstanding in [group]: simplified or every IOU, per its setting.
List<Transfer> groupTransfers(SplitGroup group, SplitBook book) {
  final expenses = book.expenses.where((e) => e.groupId == group.id);
  final settlements = book.settlements.where((s) => s.groupId == group.id);
  return group.simplifyDebts
      ? simplifyDebts(netBalances(expenses, settlements), groupId: group.id)
      : pairwiseDebts(expenses, settlements, groupId: group.id);
}

/// One person's standing with you across every group.
@immutable
class PersonBalance {
  const PersonBalance({
    required this.personId,
    required this.owesYou,
    required this.youOwe,
    required this.transfers,
    required this.since,
  });

  final String personId;

  /// Totals over all groups (both can be non-zero: they owe you in one
  /// group while you owe them in another).
  final int owesYou;
  final int youOwe;

  /// The group transfers between you and them.
  final List<Transfer> transfers;

  /// The oldest shared expense still behind what's owed (for reminders).
  final LocalDate? since;

  /// Positive: they owe you overall.
  int get net => owesYou - youOwe;
}

/// Everyone you have money outstanding with, biggest first.
List<PersonBalance> personBalances(SplitBook book) {
  final byPerson = <String, List<Transfer>>{};
  for (final g in book.groups) {
    for (final t in groupTransfers(g, book)) {
      final other = t.fromId == youId
          ? t.toId
          : t.toId == youId
          ? t.fromId
          : null;
      if (other == null) continue;
      byPerson.putIfAbsent(other, () => []).add(t);
    }
  }
  final out = [
    for (final e in byPerson.entries)
      PersonBalance(
        personId: e.key,
        owesYou: e.value
            .where((t) => t.toId == youId)
            .fold<int>(0, (a, t) => a + t.amountCents),
        youOwe: e.value
            .where((t) => t.fromId == youId)
            .fold<int>(0, (a, t) => a + t.amountCents),
        transfers: e.value,
        since: _owingSince(book, e.key, e.value),
      ),
  ]..sort((a, b) => b.net.abs().compareTo(a.net.abs()));
  return out;
}

/// The oldest expense since you and [personId] last settled, in the groups
/// where something's outstanding between you.
LocalDate? _owingSince(
  SplitBook book,
  String personId,
  List<Transfer> transfers,
) {
  LocalDate? since;
  for (final groupId in transfers.map((t) => t.groupId).toSet()) {
    LocalDate? lastSettled;
    for (final s in book.settlements) {
      final between =
          s.groupId == groupId &&
          {s.fromId, s.toId}.containsAll([youId, personId]);
      if (between && (lastSettled == null || s.date.isAfter(lastSettled))) {
        lastSettled = s.date;
      }
    }
    for (final e in book.expenses) {
      if (e.groupId != groupId) continue;
      if (lastSettled != null && e.date.isBefore(lastSettled)) continue;
      if (since == null || e.date.isBefore(since)) since = e.date;
    }
  }
  return since;
}
