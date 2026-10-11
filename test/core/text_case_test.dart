import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/text_case.dart';

void main() {
  test('first letter capitalised, the rest as typed', () {
    expect(sentenceCase('phone plan'), 'Phone plan');
    expect(sentenceCase('rent'), 'Rent');
    expect(sentenceCase('Rent'), 'Rent');
    expect(sentenceCase('  water'), 'Water');
  });

  test('brand spellings and acronyms are left alone', () {
    expect(sentenceCase('iCloud'), 'iCloud');
    expect(sentenceCase('eBay plus'), 'eBay plus');
    expect(sentenceCase('EMI'), 'EMI');
  });

  test('empty, digits first, accented letters', () {
    expect(sentenceCase(''), '');
    expect(sentenceCase('2nd car'), '2nd car');
    expect(sentenceCase('électricité'), 'Électricité');
  });

  test('Title Case: every word, brand spellings and acronyms kept', () {
    expect(titleCase('phone plan'), 'Phone Plan');
    expect(titleCase('car insurance EMI'), 'Car Insurance EMI');
    expect(titleCase('iCloud storage'), 'iCloud Storage');
    expect(titleCase('  water   bill '), 'Water Bill');
    expect(titleCase(''), '');
  });
}
