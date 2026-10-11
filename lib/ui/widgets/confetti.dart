import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/tokens.dart';

/// A one-off confetti burst over the whole screen: pieces in Steady's
/// colours shoot up from below, tumble and fall, then fade (about 1.6 s).
/// It removes itself when done and never blocks taps. With "reduce motion"
/// on, nothing is shown.
///
/// [big] for a goal reached; smaller for a milestone (25%, 50%, 75%).
void showConfetti(BuildContext context, {bool big = false}) {
  if (MediaQuery.disableAnimationsOf(context)) return;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  HapticFeedback.mediumImpact();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => ConfettiBurst(
      pieces: big ? 90 : 40,
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, this.pieces = 40, this.onDone});

  final int pieces;
  final VoidCallback? onDone;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final _t = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    // Fixed seed: the same lively burst every time (and in tests).
    final r = math.Random(7);
    _pieces = [
      for (var i = 0; i < widget.pieces; i++)
        _Piece(
          x: r.nextDouble(),
          // Upward kick, spread to both sides.
          vx: (r.nextDouble() - .5) * .9,
          vy: -(1.1 + r.nextDouble() * .7),
          spin: (r.nextDouble() - .5) * 14,
          size: 6 + r.nextDouble() * 6,
          colour: i % 4,
          round: i.isEven,
        ),
    ];
    _t.forward().whenComplete(() => widget.onDone?.call());
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final colours = [c.highlight, c.primary, c.warningFg, c.infoFg];
    return IgnorePointer(
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(_t, _pieces, colours),
          ),
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.vx,
    required this.vy,
    required this.spin,
    required this.size,
    required this.colour,
    required this.round,
  });

  /// Start across the bottom, 0–1 of the width.
  final double x;
  final double vx;
  final double vy;
  final double spin;
  final double size;
  final int colour;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t, this.pieces, this.colours) : super(repaint: t);

  final Animation<double> t;
  final List<_Piece> pieces;
  final List<Color> colours;

  @override
  void paint(Canvas canvas, Size size) {
    final time = t.value;
    // Fade out over the last third.
    final alpha = time < .66 ? 1.0 : (1 - (time - .66) / .34).clamp(0.0, 1.0);
    final paint = Paint();
    for (final p in pieces) {
      // Simple ballistics in screen heights: up fast, then gravity.
      final x = (p.x + p.vx * time) * size.width;
      final y = size.height * (1 + p.vy * time + 1.6 * time * time);
      if (y > size.height + 20) continue;
      paint.color = colours[p.colour].withValues(alpha: alpha);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(p.spin * time);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * .45,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
