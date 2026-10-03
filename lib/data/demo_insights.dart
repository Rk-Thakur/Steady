/// Demo figures for Insights and the weekly/monthly summaries, taken from the
/// design. Replace with values computed from entries once the summaries
/// engine exists (Handoff 4 · Weekly & monthly summaries).
library;

class MoodSpend {
  const MoodSpend(
    this.mood,
    this.cents, {
    this.top = false,
    this.neutral = false,
  });
  final String mood;
  final int cents;
  final bool top;
  final bool neutral;
}

class LabeledAmount {
  const LabeledAmount(this.label, this.cents, {this.note});
  final String label;
  final int cents;
  final String? note;
}

class InsightsDemo {
  static const trigger =
      "When you're tired, food delivery costs you \$142 a month.";
  static const moods = [
    MoodSpend('Tired', 14200, top: true),
    MoodSpend('Stressed', 9600),
    MoodSpend('Happy', 8800),
    MoodSpend('Bored', 6100),
    MoodSpend('Neutral', 21000, neutral: true),
  ];
  static const plannedFraction = 0.72;
  static const plannedTotalCents = 59700;
  static const lateNightCents = 21400;
  static const lateNightCount = 9;
}

class PeriodSummary {
  const PeriodSummary({
    required this.title,
    required this.range,
    required this.inCents,
    required this.inNote,
    required this.spentCents,
    required this.spentNote,
    required this.savedCents,
    required this.savedNote,
    required this.leftOverCents,
    required this.daysUnder,
    required this.chartTitle,
    required this.chartKey,
    required this.bars,
    required this.paceCents,
    required this.categories,
    required this.savings,
    required this.worthALook,
    required this.footer,
    required this.pdfToast,
  });

  final String title;
  final String range;
  final int inCents;
  final String inNote;
  final int spentCents;
  final String spentNote;
  final int savedCents;
  final String savedNote;
  final int leftOverCents;
  final String daysUnder;
  final String chartTitle;
  final String chartKey;

  /// Label → spent, against [paceCents].
  final List<LabeledAmount> bars;
  final int paceCents;
  final List<LabeledAmount> categories;
  final List<LabeledAmount> savings;
  final String worthALook;
  final String footer;
  final String pdfToast;
}

const weekSummaryDemo = PeriodSummary(
  title: 'Weekly summary',
  range: 'Sun, Sep 20 – Sat, Sep 26',
  inCents: 82000,
  inNote: '+\$120 vs last week',
  spentCents: 41260,
  spentNote: '−8% vs last week',
  savedCents: 23680,
  savedNote: '+\$18.40 vs last week',
  leftOverCents: 17060,
  daysUnder: '5 of 7',
  chartTitle: 'Spending by day',
  chartKey: '\$64 daily number',
  bars: [
    LabeledAmount('S', 4300),
    LabeledAmount('M', 7700),
    LabeledAmount('T', 3400),
    LabeledAmount('W', 6000),
    LabeledAmount('T', 8800),
    LabeledAmount('F', 5200),
    LabeledAmount('S', 4600),
  ],
  paceCents: 6400,
  categories: [
    LabeledAmount('Food', 18640),
    LabeledAmount('Transport', 9200),
    LabeledAmount('Shopping', 6420),
    LabeledAmount('Fun', 4000),
    LabeledAmount('Health', 3000),
  ],
  savings: [
    LabeledAmount('Emergency fund', 20000, note: 'Payday set-aside'),
    LabeledAmount('Leftover sweeps', 3680, note: '2 days'),
  ],
  worthALook: 'Thursday was your biggest day: \$88, mostly unplanned food delivery while tired.',
  footer: 'Calculated on this phone from your own entries. Week starts Sunday; change it in Profile.',
  pdfToast:
      'Weekly report (PDF) created on this phone. Choose where to save it.',
);

const monthSummaryDemo = PeriodSummary(
  title: 'Monthly summary',
  range: 'September 2026',
  inCents: 328000,
  inNote: '+\$410 vs Aug',
  spentCents: 174230,
  spentNote: '−6% vs Aug',
  savedCents: 86000,
  savedNote: '+\$120 vs Aug',
  leftOverCents: 67770,
  daysUnder: '22 of 30',
  chartTitle: 'Spending by week',
  chartKey: '\$448 weekly pace',
  bars: [
    LabeledAmount('Wk 1', 41000),
    LabeledAmount('Wk 2', 43500),
    LabeledAmount('Wk 3', 48500),
    LabeledAmount('Wk 4', 42500),
  ],
  paceCents: 44800,
  categories: [
    LabeledAmount('Food', 70250),
    LabeledAmount('Transport', 35600),
    LabeledAmount('Bills & subs', 31880),
    LabeledAmount('Shopping', 21400),
    LabeledAmount('Fun', 15100),
  ],
  savings: [
    LabeledAmount('Emergency fund', 40000, note: '2 set-asides'),
    LabeledAmount('New laptop', 24000, note: 'Daily set-aside'),
    LabeledAmount('Weekend trip', 22000, note: 'Daily set-aside'),
  ],
  worthALook:
      'Week 3 ran over pace by \$37. Food delivery after 10 PM was most of it.',
  footer: 'Calculated on this phone from your own entries.',
  pdfToast:
      'September report (PDF) created on this phone. Choose where to save it.',
);
