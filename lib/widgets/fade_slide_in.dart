import 'package:flutter/material.dart';

/// Fades and slides a child up into place.
/// Items with a higher [index] start a little later (a "stagger" effect).
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // 60ms extra delay per item, capped so long lists don't wait forever.
    final delayMs = index.clamp(0, 8) * 60;
    const animationMs = 350;
    final totalMs = delayMs + animationMs;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      // Interval = stay at 0 during the delay, then animate.
      curve: Interval(delayMs / totalMs, 1, curve: Curves.easeOutCubic),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
