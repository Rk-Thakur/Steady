import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// How list rows move, the same in every list (entries, bills): a row eases
/// in when it first appears (fading up, one after another by [index]) and
/// dips slightly while pressed. With the OS "reduce motion" setting on, it
/// simply appears.
///
/// Rows animate once, when they're first built, so give each a key (e.g. its
/// id): then only rows new to the list ease in.
class AppearTile extends StatefulWidget {
  const AppearTile({
    super.key,
    required this.child,
    this.index = 0,
    this.onTap,
  });

  final Widget child;

  /// Position in its list: later rows start a little later.
  final int index;
  final VoidCallback? onTap;

  @override
  State<AppearTile> createState() => _AppearTileState();
}

class _AppearTileState extends State<AppearTile>
    with SingleTickerProviderStateMixin {
  /// Each row starts this much after the one above, up to [_maxStagger].
  static const _step = Duration(milliseconds: 45);
  static const _maxStagger = 8;
  static const _enter = Duration(milliseconds: 380);

  late final AnimationController _appear;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    final delay = _step * widget.index.clamp(0, _maxStagger);
    final total = delay + _enter;
    _appear = AnimationController(vsync: this, duration: total);
    // The stagger is the first part of one animation (no timers to clean up).
    final curve = CurvedAnimation(
      parent: _appear,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
    _fade = curve;
    _slide = Tween(
      begin: const Offset(0, .18),
      end: Offset.zero,
    ).animate(curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appear.status != AnimationStatus.dismissed) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _appear.value = 1;
    } else {
      _appear.forward();
    }
  }

  @override
  void dispose() {
    _appear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(
      position: _slide,
      child: AnimatedScale(
        scale: _pressed ? .98 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            borderRadius: BorderRadius.circular(SteadyRadius.md),
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}
