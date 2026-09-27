import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Friendly message shown when there is nothing to display.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.celebration,
    this.actionLabel,
    this.actionIcon = Icons.add,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.sunYellow.withValues(alpha: 0.35),
            child: Icon(icon, size: 44, color: AppColors.mangoOrange),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: textTheme.titleLarge),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
