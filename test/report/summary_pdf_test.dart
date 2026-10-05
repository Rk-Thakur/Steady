import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/models/models.dart';
import 'package:steady/ui/insights/summary_pdf.dart';
import 'package:steady/ui/insights/summary_report.dart';

/// Writes the PDFs here when set, to look at them:
/// flutter test test/report --dart-define=PDF_DIR=/some/dir
const _dir = String.fromEnvironment('PDF_DIR');

void main() {
  final fonts = ReportFonts(
    body: pw.Font.ttf(
      File('assets/fonts/Manrope.ttf').readAsBytesSync().buffer.asByteData(),
    ),
    heading: pw.Font.ttf(
      File('assets/fonts/BricolageGrotesque.ttf')
          .readAsBytesSync()
          .buffer
          .asByteData(),
    ),
  );
  BudgetStore store() =>
      BudgetStore.sample(clock: () => const LocalDate(2026, 10, 4));

  for (final month in [false, true]) {
    test('${month ? 'monthly' : 'weekly'} report is a one-page PDF', () async {
      final report = SummaryReport.fromStore(store(), month: month);
      final bytes = await buildSummaryPdf(report, fonts);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(
        RegExp('/Type\\s*/Page[^s]').allMatches(String.fromCharCodes(bytes)),
        hasLength(1),
      );
      if (_dir.isNotEmpty) {
        File('$_dir/${report.pdfFileName}').writeAsBytesSync(bytes);
      }
    });
  }

  test('file names name the period', () {
    final s = store();
    expect(
      SummaryReport.fromStore(s, month: false).pdfFileName,
      'steady-week-2026-09-27.pdf',
    );
    expect(
      SummaryReport.fromStore(s, month: true).pdfFileName,
      matches(RegExp(r'^steady-month-2026-(09|10)\.pdf$')),
    );
  });

  test('rupees and the minus sign survive into the PDF', () async {
    final s = store();
    s.updateSettings(s.settings.copyWith(currency: Currency.inr));
    final bytes = await buildSummaryPdf(
      SummaryReport.fromStore(s, month: true),
      fonts,
    );
    expect(bytes.length, greaterThan(1000)); // built without a glyph error
    if (_dir.isNotEmpty) File('$_dir/inr.pdf').writeAsBytesSync(bytes);
  });
}
