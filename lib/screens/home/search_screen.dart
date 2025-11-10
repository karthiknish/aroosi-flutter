import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aroosi_flutter/features/profiles/list_controller.dart';
import 'package:aroosi_flutter/features/profiles/models.dart';
import 'package:aroosi_flutter/core/toast_service.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';
import 'package:aroosi_flutter/widgets/empty_states.dart';
import 'package:aroosi_flutter/widgets/error_states.dart';
import 'package:aroosi_flutter/utils/pagination.dart';
import 'package:aroosi_flutter/widgets/adaptive_refresh.dart';
import 'package:aroosi_flutter/widgets/profile_list_item.dart';

import 'package:aroosi_flutter/features/auth/auth_controller.dart';
import 'package:aroosi_flutter/utils/debug_logger.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/features/search/advanced_search_filters_screen.dart';
import 'package:aroosi_flutter/features/search/matrimony_search_integration.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/matrimony_onboarding_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const int _defaultPageSize = 12;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  // Get toast service from provider
  ToastService get _toast => ref.read(toastServiceProvider);

  @override
  void initState() {
    super.initState();
    // Load all profiles on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllProfiles();
      _loadInterests();
      _initializeMatrimonyFilters();
    });
    addLoadMoreListener(
      _scrollController,
      threshold: 200,
      canLoadMore: () {
        final state = ref.read(searchControllerProvider);
        return state.hasMore && !state.loading && state.filters != null;
      },
      onLoadMore: () => ref.read(searchControllerProvider.notifier).loadMore(),
    );
  }

  void _initializeMatrimonyFilters() async {
    // Load matrimony onboarding data and integrate with search
    final matrimonyData = ref.read(matrimonyOnboardingProvider).data;
    if (matrimonyData != null) {
      final matrimonyFilters = MatrimonySearchIntegration.fromMatrimonyOnboarding(matrimonyData);
      final enhancedFilters = MatrimonySearchIntegration.enhanceForMatrimony(matrimonyFilters);
      
      // Apply matrimony filters as default if no existing filters
      final currentFilters = ref.read(searchControllerProvider).filters;
      if (currentFilters == null || !currentFilters.hasCriteria) {
        ref.read(searchControllerProvider.notifier).search(enhancedFilters);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final auth = ref.watch(authControllerProvider);

    // Redirect to welcome if not authenticated
    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentLoc = GoRouterState.of(context).uri.toString();
        if (currentLoc != '/startup') {
          context.go('/startup');
        }
      });
      return const SizedBox.shrink();
    }

    // Show loader if auth is loading or profile is missing
    if (auth.loading || auth.profile == null) {
      return const AppScaffold(
        title: 'Search',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Show loading state when performing search or initial load
    if (state.loading && state.items.isEmpty) {
      return AppScaffold(
        title: 'Search',
        child: AdaptiveRefresh(
          onRefresh: _refresh,
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildSearchControls(context),
              ),
            ),
            SliverFillRemaining(
              child: Container(
                color: ThemeHelpers.getMaterialTheme(context).colorScheme.surface,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Loading profiles...',
                        style: ThemeHelpers.getMaterialTheme(context).textTheme.bodyLarge?.copyWith(
                          color: ThemeHelpers.getMaterialTheme(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final items = state.items;
    final hasResults = items.isNotEmpty;
    final showLoadingMore = state.loading && hasResults;

    final materialTheme = ThemeHelpers.getMaterialTheme(context);

    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: _buildSearchControls(context),
        ),
      ),
      if (state.error != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _buildErrorBanner(context, state.error!),
          ),
        ),
      if (hasResults)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Search Results',
              style: materialTheme.textTheme.titleMedium,
            ),
          ),
        ),
      if (hasResults)
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final profile = items[index];
                final score = profile.compatibilityScore;
                return Column(
                  children: [
                    ProfileListItem(
                      profile: profile,
                      compatibilityScore: score > 0 ? score : null,
                      onTap: () => _openProfileDetails(profile),
                    ),
                    if (index < items.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              },
              childCount: items.length,
            ),
          ),
        ),
      if (!hasResults)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildEmptyState(context, forCards: false),
          ),
        ),
      if (showLoadingMore)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, __) => const ProfileListSkeleton(),
              childCount: 2,
            ),
          ),
        )
      else if (hasResults && state.hasMore)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Center(
              child: Text(
                'Scroll to load more profiles',
                style: materialTheme.textTheme.bodyMedium?.copyWith(
                  color: materialTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
    ];

    return AppScaffold(
      title: 'Search',
      child: AdaptiveRefresh(
        onRefresh: _refresh,
        controller: _scrollController,
        slivers: slivers,
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    return InlineError(
      error: message,
      onRetry: _hasSearchCriteria
          ? () => _scheduleSearch(immediate: true)
          : null,
      showIcon: true,
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool forCards}) {
    final state = ref.watch(searchControllerProvider);
    final isLoading = state.loading;

    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: forCards ? 24 : 32,
        ),
        child: Container(
          color: ThemeHelpers.getMaterialTheme(context).colorScheme.surface,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading profiles...',
                  style: ThemeHelpers.getMaterialTheme(context).textTheme.titleMedium?.copyWith(
                    color: ThemeHelpers.getMaterialTheme(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: forCards ? 24 : 32,
      ),
      child: EmptySearchState(
        searchQuery: _controller.text.isNotEmpty ? _controller.text : null,
        onClearSearch: _controller.text.isNotEmpty
            ? () {
                _controller.clear();
                _loadAllProfiles();
              }
            : null,
      ),
    );
  }

  Widget _buildSearchControls(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final hasFilters = state.filters?.hasCriteria ?? false;
    final isMatrimonySearch = state.filters != null ? 
        MatrimonySearchIntegration.isMatrimonySearch(state.filters!) : false;
    
    return Column(
      children: [
        // Search Text Field with suggestions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search by name, city, or interests...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _loadAllProfiles();
                      },
                    ),
                  if (isMatrimonySearch)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ThemeHelpers.getMaterialTheme(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Matrimony',
                        style: ThemeHelpers.getMaterialTheme(context).textTheme.bodySmall?.copyWith(
                          color: ThemeHelpers.getMaterialTheme(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: ThemeHelpers.getMaterialTheme(context).colorScheme.surface,
            ),
            onChanged: (value) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                _scheduleSearch();
              });
            },
          ),
        ),
        
        // Filter buttons row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Advanced Filters Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAdvancedFilters(context),
                  icon: Icon(
                    Icons.filter_list,
                    color: hasFilters ? ThemeHelpers.getMaterialTheme(context).colorScheme.primary : null,
                  ),
                  label: Text(
                    hasFilters ? 'Filters Applied' : 'Advanced Filters',
                    style: TextStyle(
                      color: hasFilters ? ThemeHelpers.getMaterialTheme(context).colorScheme.primary : null,
                      fontWeight: hasFilters ? FontWeight.bold : null,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: hasFilters 
                          ? BorderSide(color: ThemeHelpers.getMaterialTheme(context).colorScheme.primary)
                          : BorderSide.none,
                    ),
                    backgroundColor: hasFilters 
                        ? ThemeHelpers.getMaterialTheme(context).colorScheme.primaryContainer.withAlpha(30)
                        : null,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Matrimony Presets Button
              OutlinedButton.icon(
                onPressed: () => _showMatrimonyPresets(context),
                icon: const Icon(Icons.favorite_border),
                label: const Text('Presets'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Active filters display
        if (hasFilters)
          _buildActiveFilters(context, state.filters!),
      ],
    );
  }

  Widget _buildActiveFilters(BuildContext context, SearchFilters filters) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final activeFilters = <String>[];
    
    // Collect active filter descriptions
    if (filters.minAge != null || filters.maxAge != null) {
      activeFilters.add('Age: ${filters.minAge ?? 'any'}-${filters.maxAge ?? 'any'}');
    }
    if (filters.education != null) {
      activeFilters.add('Education: ${filters.education}');
    }
    if (filters.religion != null) {
      activeFilters.add('Religion: ${filters.religion}');
    }
    if (filters.marriageIntention != null) {
      activeFilters.add(MatrimonySearchIntegration.getMarriageIntentionDisplay(filters.marriageIntention));
    }
    if (filters.requiresFamilyApproval == true) {
      activeFilters.add('Family Approval');
    }
    
    if (activeFilters.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: activeFilters.map((filter) {
          return Chip(
            label: Text(
              filter,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            backgroundColor: theme.colorScheme.primary,
            deleteIcon: Icon(
              Icons.close,
              size: 16,
              color: theme.colorScheme.onPrimary,
            ),
            onDeleted: () {
              // Clear all filters by searching with empty filters
              ref.read(searchControllerProvider.notifier).search(const SearchFilters());
            },
          );
        }).toList(),
      ),
    );
  }

  void _showAdvancedFilters(BuildContext context) {
    final currentFilters = ref.read(searchControllerProvider).filters;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => AdvancedSearchFiltersScreen(
          initialFilters: currentFilters,
        ),
      ),
    );
  }

  void _showMatrimonyPresets(BuildContext context) {
    final presets = MatrimonySearchIntegration.getMatrimonyPresets();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Matrimony Search Presets',
              style: ThemeHelpers.getMaterialTheme(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...presets.asMap().entries.map((entry) {
              final index = entry.key;
              final preset = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(MatrimonySearchIntegration.getPresetDisplayName(preset, index)),
                  subtitle: Text(MatrimonySearchIntegration.getPresetDescription(preset, index)),
                  leading: Icon(
                    Icons.favorite,
                    color: ThemeHelpers.getMaterialTheme(context).colorScheme.primary,
                  ),
                  onTap: () {
                    ref.read(searchControllerProvider.notifier).search(preset);
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: ThemeHelpers.getMaterialTheme(context).colorScheme.outline.withAlpha(50),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadAllProfiles() async {
    logDebug('SearchScreen: Loading all profiles');

    // Get current user's profile to access preferred gender
    final auth = ref.read(authControllerProvider);
    final userProfile = auth.profile;

    // Create filters with preferred gender if available
    final filters = SearchFilters(
      pageSize: _defaultPageSize,
      query: null,
      city: null,
      minAge: null,
      maxAge: null,
      sort: null,
      cursor: null,
      preferredGender: userProfile?.preferredGender?.isNotEmpty == true
          ? userProfile!.preferredGender
          : null,
    );

    await ref.read(searchControllerProvider.notifier).search(filters);
  }

  Future<void> _loadInterests() async {
    logDebug('SearchScreen: Loading interests data');
    try {
      await ref.read(interestsControllerProvider.notifier).load(mode: 'sent');
    } catch (e) {
      logDebug('SearchScreen: Failed to load interests', error: e);
    }
  }

  Future<void> _refresh() async {
    final state = ref.read(searchControllerProvider);
    if (state.filters != null) {
      // Re-run the current search
      await ref.read(searchControllerProvider.notifier).search(state.filters!);
    } else {
      // Load all profiles if no filters
      await _loadAllProfiles();
    }
    if (mounted) {
      _toast.success('Search refreshed');
    }
  }

  Future<void> _scheduleSearch({bool immediate = false}) async {
    final query = _controller.text.trim();
    final state = ref.read(searchControllerProvider);

    // Get current user's profile for preferred gender
    final auth = ref.read(authControllerProvider);
    final userProfile = auth.profile;

    // Create filters with current query and existing filters
    final filters = SearchFilters(
      pageSize: _defaultPageSize,
      query: query.isNotEmpty ? query : null,
      city: state.filters?.city,
      minAge: state.filters?.minAge,
      maxAge: state.filters?.maxAge,
      sort: state.filters?.sort,
      cursor: null,
      preferredGender:
          state.filters?.preferredGender ??
          (userProfile?.preferredGender?.isNotEmpty == true
              ? userProfile!.preferredGender
              : null),
    );

    await ref.read(searchControllerProvider.notifier).search(filters);
  }

  bool get _hasSearchCriteria {
    final query = _controller.text.trim();
    final state = ref.read(searchControllerProvider);
    final filters = state.filters;

    return query.isNotEmpty ||
        (filters != null &&
            (filters.city != null ||
                filters.minAge != null ||
                filters.maxAge != null ||
                filters.sort != null ||
                filters.preferredGender != null));
  }

  void _openProfileDetails(ProfileSummary profile) {
    if (profile.id.isEmpty) return;
    GoRouter.of(context).pushNamed(
      'details',
      pathParameters: {'id': profile.id},
    );
  }

}
