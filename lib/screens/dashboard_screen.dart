import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/dance_group.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/weather_card.dart';
import 'groups_screen.dart';

/// Home screen: banner, stats, groups per style, and live weather.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _api = ApiService();

  List<DanceGroup> _groups = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final groups = await _api.getGroups();
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _openGroups({String? style}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupsScreen(initialStyle: style)),
    );
    // Stats may have changed while we were away.
    if (mounted) _loadGroups(showSpinner: false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadGroups(showSpinner: false),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _HeroBanner(onBrowse: _openGroups),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStats(textTheme),
                  ),
                  const SizedBox(height: 24),
                  Text('Rehearsal weather', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const WeatherCard(city: AppConfig.dashboardCity),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(TextTheme textTheme) {
    if (_loading) {
      return const SizedBox(
        key: ValueKey('loading'),
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return ErrorState(
        key: const ValueKey('error'),
        message: _error!,
        onRetry: _loadGroups,
      );
    }

    final totalDancers =
        _groups.fold<int>(0, (sum, group) => sum + group.memberCount);
    final activeGroups = _groups.where((group) => group.isActive).length;

    return Column(
      key: const ValueKey('stats'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.groups,
                label: 'Groups',
                value: _groups.length,
                colors: const [AppColors.royalBlue, Color(0xFF1565C0)],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: Icons.accessibility_new,
                label: 'Dancers',
                value: totalDancers,
                colors: const [AppColors.festiveRed, AppColors.banigMagenta],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: Icons.local_fire_department,
                label: 'Active',
                value: activeGroups,
                colors: const [AppColors.mangoOrange, AppColors.sunYellow],
                foreground: AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Groups per dance style', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_groups.isEmpty)
          EmptyState(
            title: 'No dance groups yet, add the first one!',
            actionLabel: 'Go to groups',
            onAction: _openGroups,
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (final style in kDanceStyles)
                    _StyleBarRow(
                      style: style,
                      count: _groups.where((g) => g.danceStyle == style).length,
                      maxCount: _maxPerStyle(),
                      onTap: () => _openGroups(style: style),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// The biggest style count, so the longest bar fills the row.
  int _maxPerStyle() {
    var max = 1;
    for (final style in kDanceStyles) {
      final count = _groups.where((g) => g.danceStyle == style).length;
      if (count > max) max = count;
    }
    return max;
  }
}

/// Gradient "Mabuhay!" banner at the top of the dashboard.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.banigMagenta.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Big faint decoration icon in the corner.
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.celebration,
              size: 150,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mabuhay! 💃',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.sunYellow,
                  ),
                ),
                Text(
                  'Sayaw Pilipinas',
                  style: textTheme.headlineLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Philippine Dance Group Manager',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onBrowse,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.sunYellow,
                    foregroundColor: AppColors.ink,
                  ),
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('Browse dance groups'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One row of the "groups per style" chart: icon, name, colored bar, count.
class _StyleBarRow extends StatelessWidget {
  const _StyleBarRow({
    required this.style,
    required this.count,
    required this.maxCount,
    required this.onTap,
  });

  final String style;
  final int count;
  final int maxCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final info = AppTheme.styleInfo(style);

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Icon(info.icon, color: info.main, size: 22),
              const SizedBox(width: 8),
              SizedBox(
                width: 110,
                child: Text(
                  style,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Container(
                        height: 14,
                        color: info.main.withValues(alpha: 0.12),
                      ),
                      // The bar grows from 0 to its size.
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: count / maxCount),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: value,
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(gradient: info.gradient),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$count',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
