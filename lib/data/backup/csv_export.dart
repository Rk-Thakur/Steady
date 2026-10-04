import '../db/budget_repository.dart';

/// "Export spreadsheet (CSV)": every entry, readable in any spreadsheet app.
/// RFC 4180 quoting, newest first. Amounts are signed decimals (spends
/// negative) in the install's currency.
String entriesToCsv(BudgetSnapshot s) {
  final currency = s.settings?.currency.code ?? '';
  final categories = {for (final c in s.categories) c.id: c.name};
  final bills = {for (final b in s.bills) b.id: b.name};
  final partner = s.split?.personName;
  final entries = List.of(s.entries)
    ..sort((a, b) {
      final byDate = b.localDate.compareTo(a.localDate);
      return byDate != 0 ? byDate : b.createdAtUtc.compareTo(a.createdAtUtc);
    });

  final rows = <List<String>>[
    [
      'Date',
      'Type',
      'Amount',
      'Currency',
      'Where / from',
      'Category',
      'Mood',
      'Planned',
      'Note',
      'Shared with',
      'Paycheck Vault',
      'Bill',
    ],
    for (final e in entries)
      [
        e.localDate.toIso(),
        e.isSpend ? 'Spend' : 'Income',
        _amount(e.isSpend ? -e.amountCents : e.amountCents),
        currency,
        e.merchant ?? '',
        categories[e.categoryId] ?? '',
        e.mood?.label ?? '',
        switch (e.planned) {
          true => 'Yes',
          false => 'No',
          null => '',
        },
        e.note ?? '',
        e.splitId != null ? (partner ?? 'Yes') : '',
        e.toVault
            ? 'Deposit'
            : e.fromVault
            ? 'Release'
            : '',
        bills[e.billId] ?? '',
      ],
  ];
  // CRLF line endings per RFC 4180 (and what spreadsheet apps expect).
  return '${rows.map((r) => r.map(_cell).join(',')).join('\r\n')}\r\n';
}

String _amount(int cents) {
  final sign = cents < 0 ? '-' : '';
  final abs = cents.abs();
  return '$sign${abs ~/ 100}.${(abs % 100).toString().padLeft(2, '0')}';
}

/// Quotes when needed, and neutralises spreadsheet formulas in user text
/// ("CSV injection": a merchant named `=HYPERLINK(...)` must stay text).
String _cell(String v) {
  var text = v;
  final isNumber = RegExp(r'^-?\d+(\.\d+)?$').hasMatch(text);
  if (!isNumber && text.isNotEmpty && '=+-@\t\r'.contains(text[0])) {
    text = "'$text";
  }
  if (text.contains(RegExp('[",\r\n]'))) {
    text = '"${text.replaceAll('"', '""')}"';
  }
  return text;
}
