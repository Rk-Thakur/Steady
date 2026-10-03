/// Money is always integer minor units (cents). Never use doubles for amounts.
library;

/// Floor division for a positive divisor. Rounds toward negative infinity,
/// so a displayed amount never overstates what is safe, even when negative.
int floorDiv(int dividend, int divisor) {
  assert(divisor > 0, 'divisor must be positive');
  final quotient = dividend ~/ divisor;
  return (dividend % divisor != 0 && dividend < 0) ? quotient - 1 : quotient;
}

/// The design uses a true minus sign (U+2212), not a hyphen.
const String minusSign = '−';

/// Formats cents as `$1,234.56`.
///
/// - [showCents]: false rounds down to whole units (e.g. "Can I afford it?").
/// - [signed]: prefixes `+` for positive amounts. Negatives always get `−`.
String formatMoney(
  int cents, {
  String symbol = r'$',
  bool showCents = true,
  bool signed = false,
}) {
  final negative = cents < 0;
  final abs = cents.abs();
  final whole = abs ~/ 100;
  final fraction = abs % 100;

  final digits = whole.toString();
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(',');
    grouped.write(digits[i]);
  }

  final body = showCents
      ? '$symbol$grouped.${fraction.toString().padLeft(2, '0')}'
      : '$symbol$grouped';
  if (negative) return '$minusSign$body';
  if (signed && cents > 0) return '+$body';
  return body;
}
