import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A floating action button that "bounces" in when the screen opens.
class BouncyFab extends StatefulWidget {
  const BouncyFab({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon = Icons.add,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  @override
  State<BouncyFab> createState() => _BouncyFabState();
}

class _BouncyFabState extends State<BouncyFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  // elasticOut overshoots a bit and settles: that is the bounce.
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FloatingActionButton.extended(
        onPressed: widget.onPressed,
        backgroundColor: AppColors.sunYellow,
        foregroundColor: AppColors.ink,
        icon: Icon(widget.icon),
        label: Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
