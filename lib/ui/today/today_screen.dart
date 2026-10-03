import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../../domain/daily_number.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';
import '../widgets/steady_card.dart';
import '../history/history_screen.dart';
import 'bills_card.dart';
import 'entry_row.dart';
import 'hero_card.dart';
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
    if (store.today.isAfter(store.nextPayday)) return const PaidPromptBody();
    if (store.missedDays.length >= 2) return const TodayCatchUpBody();

    final number = store.dailyNumber;
    final symbol = store.symbol;
    final entries = store.todayEntries;
    final c = context.colors;
    void showBreakdown() => _showBreakdown(context, number, symbol);

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
        HeroCard(
          number: number,
          payday: store.nextPayday,
          symbol: symbol,
          onTap: () => _showBreakdown(context, number, symbol),
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

  void _showBreakdown(BuildContext context, DailyNumber n, String symbol) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _BreakdownSheet(number: n, symbol: symbol),
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
    final tomorrow = DailyNumberCalculator.tomorrow(number);
    final spreadDays = tomorrow.daysLeft;
    final over = formatMoney(number.overspentByCents, symbol: symbol);
    final handled = store.overspendHandledOn(store.today);
    // The category with the most limit left covers it (design: Fun money).
    final source = store.categories
        .where((c) => (c.monthlyLimitCents ?? 0) >= number.overspentByCents)
        .fold<BudgetCategory?>(
          null,
          (best, c) =>
              best == null ||
                  c.id == 'fun' ||
                  (best.id != 'fun' &&
                      c.monthlyLimitCents! > best.monthlyLimitCents!)
              ? c
              : best,
        );

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
                  text: switch (handled) {
                    OverspendStrategy.takeFromCategory =>
                      '$over came out of this month\'s ${source?.name ?? 'category'} limit. Tomorrow\'s number: ',
                    _ =>
                      "We'll spread $over over the next $spreadDays ${spreadDays == 1 ? 'day' : 'days'}. Tomorrow's number: ",
                  },
                ),
                TextSpan(
                  text: formatMoney(tomorrow.safeToSpendCents, symbol: symbol),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '. Bills and goals are untouched.'),
              ],
            ),
          ),
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
            'Take it from ${source.name} money instead',
            kind: ButtonKind.secondary,
            onPressed: () => store.handleOverspend(
              OverspendStrategy.takeFromCategory,
              categoryId: source.id,
              overCents: number.overspentByCents,
            ),
          ),
        ],
      ],
    );
  }
}

/// Tap the hero: how today's number was worked out.
class _BreakdownSheet extends StatelessWidget {
  const _BreakdownSheet({required this.number, required this.symbol});

  final DailyNumber number;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i = number.input;
    String m(int cents) => formatMoney(cents, symbol: symbol);

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
              const SizedBox(height: SteadySpace.s3),
              row('Money at the start of today', m(i.moneyAtStartOfDayCents)),
              if (i.incomeTodayCents > 0)
                row('Income logged today', '+${m(i.incomeTodayCents)}'),
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
