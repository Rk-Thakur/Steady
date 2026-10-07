import '../../core/money.dart';
import '../../domain/number_change.dart';

/// Words for [NumberChange], shared by the hero card and the breakdown.
abstract final class NumberChangeText {
  /// "Up $4.25 from yesterday: you spent less". Null when unchanged.
  static String? headline(NumberChange c, String symbol) {
    if (c.isUnchanged) return null;
    final amount = formatMoney(c.totalCents.abs(), symbol: symbol);
    final direction = c.totalCents > 0 ? 'Up' : 'Down';
    return '$direction $amount from yesterday: ${_reason(c)}';
  }

  static String _reason(NumberChange c) => switch (c.mainReason) {
    NumberChangeReason.spending =>
      c.spendingCents > 0 ? 'you spent less' : 'you spent more',
    NumberChangeReason.income => 'income logged today',
    NumberChangeReason.other => 'bills or goals changed',
  };

  /// The breakdown's "Since yesterday" rows: label and signed amount.
  static List<(String, int)> parts(NumberChange c, int daysLeft) {
    final days = daysLeft == 1 ? 'today' : 'over $daysLeft days';
    return [
      if (c.spendingCents > 0)
        ('Left over yesterday, spread $days', c.spendingCents),
      if (c.spendingCents < 0)
        ("Over yesterday's number, spread $days", c.spendingCents),
      if (c.incomeCents != 0)
        ('Income logged today, spread $days', c.incomeCents),
      if (c.otherCents != 0)
        ('Bills, goals, balance or payday changed', c.otherCents),
    ];
  }
}
