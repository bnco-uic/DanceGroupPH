import 'package:flutter/material.dart';

import '../models/dance_group.dart';
import '../theme/app_theme.dart';

/// Circle with the group's initials. Wrapped in a Hero so it "flies"
/// from the card to the detail screen header.
class GroupAvatar extends StatelessWidget {
  const GroupAvatar({super.key, required this.group, this.size = 56});

  final DanceGroup group;
  final double size;

  @override
  Widget build(BuildContext context) {
    final info = AppTheme.styleInfo(group.danceStyle);

    return Hero(
      tag: 'group-avatar-${group.id}',
      // Material keeps the text styled correctly while it flies.
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: size / 16,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            group.initials,
            style: TextStyle(
              color: info.main,
              fontSize: size * 0.36,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
