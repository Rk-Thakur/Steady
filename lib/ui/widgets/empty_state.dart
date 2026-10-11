import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'kit.dart';

/// "Nothing here yet", friendly: a small illustration (two soft circles in
/// the screen's tone with an icon), a short title, and what to do next.
///
/// It eases in once (rising and growing slightly) and then stays still, so
/// it never runs an endless animation. With "reduce motion" on, it simply
/// appears.
class EmptyState extends StatefulWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.tone = BannerTone.primary,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final BannerTone tone;

  /// Smaller, for a section inside a screen (Today's list).
  final bool compact;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final _scale = Tween(
    begin: .94,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _in, curve: Curves.easeOutBack));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_in.status != AnimationStatus.dismissed) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _in.value = 1;
    } else {
      _in.forward();
    }
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (soft, strong) = switch (widget.tone) {
      BannerTone.primary => (c.primarySoft, c.positive),
      BannerTone.warning => (c.warningBg, c.warningFg),
      BannerTone.danger => (c.dangerBg, c.dangerFg),
      BannerTone.info => (c.infoBg, c.infoFg),
      BannerTone.neutral => (c.segmentTrack, c.mutedStrong),
    };
    final size = widget.compact ? 64.0 : 96.0;

    final art = ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Two overlapping soft circles behind the icon.
            Positioned(
              left: 0,
              top: size * .08,
              child: _Blob(size: size * .78, color: soft),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: _Blob(
                size: size * .58,
                color: strong.withValues(alpha: .14),
              ),
            ),
            Icon(widget.icon, size: size * .4, color: strong),
          ],
        ),
      ),
    );

    final text = Column(
      crossAxisAlignment: widget.compact
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          textAlign: widget.compact ? TextAlign.start : TextAlign.center,
          style: SteadyType.heading.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: SteadySpace.s1),
        Text(
          widget.body,
          textAlign: widget.compact ? TextAlign.start : TextAlign.center,
          style: SteadyType.body.copyWith(color: c.muted, height: 1.45),
        ),
      ],
    );

    return FadeTransition(
      opacity: _in,
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: widget.compact ? SteadySpace.s2 : SteadySpace.s6,
          ),
          child: widget.compact
              ? Row(
                  children: [
                    art,
                    const SizedBox(width: SteadySpace.s4),
                    Expanded(child: text),
                  ],
                )
              : Column(
                  children: [
                    art,
                    const SizedBox(height: SteadySpace.s4),
                    text,
                  ],
                ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
