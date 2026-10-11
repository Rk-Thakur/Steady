import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/date_format.dart';
import '../../core/local_date.dart';
import '../../core/money.dart';
import '../../data/budget_store.dart';
import '../../data/store_scope.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';
import 'today_screen.dart';

// ─── S1 Empty · new manual user ────────────────────────────────────────────

class TodayEmptyBody extends StatelessWidget {
  const TodayEmptyBody({super.key, this.onLogSpend});
  final VoidCallback? onLogSpend;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final n = store.dailyNumber;
    return TabBody(
      gap: SteadySpace.sectionGap,
      children: [
        const TodayHeader(),
        Container(
          padding: const EdgeInsets.all(SteadySpace.s5),
          decoration: BoxDecoration(
            color: c.hero,
            borderRadius: BorderRadius.circular(SteadyRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Safe to spend today',
                style: SteadyType.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.onHero,
                ),
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatMoney(n.safeToSpendCents, symbol: store.symbol),
                  style: SteadyType.amountXl.copyWith(color: c.onHero),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Nothing spent yet today · Payday ${formatShortDate(store.nextPayday)}',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.onHeroMuted,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SteadySpace.s5,
            vertical: SteadySpace.s6,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.dashed, width: 1.5),
            borderRadius: BorderRadius.circular(SteadyRadius.xl),
          ),
          child: Column(
            children: [
              const IconTile(
                icon: Icons.edit_note_rounded,
                tone: BannerTone.primary,
                size: 64,
                radius: 20,
              ),
              const SizedBox(height: SteadySpace.s3),
              Text(
                'Log your first spend',
                style: SteadyType.heading.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: SteadySpace.s3),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 270),
                child: Text(
                  'Add purchases as you go. It takes about 5 seconds, and your daily number updates right away.',
                  textAlign: TextAlign.center,
                  style: SteadyType.body.copyWith(
                    fontSize: 14,
                    height: 1.5,
                    color: c.muted,
                  ),
                ),
              ),
              const SizedBox(height: SteadySpace.s3),
              SteadyButton(
                'Log a spend',
                kind: ButtonKind.inverse,
                height: 48,
                expand: false,
                onPressed:
                    onLogSpend ??
                    () => Navigator.of(context).pushNamed(Routes.logSpend),
              ),
            ],
          ),
        ),
        Panel(
          onTap: () => Navigator.of(context).pushNamed(Routes.billEdit),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add your bills',
                      style: SteadyType.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'So we can set them aside before payday',
                      style: SteadyType.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Add',
                style: SteadyType.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── S2 Loading skeleton ───────────────────────────────────────────────────

class TodayLoadingBody extends StatelessWidget {
  const TodayLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget row(double a, double b) => Row(
      children: [
        const Skeleton(width: 40, height: 40, radius: 12),
        const SizedBox(width: SteadySpace.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(
                widthFactor: a,
                child: const Skeleton(height: 13),
              ),
              const SizedBox(height: 6),
              FractionallySizedBox(
                widthFactor: b,
                child: const Skeleton(height: 11),
              ),
            ],
          ),
        ),
      ],
    );

    return Semantics(
      label: 'Loading your budget',
      child: TabBody(
        gap: SteadySpace.sectionGap,
        children: [
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 90, height: 12),
                    SizedBox(height: 8),
                    Skeleton(width: 190, height: 24),
                  ],
                ),
              ),
              Skeleton(width: 44, height: 44, radius: 99),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(SteadySpace.s5),
            decoration: BoxDecoration(
              color: c.hero,
              borderRadius: BorderRadius.circular(SteadyRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(
                  width: 140,
                  height: 14,
                  radius: 6,
                  color: c.heroSkeleton,
                ),
                const SizedBox(height: 14),
                Skeleton(
                  width: 180,
                  height: 52,
                  radius: 10,
                  color: c.heroSkeleton,
                ),
                const SizedBox(height: 14),
                Skeleton(height: 8, radius: 99, color: c.heroSkeleton),
                const SizedBox(height: 14),
                FractionallySizedBox(
                  widthFactor: .7,
                  child: Skeleton(height: 12, radius: 6, color: c.heroSkeleton),
                ),
              ],
            ),
          ),
          const Row(
            children: [
              Expanded(child: Skeleton(height: 52, radius: 99)),
              SizedBox(width: 10),
              Expanded(child: Skeleton(height: 52, radius: 99)),
            ],
          ),
          const Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 150, height: 16),
                SizedBox(height: 10),
                Skeleton(height: 34, radius: 6),
                SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: .8,
                  child: Skeleton(height: 12),
                ),
              ],
            ),
          ),
          row(.6, .4),
          row(.5, .35),
        ],
      ),
    );
  }
}

// ─── S3 Catch-up reminder ──────────────────────────────────────────────────

class TodayCatchUpBody extends StatefulWidget {
  const TodayCatchUpBody({super.key, this.demoMissed});

  /// Gallery preview: show these missed days even if the store has none.
  final List<LocalDate>? demoMissed;

  @override
  State<TodayCatchUpBody> createState() => _TodayCatchUpBodyState();
}

class _TodayCatchUpBodyState extends State<TodayCatchUpBody> {
  /// Days confirmed as "no spends" on this screen, until all are done.
  final _nothing = <LocalDate>{};

  /// "Nothing" for [day]. Once every missed day is answered, catch-up is
  /// saved as done and Today goes back to normal.
  void _noSpends(BudgetStore store, LocalDate day, List<LocalDate> missed) {
    setState(() => _nothing.add(day));
    if (widget.demoMissed != null || !missed.every(_nothing.contains)) return;
    HapticFeedback.mediumImpact();
    store.markCaughtUp();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text('All caught up. Your number is exact again.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final missed = widget.demoMissed ?? store.missedDays;
    final open = missed.where((d) => !_nothing.contains(d)).toList();
    final weekdays = missed
        .map((d) => formatShortDay(d).substring(0, 3))
        .join(' and ');
    final estimate = formatMoney(
      store.dailyNumber.dailyAllowanceCents,
      symbol: store.symbol,
      showCents: false,
    );

    return TabBody(
      gap: SteadySpace.sectionGap,
      children: [
        const TodayHeader(),
        if (open.isNotEmpty)
          SoftBanner(
            tone: BannerTone.warning,
            icon: Icons.edit_note_rounded,
            radius: 18,
            child: LeadText(
              lead: 'Nothing logged for ${missed.length} days.',
              body: 'Catch up in under a minute so your number stays right.',
              leadColor: c.warningFg,
            ),
          ),
        Container(
          padding: const EdgeInsets.all(SteadySpace.s5),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.dashed, width: 2),
            borderRadius: BorderRadius.circular(SteadyRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Safe to spend today',
                      style: SteadyType.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (open.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: c.segmentTrack,
                        borderRadius: BorderRadius.circular(SteadyRadius.pill),
                      ),
                      child: Text(
                        'Estimate',
                        style: SteadyType.overline.copyWith(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700,
                          color: c.mutedStrong,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                open.isEmpty ? estimate : '~$estimate',
                style: SteadyType.amountXl.copyWith(
                  color: open.isEmpty ? c.ink : c.muted,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                open.isEmpty
                    ? 'All caught up. Your number is firm again.'
                    : 'A best guess: it assumes you spent nothing on '
                          '$weekdays. If you did spend, your real number is '
                          'lower. Catch up to make it exact.',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.muted,
                ),
              ),
            ],
          ),
        ),
        GroupedList(
          padding: const EdgeInsets.symmetric(horizontal: SteadySpace.s4),
          children: [
            for (final d in missed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatDayHeader(d),
                            style: SteadyType.body.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          Text(
                            'No spends logged',
                            style: SteadyType.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              color: c.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_nothing.contains(d))
                      Text(
                        'No spends ✓',
                        style: SteadyType.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.positive,
                        ),
                      )
                    else ...[
                      SteadyButton(
                        'Add',
                        kind: ButtonKind.inverse,
                        height: 40,
                        expand: false,
                        onPressed: () => Navigator.of(context).pushNamed(
                          Routes.logSpend,
                          arguments: LogSpendArgs(date: d),
                        ),
                      ),
                      const SizedBox(width: SteadySpace.s2),
                      SteadyButton(
                        'Nothing',
                        kind: ButtonKind.secondary,
                        height: 40,
                        expand: false,
                        onPressed: () => _noSpends(store, d, missed),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
        if (open.isNotEmpty && widget.demoMissed == null)
          Center(
            child: LinkText('Not now, show my day', onTap: store.snoozeCatchUp),
          ),
      ],
    );
  }
}

// ─── V2 Did you get paid? ──────────────────────────────────────────────────

class PaidPromptBody extends StatefulWidget {
  const PaidPromptBody({super.key});

  @override
  State<PaidPromptBody> createState() => _PaidPromptBodyState();
}

class _PaidPromptBodyState extends State<PaidPromptBody> {
  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final safe = formatMoney(
      store.dailyNumber.safeToSpendCents,
      symbol: store.symbol,
    );

    final today = store.today;
    final payLine = today == store.nextPayday
        ? 'Payday is today.'
        : 'Payday was ${formatShortDay(store.nextPayday)}.';
    final lastPay = store.history
        .where((e) => e.isIncome && !e.toVault && !e.fromVault)
        .firstOrNull;
    final usual = lastPay == null
        ? ''
        : ' You usually get about ${formatMoney(lastPay.amountCents, symbol: store.symbol, showCents: false)}.';
    return TabBody(
      gap: SteadySpace.sectionGap,
      children: [
        const TodayHeader(),
        Panel(
          radius: SteadyRadius.xl,
          borderColor: c.primary,
          borderWidth: 2,
          padding: const EdgeInsets.all(SteadySpace.s5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'EXPECTED THIS WEEK',
                style: SteadyType.overline.copyWith(
                  fontSize: 13,
                  letterSpacing: 1,
                  color: c.positive,
                ),
              ),
              const SizedBox(height: SteadySpace.s3),
              Text(
                'Did your payment arrive?',
                style: SteadyType.title.copyWith(height: 1.15),
              ),
              const SizedBox(height: SteadySpace.s3),
              Text(
                '$payLine$usual',
                style: SteadyType.body.copyWith(fontSize: 14, color: c.muted),
              ),
              const SizedBox(height: SteadySpace.s3),
              ...[
                SteadyButton(
                  'Yes, log it',
                  onPressed: () =>
                      Navigator.of(context).pushNamed(Routes.logIncome),
                ),
                const SizedBox(height: SteadySpace.s2),
                ButtonRow(
                  children: [
                    SteadyButton(
                      'Not yet',
                      kind: ButtonKind.secondary,
                      height: 48,
                      onPressed: () {
                        store.snoozePayPrompt();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Okay. We'll ask again tomorrow. Your number stays the same.",
                            ),
                          ),
                        );
                      },
                    ),
                    SteadyButton(
                      "It won't come",
                      kind: ButtonKind.secondary,
                      height: 48,
                      onPressed: store.payWontCome,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SteadySpace.s5,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: c.hero,
            borderRadius: BorderRadius.circular(SteadyRadius.xl),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safe to spend today',
                      style: SteadyType.caption.copyWith(color: c.onHeroMuted),
                    ),
                    Text(
                      safe,
                      style: SteadyType.amountXl.copyWith(
                        fontSize: 36,
                        letterSpacing: -1,
                        color: c.onHero,
                      ),
                    ),
                  ],
                ),
              ),
              SteadyButton(
                'Log income',
                kind: ButtonKind.highlight,
                height: 44,
                expand: false,
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.logIncome),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
