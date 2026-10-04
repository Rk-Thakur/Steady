import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/notifications.dart';
import '../../core/date_format.dart';
import '../../core/local_date.dart';
import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';

/// The Steady wave mark on a dark rounded tile.
class SteadyLogo extends StatelessWidget {
  const SteadyLogo({super.key, this.size = 56});
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: SteadyColors.light.ink,
        borderRadius: BorderRadius.circular(size * .29),
      ),
      child: Center(
        child: CustomPaint(
          size: Size.square(size * .54),
          painter: _WavePainter(c.highlight),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // SVG path "M3 16c3 0 3-8 6-8s3 8 6 8 3-8 6-8" in a 24×24 box.
    final s = size.width / 24;
    final path = Path()
      ..moveTo(3 * s, 16 * s)
      ..cubicTo(6 * s, 16 * s, 6 * s, 8 * s, 9 * s, 8 * s)
      ..cubicTo(12 * s, 8 * s, 12 * s, 16 * s, 15 * s, 16 * s)
      ..cubicTo(18 * s, 16 * s, 18 * s, 8 * s, 21 * s, 8 * s);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.color != color;
}

// ─── O0 Splash ─────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.autoAdvance = true});

  /// The loading view shown while the database opens at launch: same look,
  /// no navigation of its own.
  const SplashScreen.loading({super.key}) : autoAdvance = false;

  /// Advances on a timer or tap. False for [SplashScreen.loading].
  final bool autoAdvance;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoAdvance) {
      _timer = Timer(const Duration(milliseconds: 1400), _continue);
    }
  }

  void _continue() {
    if (!mounted || !widget.autoAdvance) return;
    _timer?.cancel();
    final settings = StoreScope.of(context).settings;
    final nav = Navigator.of(context);
    nav.pushReplacementNamed(settings.onboarded ? Routes.home : Routes.welcome);
    if (settings.onboarded && settings.appLockEnabled && settings.pin != null) {
      nav.pushNamed(Routes.lock);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduce = MediaQuery.disableAnimationsOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: c.hero,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _continue,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SteadyLogo(size: 104),
                    const SizedBox(height: 22),
                    Text(
                      'Steady',
                      style: SteadyType.amountXl.copyWith(
                        fontSize: 52,
                        color: c.onHero,
                      ),
                    ),
                    const SizedBox(height: SteadySpace.s2),
                    Text(
                      'Spend forward, not backward.',
                      style: SteadyType.body.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: c.highlight,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.paddingOf(context).bottom + 48,
                child: Semantics(
                  label: 'Loading',
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _dots,
                        builder: (context, _) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < 3; i++) ...[
                              if (i > 0) const SizedBox(width: SteadySpace.s2),
                              Transform.translate(
                                // Rise 4 px, staggered 150 ms (Handoff 2 · Motion).
                                offset: Offset(
                                  0,
                                  reduce
                                      ? 0
                                      : -4 * _bump(_dots.value - i * .125),
                                ),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: c.highlight,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'SMART BUDGET TRACKER',
                        style: SteadyType.overline.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: c.onHeroMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static double _bump(double t) {
    final x = t % 1;
    return x < .5
        ? Curves.easeInOut.transform(x * 2)
        : Curves.easeInOut.transform((1 - x) * 2);
  }
}

// ─── O1 Welcome ────────────────────────────────────────────────────────────

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pad = MediaQuery.paddingOf(context);
    Widget feature(IconData icon, String title, String body) => Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: c.highlight, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: SteadyType.body.copyWith(
                  fontWeight: FontWeight.w800,
                  color: c.onHero,
                  height: 1.4,
                ),
              ),
              Text(
                body,
                style: SteadyType.body.copyWith(
                  color: c.onHeroMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: c.hero,
        body: FillOrScroll(
          padding: EdgeInsets.fromLTRB(
            SteadySpace.s6,
            pad.top + 40,
            SteadySpace.s6,
            pad.bottom + SteadySpace.s6,
          ),
          children: [
            const Align(alignment: Alignment.centerLeft, child: SteadyLogo()),
            const SizedBox(height: 28),
            Text(
              'Know what you can spend today.',
              style: SteadyType.title.copyWith(
                fontSize: 42,
                height: 1.05,
                letterSpacing: -1,
                color: c.onHero,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Steady sets aside your bills and goals first, then gives you one daily number you can trust.',
              style: SteadyType.body.copyWith(
                fontSize: 16,
                height: 1.5,
                color: c.onHeroMuted,
              ),
            ),
            const SizedBox(height: 28),
            feature(
              Icons.today_outlined,
              'Safe to spend, daily',
              'One number, updated every morning',
            ),
            const SizedBox(height: SteadySpace.s4),
            feature(
              Icons.balance_outlined,
              'Check before you buy',
              'See the trade-off, not just the price',
            ),
            const SizedBox(height: SteadySpace.s4),
            feature(
              Icons.savings_outlined,
              "Steady pay, even if income isn't",
              'Built for freelance, gig and tips',
            ),
            const Spacer(),
            SteadyButton(
              'Get started',
              kind: ButtonKind.highlight,
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.onbIncome),
            ),
            const SizedBox(height: 14),
            // Steady has no accounts; returning users restore a backup file.
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(Routes.backup),
              style: TextButton.styleFrom(
                foregroundColor: c.highlight,
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Restore from a backup file'),
            ),
            if (kDebugMode)
              TextButton(
                onPressed: () {
                  StoreScope.of(context).loadSample();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.home, (_) => false);
                },
                style: TextButton.styleFrom(foregroundColor: c.onHeroMuted),
                child: const Text('Debug: load sample data'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Back button + step bars, shared by the three setup steps.
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleIconButton(
        icon: Icons.chevron_left_rounded,
        label: 'Back',
        onTap: () => Navigator.of(context).maybePop(),
      ),
      const SizedBox(width: SteadySpace.s3),
      Expanded(child: StepBars(step: step)),
    ],
  );
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.step, required this.title, this.body});
  final int step;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $step of 3',
          style: SteadyType.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: c.muted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: SteadyType.title.copyWith(fontSize: 30, height: 1.1),
        ),
        if (body != null) ...[
          const SizedBox(height: 6),
          Text(body!, style: SteadyType.body.copyWith(color: c.muted)),
        ],
      ],
    );
  }
}

// ─── O2 How you get paid ───────────────────────────────────────────────────

class OnbIncomeScreen extends StatefulWidget {
  /// [editing]: opened from Settings; Continue saves and goes back.
  const OnbIncomeScreen({super.key, this.editing = false});
  final bool editing;

  @override
  State<OnbIncomeScreen> createState() => _OnbIncomeScreenState();
}

class _OnbIncomeScreenState extends State<OnbIncomeScreen> {
  IncomeType? _pick;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final pick = _pick ?? store.settings.incomeType;
    return SteadyPage(
      header: widget.editing ? null : const _StepHeader(step: 1),
      title: widget.editing ? 'Income type' : null,
      leading: widget.editing ? PageLeading.back : PageLeading.none,
      gap: 18,
      bottom: SteadyButton(
        widget.editing ? 'Save' : 'Continue',
        onPressed: () {
          store.updateSettings(store.settings.copyWith(incomeType: pick));
          widget.editing
              ? Navigator.of(context).pop()
              : Navigator.of(context).pushNamed(Routes.onbMoney);
        },
      ),
      children: [
        if (!widget.editing)
          const _StepTitle(
            step: 1,
            title: 'How do you get paid?',
            body: 'This shapes how we calculate your daily number.',
          ),
        for (final t in IncomeType.values)
          RadioCard(
            title: t.title,
            subtitle: t.subtitle,
            selected: t == pick,
            onTap: () => setState(() => _pick = t),
          ),
        AnimatedSize(
          duration: SteadyMotion.reduced,
          child: pick == IncomeType.salary
              ? const SizedBox(width: double.infinity)
              : SoftBanner(
                  icon: Icons.savings_outlined,
                  child: LeadText(
                    lead: "We'll turn on Paycheck Vault.",
                    body: 'Uneven deposits get smoothed into a steady weekly pay.',
                    leadColor: context.colors.positive,
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── O3 Set up your money ──────────────────────────────────────────────────

class OnbMoneyScreen extends StatefulWidget {
  const OnbMoneyScreen({super.key});

  @override
  State<OnbMoneyScreen> createState() => _OnbMoneyScreenState();
}

class _OnbMoneyScreenState extends State<OnbMoneyScreen> {
  TextEditingController? _balance;
  late LocalDate _payday;
  late PayFrequency _freq;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_balance != null) return;
    final store = StoreScope.of(context);
    final input = store.dailyInput;
    final now =
        input.moneyAtStartOfDayCents +
        input.incomeTodayCents -
        input.spentTodayCents;
    _balance = TextEditingController(text: now > 0 ? centsToField(now) : '');
    _payday = store.nextPayday.isAfter(store.today)
        ? store.nextPayday
        : store.today.addDays(14);
    _freq = store.settings.payFrequency;
  }

  @override
  void dispose() {
    _balance?.dispose();
    super.dispose();
  }

  Future<void> _pickPayday() async {
    final today = StoreScope.of(context).today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_payday.year, _payday.month, _payday.day),
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year, today.month + 3, today.day),
    );
    if (picked != null) {
      setState(() => _payday = LocalDate.fromDateTime(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final symbol = store.symbol;
    final balance = parseCents(_balance!.text);
    final bills = store.bills.where((b) => b.isReservedBefore(_payday)).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    void addBill(BillPrefill prefill) =>
        Navigator.of(context).pushNamed(Routes.billEdit, arguments: prefill);

    return SteadyPage(
      header: const _StepHeader(step: 2),
      leading: PageLeading.none,
      gap: 18,
      bottom: SteadyButton(
        'Continue',
        onPressed: balance == null
            ? null
            : () {
                store.updateSettings(
                  store.settings.copyWith(payFrequency: _freq),
                );
                store.startCycle(balanceCents: balance, payday: _payday);
                Navigator.of(context).pushNamed(Routes.onbReveal);
              },
      ),
      children: [
        const _StepTitle(
          step: 2,
          title: 'Set up your money',
          body: 'No bank login needed. You decide what goes in.',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SteadyField(
                label: 'Money you have now',
                controller: _balance,
                emphasis: true,
                hint: '${symbol}0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: SteadySpace.s3),
            Expanded(
              child: SteadyField(
                key: ValueKey(_payday),
                label: 'Next payday',
                initialValue: formatShortDay(_payday),
                emphasis: true,
                readOnly: true,
                onTap: _pickPayday,
              ),
            ),
          ],
        ),
        Panel(
          padding: const EdgeInsets.fromLTRB(
            SteadySpace.s4,
            6,
            SteadySpace.s4,
            14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: SteadySpace.s1),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bills before payday',
                        style: SteadyType.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${bills.length} added',
                      style: SteadyType.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
              ),
              for (final b in bills) ...[
                ValueRow(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  label: b.name,
                  labelWidget: NameMeta(
                    name: b.name,
                    meta: formatShortDate(b.dueDate),
                  ),
                  value:
                      '${b.isEstimate ? '~' : ''}${formatMoney(b.amountCents, symbol: symbol)}',
                ),
                Divider(color: c.lineSoft, height: 1),
              ],
              const SizedBox(height: SteadySpace.s3),
              Wrap(
                spacing: SteadySpace.s2,
                runSpacing: SteadySpace.s2,
                children: [
                  AddChip(
                    label: '+ Phone',
                    onTap: () => addBill(
                      const BillPrefill(
                        name: 'Phone',
                        amountCents: 4500,
                        dueInDays: 3,
                      ),
                    ),
                  ),
                  AddChip(
                    label: '+ Subscriptions',
                    onTap: () => addBill(
                      const BillPrefill(
                        name: 'Subscription',
                        subscription: true,
                      ),
                    ),
                  ),
                  AddChip(
                    label: '+ Other bill',
                    onTap: () => addBill(const BillPrefill()),
                  ),
                ],
              ),
            ],
          ),
        ),
        ChipGroup<PayFrequency>(
          label: 'How often are you paid?',
          options: const [
            PayFrequency.weekly,
            PayFrequency.everyTwoWeeks,
            PayFrequency.monthly,
            PayFrequency.varies,
          ],
          selected: _freq,
          labelOf: (f) => f.label,
          onSelected: (f) => setState(() => _freq = f),
        ),
      ],
    );
  }
}

// ─── O4 Your daily number ──────────────────────────────────────────────────

class OnbRevealScreen extends StatelessWidget {
  const OnbRevealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final symbol = store.symbol;
    final n = store.dailyNumber;
    final i = n.input;
    String m(int cents) => formatMoney(cents, symbol: symbol);
    final billCount = store.upcomingBills.length;
    final firstGoal = store.goals
        .where((g) => !g.paused && !g.isReached)
        .firstOrNull;

    Widget link(String label, String route, [Object? args]) => GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route, arguments: args),
      child: Text(
        ' $label',
        style: SteadyType.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: c.primary,
        ),
      ),
    );

    return SteadyPage(
      header: const _StepHeader(step: 3),
      leading: PageLeading.none,
      gap: 18,
      bottom: SteadyButton(
        "Looks right, let's go",
        kind: ButtonKind.highlight,
        onPressed: () =>
            Navigator.of(context).pushNamed(Routes.notifPermission),
      ),
      children: [
        const _StepTitle(step: 3, title: "Here's your daily number"),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: c.hero,
            borderRadius: BorderRadius.circular(SteadyRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You can safely spend',
                style: SteadyType.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.onHeroMuted,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formatMoney(
                      n.dailyAllowanceCents,
                      symbol: symbol,
                      showCents: false,
                    ),
                    style: SteadyType.amountXl.copyWith(
                      fontSize: 60,
                      letterSpacing: -2,
                      color: c.highlight,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'a day',
                    style: SteadyType.body.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: c.onHeroMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'until payday on ${formatShortDay(store.nextPayday)}',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.onHeroMuted,
                ),
              ),
            ],
          ),
        ),
        GroupedList(
          padding: const EdgeInsets.symmetric(horizontal: SteadySpace.s4),
          children: [
            ValueRow(
              label: 'Balance today',
              muted: false,
              value: m(i.moneyAtStartOfDayCents + i.incomeTodayCents),
            ),
            ValueRow(
              label: '',
              labelWidget: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$billCount ${billCount == 1 ? 'bill' : 'bills'} before payday',
                    style: SteadyType.body.copyWith(fontSize: 15),
                  ),
                  link('Review', Routes.bills),
                ],
              ),
              value: '− ${m(i.unpaidBillsBeforePaydayCents)}',
            ),
            if (i.goalSetAsidesCents > 0)
              ValueRow(
                label: '',
                labelWidget: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        firstGoal == null ? 'Goals' : '${firstGoal.name} goal',
                        overflow: TextOverflow.ellipsis,
                        style: SteadyType.body.copyWith(fontSize: 15),
                      ),
                    ),
                    firstGoal == null
                        ? link('Edit', Routes.goals)
                        : link('Edit', Routes.goalDetail, firstGoal.id),
                  ],
                ),
                value: '− ${m(i.goalSetAsidesCents)}',
              ),
            ValueRow(
              label:
                  '${m(n.poolCents)} ÷ ${n.daysLeft} ${n.daysLeft == 1 ? 'day' : 'days'}',
              value: '= ${m(n.dailyAllowanceCents)}',
              valueColor: c.positive,
            ),
          ],
        ),
        const SoftBanner(
          tone: BannerTone.info,
          icon: Icons.info_outline_rounded,
          child: Text(
            "Spend less today and tomorrow's number goes up. Spend more and it adjusts gently.",
          ),
        ),
      ],
    );
  }
}

// ─── O5 Allow reminders ────────────────────────────────────────────────────

class NotifPermissionScreen extends StatelessWidget {
  const NotifPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;

    void finish({required bool reminders}) {
      store.updateSettings(
        store.settings.copyWith(
          onboarded: true,
          // "Not now": nothing is scheduled until turned on in Settings.
          reminders: reminders ? null : ReminderSettings.off,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
    }

    Future<void> allow() async {
      // The OS asks the user; reminders stay on either way, and the
      // Reminders screen explains how to allow them later if declined.
      await Notifications.instance.requestPermission();
      finish(reminders: true);
    }

    Widget preview(String time, String title, String body) => Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: SteadySpace.s3,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: c.line, offset: const Offset(0, 1))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.hero,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 20,
              color: c.highlight,
            ),
          ),
          const SizedBox(width: SteadySpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Steady',
                        style: SteadyType.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: SteadyType.caption.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: SteadyType.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                Text(
                  body,
                  style: SteadyType.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: c.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final nextBill = store.upcomingBills.firstOrNull;
    return SteadyPage(
      header: Row(
        children: [
          CircleIconButton(
            icon: Icons.chevron_left_rounded,
            label: 'Back',
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: SteadySpace.s3),
          Text(
            'Almost done',
            style: SteadyType.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: c.muted,
            ),
          ),
        ],
      ),
      leading: PageLeading.none,
      gap: 22,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SteadyButton('Allow reminders', onPressed: allow),
          const SizedBox(height: 10),
          SteadyButton(
            'Not now',
            kind: ButtonKind.link,
            height: 48,
            onPressed: () => finish(reminders: false),
          ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              preview(
                '8:30 PM',
                'Anything to log today?',
                'Takes 5 seconds. Keeps your number right.',
              ),
              const SizedBox(height: 10),
              preview(
                '9:00 AM',
                nextBill == null
                    ? 'A bill is due in 2 days'
                    : '${nextBill.name} due in 2 days',
                nextBill == null
                    ? 'Already set aside'
                    : '${formatMoney(nextBill.amountCents, symbol: store.symbol)} · already set aside',
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A nudge keeps manual tracking easy',
              style: SteadyType.title.copyWith(fontSize: 30, height: 1.1),
            ),
            const SizedBox(height: 10),
            Text(
              'Steady can remind you to log, and warn you before bills are due. You pick the times in Settings.',
              style: SteadyType.body.copyWith(color: c.muted, height: 1.5),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline_rounded, size: 18, color: c.positive),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Reminders are scheduled on this phone. Nothing comes from a server, and your data never leaves the device.',
                style: SteadyType.caption.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
