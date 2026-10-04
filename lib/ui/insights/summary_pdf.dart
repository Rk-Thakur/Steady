import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../domain/insights.dart';
import '../../theme/tokens.dart';
import 'summary_report.dart';

/// Steady's own typefaces, embedded so the report looks like the app and
/// prints every currency symbol (₹ € £ $) and the true minus sign.
class ReportFonts {
  const ReportFonts({required this.body, required this.heading});

  final pw.Font body;
  final pw.Font heading;

  static Future<ReportFonts> load() async => ReportFonts(
    body: pw.Font.ttf(await rootBundle.load('assets/fonts/Manrope.ttf')),
    heading: pw.Font.ttf(
      await rootBundle.load('assets/fonts/BricolageGrotesque.ttf'),
    ),
  );
}

/// The weekly / monthly summary as a one-page A4 PDF, made on this phone
/// (Handoff 4: "Weekly report (PDF) created on this phone"). Always the light
/// palette: it's meant for paper.
Future<Uint8List> buildSummaryPdf(SummaryReport r, ReportFonts fonts) {
  const t = SteadyColors.light;
  PdfColor pdf(Color c) => PdfColor.fromInt(c.toARGB32());
  final ink = pdf(t.ink);
  final muted = pdf(t.muted);
  final line = pdf(t.line);
  final s = r.summary;

  pw.TextStyle style(
    double size, {
    PdfColor? color,
    bool heading = false,
    double? height,
  }) => pw.TextStyle(
    font: heading ? fonts.heading : fonts.body,
    fontSize: size,
    color: color ?? ink,
    lineSpacing: height ?? 1.5,
  );

  pw.Widget panel({required pw.Widget child, PdfColor? color}) => pw.Container(
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      color: color ?? pdf(t.surface),
      border: color == null ? pw.Border.all(color: line) : null,
      borderRadius: pw.BorderRadius.circular(12),
    ),
    child: child,
  );

  PdfColor toneColor(NoteTone tone) => switch (tone) {
    NoteTone.good => pdf(t.positive),
    NoteTone.bad => pdf(t.warningFg),
    NoteTone.neutral => muted,
  };

  pw.Widget stat(String label, String value, ReportNote note) => pw.Expanded(
    child: panel(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: style(9, color: muted)),
          pw.SizedBox(height: 2),
          pw.Text(value, style: style(16, heading: true)),
          pw.SizedBox(height: 2),
          pw.Text(note.text, style: style(8, color: toneColor(note.tone))),
        ],
      ),
    ),
  );

  // Steady's wave mark (same path as the notification icon).
  final logo = pw.Container(
    width: 30,
    height: 30,
    decoration: pw.BoxDecoration(
      color: pdf(t.inverse),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    padding: const pw.EdgeInsets.all(6),
    child: pw.SvgImage(
      svg:
          '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">'
          '<path d="M3,16 C6,16 6,8 9,8 C12,8 12,16 15,16 C18,16 18,8 21,8" '
          'fill="none" stroke="#C9F26B" stroke-width="2.4" '
          'stroke-linecap="round" stroke-linejoin="round"/></svg>',
    ),
  );

  final doc = pw.Document(
    title: '${r.title} · ${r.range}',
    author: 'Steady',
    creator: 'Steady',
  );
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      theme: pw.ThemeData.withFont(base: fonts.body, bold: fonts.body),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              logo,
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(r.title, style: style(22, heading: true)),
                    pw.Text(r.range, style: style(11, color: muted)),
                  ],
                ),
              ),
              pw.Text(
                'Created ${formatShortDay(r.createdOn)}, ${r.createdOn.year}',
                style: style(8, color: muted),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Row(
            children: [
              stat('Money in', r.money(s.inCents), r.inNote),
              pw.SizedBox(width: 8),
              stat('Spent', r.money(s.spentCents), r.spentNote),
              pw.SizedBox(width: 8),
              stat('Saved', r.money(s.savedCents), r.savedNote),
            ],
          ),
          pw.SizedBox(height: 10),
          panel(
            color: pdf(t.hero),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        r.leftOverLabel,
                        style: style(9, color: pdf(t.onHeroMuted)),
                      ),
                      pw.Text(
                        r.leftOver,
                        style: style(
                          24,
                          heading: true,
                          color: r.leftOverNegative
                              ? pdf(t.onHero)
                              : pdf(t.highlight),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Days under your number',
                      style: style(9, color: pdf(t.onHeroMuted)),
                    ),
                    pw.Text(
                      r.daysUnder,
                      style: style(16, heading: true, color: pdf(t.onHero)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          panel(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text(r.chartTitle, style: style(11))),
                    pw.Text('– – ${r.chartKey}', style: style(8, color: muted)),
                  ],
                ),
                pw.SizedBox(height: 8),
                _chart(s, pdf(t.primary), pdf(t.chartOver), ink, muted, style),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    _key(pdf(t.primary), 'Under', style(8, color: muted)),
                    pw.SizedBox(width: 12),
                    _key(pdf(t.chartOver), 'Over', style(8, color: muted)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: panel(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Text('Top categories', style: style(11)),
                      pw.SizedBox(height: 6),
                      if (s.categories.isEmpty)
                        pw.Text(
                          'Nothing spent yet.',
                          style: style(9, color: muted),
                        ),
                      for (final c in s.categories)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 6),
                          child: pw.Row(
                            children: [
                              pw.SizedBox(
                                width: 70,
                                child: pw.Text(c.name, style: style(9)),
                              ),
                              pw.Expanded(
                                child: _bar(
                                  c.cents / (s.categories.first.cents * 1.12),
                                  pdf(t.primary),
                                  pdf(t.progressTrack),
                                ),
                              ),
                              pw.SizedBox(
                                width: 64,
                                child: pw.Text(
                                  r.money(c.cents),
                                  textAlign: pw.TextAlign.right,
                                  style: style(9),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: panel(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Text('Where savings went', style: style(11)),
                      pw.SizedBox(height: 6),
                      if (s.savings.isEmpty)
                        pw.Text(
                          'No goal set-asides in this period.',
                          style: style(9, color: muted),
                        ),
                      for (final sv in s.savings)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 6),
                          child: pw.Row(
                            children: [
                              pw.Expanded(
                                child: pw.Text(sv.name, style: style(9)),
                              ),
                              pw.Text(
                                formatMoney(
                                  sv.cents,
                                  symbol: r.symbol,
                                  signed: true,
                                ),
                                style: style(9, color: pdf(t.positive)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (r.worthALook != null) ...[
            pw.SizedBox(height: 10),
            panel(
              color: pdf(t.warningBg),
              child: pw.RichText(
                text: pw.TextSpan(
                  style: style(10),
                  children: [
                    pw.TextSpan(
                      text: 'Worth a look. ',
                      style: style(10, color: pdf(t.warningFg)),
                    ),
                    pw.TextSpan(text: r.worthALook),
                  ],
                ),
              ),
            ),
          ],
          pw.Spacer(),
          pw.Divider(color: line, thickness: 0.5),
          pw.Text(
            '${r.footer} Steady has no account and no cloud: '
            'this report was made on your phone and goes only where you save it.',
            style: style(8, color: muted),
          ),
        ],
      ),
    ),
  );
  return doc.save();
}

/// Bars against a dashed pace line; over the line = the Over color.
pw.Widget _chart(
  PeriodSummary s,
  PdfColor under,
  PdfColor over,
  PdfColor ink,
  PdfColor muted,
  pw.TextStyle Function(double size, {PdfColor? color}) style,
) {
  const height = 90.0;
  final max =
      [
        ...s.bars.map((b) => b.cents),
        s.paceCents,
        1,
      ].reduce((a, b) => a > b ? a : b) *
      1.1;
  return pw.SizedBox(
    height: height + 16,
    child: pw.Stack(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < s.bars.length; i++) ...[
              if (i > 0) pw.SizedBox(width: s.isMonth ? 14 : 8),
              pw.Expanded(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    // No bar at all on a no-spend day (a zero-height
                    // rounded box draws stray corner marks).
                    if (s.bars[i].cents > 0)
                      pw.Container(
                        height: s.bars[i].cents / max * height,
                        decoration: pw.BoxDecoration(
                          color: s.bars[i].over ? over : under,
                          borderRadius: const pw.BorderRadius.vertical(
                            top: pw.Radius.circular(4),
                          ),
                        ),
                      ),
                    pw.SizedBox(height: 4),
                    pw.Text(s.bars[i].label, style: style(7, color: muted)),
                  ],
                ),
              ),
            ],
          ],
        ),
        pw.Positioned(
          left: 0,
          right: 0,
          bottom: 16 + s.paceCents / max * height,
          child: pw.Container(
            height: 0,
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                  color: ink,
                  width: 1,
                  style: pw.BorderStyle.dashed,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _bar(double value, PdfColor fill, PdfColor track) => pw.Container(
  height: 6,
  decoration: pw.BoxDecoration(
    color: track,
    borderRadius: pw.BorderRadius.circular(3),
  ),
  alignment: pw.Alignment.centerLeft,
  child: pw.LayoutBuilder(
    builder: (context, box) => pw.Container(
      width: (box?.maxWidth ?? 0) * value.clamp(0.0, 1.0),
      height: 6,
      decoration: pw.BoxDecoration(
        color: fill,
        borderRadius: pw.BorderRadius.circular(3),
      ),
    ),
  ),
);

pw.Widget _key(PdfColor color, String label, pw.TextStyle style) => pw.Row(
  children: [
    pw.Container(
      width: 8,
      height: 8,
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(2),
      ),
    ),
    pw.SizedBox(width: 4),
    pw.Text(label, style: style),
  ],
);
