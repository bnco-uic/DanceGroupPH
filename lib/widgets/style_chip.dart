import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A colorful pill for a dance style.
/// - Without onTap: a small label (used on cards).
/// - With onTap: a filter chip with a 48px tall tap area.
class StyleChip extends StatelessWidget {
  const StyleChip({
    super.key,
    required this.style,
    this.label,
    this.selected = true,
    this.onTap,
  });

  final String style;
  final String? label; // defaults to the style name
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final info = AppTheme.styleInfo(style);
    final foreground = selected ? info.onColor : info.main;

    final pill = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: selected ? info.gradient : null,
        color: selected ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? Colors.transparent : info.main.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label ?? style,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return pill;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Center(widthFactor: 1, child: pill),
        ),
      ),
    );
  }
}
