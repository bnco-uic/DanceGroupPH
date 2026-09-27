import 'package:flutter/material.dart';

import '../models/dance_group.dart';
import '../theme/app_theme.dart';
import 'group_avatar.dart';
import 'style_chip.dart';

/// One dance group in the grid: gradient header + name, city, members.
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.group, required this.onTap});

  final DanceGroup group;
  final VoidCallback onTap;

  /// Height of the gradient top part (the grid uses it to size the card).
  static const double headerHeight = 92;

  @override
  Widget build(BuildContext context) {
    final info = AppTheme.styleInfo(group.danceStyle);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: headerHeight,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(gradient: info.gradient),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GroupAvatar(group: group, size: 60),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(info.icon, color: info.onColor, size: 26),
                      const Spacer(),
                      if (!group.isActive) const InactiveBadge(),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.groupName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    _IconText(icon: Icons.place_outlined, text: group.city),
                    const SizedBox(height: 2),
                    _IconText(
                      icon: Icons.groups_outlined,
                      text: '${group.memberCount} dancers',
                    ),
                    const Spacer(),
                    StyleChip(style: group.danceStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grey "Inactive" label for groups that are on break.
class InactiveBadge extends StatelessWidget {
  const InactiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Inactive',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.muted),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}
