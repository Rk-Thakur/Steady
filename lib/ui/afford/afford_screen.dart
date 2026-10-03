import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../data/budget_store.dart';
import '../../data/store_scope.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';

/// 02 Can I afford it? Shows the trade-off, not just the price.
/// Rounds to whole dollars; work time to the nearest half hour (Handoff 3).
class AffordScreen extends StatefulWidget {
  const AffordScreen({super.key});

  @override
  State<AffordScreen> createState() => _AffordScreenState();
}

enum Verdict { fitsToday, tradeOff, notBeforePayday }

/// The Can I afford it? answer for [priceCents], from the current daily number.
class AffordAnswer {
  AffordAnswer(BudgetStore store, this.priceCents) {
    final n = store.dailyNumber;
    days = n.daysLeft;
    safeNowCents = n.safeToSpendCents;
    // Spread the price over the rest of the cycle, today included.
    newDailyCents = floorDiv(safeNowCents * days - priceCents, days);
    verdict = priceCents <= safeNowCents
        ? Verdict.fitsToday
        : newDailyCents >= 0
        ? Verdict.tradeOff
        : Verdict.notBeforePayday;
    final rate = store.settings.hourlyRateCents;
    workHalfHours = rate == null || rate <= 0
        ? null
        : (priceCents * 2 / rate).round();
    final goalsDaily = store.goalsDailyCents;
    goalDelayDays = goalsDaily <= 0
        ? null
        : (priceCents + goalsDaily - 1) ~/ goalsDaily;
    firstGoalName = store.goals
        .where((g) => !g.paused && !g.isReached)
        .firstOrNull
        ?.name;
    saveDailyCents = (priceCents + days - 1) ~/ days;
  }

  final int priceCents;
  late final int days;
  late final int safeNowCents;
  late final int newDailyCents;
  late final Verdict verdict;
  late final int? workHalfHours;
  late final int? goalDelayDays;
  late final String? firstGoalName;
  late final int saveDailyCents;

  bool get billsCovered => verdict != Verdict.notBeforePayday;
}

class _AffordScreenState extends State<AffordScreen> {
  final _price = TextEditingController();
  final _what = TextEditingController();
  String? _toast;

  @override
  void dispose() {
    _price.dispose();
    _what.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final symbol = store.symbol;
    final price = parseCents(_price.text);
    final answer = price == null || price <= 0
        ? null
        : AffordAnswer(store, price);
    String whole(int cents) =>
        formatMoney(cents, symbol: symbol, showCents: false);

    return SteadyPage(
      title: 'Can I afford it?',
      bottom: answer == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusToast(message: _toast),
                if (_toast != null) const SizedBox(height: 10),
                SteadyButton(
                  'Buy it now',
                  kind: answer.verdict == Verdict.notBeforePayday
                      ? ButtonKind.secondary
                      : ButtonKind.primary,
                  onPressed: () => Navigator.of(context).pushReplacementNamed(
                    Routes.logSpend,
                    arguments: LogSpendArgs(
                      amountCents: price,
                      merchant: _what.text.trim(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SteadyButton(
                  'Wait 48 hours, then ask me',
                  kind: answer.verdict == Verdict.notBeforePayday
                      ? ButtonKind.primary
                      : ButtonKind.secondary,
                  icon: Icons.schedule_rounded,
                  onPressed: () {
                    final when = store.today.addDays(2);
                    setState(
                      () => _toast =
                          "Okay. We'll ask again ${formatShortDay(when)}. Nothing was bought.",
                    );
                  },
                ),
                SteadyButton(
                  'Save for it: ${whole(answer.saveDailyCents)}/day until payday',
                  kind: ButtonKind.link,
                  onPressed: () => Navigator.of(context).pushNamed(
                    Routes.goalNew,
                    arguments: GoalNewArgs(
                      name: _what.text.trim(),
                      targetCents: price,
                    ),
                  ),
                ),
              ],
            ),
      children: [
        SteadyField(
          label: 'Price',
          amount: true,
          controller: _price,
          hint: '${symbol}0.00',
          autofocus: true,
          onChanged: (_) => setState(() => _toast = null),
        ),
        SteadyField(
          label: 'What is it?',
          controller: _what,
          hint: 'e.g. Running shoes',
        ),
        if (answer == null)
          SoftBanner(
            icon: Icons.lightbulb_outline_rounded,
            tone: BannerTone.info,
            child: Text(
              'Enter a price to see what it does to your daily number, your goals and your bills.',
              style: TextStyle(color: c.ink),
            ),
          )
        else
          Panel(
            radius: SteadyRadius.xl,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VerdictPill(answer.verdict),
                const SizedBox(height: SteadySpace.s2),
                ValueRow(
                  label: 'Daily safe-to-spend',
                  value: answer.verdict == Verdict.fitsToday
                      ? '${whole(answer.safeNowCents)} → ${whole(answer.safeNowCents - answer.priceCents)} today'
                      : '${whole(answer.safeNowCents)} → ${whole(answer.newDailyCents)} for ${answer.days} days',
                  valueColor: answer.newDailyCents < 0 ? c.dangerFg : null,
                ),
                if (answer.workHalfHours != null)
                  ValueRow(
                    label: 'Your work time',
                    value: '≈ ${_hours(answer.workHalfHours!)}',
                  ),
                if (answer.goalDelayDays != null &&
                    answer.firstGoalName != null)
                  ValueRow(
                    label: '${answer.firstGoalName} goal',
                    value:
                        '${answer.goalDelayDays} ${answer.goalDelayDays == 1 ? 'day' : 'days'} later',
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Bills before payday',
                          style: SteadyType.body.copyWith(
                            fontSize: 14,
                            color: c.muted,
                          ),
                        ),
                      ),
                      Icon(
                        answer.billsCovered
                            ? Icons.check_rounded
                            : Icons.priority_high_rounded,
                        size: 16,
                        color: answer.billsCovered ? c.positive : c.dangerFg,
                      ),
                      const SizedBox(width: SteadySpace.s1),
                      Text(
                        answer.billsCovered
                            ? 'Still covered'
                            : 'Would not be covered',
                        style: SteadyType.body.copyWith(
                          fontWeight: FontWeight.w800,
                          color: answer.billsCovered ? c.positive : c.dangerFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _hours(int halfHours) {
    final h = halfHours / 2;
    final text = h == h.roundToDouble()
        ? h.toStringAsFixed(0)
        : h.toStringAsFixed(1);
    return '$text ${h == 1 ? 'hour' : 'hours'}';
  }
}

class _VerdictPill extends StatelessWidget {
  const _VerdictPill(this.verdict);
  final Verdict verdict;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (label, bg, fg) = switch (verdict) {
      Verdict.fitsToday => ('Yes, it fits today', c.primarySoft, c.positive),
      Verdict.tradeOff => ('Yes, with a trade-off', c.warningBg, c.warningFg),
      Verdict.notBeforePayday => ('Not before payday', c.dangerBg, c.dangerFg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(SteadyRadius.pill),
      ),
      child: Text(
        label,
        style: SteadyType.caption.copyWith(
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
