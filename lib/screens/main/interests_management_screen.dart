import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aroosi_flutter/core/toast_service.dart';
import 'package:aroosi_flutter/features/profiles/list_controller.dart';
import 'package:aroosi_flutter/utils/pagination.dart';
import 'package:aroosi_flutter/widgets/adaptive_refresh.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';
import 'package:aroosi_flutter/widgets/paged_list_footer.dart';
import 'package:aroosi_flutter/theme/colors.dart';
import 'package:aroosi_flutter/theme/motion.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';

import 'interest_management/interest_management_components.dart';

class InterestsManagementScreen extends ConsumerStatefulWidget {
  const InterestsManagementScreen({super.key});

  @override
  ConsumerState<InterestsManagementScreen> createState() =>
      _InterestsManagementScreenState();
}

class _InterestsManagementScreenState
    extends ConsumerState<InterestsManagementScreen> {
  final _scrollController = ScrollController();
  String _currentMode = 'sent';
  bool _showCulturalInsights = false;
  bool _showCompatibilityScore = true;
  final String _viewMode = 'traditional';
  bool _showIcebreakers = false;
  bool _showFamilyInvolvement = false;
  bool _showCourtshipJourney = false;

  static const List<String> _icebreakerPrompts = [
    "What's your favorite cultural tradition?",
    "What's a hobby you've always wanted to try?",
    "What's your go-to comfort food?",
    "What's a book that changed your perspective?",
    "What's your favorite way to spend a weekend?",
  ];

  static const List<GuidedStep> _familySteps = [
    GuidedStep(
      icon: Icons.family_restroom,
      title: 'Initial Meeting',
      subtitle:
          'Introduce your partner to immediate family in a casual setting.',
    ),
    GuidedStep(
      icon: Icons.restaurant,
      title: 'Family Gathering',
      subtitle: 'Host a small family dinner or gathering.',
    ),
    GuidedStep(
      icon: Icons.diversity_3,
      title: 'Cultural Exchange',
      subtitle: 'Share and learn about each other\'s family traditions.',
    ),
  ];

  static const List<GuidedStep> _courtshipSteps = [
    GuidedStep(
      icon: Icons.chat,
      title: 'Getting to Know You',
      subtitle: 'Focus on shared interests and values through conversations.',
    ),
    GuidedStep(
      icon: Icons.groups,
      title: 'Family Involvement',
      subtitle: 'Introduce partners to respective families.',
    ),
    GuidedStep(
      icon: Icons.heart_broken,
      title: 'Commitment Discussion',
      subtitle: 'Discuss future plans and long-term compatibility.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(interestsControllerProvider.notifier).load(mode: _currentMode);
    });
    addLoadMoreListener(
      _scrollController,
      threshold: 200,
      canLoadMore: () {
        final state = ref.read(interestsControllerProvider);
        return state.hasMore && !state.loading;
      },
      onLoadMore: () =>
          ref.read(interestsControllerProvider.notifier).loadMore(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interestsControllerProvider);

    if (!state.loading && state.error != null && state.items.isEmpty) {
      return AppScaffold(
        title: 'Interests',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.error!),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref
                    .read(interestsControllerProvider.notifier)
                    .load(mode: _currentMode),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final content = AdaptiveRefresh(
      onRefresh: () async {
        await ref
            .read(interestsControllerProvider.notifier)
            .load(mode: _currentMode);
        ToastService.instance.success('Refreshed');
      },
      controller: _scrollController,
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    AppColors.secondary.withValues(alpha: 0.15),
                    ThemeHelpers.getSurfaceColor(context),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    blurRadius: 36,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    JourneyIntro(state: state, currentMode: _currentMode),
                    const SizedBox(height: 20),
                    ModeSelector(
                      currentMode: _currentMode,
                      onModeChanged: (mode) {
                        if (_currentMode == mode) return;
                        setState(() {
                          _currentMode = mode;
                        });
                        ref
                            .read(interestsControllerProvider.notifier)
                            .load(mode: _currentMode);
                      },
                    ),
                    const SizedBox(height: 20),
                    JourneyMetrics(state: state),
                    const SizedBox(height: 24),
                    InsightControls(
                      showCulturalInsights: _showCulturalInsights,
                      showCompatibilityScore: _showCompatibilityScore,
                      onCulturalInsightsChanged: (value) {
                        setState(() => _showCulturalInsights = value);
                      },
                      onCompatibilityScoreChanged: (value) {
                        setState(() => _showCompatibilityScore = value);
                      },
                    ),
                    AnimatedSwitcher(
                      duration: AppMotionDurations.medium,
                      switchInCurve: Curves.easeOutQuad,
                      switchOutCurve: Curves.easeInQuad,
                      child: !_showCulturalInsights
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: _viewMode == 'traditional'
                                  ? const TraditionalInsightsCard()
                                  : const ModernInsightsCard(),
                            ),
                    ),
                    const SizedBox(height: 20),
                    JourneyModulesSection(
                      showIcebreakers: _showIcebreakers,
                      showFamilyInvolvement: _showFamilyInvolvement,
                      showCourtshipJourney: _showCourtshipJourney,
                      onIcebreakersChanged: (value) {
                        setState(() => _showIcebreakers = value);
                      },
                      onFamilyInvolvementChanged: (value) {
                        setState(() => _showFamilyInvolvement = value);
                      },
                      onCourtshipJourneyChanged: (value) {
                        setState(() => _showCourtshipJourney = value);
                      },
                      icebreakerPrompts: _icebreakerPrompts,
                      familySteps: _familySteps,
                      courtshipSteps: _courtshipSteps,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (state.items.isEmpty && !state.loading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No interests found')),
            ),
          )
        else
          _buildListSliver(state),
      ],
    );

    return AppScaffold(title: 'Interests', usePadding: false, child: content);
  }

  Widget _buildListSliver(InterestsState state) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= state.items.length) {
              return PagedListFooter(
                hasMore: state.hasMore,
                isLoading: state.loading,
              );
            }
            final interest = state.items[index];
            return InterestCard(
              interest: interest,
              mode: _currentMode,
              viewMode: _viewMode,
              showCompatibilityScore: _showCompatibilityScore,
            );
          },
          childCount: state.items.length + (state.hasMore ? 1 : 0),
        ),
      ),
    );
  }
}
