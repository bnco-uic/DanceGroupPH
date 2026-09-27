import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shows an error message with a Retry button.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
            backgroundColor: AppColors.festiveRed.withValues(alpha: 0.12),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 44,
              color: AppColors.festiveRed,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops, something went wrong',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
