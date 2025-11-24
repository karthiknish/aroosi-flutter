import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aroosi_flutter/widgets/profile_list_item.dart';
import 'package:aroosi_flutter/widgets/paged_list_footer.dart';
import 'package:aroosi_flutter/widgets/adaptive_refresh.dart';

import 'package:aroosi_flutter/platform/adaptive_feedback.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';
import 'package:aroosi_flutter/features/profiles/list_controller.dart';
import 'package:aroosi_flutter/utils/pagination.dart';
import 'package:aroosi_flutter/core/toast_service.dart';
import 'package:aroosi_flutter/features/profiles/selection.dart';
import 'package:aroosi_flutter/widgets/error_states.dart';
import 'package:aroosi_flutter/widgets/empty_states.dart';
import 'package:aroosi_flutter/widgets/offline_states.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final _scrollController = ScrollController();

  Future<void> _refresh() async {
    await ref.read(favoritesControllerProvider.notifier).refresh();
    if (!mounted) return;
    ToastService.instance.success('Favorites refreshed');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesControllerProvider.notifier).refresh();
    });
    addLoadMoreListener(
      _scrollController,
      threshold: 120,
      canLoadMore: () {
        final s = ref.read(favoritesControllerProvider);
        return s.hasMore && !s.loading;
      },
      onLoadMore: () =>
          ref.read(favoritesControllerProvider.notifier).loadMore(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesControllerProvider);

    // Loading state
    if (state.loading && state.items.isEmpty) {
      return AppScaffold(
        title: 'Favorites',
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error state when nothing loaded
    if (!state.loading && state.error != null && state.items.isEmpty) {
      final error = state.error!;
      final isOfflineError =
          error.toLowerCase().contains('network') ||
          error.toLowerCase().contains('connection') ||
          error.toLowerCase().contains('timeout') ||
          error.toLowerCase().contains('offline');

      return AppScaffold(
        title: 'Favorites',
        child: isOfflineError
            ? OfflineState(
                title: 'Connection Lost',
                subtitle: 'Unable to load favorites',
                description: 'Check your internet connection and try again',
                onRetry: () =>
                    ref.read(favoritesControllerProvider.notifier).refresh(),
              )
            : ErrorState(
                title: 'Failed to Load Favorites',
                subtitle: 'Something went wrong',
                errorMessage: error,
                onRetryPressed: () =>
                    ref.read(favoritesControllerProvider.notifier).refresh(),
              ),
      );
    }

    // Empty state when loaded but no items
    if (!state.loading && state.error == null && state.items.isEmpty) {
      return AppScaffold(
        title: 'Favorites',
        child: EmptyFavoritesState(
          onExplore: () => context.push('/search'),
        ),
      );
    }

    // Build list content once to reuse for both platforms
    Widget buildListItem(BuildContext context, int index) {
      if (state.items.isEmpty && state.loading) {
        return const ProfileListSkeleton();
      }
      if (index >= state.items.length) {
        return PagedListFooter(
          hasMore: state.hasMore,
          isLoading: state.loading,
        );
      }
      final p = state.items[index];
      return ProfileListItem(
        profile: p,
        onTap: () {
          ref.read(lastSelectedProfileIdProvider.notifier).set(p.id);
          context.push('/details/${p.id}');
        },
        onLongPress: () async {
          final ctx = context;
          final i = await showAdaptiveActionSheet(
            ctx,
            title: p.displayName,
            actions: const ['Remove from favorites'],
          );
          if (i == 0) {
            await ref
                .read(favoritesControllerProvider.notifier)
                .toggleFavorite(p.id);
            ToastService.instance.success('Removed');
          }
        },
      );
    }

    final slivers = [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          buildListItem,
          childCount: (state.items.isEmpty && state.loading)
              ? 6
              : state.items.length + (state.hasMore ? 1 : 0),
        ),
      ),
    ];

    return AppScaffold(
      title: 'Favorites',
      usePadding: false,
      actions: [
        // Bulk actions can be wired later (requires backend endpoint)
      ],
      child: AdaptiveRefresh(
        onRefresh: _refresh,
        controller: _scrollController,
        slivers: slivers,
      ),
    );
  }
}
