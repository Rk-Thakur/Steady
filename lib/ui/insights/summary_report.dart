import '../../core/date_format.dart';
import '../../core/local_date.dart';
import '../../core/money.dart';
import '../../data/budget_store.dart';
import '../../domain/insights.dart';

/// Whether a change is good news for the user (colors the "vs last week"
/// notes on screen and in the PDF).
enum NoteTone { good, bad, neutral }

class ReportNote {
  const ReportNote(this.text, this.tone);
  final String text;
  final NoteTone tone;
}

/// Everything a weekly / monthly summary says, worked out once so the screen
/// (V5 / V6) and the PDF report show exactly the same figures and words.
class SummaryReport {
  SummaryReport._({
    required this.summary,
    required this.isMonth,
    required this.symbol,
    required this.isCurrent,
    required this.inNote,
    required this.spentNote,
    required this.savedNote,
    required this.weekStartsOn,
    required this.createdOn,
  });

  /// The summary the screen opens on: the last finished week or month (or
  /// the current one for a new user).
  factory SummaryReport.fromStore(BudgetStore store, {required bool month}) {
    final period = summaryPeriodFor(
      today: store.today,
      isMonth: month,
      weekStartsOn: store.settings.weekStartsOn,
      entries: store.entries,
    );
    PeriodSummary summaryOf(Period p) => summarize(
      period: p,
      isMonth: month,
      today: store.today,
      entries: store.entries,
      categories: store.categories,
      goals: store.goals,
      dailyNumbers: store.dailyNumbers,
      fallbackPaceCents: store.dailyNumber.dailyAllowanceCents,
    );
    final s = summaryOf(period);
    final prev = summaryOf(period.previous);
    final symbol = store.symbol;
    final vs = month
        ? 'vs ${formatMonthYear(prev.period.start).substring(0, 3)}'
        : 'vs last week';

    // "+$120 vs last week": good when the change helps the user.
    ReportNote note(
      int now,
      int before, {
      bool lowerIsBetter = false,
      bool percent = false,
    }) {
      if (!prev.hasEntries) {
        return const ReportNote('Nothing to compare yet', NoteTone.neutral);
      }
      final diff = now - before;
      if (diff == 0) {
        return const ReportNote('Same as before', NoteTone.neutral);
      }
      final text = percent && before > 0
          ? '${diff > 0 ? '+' : '−'}${(diff.abs() * 100 / before).round()}% $vs'
          : '${formatMoney(diff, symbol: symbol, showCents: false, signed: true)} $vs';
      final good = lowerIsBetter ? diff < 0 : diff > 0;
      return ReportNote(text, good ? NoteTone.good : NoteTone.bad);
    }

    return SummaryReport._(
      summary: s,
      isMonth: month,
      symbol: symbol,
      isCurrent: period.contains(store.today),
      inNote: note(s.inCents, prev.inCents),
      spentNote: note(
        s.spentCents,
        prev.spentCents,
        lowerIsBetter: true,
        percent: true,
      ),
      savedNote: note(s.savedCents, prev.savedCents),
      weekStartsOn: store.settings.weekStartsOn,
      createdOn: store.today,
    );
  }

  final PeriodSummary summary;
  final bool isMonth;
  final String symbol;

  /// The period still running (a new user's first week or month).
  final bool isCurrent;
  final ReportNote inNote;
  final ReportNote spentNote;
  final ReportNote savedNote;
  final int weekStartsOn;
  final LocalDate createdOn;

  Period get period => summary.period;

  String money(int cents) => formatMoney(cents, symbol: symbol);
  String whole(int cents) =>
      formatMoney(cents, symbol: symbol, showCents: false);

  String get title => isMonth ? 'Monthly summary' : 'Weekly summary';

  String get range => isMonth
      ? '${formatMonthYear(period.start)}${isCurrent ? ' so far' : ''}'
      : '${formatShortDay(period.start)} – '
            '${isCurrent ? 'today' : formatShortDay(period.end)}';

  bool get leftOverNegative => summary.leftOverCents < 0;

  /// Negative when bills or spending were paid from money that came in
  /// before this period: said plainly rather than as a scary minus.
  String get leftOverLabel => leftOverNegative
      ? 'More went out than came in'
      : 'Left over after spending & saving';

  String get leftOver => money(summary.leftOverCents.abs());

  String get daysUnder => summary.daysCounted == 0
      ? '—'
      : '${summary.daysUnder} of ${summary.daysCounted}';

  String get chartTitle => isMonth ? 'Spending by week' : 'Spending by day';

  String get chartKey =>
      '${whole(summary.paceCents)} ${isMonth ? 'weekly pace' : 'daily number'}';

  String get footer => isMonth
      ? 'Calculated on this phone from your own entries.'
      : 'Calculated on this phone from your own entries. '
            'Week starts ${weekdayName(weekStartsOn)}; change it in Profile.';

  /// "steady-week-2026-09-27.pdf" / "steady-month-2026-09.pdf".
  String get pdfFileName => isMonth
      ? 'steady-month-${period.start.toIso().substring(0, 7)}.pdf'
      : 'steady-week-${period.start.toIso()}.pdf';

  /// "Worth a look": the biggest day (or week) and what drove it.
  String? get worthALook {
    final b = summary.biggest;
    if (b == null) return null;
    final what = isMonth
        ? 'Week ${b.bar.label.substring(3)}'
        : weekdayName(b.bar.start.weekday);
    final drivers = [
      if (b.topCategory != null) 'mostly ${b.topCategory!.toLowerCase()}',
      if (b.topMood != null) 'while ${b.topMood!.label.toLowerCase()}',
    ].join(' ');
    final tail = drivers.isEmpty
        ? '.'
        : '. ${drivers[0].toUpperCase()}${drivers.substring(1)}.';
    if (b.overByCents > 0) {
      return isMonth
          ? '$what ran over pace by ${whole(b.overByCents)}$tail'
          : '$what went ${whole(b.overByCents)} over your number$tail';
    }
    return '$what was your biggest ${isMonth ? 'week' : 'day'}: '
        '${whole(b.bar.cents)}${drivers.isEmpty ? '' : ', $drivers'}.';
  }
}
