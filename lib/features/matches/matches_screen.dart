import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aroosi_flutter/features/matches/matches_provider.dart';
import 'package:aroosi_flutter/features/matches/models.dart';
import 'package:aroosi_flutter/features/auth/auth_controller.dart';
import 'package:aroosi_flutter/core/responsive.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';
import 'package:aroosi_flutter/widgets/paged_list_footer.dart';
import 'package:aroosi_flutter/widgets/empty_states.dart';
import 'package:aroosi_flutter/widgets/retryable_network_image.dart';
import 'package:aroosi_flutter/widgets/error_states.dart';
import 'package:aroosi_flutter/widgets/offline_states.dart';
import 'package:aroosi_flutter/core/toast_service.dart';
import 'package:aroosi_flutter/widgets/adaptive_refresh.dart';
import 'package:aroosi_flutter/theme/colors.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/theme/motion.dart';
import 'package:aroosi_flutter/widgets/animations/motion.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  final _scrollController = ScrollController();
  String? _currentSort;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider);
      if (user.profile != null) {
        ref.read(matchesProvider.notifier).observeMatches(user.profile!.id);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchesState = ref.watch(matchesProvider);
    final user = ref.watch(authControllerProvider);

    if (user.profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Handle matches controller errors
    ref.listen(matchesProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        final error = next.error.toString();
        final isOfflineError =
            error.toLowerCase().contains('network') ||
            error.toLowerCase().contains('connection') ||
            error.toLowerCase().contains('timeout');

        if (isOfflineError) {
          ToastService.instance.error('Connection error while loading matches');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection error while loading matches'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => ref.read(matchesProvider.notifier).refresh(),
              ),
            ),
          );
        } else {
          ToastService.instance.error('Failed to load matches: $error');
        }
      }
    });

    if (!matchesState.isLoading && matchesState.error != null && matchesState.items.isEmpty) {
      final error = matchesState.error.toString();
      final isOfflineError =
          error.toLowerCase().contains('network') ||
          error.toLowerCase().contains('connection') ||
          error.toLowerCase().contains('timeout');

      return AppScaffold(
        title: 'Matches',
        child: isOfflineError
            ? OfflineState(
                title: 'No Connection',
                subtitle: 'Unable to load matches',
                description:
                    'Please check your internet connection and try again',
                onRetry: () => ref.read(matchesProvider.notifier).refresh(),
              )
            : ErrorState(
                title: 'Failed to Load Matches',
                subtitle: 'Something went wrong',
                errorMessage: error,
                onRetryPressed: () => ref.read(matchesProvider.notifier).refresh(),
              ),
      );
    }

    Widget buildGridSliver() {
      return Builder(
        builder: (context) {
          final columns = Responsive.gridColumns(context);
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: Responsive.isTablet(context) ? 3.2 / 4 : 3 / 4,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (matchesState.items.isEmpty && matchesState.isLoading) {
                  return _MatchSkeleton();
                }
                if (index >= matchesState.items.length) {
                  return PagedListFooter(
                    hasMore: false,
                    isLoading: matchesState.isLoading,
                  );
                }
                final matchItem = matchesState.items[index];
                final itemDelay = Duration(
                  milliseconds:
                      (AppMotionDurations.fast.inMilliseconds ~/ 2) *
                      (index % 6),
                );
                return FadeSlideIn(
                  duration: AppMotionDurations.short,
                  delay: itemDelay,
                  beginOffset: const Offset(0, 0.08),
                  child: MotionPressable(
                    onPressed: () {
                      context.push('/matches/${matchItem.id}');
                    },
                    child: _MatchCard(matchItem: matchItem),
                  ),
                );
              },
              childCount: matchesState.items.isEmpty && matchesState.isLoading
                  ? 6
                  : matchesState.items.length,
            ),
          );
        },
      );
    }

    final content = AdaptiveRefresh(
      onRefresh: () async {
        await ref.read(matchesProvider.notifier).refresh();
        ToastService.instance.success('Matches refreshed');
      },
      controller: _scrollController,
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildMatchesHero(context),
          ),
        ),
        if (matchesState.items.isEmpty && !matchesState.isLoading)
          SliverToBoxAdapter(
            child: EmptyMatchesState(
              onExplore: () => context.push('/discover'),
              onImproveProfile: () => context.push('/main/edit-profile'),
            ),
          )
        else
          buildGridSliver(),
      ],
    );

    return AppScaffold(title: 'Matches', child: content);
  }

  Widget _buildMatchesHero(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(56),
            AppColors.secondary.withAlpha(46),
            ThemeHelpers.getMaterialTheme(context).colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(36),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Matches',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with people who match your preferences',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(140),
              ),
            ),
            const SizedBox(height: 20),
            _buildSortDropdown(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown(ThemeData theme) {
    final options = <Map<String, Object?>>[
      {'value': null, 'label': 'Default Order'},
      {'value': 'recent', 'label': 'Recently Active'},
      {'value': 'newest', 'label': 'Newest First'},
      {'value': 'distance', 'label': 'Nearest First'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(229),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(31)),
      ),
      child: DropdownButton<String?>(
        value: _currentSort,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.sort, color: AppColors.primary),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        dropdownColor: theme.colorScheme.surface,
        items: options.map((option) {
          return DropdownMenuItem<String?>(
            value: option['value'] as String?,
            child: Text(option['label'] as String),
          );
        }).toList(),
        onChanged: (value) {
          _onSortSelected(value);
        },
      ),
    );
  }

  void _onSortSelected(String? value) {
    if (_currentSort == value) return;
    setState(() {
      _currentSort = value;
    });
    ref.read(matchesProvider.notifier).refresh();
  }
}

class _MatchCard extends StatelessWidget {
  final MatchListItem matchItem;

  const _MatchCard({required this.matchItem});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final displayName = (matchItem.counterpartProfile?.displayName ?? 'Match').trim();
    final name = displayName.isEmpty ? 'Match' : displayName;
    final accent = _accentColor;
    final backgroundUrl = matchItem.counterpartProfile?.avatarUrl;
    final statusLabel = _statusLabel();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned.fill(
            child: backgroundUrl != null
                ? RetryableNetworkImage(
                    url: backgroundUrl,
                    fit: BoxFit.cover,
                    placeholder: Container(color: accent.withAlpha(20)),
                    errorWidget: Container(
                      color: accent.withAlpha(31),
                      child: Center(
                        child: Icon(
                          Icons.favorite_outline,
                          color: accent.withAlpha(153),
                        ),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent.withAlpha(46), accent.withAlpha(13)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withAlpha(166),
                    Colors.black.withAlpha(26),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: _buildStatusChip(statusLabel, accent),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withAlpha(179),
                    Colors.black.withAlpha(51),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (matchItem.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            matchItem.unreadCount > 99
                                ? '99+'
                                : '${matchItem.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 14,
                        color: Colors.pinkAccent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Match',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withAlpha(191),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.white.withAlpha(153),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatRelativeTime(matchItem.lastUpdatedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withAlpha(153),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  if (matchItem.lastMessagePreview?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      '"${matchItem.lastMessagePreview!.trim()}"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withAlpha(224),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(115),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(31)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite,
            size: 16,
            color: accent,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _statusLabel() {
    return 'Match';
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Color get _accentColor {
    return Colors.pinkAccent;
  }
}

class _MatchSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = ThemeHelpers.getMaterialTheme(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final hilite = isDark ? Colors.grey.shade700 : Colors.grey.shade200;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          // Background image placeholder
          Positioned.fill(child: Container(color: base.withAlpha(102))),
          // Status chip placeholder
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              width: 80,
              height: 24,
              decoration: BoxDecoration(
                color: hilite.withAlpha(128),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Bottom content overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withAlpha(179),
                    Colors.black.withAlpha(51),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name placeholder
                  Container(
                    width: 120,
                    height: 20,
                    color: hilite.withAlpha(128),
                    margin: const EdgeInsets.only(bottom: 8),
                  ),
                  // Status and time row
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: hilite.withAlpha(128),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 80,
                        height: 12,
                        color: hilite.withAlpha(128),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: hilite.withAlpha(128),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 40,
                        height: 12,
                        color: hilite.withAlpha(128),
                      ),
                    ],
                  ),
                  // Message preview placeholder (sometimes shown)
                  if (DateTime.now().millisecond % 3 == 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: 180,
                      height: 14,
                      color: hilite.withAlpha(102),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
