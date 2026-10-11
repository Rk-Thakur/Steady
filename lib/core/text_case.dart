import 'package:flutter/widgets.dart' show StringCharacters;

/// Sentence case for display: the first letter capitalised, the rest as
/// typed ("phone plan" → "Phone plan", "EMI" stays "EMI").
///
/// Names that already have a capital after the first letter are brand
/// spellings ("iCloud", "eBay") and are kept exactly as typed.
String sentenceCase(String s) {
  final t = s.trimLeft();
  if (t.isEmpty) return s;
  final first = t.characters.first;
  final rest = t.substring(first.length);
  if (rest.contains(RegExp('[A-Z]'))) return t;
  return first.toUpperCase() + rest;
}

/// Title Case for display: every word starts with a capital, the rest as
/// typed ("phone plan" → "Phone Plan", "car insurance EMI" → "Car Insurance
/// EMI"). Words with a capital after their first letter are brand spellings
/// ("iCloud") and are kept exactly as typed.
String titleCase(String s) => s
    .trim()
    .split(RegExp(r'\s+'))
    .map((w) => w.isEmpty ? w : sentenceCase(w))
    .join(' ');
