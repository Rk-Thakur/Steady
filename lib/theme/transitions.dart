import 'package:flutter/material.dart';

/// Screen-to-screen motion on Android: a "shared axis" step sideways. The
/// new screen fades in while sliding a short way from the right; the old one
/// fades out a little to the left. (iOS keeps its native transition, with
/// swipe-back.) With "reduce motion" on, screens just cross-fade.
class SharedAxisPageTransitionsBuilder extends PageTransitionsBuilder {
  const SharedAxisPageTransitionsBuilder();

  static const _shift = 30.0;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(opacity: animation, child: child);
    }
    // In: fade after a short beat, slide from the right.
    final inFade = CurvedAnimation(
      parent: animation,
      curve: const Interval(.3, 1, curve: Curves.easeOut),
    );
    final inSlide = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    // Out (another screen coming on top): fade early, drift left.
    final outFade = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0, .3, curve: Curves.easeIn),
    );
    return AnimatedBuilder(
      animation: Listenable.merge([animation, secondaryAnimation]),
      child: child,
      builder: (context, child) {
        final dx =
            _shift * (1 - inSlide.value) -
            _shift * Curves.easeInCubic.transform(secondaryAnimation.value);
        return Opacity(
          opacity: inFade.value * (1 - outFade.value),
          child: Transform.translate(offset: Offset(dx, 0), child: child),
        );
      },
    );
  }
}
