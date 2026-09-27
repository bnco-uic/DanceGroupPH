import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Green SnackBar with a check icon.
void showSuccessSnackBar(BuildContext context, String message) {
  _showSnackBar(context, message, AppColors.successGreen, Icons.check_circle);
}

/// Red SnackBar with an error icon.
void showErrorSnackBar(BuildContext context, String message) {
  _showSnackBar(context, message, AppColors.festiveRed, Icons.error_outline);
}

void _showSnackBar(
  BuildContext context,
  String message,
  Color color,
  IconData icon,
) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
