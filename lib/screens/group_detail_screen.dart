import 'package:flutter/material.dart';

import '../models/dance_group.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/snackbars.dart';
import '../widgets/group_avatar.dart';
import '../widgets/group_card.dart';
import '../widgets/weather_card.dart';
import 'group_form_screen.dart';

/// Shows one group, its city's weather, and the Edit and Delete buttons.
class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key, required this.group});

  final DanceGroup group;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _api = ApiService();

  late DanceGroup _group; // updated after a successful edit
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
  }

  // UPDATE: open the form pre-filled with this group.
  Future<void> _edit() async {
    final updated = await Navigator.push<DanceGroup>(
      context,
      MaterialPageRoute(builder: (_) => GroupFormScreen(group: _group)),
    );
    if (updated == null || !mounted) return;
    setState(() => _group = updated);
    showSuccessSnackBar(context, 'Changes to "${updated.groupName}" saved.');
  }

  // DELETE: ask first, then delete and go back to the list.
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.festiveRed,
          size: 40,
        ),
        title: Text('Delete ${_group.groupName}?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.festiveRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await _api.deleteGroup(_group.id!);
      if (!mounted) return;
      showSuccessSnackBar(context, '"${_group.groupName}" was deleted.');
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      showErrorSnackBar(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = AppTheme.styleInfo(_group.danceStyle);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group details'),
        backgroundColor: info.main,
        foregroundColor: info.onColor,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: Theme.of(context)
            .appBarTheme
            .titleTextStyle
            ?.copyWith(color: info.onColor),
      ),
      body: ListView(
        children: [
          _buildHeader(info),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoSection(info),
                if ((_group.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Our story',
                    children: [Text(_group.description!)],
                  ),
                ],
                const SizedBox(height: 16),
                WeatherCard(city: _group.city),
                const SizedBox(height: 20),
                _buildActions(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Big gradient header: Hero avatar, name, style, and status.
  Widget _buildHeader(StyleInfo info) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      decoration: BoxDecoration(
        // Starts with the AppBar color so the two blend together.
        gradient: LinearGradient(
          colors: info.colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          GroupAvatar(group: _group, size: 96),
          const SizedBox(height: 12),
          Text(
            _group.groupName,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: info.onColor),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(info.icon, color: info.onColor),
              const SizedBox(width: 6),
              Text(
                '${_group.danceStyle} dance',
                style: TextStyle(
                  color: info.onColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (!_group.isActive) ...[
                const SizedBox(width: 8),
                const InactiveBadge(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(StyleInfo info) {
    const notRecorded = 'Not recorded';
    return _Section(
      title: 'About the group',
      children: [
        _InfoRow(
          icon: info.icon,
          color: info.main,
          label: 'Dance style',
          value: _group.danceStyle,
        ),
        _InfoRow(icon: Icons.map_outlined, label: 'Region', value: _group.region),
        _InfoRow(icon: Icons.place_outlined, label: 'City', value: _group.city),
        _InfoRow(
          icon: Icons.event_outlined,
          label: 'Founded',
          value: _group.foundedYear?.toString() ?? notRecorded,
        ),
        _InfoRow(
          icon: Icons.groups_outlined,
          label: 'Members',
          value: '${_group.memberCount} dancers',
        ),
        _InfoRow(
          icon: Icons.person_outline,
          label: 'Leader',
          value: _group.leaderName ?? notRecorded,
        ),
        _InfoRow(
          icon: Icons.music_note_outlined,
          label: 'Signature dance',
          value: _group.signatureDance ?? notRecorded,
        ),
        _InfoRow(
          icon: _group.isActive ? Icons.check_circle_outline : Icons.pause_circle_outline,
          color: _group.isActive ? AppColors.successGreen : AppColors.muted,
          label: 'Status',
          value: _group.isActive ? 'Active' : 'Inactive',
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _deleting ? null : _edit,
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _deleting ? null : _confirmDelete,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.festiveRed,
              side: const BorderSide(color: AppColors.festiveRed),
            ),
            icon: _deleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.delete_outline),
            label: Text(_deleting ? 'Deleting...' : 'Delete'),
          ),
        ),
      ],
    );
  }
}

/// White card with a title, used for the info sections.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Icon + label + value on one line.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.royalBlue,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
