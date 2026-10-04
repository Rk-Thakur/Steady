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

/// Demo income for the last 8 weeks, in cents, until weekly history is
/// computed from entries.
const _demoWeeklyIncome = [
  26000,
  78000,
  37000,
  2000,
  94000,
  42000,
  53000,
  57000,
];

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

    void adjust(int delta) => store.updateVault(
      vault.copyWith(
        steadyPayWeeklyCents: (steady + delta).clamp(30000, 150000),
      ),
    );

    return TabBody(
      children: [
        const TabTitle(
          'Paycheck Vault',
          subtitle: 'Uneven income in, steady pay out',
        ),
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
                    : 'Not set yet. Pick a weekly amount you can count on.',
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
              _IncomeChart(weeks: _demoWeeklyIncome, steady: steady),
              const SizedBox(height: 10),
              Text(
                'Big weeks fill the vault. Slow weeks are paid from it, so your daily number never swings. '
                'It is a reserve inside Steady; no real money moves.',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.muted,
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
                value: vault.targetCents == 0 ? 0 : balance / vault.targetCents,
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
        if (_editing || !active)
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
              : () => adjust(30000),
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
    final max = [...weeks, steady].reduce((a, b) => a > b ? a : b) * 1.03;
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
