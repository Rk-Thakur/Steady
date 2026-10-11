import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/date_format.dart';
import '../../core/local_date.dart';
import '../../core/money.dart';
import '../../domain/daily_number.dart';
import '../../theme/tokens.dart';

/// "Safe to spend today" hero. Pine card normally; white card with an Alert
/// border, label and icon when overspent (S4), so state never relies on hue.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.number,
    required this.payday,
    required this.symbol,
    this.change,
    this.onTap,
  });

  final DailyNumber number;
  final LocalDate payday;
  final String symbol;

  /// Since yesterday; shown as "Up $4.25 from yesterday: you spent less".
  final String? change;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final over = number.isOverspent;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final fg = over ? c.ink : c.onHero;
    final fgMuted = over ? c.muted : c.onHeroMuted;
    final amountColor = over ? c.dangerFg : c.onHero;
    String money(int cents) => formatMoney(cents, symbol: symbol);

    final spentLine = over
        ? 'Spent ${money(number.spentTodayCents)} of ${money(number.dailyAllowanceCents)} today'
        : 'Spent ${money(number.spentTodayCents)} of ${money(number.dailyAllowanceCents)}';

    final card = Semantics(
      button: onTap != null,
      label:
          'Safe to spend today, ${money(number.safeToSpendCents)}. '
          '${over ? 'Over by ${money(number.overspentByCents)}.' : 'On track.'} '
          '${change != null && !over ? '$change. ' : ''}'
          '$spentLine. Payday ${formatShortDate(payday)}.',
      hint: onTap != null ? 'Shows how the number is worked out' : null,
      excludeSemantics: true,
      child: Material(
        color: over ? c.surface : c.hero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SteadyRadius.xl),
          side: over
              ? BorderSide(color: c.dangerFg, width: 2)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        // A soft diagonal gradient (deeper toward the corner); white text
        // keeps its contrast. In dark mode a faint top edge lifts it off
        // the background.
        child: Ink(
          decoration: over
              ? null
              : BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c.hero, Color.lerp(c.hero, Colors.black, .22)!],
                  ),
                  border: Theme.of(context).brightness == Brightness.dark
                      ? Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: .10),
                          ),
                        )
                      : null,
                ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(SteadySpace.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Safe to spend today',
                                style: SteadyType.body.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: fg,
                                ),
                              ),
                            ),
                            // Tapping the card explains the number; this says so.
                            if (onTap != null) ...[
                              const SizedBox(width: SteadySpace.s1),
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: fgMuted,
                              ),
                            ],
                          ],
                        ),
                      ),
                      over
                          ? _StatusPill(
                              label:
                                  'Over by ${money(number.overspentByCents)}',
                              background: c.dangerBg,
                              foreground: c.dangerFg,
                              icon: Icons.priority_high_rounded,
                            )
                          : _StatusPill(
                              label: 'On track',
                              background: c.highlight,
                              foreground: c.onHighlight,
                            ),
                    ],
                  ),
                  const SizedBox(height: SteadySpace.s3),
                  _AnimatedAmount(
                    cents: number.safeToSpendCents,
                    symbol: symbol,
                    color: amountColor,
                    duration: reduceMotion
                        ? SteadyMotion.reduced
                        : SteadyMotion.heroNumber,
                  ),
                  if (!over) ...[
                    const SizedBox(height: SteadySpace.s3),
                    Text(
                      'Bills, savings & goals already set aside',
                      style: SteadyType.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: fgMuted,
                      ),
                    ),
                    if (change case final change?) ...[
                      const SizedBox(height: SteadySpace.s1),
                      Text(
                        change,
                        style: SteadyType.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: SteadySpace.s3),
                  _ProgressBar(
                    value: number.spentFraction,
                    track: over ? c.dangerBg : c.heroTrack,
                    fill: over ? c.dangerFg : c.highlight,
                    duration: reduceMotion
                        ? SteadyMotion.reduced
                        : SteadyMotion.progress,
                  ),
                  const SizedBox(height: SteadySpace.s3),
                  DefaultTextStyle(
                    style: SteadyType.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: fgMuted,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(spentLine)),
                        if (!over) Text('Payday ${formatShortDate(payday)}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return HeroReaction(
      cents: number.safeToSpendCents,
      over: over,
      child: card,
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SteadyRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: SteadySpace.s1),
          ],
          Text(
            label,
            style: SteadyType.overline.copyWith(
              letterSpacing: 0,
              fontWeight: icon != null ? FontWeight.w800 : FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Counts from the previous value to the new one (400 ms ease-out).
/// Shrinks to fit rather than wrapping mid-number.
class _AnimatedAmount extends StatelessWidget {
  const _AnimatedAmount({
    required this.cents,
    required this.symbol,
    required this.color,
    required this.duration,
  });

  final int cents;
  final String symbol;
  final Color color;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width <= 360;
    final size = narrow ? 48.0 : 56.0;
    final style = SteadyType.amountXl.copyWith(
      color: color,
      fontSize: size,
      fontVariations: SteadyFonts.opticalSize(size),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(end: cents.toDouble()),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, _) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          formatMoney(value.round(), symbol: symbol),
          style: style,
          maxLines: 1,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.value,
    required this.track,
    required this.fill,
    required this.duration,
  });

  final double value;
  final Color track;
  final Color fill;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(SteadyRadius.pill),
      child: SizedBox(
        height: 8,
        child: ColoredBox(
          color: track,
          child: TweenAnimationBuilder<double>(
            // Fills from empty on open, then animates each spend.
            tween: Tween(begin: 0, end: value),
            duration: duration,
            curve: SteadyMotion.progressCurve,
            builder: (context, v, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: v,
              child: ColoredBox(color: fill),
            ),
          ),
        ),
      ),
    );
  }
}

/// The hero reacting to its number: a gentle pulse and glow when it goes up
/// (income logged, a spend deleted), and a short shake with a firm tap when
/// it tips into overspent. With "reduce motion" on, it just updates.
class HeroReaction extends StatefulWidget {
  const HeroReaction({
    super.key,
    required this.cents,
    required this.over,
    required this.child,
  });

  final int cents;
  final bool over;
  final Widget child;

  @override
  State<HeroReaction> createState() => _HeroReactionState();
}

class _HeroReactionState extends State<HeroReaction>
    with TickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );

  @override
  void didUpdateWidget(HeroReaction old) {
    super.didUpdateWidget(old);
    if (MediaQuery.disableAnimationsOf(context)) return;
    if (widget.over && !old.over) {
      HapticFeedback.mediumImpact();
      _shake.forward(from: 0);
    } else if (widget.cents > old.cents && !widget.over) {
      _pulse.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedBuilder(
      animation: Listenable.merge([_pulse, _shake]),
      child: widget.child,
      builder: (context, child) {
        // Up and back: 0 → 1 → 0 over the pulse.
        final p = math.sin(_pulse.value * math.pi);
        // A few side-to-side swings that die away.
        final t = _shake.value;
        final dx = _shake.isAnimating
            ? math.sin(t * math.pi * 6) * 8 * (1 - t)
            : 0.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(
            scale: 1 + .025 * p,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SteadyRadius.xl),
                boxShadow: p == 0
                    ? null
                    : [
                        BoxShadow(
                          color: c.highlight.withValues(alpha: .45 * p),
                          blurRadius: 28 * p,
                          spreadRadius: 2 * p,
                        ),
                      ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
