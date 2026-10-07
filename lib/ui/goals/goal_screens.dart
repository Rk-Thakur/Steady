import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../data/budget_store.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';

BannerTone _toneOf(GoalKind kind) => switch (kind) {
  GoalKind.safety => BannerTone.primary,
  GoalKind.thing => BannerTone.info,
  GoalKind.trip => BannerTone.warning,
  GoalKind.debt => BannerTone.danger,
};

/// "$15.38/day · ETA Dec 2026" or "$8.00/day · by Jan 30".
String _goalMeta(BudgetStore store, Goal g) {
  final perDay =
      '${formatMoney(g.dailySetAsideCents, symbol: store.symbol)}/day';
  if (g.paused) return '$perDay · paused';
  if (g.targetDate != null) {
    return '$perDay · by ${formatShortDate(g.targetDate!)}';
  }
  final days = g.daysToGo;
  if (days == null) return perDay;
  final eta = store.today.addDays(days);
  return '$perDay · ETA ${formatMonthYear(eta).substring(0, 3)} ${eta.year}';
}

// ─── G1 Goals ──────────────────────────────────────────────────────────────

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    String whole(int cents) =>
        formatMoney(cents, symbol: store.symbol, showCents: false);

    return SteadyPage(
      title: 'Goals',
      trailing: SteadyButton(
        '+ New goal',
        kind: ButtonKind.inverse,
        height: 44,
        expand: false,
        onPressed: () => Navigator.of(context).pushNamed(Routes.goalNew),
      ),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SteadySpace.s4,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set aside for goals',
                          style: SteadyType.body.copyWith(fontSize: 14),
                        ),
                        Text(
                          'Already out of your daily number',
                          style: SteadyType.caption.copyWith(
                            fontWeight: FontWeight.w500,
                            color: c.mutedStrong,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: whole(store.goalsDailyCents),
                          style: SteadyType.title,
                        ),
                        TextSpan(
                          text: '/day',
                          style: SteadyType.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: c.mutedStrong,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (store.plan.goalSetAsideCents > 0) ...[
                const SizedBox(height: SteadySpace.s2),
                Text(
                  'This pay cycle: ${whole(store.plan.goalSetAsideCents)} held '
                  'back. It moves into your goals on payday, '
                  '${formatShortDay(store.nextPayday)}.',
                  style: SteadyType.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: c.mutedStrong,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (store.goals.isEmpty)
          Text(
            'No goals yet. Start one and it comes out of your daily number automatically.',
            style: SteadyType.body.copyWith(color: c.muted),
          ),
        for (final g in store.goals)
          Panel(
            onTap: () =>
                Navigator.of(context)
                    .pushNamed(Routes.goalDetail, arguments: g.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    LetterTile(letter: g.name, tone: _toneOf(g.kind)),
                    const SizedBox(width: SteadySpace.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.name,
                            style: SteadyType.heading.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            _goalMeta(store, g),
                            style: SteadyType.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              color: c.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${g.percent}%',
                      style: SteadyType.body.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Bar(value: g.progress),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        whole(g.savedCents),
                        style: SteadyType.caption.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      'of ${whole(g.targetCents)}',
                      style: SteadyType.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
                if (store.cycleSetAsideFor(g) > 0) ...[
                  const SizedBox(height: SteadySpace.s1),
                  Text(
                    '+${whole(store.cycleSetAsideFor(g))} set aside this cycle · '
                    'added on payday',
                    style: SteadyType.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: c.positive,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

// ─── G2 New goal ───────────────────────────────────────────────────────────

class GoalNewScreen extends StatefulWidget {
  const GoalNewScreen({super.key, this.args = const GoalNewArgs()});
  final GoalNewArgs args;

  @override
  State<GoalNewScreen> createState() => _GoalNewScreenState();
}

class _GoalNewScreenState extends State<GoalNewScreen> {
  late final _name = TextEditingController(text: widget.args.name ?? '');
  late final _target = TextEditingController(
    text: widget.args.targetCents == null
        ? ''
        : centsToField(widget.args.targetCents!),
  );
  final _saved = TextEditingController();
  GoalKind _kind = GoalKind.thing;
  int _months = 5;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _saved.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final symbol = store.symbol;
    final target = parseCents(_target.text);
    // Money already put away for it counts from the start.
    final saved = math.max(0, parseCents(_saved.text) ?? 0);
    final remaining = target == null ? 0 : target - saved;
    final alreadyThere = target != null && target > 0 && remaining <= 0;
    final perDay = target == null || target <= 0 || alreadyThere
        ? null
        : (remaining + _months * 30 - 1) ~/ (_months * 30);
    final number = store.dailyNumber;
    final allowance = number.dailyAllowanceCents;
    // Held back from today to payday, like the store will (never more
    // than the goal needs).
    final after = perDay == null
        ? allowance
        : floorDiv(
            number.poolCents - math.min(perDay * number.daysLeft, remaining),
            number.daysLeft,
          );
    final name = _name.text.trim();
    String m(int cents) => formatMoney(cents, symbol: symbol);

    void start() {
      store.addGoal(
        Goal(
          id: store.newId('goal'),
          name: name.isEmpty ? _kind.label : name,
          kind: _kind,
          targetCents: target!,
          savedCents: saved,
          dailySetAsideCents: perDay!,
          targetDate: store.today.addDays(_months * 30),
          createdOn: store.today,
        ),
      );
      Navigator.of(context).pop();
    }

    return SteadyPage(
      title: 'New goal',
      gap: 18,
      bottom: SteadyButton(
        'Start this goal',
        onPressed: perDay == null ? null : start,
      ),
      children: [
        ChipGroup<GoalKind>(
          label: 'What kind?',
          height: 44,
          options: GoalKind.values,
          selected: _kind,
          labelOf: (k) => k.label,
          onSelected: (k) => setState(() => _kind = k),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SteadyField(
                label: 'Name',
                controller: _name,
                hint: 'e.g. New laptop',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: SteadySpace.s3),
            Expanded(
              child: SteadyField(
                label: 'Target',
                controller: _target,
                emphasis: true,
                hint: '${symbol}0',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SteadyField(
              label: 'Already saved (optional)',
              controller: _saved,
              hint: '${symbol}0',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: SteadySpace.s2),
            Text(
              alreadyThere
                  ? "That's already the whole target. Nothing more to set aside."
                  : "Money you've already put away for this, like in a savings "
                        "account. It isn't taken from your daily number.",
              style: SteadyType.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: alreadyThere
                    ? context.colors.warningFg
                    : context.colors.muted,
              ),
            ),
          ],
        ),
        ChipGroup<int>(
          label: 'How fast?',
          height: 44,
          options: const [3, 5, 8, 12],
          selected: _months,
          labelOf: (n) => '$n months',
          onSelected: (n) => setState(() => _months = n),
        ),
        Panel(
          child: Semantics(
            liveRegion: true,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        'Set aside each day',
                        style: SteadyType.body.copyWith(
                          fontSize: 14,
                          color: context.colors.muted,
                        ),
                      ),
                    ),
                    Text(
                      perDay == null ? '—' : m(perDay),
                      style: SteadyType.title.copyWith(fontSize: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ValueRow(
                  padding: EdgeInsets.zero,
                  label: 'Your daily number',
                  value: perDay == null
                      ? m(allowance)
                      : '${m(allowance)} → ${m(after)}',
                ),
              ],
            ),
          ),
        ),
        if (perDay != null)
          Text(
            'Starts today. It comes out of your daily number until payday '
            '(${formatShortDay(store.nextPayday)}), then moves into the goal. '
            'Same again every pay cycle.',
            style: SteadyType.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: context.colors.muted,
            ),
          ),
      ],
    );
  }
}

// ─── G3 Goal detail ────────────────────────────────────────────────────────

class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({super.key, required this.goalId});
  final String goalId;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final g = store.goalById(goalId);
    if (g == null) {
      return const SteadyPage(
        title: 'Goal',
        children: [Text('This goal no longer exists.')],
      );
    }
    final c = context.colors;
    final symbol = store.symbol;
    String whole(int cents) =>
        formatMoney(cents, symbol: symbol, showCents: false);
    String m(int cents) => formatMoney(cents, symbol: symbol);
    final badge = g.percent >= 75
        ? 'three-quarters badge earned'
        : g.percent >= 50
        ? 'halfway badge earned'
        : g.percent >= 25
        ? 'first-quarter badge earned'
        : 'first badge at 25%';
    final eta = _goalMeta(store, g).split(' · ').last;
    final held = store.cycleSetAsideFor(g);

    Future<void> addMoney() async {
      final added = await _askAmount(context, symbol);
      if (added == null || !context.mounted) return;
      final updated = g.copyWith(savedCents: g.savedCents + added);
      store.updateGoal(updated);
      if (updated.isReached) {
        Navigator.of(context)
            .pushReplacementNamed(Routes.goalDone, arguments: g.id);
      }
    }

    return SteadyPage(
      title: g.name,
      bottom: ButtonRow(
        children: [
          SteadyButton(
            'Add money',
            kind: ButtonKind.highlight,
            onPressed: addMoney,
          ),
          SteadyButton(
            g.paused ? 'Resume goal' : 'Pause goal',
            kind: ButtonKind.secondary,
            onPressed: () => store.updateGoal(g.copyWith(paused: !g.paused)),
          ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(SteadySpace.s5),
          decoration: BoxDecoration(
            color: c.hero,
            borderRadius: BorderRadius.circular(SteadyRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      whole(g.savedCents),
                      style: SteadyType.amountXl.copyWith(
                        fontSize: 44,
                        color: c.onHero,
                      ),
                    ),
                  ),
                  Text(
                    'of ${whole(g.targetCents)}',
                    style: SteadyType.body.copyWith(
                      fontSize: 14,
                      color: c.onHeroMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SteadySpace.s3),
              _MilestoneBar(progress: g.progress),
              const SizedBox(height: SteadySpace.s3),
              DefaultTextStyle(
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.onHeroMuted,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text('${g.percent}% · $badge')),
                    Text(eta),
                  ],
                ),
              ),
              if (held > 0) ...[
                const SizedBox(height: SteadySpace.s2),
                Text(
                  '+${m(held)} set aside this cycle · added on '
                  '${formatShortDay(store.nextPayday)}',
                  style: SteadyType.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.onHero,
                  ),
                ),
              ],
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: StatTile(label: 'Per day', value: m(g.dailySetAsideCents)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: 'Still to save',
                value: whole(math.max(0, g.targetCents - g.savedCents)),
              ),
            ),
          ],
        ),
        if (g.paused)
          SoftBanner(
            tone: BannerTone.warning,
            child: LeadText(
              lead: 'Paused.',
              body:
                  'Your daily number goes up ${m(g.dailySetAsideCents)} until you resume.',
              leadColor: c.warningFg,
            ),
          ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How it fills up',
                style: SteadyType.heading.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: SteadySpace.s2),
              Text(
                g.isReached
                    ? 'Reached. Nothing more comes out of your daily number.'
                    : g.paused
                    ? "Paused: nothing is set aside until you resume. What's "
                          'already held this cycle still moves in on payday.'
                    : 'Every day, ${m(g.dailySetAsideCents)} comes out of your '
                          "daily number. It's held until payday, then added "
                          "here. You don't need to move it yourself.",
                style: SteadyType.body.copyWith(color: c.muted),
              ),
              const SizedBox(height: SteadySpace.s2),
              Text(
                'Put money away yourself? Use Add money.',
                style: SteadyType.body.copyWith(color: c.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Future<int?> _askAmount(BuildContext context, String symbol) {
    final controller = TextEditingController();
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          SteadySpace.s5,
          0,
          SteadySpace.s5,
          MediaQuery.viewInsetsOf(context).bottom + SteadySpace.s6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add money', style: SteadyType.title.copyWith(fontSize: 24)),
            const SizedBox(height: SteadySpace.s4),
            SteadyField(
              label: 'Amount',
              amount: true,
              controller: controller,
              hint: '${symbol}0.00',
              autofocus: true,
            ),
            const SizedBox(height: SteadySpace.s2),
            Text(
              "Money you've put away yourself, like in a savings account. "
              "It isn't taken from your daily number.",
              style: SteadyType.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.muted,
              ),
            ),
            const SizedBox(height: SteadySpace.s4),
            SteadyButton(
              'Add to goal',
              onPressed: () {
                final cents = parseCents(controller.text);
                if (cents != null && cents > 0) {
                  Navigator.of(context).pop(cents);
                }
              },
            ),
          ],
        ),
      ),
    ).whenComplete(controller.dispose);
  }
}

/// Progress with 25 / 50 / 75 % milestone ticks (dark once passed).
class _MilestoneBar extends StatelessWidget {
  const _MilestoneBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 20,
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          alignment: Alignment.centerLeft,
          children: [
            Bar(
              value: progress,
              height: 14,
              fill: c.highlight,
              track: Colors.white.withValues(alpha: 0.18),
            ),
            for (final m in const [.25, .5, .75])
              Positioned(
                left: box.maxWidth * m - 2,
                child: Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: progress >= m ? c.onHighlight : c.inputBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── G4 Goal reached ───────────────────────────────────────────────────────

class GoalDoneScreen extends StatefulWidget {
  const GoalDoneScreen({super.key, this.goalId});
  final String? goalId;

  @override
  State<GoalDoneScreen> createState() => _GoalDoneScreenState();
}

class _GoalDoneScreenState extends State<GoalDoneScreen>
    with SingleTickerProviderStateMixin {
  // Check scales .6 → 1 (500 ms spring), confetti falls once (1.2 s).
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final g = widget.goalId == null ? null : store.goalById(widget.goalId!);
    final symbol = store.symbol;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final pad = MediaQuery.paddingOf(context);
    final saved = formatMoney(
      g?.targetCents ?? 120000,
      symbol: symbol,
      showCents: false,
    );
    final name = (g?.name ?? 'new laptop').toLowerCase();
    final perDay = formatMoney(g?.dailySetAsideCents ?? 800, symbol: symbol);

    // Kept to the margins and above the check so nothing covers the text.
    const confetti = [
      (40.0, 70.0, 10.0, 14.0, 20.0, 0),
      (300.0, 90.0, 8.0, 8.0, 0.0, 1),
      (70.0, 150.0, 6.0, 16.0, 35.0, 1),
      (330.0, 160.0, 12.0, 12.0, 0.0, 0),
      (200.0, 40.0, 8.0, 18.0, -25.0, 2),
      (14.0, 170.0, 10.0, 10.0, 0.0, 2),
      (366.0, 120.0, 7.0, 14.0, 40.0, 1),
      (110.0, 60.0, 6.0, 6.0, 0.0, 0),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: c.hero,
        body: Stack(
          children: [
            for (final (x, y, w, h, rot, color) in confetti)
              AnimatedBuilder(
                animation: _anim,
                builder: (context, child) {
                  final t = reduce ? 1.0 : Curves.easeIn.transform(_anim.value);
                  return Positioned(
                    left: x / 390 * MediaQuery.sizeOf(context).width,
                    top: pad.top + y * t - 40 * (1 - t),
                    child: Opacity(opacity: .85 * t, child: child),
                  );
                },
                child: Transform.rotate(
                  angle: rot * math.pi / 180,
                  child: Container(
                    width: w,
                    height: h,
                    decoration: BoxDecoration(
                      color: [c.highlight, Colors.white, c.billPending][color],
                      borderRadius: BorderRadius.circular(w == h ? 99 : 2),
                    ),
                  ),
                ),
              ),
            FillOrScroll(
              padding: EdgeInsets.fromLTRB(
                SteadySpace.s6,
                pad.top + 96,
                SteadySpace.s6,
                pad.bottom + SteadySpace.s6,
              ),
              children: [
                ScaleTransition(
                  scale: reduce
                      ? const AlwaysStoppedAnimation(1.0)
                      : Tween(begin: .6, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _anim,
                            curve: const Interval(
                              0,
                              .42,
                              curve: Curves.elasticOut,
                            ),
                          ),
                        ),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: c.highlight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 52,
                      color: c.onHighlight,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'GOAL REACHED',
                  style: SteadyType.overline.copyWith(
                    fontSize: 14,
                    letterSpacing: 1.5,
                    color: c.highlight,
                  ),
                ),
                const SizedBox(height: SteadySpace.s2),
                Text(
                  'You saved $saved for your $name',
                  textAlign: TextAlign.center,
                  style: SteadyType.title.copyWith(
                    fontSize: 38,
                    height: 1.05,
                    letterSpacing: -1,
                    color: c.onHero,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: 'Saved',
                        value: saved,
                        onDark: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        label: 'Was setting aside',
                        value: '$perDay/day',
                        onDark: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: SteadySpace.s4,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: c.inverse,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Your daily number goes up '),
                        TextSpan(
                          text: perDay,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: c.highlight,
                          ),
                        ),
                        const TextSpan(text: ' starting tomorrow.'),
                      ],
                    ),
                    style: SteadyType.body.copyWith(
                      fontSize: 14,
                      color: c.onInverse,
                    ),
                  ),
                ),
                const Spacer(),
                SteadyButton(
                  'Start the next goal',
                  kind: ButtonKind.highlight,
                  onPressed: () =>
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.goalNew),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: TextButton.styleFrom(
                    foregroundColor: c.highlight,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Back to goals'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
