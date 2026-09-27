import 'package:flutter/material.dart';

import '../models/dance_group.dart';
import '../services/api_service.dart';
import '../utils/snackbars.dart';
import '../widgets/bouncy_fab.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/group_card.dart';
import '../widgets/style_chip.dart';
import 'group_detail_screen.dart';
import 'group_form_screen.dart';

/// READ: all dance groups in a responsive grid, with search and filters.
class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key, this.initialStyle});

  /// Pre-selected style filter (when opened from the dashboard bars).
  final String? initialStyle;

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _api = ApiService();
  final _searchController = TextEditingController();

  List<DanceGroup> _groups = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  String? _styleFilter; // null = all styles

  @override
  void initState() {
    super.initState();
    _styleFilter = widget.initialStyle;
    _loadGroups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// showSpinner: false for pull-to-refresh and quiet reloads.
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
      if (!showSpinner && _groups.isNotEmpty) {
        // Keep showing the old list; just tell the user.
        showErrorSnackBar(context, e.message);
      } else {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  /// Groups that match the search text and the selected style.
  List<DanceGroup> get _visibleGroups {
    final query = _query.trim().toLowerCase();
    return _groups.where((group) {
      final styleOk = _styleFilter == null || group.danceStyle == _styleFilter;
      final searchOk = query.isEmpty ||
          group.groupName.toLowerCase().contains(query) ||
          group.city.toLowerCase().contains(query);
      return styleOk && searchOk;
    }).toList();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _styleFilter = null;
    });
  }

  Future<void> _openDetail(DanceGroup group) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupDetailScreen(group: group)),
    );
    // The group may have been edited or deleted: reload quietly.
    if (mounted) _loadGroups(showSpinner: false);
  }

  Future<void> _openAddForm() async {
    final created = await Navigator.push<DanceGroup>(
      context,
      MaterialPageRoute(builder: (_) => const GroupFormScreen()),
    );
    if (created == null || !mounted) return;

    // Put the new group at the top right away (no manual refresh).
    _clearFilters();
    setState(() => _groups.insert(0, created));
    showSuccessSnackBar(context, '"${created.groupName}" was added. Mabuhay!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dance Groups')),
      floatingActionButton: BouncyFab(
        onPressed: _openAddForm,
        label: 'Add group',
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStyleFilters(),
          Expanded(
            // Fades between loading, error, and content.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by group name or city',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildStyleFilters() {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          StyleChip(
            style: 'All',
            selected: _styleFilter == null,
            onTap: () => setState(() => _styleFilter = null),
          ),
          for (final style in kDanceStyles)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: StyleChip(
                style: style,
                selected: _styleFilter == style,
                // Tapping the selected chip again turns the filter off.
                onTap: () => setState(
                  () => _styleFilter = _styleFilter == style ? null : style,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        key: const ValueKey('error'),
        child: SingleChildScrollView(
          child: ErrorState(message: _error!, onRetry: _loadGroups),
        ),
      );
    }

    final groups = _visibleGroups;

    return RefreshIndicator(
      key: const ValueKey('content'),
      onRefresh: () => _loadGroups(showSpinner: false),
      child: groups.isEmpty
          // A ListView so pull-to-refresh still works when empty.
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _groups.isEmpty
                    ? EmptyState(
                        title: 'No dance groups yet, add the first one!',
                        message: 'Tap "Add group" to register a dance group.',
                        actionLabel: 'Add group',
                        onAction: _openAddForm,
                      )
                    : EmptyState(
                        icon: Icons.search_off,
                        title: 'No groups match your search',
                        message: 'Try another name, city, or dance style.',
                        actionLabel: 'Clear filters',
                        actionIcon: Icons.filter_alt_off,
                        onAction: _clearFilters,
                      ),
              ],
            )
          : _buildGrid(groups),
    );
  }

  Widget _buildGrid(List<DanceGroup> groups) {
    // Card body grows with the phone's text size setting.
    final cardHeight = GroupCard.headerHeight +
        MediaQuery.textScalerOf(context).scale(150);

    return LayoutBuilder(
      builder: (context, constraints) {
        // About one column per 220px: 2 on phones, more on tablets/web.
        final columns = (constraints.maxWidth / 220).floor().clamp(2, 6);

        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: cardHeight,
          ),
          itemCount: groups.length,
          itemBuilder: (context, index) => FadeSlideIn(
            index: index,
            child: GroupCard(
              group: groups[index],
              onTap: () => _openDetail(groups[index]),
            ),
          ),
        );
      },
    );
  }
}
