import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../../domain/schedule.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';

/// 05 Paycheck Vault: uneven income in, steady pay out.
class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final symbol = store.symbol;
    final vault = store.vault;
    final steady = vault.steadyPayWeeklyCents;
    final balance = store.vaultBalanceCents;
    final weeks = steady == 0 ? 0 : balance / steady;
    String whole(int cents) =>
        formatMoney(cents, symbol: symbol, showCents: false);
    // Releases happen every Monday after the last one.
    final release = mondayAfter(vault.lastReleaseDate ?? store.today);
    final active = vault.isActive;
    final income = store.weeklyIncomeCents;
    final hasIncome = income.any((w) => w > 0);

    // A first steady pay to start from: the average week of the last 8,
    // rounded down to a whole 10, or the lowest step without history.
    void setUp() {
      final average = income.fold(0, (a, b) => a + b) ~/ income.length;
      store.updateVault(
        vault.copyWith(
          steadyPayWeeklyCents: (average ~/ 1000 * 1000).clamp(30000, 150000),
        ),
      );
      // Show + / − straight away to fine-tune it.
      setState(() => _editing = true);
    }

    void adjust(int delta) => store.updateVault(
      vault.copyWith(
        steadyPayWeeklyCents: (steady + delta).clamp(30000, 150000),
      ),
    );

    return TabBody(
      children: [
        TabTitle(
          'Paycheck Vault',
          subtitle: 'Uneven income in, steady pay out',
          trailing: active
              ? CircleIconButton(
                  icon: Icons.help_outline_rounded,
                  label: 'How the Vault works',
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const SafeArea(
                      top: false,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          SteadySpace.screenMargin,
                          0,
                          SteadySpace.screenMargin,
                          SteadySpace.s6,
                        ),
                        child: VaultExplainer(),
                      ),
                    ),
                  ),
                )
              : null,
        ),
        if (!active) const Panel(child: VaultExplainer()),
        Container(
          padding: const EdgeInsets.all(SteadySpace.s5),
          decoration: BoxDecoration(
            color: c.inverse,
            borderRadius: BorderRadius.circular(SteadyRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your steady pay',
                style: SteadyType.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.onInverseMuted,
                ),
              ),
              const SizedBox(height: 10),
              // One text so "/ week" wraps under the amount with large text.
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: whole(steady),
                      style: SteadyType.amountXl.copyWith(
                        fontSize: 48,
                        color: c.highlight,
                      ),
                    ),
                    TextSpan(
                      text: '  / week',
                      style: SteadyType.body.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: c.onInverseMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                active
                    ? 'Next release to your daily number · ${formatShortDay(release)}'
                    : "Not set yet. Pick what you'd live on in a slow week.",
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.onInverseMuted,
                ),
              ),
            ],
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Income in · last 8 weeks',
                      style: SteadyType.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _DashKey(color: c.ink),
                  const SizedBox(width: 6),
                  Text(
                    'steady pay',
                    style: SteadyType.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (hasIncome)
                _IncomeChart(weeks: income, steady: steady)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: SteadySpace.s4),
                  child: Text(
                    'No income logged in the last 8 weeks. Log pay when it '
                    'arrives and each week shows up here.',
                    style: SteadyType.body.copyWith(color: c.muted),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                'Big weeks fill the vault. Slow weeks are paid from it, so your daily number never swings.',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.muted,
                ),
              ),
            ],
          ),
        ),
        if (active || balance != 0)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Vault balance',
                        style: SteadyType.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      whole(balance),
                      style: SteadyType.heading.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Bar(
                  value: vault.targetCents == 0
                      ? 0
                      : balance / vault.targetCents,
                ),
                const SizedBox(height: 10),
                DefaultTextStyle(
                  style: SteadyType.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: c.muted,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Covers ${weeks.toStringAsFixed(1)} slow weeks',
                        ),
                      ),
                      Text(
                        'Target: ${vault.targetWeeks} weeks · ${whole(vault.targetCents)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (_editing)
          Panel(
            borderColor: c.primary,
            borderWidth: 2,
            padding: const EdgeInsets.symmetric(
              horizontal: SteadySpace.s4,
              vertical: 14,
            ),
            child: Row(
              children: [
                CircleIconButton(
                  icon: Icons.remove_rounded,
                  label: 'Lower steady pay by ${whole(2000)}',
                  onTap: () => adjust(-2000),
                ),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Column(
                      children: [
                        Text(
                          '${whole(steady)} / week',
                          style: SteadyType.heading.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Lower pay = longer buffer',
                          style: SteadyType.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: c.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CircleIconButton(
                  icon: Icons.add_rounded,
                  label: 'Raise steady pay by ${whole(2000)}',
                  background: c.inverse,
                  foreground: c.highlight,
                  bordered: false,
                  onTap: () => adjust(2000),
                ),
              ],
            ),
          ),
        SteadyButton(
          'Log income',
          kind: ButtonKind.highlight,
          onPressed: () => Navigator.of(context).pushNamed(Routes.logIncome),
        ),
        SteadyButton(
          !active
              ? 'Set steady pay'
              : _editing
              ? 'Done'
              : 'Adjust steady pay',
          kind: ButtonKind.secondary,
          onPressed: active
              ? () => setState(() => _editing = !_editing)
              : setUp,
        ),
      ],
    );
  }
}

/// What the Vault is, in three steps. Inline until it's set up; the "?"
/// button shows it after that.
class VaultExplainer extends StatelessWidget {
  const VaultExplainer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget step(int n, String lead, String body) => Padding(
      padding: const EdgeInsets.only(top: SteadySpace.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$n',
              style: SteadyType.caption.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: SteadySpace.s3),
          Expanded(
            child: LeadText(lead: lead, body: body),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('How the Vault works', style: SteadyType.heading),
        Text(
          'For pay that changes week to week: freelance, gig work, commission.',
          style: SteadyType.caption.copyWith(
            fontWeight: FontWeight.w500,
            color: c.muted,
          ),
        ),
        step(
          1,
          'Pay goes in.',
          'When you log income, choose Paycheck Vault. It waits there '
              "instead of landing on today's number all at once.",
        ),
        step(
          2,
          'Steady pay comes out.',
          'Every Monday, your steady pay moves from the Vault into your '
              'daily number, like a regular paycheck.',
        ),
        step(
          3,
          'Big weeks cover slow ones.',
          'A great week tops the Vault up; a slow week is paid from it. '
              'Aim for about 4 weeks of steady pay inside.',
        ),
        const SizedBox(height: SteadySpace.s3),
        Text(
          'No real money moves. Keep it in your bank account as usual; the '
          'Vault is how Steady counts it, so you don\'t spend next month\'s '
          'rent in a good week.',
          style: SteadyType.caption.copyWith(
            fontWeight: FontWeight.w500,
            color: c.muted,
          ),
        ),
      ],
    );
  }
}

class _DashKey extends StatelessWidget {
  const _DashKey({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 16,
    height: 2,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Expanded(child: ColoredBox(color: color)),
        ],
      ],
    ),
  );
}

/// Weekly income bars with a dashed steady-pay line. Weeks above steady pay
/// are Pine (they fill the vault); weeks below are muted.
class _IncomeChart extends StatelessWidget {
  const _IncomeChart({required this.weeks, required this.steady});
  final List<int> weeks;
  final int steady;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const height = 120.0;
    final max = [...weeks, steady, 1].reduce((a, b) => a > b ? a : b) * 1.03;
    return Semantics(
      label: 'Income for the last 8 weeks compared with steady pay',
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < weeks.length; i++) ...[
                  if (i > 0) const SizedBox(width: SteadySpace.s2),
                  Expanded(
                    child: Container(
                      height: (weeks[i] / max * height).clamp(3, height),
                      decoration: BoxDecoration(
                        color: weeks[i] >= steady ? c.primary : c.billPending,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                          bottom: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: steady / max * height,
              child: _DashedLine(color: c.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final n = (box.maxWidth / 8).floor();
      return Row(
        children: [
          for (var i = 0; i < n; i++)
            Container(
              width: 5,
              height: 2,
              margin: const EdgeInsets.only(right: 3),
              color: color,
            ),
        ],
      );
    },
  );
}
