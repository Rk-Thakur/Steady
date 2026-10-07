import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/local_date.dart';
import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../../domain/daily_number.dart';
import '../../domain/models/models.dart';
import '../../domain/number_change.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';
import '../widgets/steady_card.dart';
import '../history/history_screen.dart';
import '../shell/home_shell.dart';
import 'bills_card.dart';
import 'cycle_summary_sheet.dart';
import 'entry_row.dart';
import 'hero_card.dart';
import 'number_change_text.dart';
import 'today_states.dart';

/// 01 Today · Safe to spend (and S4 Overspent today).
class TodayScreen extends StatelessWidget {
  const TodayScreen({
    super.key,
    required this.onLogSpend,
    required this.onOpenBills,
  });

  final VoidCallback onLogSpend;
  final VoidCallback onOpenBills;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    // Edge states replace the normal Today layout (Step 4 · Edge states).
    if (store.isNewUser) return TodayEmptyBody(onLogSpend: onLogSpend);
    if (store.isAwaitingPay) return const PaidPromptBody();
    if (store.showCatchUp) return const TodayCatchUpBody();

    final number = store.dailyNumber;
    final symbol = store.symbol;
    final entries = store.todayEntries;
    final c = context.colors;
    final change = store.numberChange;
    final balances = store.splitBalances;
    final owedToYou = balances.fold(0, (sum, b) => sum + b.owesYou);
    final youOwe = balances.fold(0, (sum, b) => sum + b.youOwe);
    // A cycle just started: show what happened once, when Today is on top
    // (not under the Log income screen that started it).
    final summary = store.cycleSummary;
    if (summary != null &&
        store.cycleSummaryUnseen &&
        (ModalRoute.of(context)?.isCurrent ?? true)) {
      store.markCycleSummarySeen();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        showCycleSummary(
          context,
          summary: summary,
          number: store.dailyNumber,
          symbol: store.symbol,
        );
      });
    }
    void showBreakdown() => _showBreakdown(context, number, change, symbol);

    // S4 Overspent today: just the fix until the user picks an option.
    if (number.isOverspent && store.overspendHandledOn(store.today) == null) {
      return TabBody(
        gap: SteadySpace.sectionGap,
        children: [
          const TodayHeader(),
          HeroCard(
            number: number,
            payday: store.nextPayday,
            symbol: symbol,
            onTap: showBreakdown,
          ),
          _OverspentFix(number: number, symbol: symbol),
        ],
      );
    }

    return TabBody(
      gap: SteadySpace.sectionGap,
      children: [
        const TodayHeader(),
        if (store.newCycleStartedOn != null)
          _NewCycleBanner(
            number: number,
            payday: store.nextPayday,
            symbol: symbol,
          ),
        if (store.saveError != null)
          SoftBanner(
            tone: BannerTone.danger,
            icon: Icons.sync_problem_rounded,
            child: LeadText(
              lead: "Your last change wasn't saved.",
              body: "It's still on screen. Try again in a moment; if it keeps happening, restart Steady.",
              leadColor: c.dangerFg,
            ),
          ),
        if (store.missedDays.isNotEmpty)
          _EstimateBanner(missed: store.missedDays),
        HeroCard(
          number: number,
          payday: store.nextPayday,
          symbol: symbol,
          change: change == null
              ? null
              : NumberChangeText.headline(change, symbol),
          onTap: showBreakdown,
        ),
        if (store.nextVaultRelease case final next?)
          _VaultStrip(
            balanceCents: store.vaultBalanceCents,
            nextDate: next.date,
            nextCents: next.cents,
            symbol: symbol,
          ),
        if (owedToYou > 0 || youOwe > 0)
          _SplitsStrip(
            owedToYouCents: owedToYou,
            youOweCents: youOwe,
            symbol: symbol,
          ),
        if (number.isOverspent) _OverspentFix(number: number, symbol: symbol),
        ButtonRow(
          children: [
            SteadyButton(
              'Can I afford it?',
              kind: ButtonKind.highlight,
              onPressed: () => Navigator.of(context).pushNamed(Routes.afford),
            ),
            SteadyButton(
              'Log spend',
              kind: ButtonKind.secondary,
              onPressed: onLogSpend,
            ),
          ],
        ),
        BillsCard(
          bills: store.billsThisCycle,
          reservedCents: store.reservedBillsCents,
          needsReviewCount: store.billsNeedingReview,
          symbol: symbol,
          afterPayday: store.billsRightAfterNextPayday,
          payday: store.nextPayday,
          onSeeAll: onOpenBills,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'Today',
              actionLabel: 'History',
              onAction: () => Navigator.of(context).pushNamed(Routes.history),
            ),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SteadySpace.s3),
                child: Text(
                  'Nothing logged today. Tap + when you spend.',
                  style: SteadyType.body.copyWith(color: c.muted),
                ),
              )
            else
              for (final e in entries)
                SwipeToDelete(
                  entry: e,
                  aboveTabBar: true,
                  child: InkWell(
                    onTap: () =>
                        Navigator.of(context)
                            .pushNamed(Routes.editEntry, arguments: e.id),
                    child: EntryRow(
                      entry: e,
                      category: store.categoryById(e.categoryId),
                      symbol: symbol,
                    ),
                  ),
                ),
          ],
        ),
      ],
    );
  }

  void _showBreakdown(
    BuildContext context,
    DailyNumber n,
    NumberChange? change,
    String symbol,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _BreakdownSheet(number: n, change: change, symbol: symbol),
    );
  }
}

/// Date, greeting, Notifications and Profile buttons. Shared by every
/// Today state.
class TodayHeader extends StatelessWidget {
  const TodayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final name = store.settings.displayName?.trim();
    final hasName = name != null && name.isNotEmpty;
    final greeting = greetingFor(DateTime.now());
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDayHeader(store.today),
                style: SteadyType.caption.copyWith(color: c.muted),
              ),
              Text(
                hasName ? '$greeting, $name' : 'Good ${greeting.toLowerCase()}',
                style: SteadyType.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _CircleButton(
          label: 'Notifications',
          background: c.surface,
          border: c.line,
          onTap: () => Navigator.of(context).pushNamed(Routes.notifications),
          child: Icon(Icons.notifications_none_rounded, size: 20, color: c.ink),
        ),
        const SizedBox(width: SteadySpace.s2),
        _CircleButton(
          label: 'Profile and settings',
          background: c.hero,
          onTap: () => Navigator.of(context).pushNamed(Routes.settings),
          child: hasName
              ? Text(
                  name.characters.first.toUpperCase(),
                  style: SteadyType.heading.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: c.onHero,
                  ),
                )
              : Icon(Icons.person_outline_rounded, size: 20, color: c.onHero),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.label,
    required this.background,
    required this.onTap,
    required this.child,
    this.border,
  });

  final String label;
  final Color background;
  final Color? border;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: CircleBorder(
          side: border != null ? BorderSide(color: border!) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: SteadySize.iconButton,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// S4: "No panic. Here's the fix." with tomorrow's re-spread number.
class _OverspentFix extends StatelessWidget {
  const _OverspentFix({required this.number, required this.symbol});

  final DailyNumber number;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    String m(int cents) => formatMoney(cents, symbol: symbol);
    final handled = store.overspendHandledOn(store.today);
    final over = m(
      handled?.takesFromCategory == true
          ? handled!.amountCents
          : number.overspentByCents,
    );
    // Before a choice: what spreading would do. After: what actually happens.
    final tomorrow = handled == null
        ? DailyNumberCalculator.tomorrow(number)
        : store.tomorrowNumber;
    final spreadDays = tomorrow.daysLeft;
    final source = handled == null
        ? store.overspendCoverFor(number.overspentByCents)
        : handled.takesFromCategory
        ? store.categoryById(handled.categoryId)
        : null;
    final sourceLeft = source == null ? null : store.leftThisMonth(source);

    final card = Container(
      padding: const EdgeInsets.all(SteadySpace.s4),
      decoration: BoxDecoration(
        color: c.primarySoft,
        borderRadius: BorderRadius.circular(SteadyRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            handled == null ? "No panic. Here's the fix." : 'Sorted.',
            style: SteadyType.body.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: SteadySpace.s2),
          Text.rich(
            TextSpan(
              style: SteadyType.body.copyWith(fontSize: 14, height: 1.5),
              children: [
                TextSpan(
                  text: handled?.takesFromCategory == true
                      ? "$over came out of what's left of ${source?.name ?? 'that category'} "
                            "this month${sourceLeft == null ? '' : ' (${m(sourceLeft)} left)'}. "
                            "Tomorrow's number: "
                      : "We'll spread $over over the next $spreadDays "
                            "${spreadDays == 1 ? 'day' : 'days'}. Tomorrow's number: ",
                ),
                TextSpan(
                  text: m(tomorrow.safeToSpendCents),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '. Bills and goals are untouched.'),
              ],
            ),
          ),
          if (handled?.takesFromCategory == true) ...[
            const SizedBox(height: SteadySpace.s2),
            Text(
              'Spend less on ${source?.name.toLowerCase() ?? 'it'} to make up '
              "for it. If that spending goes past what's left, the rest is "
              'spread over your remaining days.',
              style: SteadyType.caption.copyWith(color: c.muted),
            ),
          ],
        ],
      ),
    );

    if (handled != null) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card,
        const SizedBox(height: SteadySpace.sectionGap),
        SteadyButton(
          'Spread it out (recommended)',
          onPressed: () =>
              store.handleOverspend(OverspendStrategy.spreadEvenly),
        ),
        if (source != null) ...[
          const SizedBox(height: 10),
          SteadyButton(
            'Cover it from ${source.name} instead',
            kind: ButtonKind.secondary,
            onPressed: () => store.handleOverspend(
              OverspendStrategy.takeFromCategory,
              categoryId: source.id,
              overCents: number.overspentByCents,
            ),
          ),
          if (sourceLeft != null) ...[
            const SizedBox(height: SteadySpace.s2),
            Text(
              '${source.name} has ${m(sourceLeft)} left of its monthly limit. '
              'Covering $over from it keeps tomorrow at '
              '${m(DailyNumberCalculator.tomorrow(number, newCoverCents: number.overspentByCents).safeToSpendCents)} '
              '(instead of ${m(tomorrow.safeToSpendCents)}), and leaves '
              '${m(sourceLeft - number.overspentByCents)} for '
              '${source.name.toLowerCase()} this month.',
              style: SteadyType.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: c.muted,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Tap the hero: how today's number was worked out.
class _BreakdownSheet extends StatelessWidget {
  const _BreakdownSheet({
    required this.number,
    required this.change,
    required this.symbol,
  });

  final DailyNumber number;
  final NumberChange? change;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i = number.input;
    String m(int cents) => formatMoney(cents, symbol: symbol);
    String signed(int cents) => cents > 0 ? '+${m(cents)}' : m(cents);
    final change = this.change;
    final changed = change != null && !change.isUnchanged;

    Widget row(String label, String value, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: SteadyType.body.copyWith(color: strong ? c.ink : c.muted),
            ),
          ),
          Text(
            value,
            style: SteadyType.body.copyWith(
              fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SteadySpace.screenMargin,
            0,
            SteadySpace.screenMargin,
            SteadySpace.s6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('How today\'s number works', style: SteadyType.title),
              if (changed) ...[
                const SizedBox(height: SteadySpace.s3),
                Text(
                  'Since yesterday',
                  style: SteadyType.overline.copyWith(color: c.muted),
                ),
                row("Yesterday's number", m(change.yesterdayCents)),
                for (final (label, cents) in NumberChangeText.parts(
                  change,
                  number.daysLeft,
                ))
                  row(label, signed(cents)),
                row(
                  "Today's number",
                  m(number.dailyAllowanceCents),
                  strong: true,
                ),
                Text(
                  'Money you don\'t spend stays in the pot and is shared over '
                  'the days left, so each day after gets a little more. '
                  'Spending more works the same way, the other direction.',
                  style: SteadyType.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: c.muted,
                  ),
                ),
                const SizedBox(height: SteadySpace.s4),
                Text(
                  'Worked out',
                  style: SteadyType.overline.copyWith(color: c.muted),
                ),
              ] else
                const SizedBox(height: SteadySpace.s3),
              row('Money at the start of today', m(i.moneyAtStartOfDayCents)),
              if (i.incomeTodayCents > 0)
                row('Income logged today', '+${m(i.incomeTodayCents)}'),
              if (i.coveredCents > 0)
                row(
                  'Overspends your categories are covering',
                  '+${m(i.coveredCents)}',
                ),
              if (i.billPaymentsTodayCents > 0)
                row('Bills paid today', m(-i.billPaymentsTodayCents)),
              row(
                'Bills due before payday',
                m(-i.unpaidBillsBeforePaydayCents),
              ),
              row('Set aside for goals', m(-i.goalSetAsidesCents)),
              const Divider(),
              row('Left until payday', m(number.poolCents), strong: true),
              row('Days left, including today', '÷ ${number.daysLeft}'),
              const Divider(),
              row(
                'Today\'s allowance',
                m(number.dailyAllowanceCents),
                strong: true,
              ),
              row('Spent today', m(-number.spentTodayCents)),
              const Divider(),
              row(
                'Safe to spend today',
                m(number.safeToSpendCents),
                strong: true,
              ),
              const SizedBox(height: SteadySpace.s2),
              Text(
                'Rounded down to the cent, so it never overstates what is safe. '
                'Recalculated at midnight and after every entry.',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown on the day a new pay cycle starts (pay logged, "It won't come", or
/// an automatic cycle for pay that varies).
class _NewCycleBanner extends StatelessWidget {
  const _NewCycleBanner({
    required this.number,
    required this.payday,
    required this.symbol,
  });
  final DailyNumber number;
  final LocalDate payday;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return SoftBanner(
      icon: Icons.autorenew_rounded,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LeadText(
                  lead: 'New pay cycle.',
                  body:
                      '${formatMoney(number.dailyAllowanceCents, symbol: symbol)} a day until '
                      '${formatShortDay(payday)}. Bills and goals are set aside again.',
                ),
                if (store.cycleSummary case final summary?)
                  LinkText(
                    'See what carried over',
                    onTap: () => showCycleSummary(
                      context,
                      summary: summary,
                      number: number,
                      symbol: symbol,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Dismiss',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: store.dismissNewCycle,
          ),
        ],
      ),
    );
  }
}

/// For Vault users: what's in the Vault and the next Monday release, next
/// to the number it feeds. Opens the Vault.
class _VaultStrip extends StatelessWidget {
  const _VaultStrip({
    required this.balanceCents,
    required this.nextDate,
    required this.nextCents,
    required this.symbol,
  });
  final int balanceCents;
  final LocalDate nextDate;
  final int nextCents;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    String whole(int cents) =>
        formatMoney(cents, symbol: symbol, showCents: false);
    return _TodayStrip(
      icon: Icons.savings_outlined,
      lead: 'Vault ${whole(balanceCents)}',
      body: nextCents > 0
          ? ' · ${whole(nextCents)} joins your number '
                '${formatShortDay(nextDate)}'
          : ' · empty, nothing to release ${formatShortDay(nextDate)}',
      onTap: () => goToTab(context, ShellTab.vault),
    );
  }
}

/// Split expenses, next to the number: money owed back isn't in it yet,
/// and money you owe hasn't come out of it yet. Opens Split expenses.
class _SplitsStrip extends StatelessWidget {
  const _SplitsStrip({
    required this.owedToYouCents,
    required this.youOweCents,
    required this.symbol,
  });
  final int owedToYouCents;
  final int youOweCents;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    String m(int cents) => formatMoney(cents, symbol: symbol);
    final both = owedToYouCents > 0 && youOweCents > 0;
    return _TodayStrip(
      icon: Icons.people_outline_rounded,
      lead: [
        if (owedToYouCents > 0) '${m(owedToYouCents)} owed back to you',
        if (youOweCents > 0) '${both ? 'you' : 'You'} owe ${m(youOweCents)}',
      ].join(' · '),
      body: both
          ? '. Each counts in your number once it changes hands.'
          : owedToYouCents > 0
          ? ". Not in your number yet; it's added when they pay you back."
          : '. It comes off your number when you pay.',
      onTap: () => Navigator.of(context).pushNamed(Routes.splits),
    );
  }
}

/// A one-line, tappable note under the hero.
class _TodayStrip extends StatelessWidget {
  const _TodayStrip({
    required this.icon,
    required this.lead,
    required this.body,
    required this.onTap,
  });
  final IconData icon;
  final String lead;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: c.line),
        borderRadius: BorderRadius.circular(SteadyRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: SteadySize.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: SteadySpace.s4,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: c.mutedStrong),
              const SizedBox(width: SteadySpace.s3),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: lead,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: body,
                        style: TextStyle(color: c.muted),
                      ),
                    ],
                  ),
                  style: SteadyType.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: c.ink,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: c.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Days with nothing logged make today's number a guess. One day: answer it
/// here. More: back to catch-up (after "Not now").
class _EstimateBanner extends StatelessWidget {
  const _EstimateBanner({required this.missed});
  final List<LocalDate> missed;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final one = missed.length == 1;
    final day = one ? formatShortDay(missed.single).substring(0, 3) : '';
    return SoftBanner(
      tone: BannerTone.warning,
      icon: Icons.edit_note_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LeadText(
            lead: 'Your number is an estimate.',
            body: one
                ? 'Nothing is logged for $day, so it assumes you spent '
                      'nothing then.'
                : 'Nothing is logged for ${missed.length} days, so it '
                      'assumes you spent nothing then.',
            leadColor: c.warningFg,
          ),
          Wrap(
            spacing: SteadySpace.s4,
            children: one
                ? [
                    LinkText(
                      'Add a spend',
                      onTap: () => Navigator.of(context).pushNamed(
                        Routes.logSpend,
                        arguments: LogSpendArgs(date: missed.single),
                      ),
                    ),
                    LinkText('I spent nothing', onTap: store.markCaughtUp),
                  ]
                : [LinkText('Catch up', onTap: store.resumeCatchUp)],
          ),
        ],
      ),
    );
  }
}
