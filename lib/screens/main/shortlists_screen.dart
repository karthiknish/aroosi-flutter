import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aroosi_flutter/widgets/shortlist_list_item.dart';
import 'package:aroosi_flutter/widgets/paged_list_footer.dart';
import 'package:aroosi_flutter/widgets/adaptive_refresh.dart';

import 'package:aroosi_flutter/platform/adaptive_dialogs.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';
import 'package:aroosi_flutter/features/profiles/list_controller.dart';
import 'package:aroosi_flutter/utils/pagination.dart';
import 'package:aroosi_flutter/core/toast_service.dart';
import 'package:aroosi_flutter/features/profiles/selection.dart';
import 'package:aroosi_flutter/widgets/error_states.dart';
import 'package:aroosi_flutter/widgets/empty_states.dart';
import 'package:aroosi_flutter/widgets/offline_states.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';

class ShortlistsScreen extends ConsumerStatefulWidget {
  const ShortlistsScreen({super.key});

  @override
  ConsumerState<ShortlistsScreen> createState() => _ShortlistsScreenState();
}

class _ShortlistsScreenState extends ConsumerState<ShortlistsScreen> {
  final _scrollController = ScrollController();
  String _draftNote = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shortlistControllerProvider.notifier).refresh();
    });
    addLoadMoreListener(
      _scrollController,
      threshold: 120,
      canLoadMore: () {
        final s = ref.read(shortlistControllerProvider);
        return s.hasMore && !s.loading;
      },
      onLoadMore: () =>
          ref.read(shortlistControllerProvider.notifier).loadMore(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shortlistControllerProvider);

    // Loading state
    if (state.loading && state.items.isEmpty) {
      return AppScaffold(
        title: 'Shortlists',
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
        title: 'Shortlists',
        child: isOfflineError
            ? OfflineState(
                title: 'Connection Lost',
                subtitle: 'Unable to load shortlist',
                description: 'Check your internet connection and try again',
                onRetry: () =>
                    ref.read(shortlistControllerProvider.notifier).refresh(),
              )
            : ErrorState(
                title: 'Failed to Load Shortlist',
                subtitle: 'Something went wrong',
                errorMessage: error,
                onRetryPressed: () =>
                    ref.read(shortlistControllerProvider.notifier).refresh(),
              ),
      );
    }

    // Empty state
    if (!state.loading && state.error == null && state.items.isEmpty) {
      return AppScaffold(
        title: 'Shortlists',
        child: EmptyShortlistState(
          onExplore: () => context.push('/search'),
        ),
      );
    }

    Widget buildItem(BuildContext context, int index) {
      if (state.items.isEmpty && state.loading) {
        return const ShortlistListSkeleton();
      }
      if (index >= state.items.length) {
        return PagedListFooter(
          hasMore: state.hasMore,
          isLoading: state.loading,
        );
      }
      final entry = state.items[index];
      return ShortlistListItem(
        entry: entry,
        onTap: () {
          ref.read(lastSelectedProfileIdProvider.notifier).set(entry.userId);
          context.push('/details/${entry.userId}');
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Note button
            IconButton(
              icon: Icon(
                entry.note != null && entry.note!.isNotEmpty
                    ? Icons.note
                    : Icons.note_add_outlined,
                color: entry.note != null && entry.note!.isNotEmpty
                    ? ThemeHelpers.getMaterialTheme(context).primaryColor
                    : null,
              ),
              onPressed: () async {
                _draftNote = entry.note ?? '';
                if (!context.mounted) return;
                await showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Edit Note'),
                    content: TextField(
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Write a personal note about this user',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _draftNote),
                      onChanged: (value) => _draftNote = value,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final success = await ref
                              .read(shortlistControllerProvider.notifier)
                              .setNote(entry.userId, _draftNote.trim());
                          if (!dialogContext.mounted) return;
                          Navigator.of(dialogContext).pop();

                          if (success) {
                            ToastService.instance.success('Note saved');
                          } else {
                            ToastService.instance.error('Failed to save note');
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Remove button
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () async {
                final confirmed = await showAdaptiveConfirm(
                  context,
                  title: 'Remove from shortlist?',
                  message: 'This will remove the match from your shortlist.',
                );
                if (!context.mounted) return;
                if (confirmed == true) {
                  final result = await ref
                      .read(shortlistControllerProvider.notifier)
                      .toggleShortlist(entry.userId);
                  if (!context.mounted) return;

                  if (result['success'] == true) {
                    ToastService.instance.success('Removed from shortlist');
                  } else {
                    final error =
                        result['error'] as String? ??
                        'Failed to remove from shortlist';
                    final isPlanLimit = result['isPlanLimit'] as bool? ?? false;

                    if (isPlanLimit) {
                      // Show upgrade dialog for plan limits
                      final shouldUpgrade = await showAdaptiveConfirm(
                        context,
                        title: 'Limit Reached',
                        message: error,
                        confirmText: 'OK',
                        cancelText: 'Cancel',
                      );
                      if (!context.mounted) return;
                      if (shouldUpgrade) {
                        // Limit reached - no action needed
                      }
                    } else {
                      ToastService.instance.error(error);
                    }
                  }
                }
              },
            ),
          ],
        ),
      );
    }

    final listChild = ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: (state.items.isEmpty && state.loading)
          ? 6
          : state.items.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: buildItem,
    );

    final slivers = [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          buildItem,
          childCount: (state.items.isEmpty && state.loading)
              ? 6
              : state.items.length + (state.hasMore ? 1 : 0),
        ),
      ),
    ];

    final content = AdaptiveRefresh(
      onRefresh: () async {
        await ref.read(shortlistControllerProvider.notifier).refresh();
        if (!context.mounted) return;
        ToastService.instance.success('Refreshed');
      },
      controller: _scrollController,
      slivers: slivers,
      child: listChild,
    );

    return AppScaffold(
      title: 'Shortlists',
      actions: [
        // Bulk clear can be added later when backend supports it
      ],
      child: content,
    );
  }
}
