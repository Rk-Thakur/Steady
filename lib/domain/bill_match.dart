import '../core/local_date.dart';
import 'models/models.dart';

/// Catches a bill being logged as an ordinary spend. Bills are already set
/// aside before payday, so logging one as a spend would count it twice; the
/// right move is "Mark as paid".
///
/// A match is a bill still reserved before payday whose name matches what
/// was typed ("rent", "Rent payment"), or one due within a week that costs
/// exactly this much (within 20% for estimates like electric).
Bill? likelyBillFor({
  required String? merchant,
  required int amountCents,
  required Iterable<Bill> reservedBills,
  required LocalDate today,
}) {
  if (amountCents <= 0) return null;
  final typed = _key(merchant ?? '');
  final soonest = reservedBills.toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  if (typed.length >= 3) {
    for (final b in soonest) {
      final name = _key(b.name);
      if (name.length >= 3 && (typed.contains(name) || name.contains(typed))) {
        return b;
      }
    }
  }
  final weekAhead = today.addDays(7);
  for (final b in soonest) {
    if (b.dueDate.isAfter(weekAhead)) continue;
    final close = b.isEstimate
        ? (amountCents - b.amountCents).abs() * 5 <= b.amountCents
        : amountCents == b.amountCents;
    if (close) return b;
  }
  return null;
}

/// Letters and digits only, lowercase: "Phone plan!" → "phoneplan".
String _key(String s) => s.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
