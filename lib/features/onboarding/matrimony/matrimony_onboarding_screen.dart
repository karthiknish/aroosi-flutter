import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/matrimony_onboarding_provider.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/constants.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/models.dart';
import 'package:aroosi_flutter/theme/motion.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/widgets/animations/motion.dart';
import 'package:aroosi_flutter/l10n/app_localizations.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';

import 'steps/welcome_step.dart';
import 'steps/marriage_intentions_step.dart';
import 'steps/family_values_step.dart';
import 'steps/religious_preferences_step.dart';
import 'steps/partner_preferences_step.dart';
import 'steps/family_involvement_step.dart';
import 'steps/completion_step.dart';

class MatrimonyOnboardingScreen extends ConsumerStatefulWidget {
  const MatrimonyOnboardingScreen({super.key});

  @override
  ConsumerState<MatrimonyOnboardingScreen> createState() => _MatrimonyOnboardingScreenState();
}

class _MatrimonyOnboardingScreenState extends ConsumerState<MatrimonyOnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _contentController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: AppMotionDurations.medium,
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: AppMotionDurations.long,
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Initialize onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matrimonyOnboardingProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onboardingState = ref.watch(matrimonyOnboardingProvider);
    final notifier = ref.read(matrimonyOnboardingProvider.notifier);

    // Update progress animation when step changes
    ref.listen(matrimonyOnboardingProvider, (previous, next) {
      if (previous?.currentStepIndex != next.currentStepIndex) {
        _progressController.animateTo(next.progress);
        _contentController.forward();
      }
    });

    if (onboardingState.isLoading && onboardingState.data == null) {
      return const AppScaffold(
        title: 'Onboarding',
        usePadding: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final currentStep = onboardingState.currentStep;
    if (currentStep == null) {
      return const AppScaffold(
        title: 'Onboarding',
        usePadding: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      title: 'Onboarding',
      usePadding: false,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, onboardingState, l10n),
            _buildProgressBar(onboardingState),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotionDurations.medium,
                child: _buildStepContent(currentStep, onboardingState),
              ),
            ),
            _buildBottomActions(onboardingState, notifier, context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MatrimonyOnboardingState state, AppLocalizations l10n) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final currentStep = state.currentStep;
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!state.isFirstStep)
                IconButton(
                  onPressed: () {
                    ref.read(matrimonyOnboardingProvider.notifier).previousStep();
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentStep?.title ?? '',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentStep?.subtitle ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currentStep?.description ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(MatrimonyOnboardingState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${state.currentStepIndex + 1} of ${state.steps.length}',
                style: ThemeHelpers.getMaterialTheme(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${state.completedSteps}/${state.steps.length} completed',
                style: ThemeHelpers.getMaterialTheme(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: state.progress,
                backgroundColor: ThemeHelpers.getMaterialTheme(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeHelpers.getMaterialTheme(context).colorScheme.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(MatrimonyOnboardingStep currentStep, MatrimonyOnboardingState state) {
    final key = ValueKey(currentStep.id);
    
    switch (currentStep.id) {
      case MatrimonyConstants.welcomeStep:
        return FadeSlideIn(
          key: key,
          duration: AppMotionDurations.medium,
          child: WelcomeStep(
            onNext: () => _handleNext(),
          ),
        );
      case MatrimonyConstants.marriageIntentionsStep:
        return FadeSlideIn(
          key: key,
          duration: AppMotionDurations.medium,
          child: MarriageIntentionsStep(
            selectedIntentionId: state.data?.marriageIntentionId,
            onIntentionSelected: (intentionId) {
              ref.read(matrimonyOnboardingProvider.notifier).updateMarriageIntention(intentionId);
            },
            onNext: () => _handleNext(),
          ),
        );
      case MatrimonyConstants.familyValuesStep:
        return FadeSlideIn(
          key: key,
          duration: AppMotionDurations.medium,
          child: FamilyValuesStep(
            selectedFamilyValueIds: state.data?.familyValueIds ?? [],
            onFamilyValuesSelected: (familyValueIds) {
              ref.read(matrimonyOnboardingProvider.notifier).updateFamilyValues(familyValueIds);
            },
            onNext: () => _handleNext(),
          ),
        );
      case MatrimonyConstants.religiousPreferencesStep:
        return FadeSlideIn(
          key: key,
          duration: AppMotionDurations.medium,
          child: ReligiousPreferencesStep(
            selectedPreferenceId: state.data?.religiousPreferenceId,
            onPreferenceSelected: (preferenceId) {
              ref.read(matrimonyOnboardingProvider.notifier).updateReligiousPreference(preferenceId);
            },
            onNext: () => _handleNext(),
          ),
        );
      case MatrimonyConstants.partnerPreferencesStep:
        return FadeSlideIn(
          key: key,
          duration: AppMotionDurations.medium,
          child: PartnerPreferencesStep(
            partnerPreferences: state.data?.partnerPreferences,
            onPreferencesUpdated: (preferences) {
              ref.read(matrimonyOnboardingProvider.notifier).updatePartnerPreferences(preferences);
            },
            onNext: () => _handleNext(),
          ),
        );
      case MatrimonyConstants.familyInvolvementStep:
        return FadeSlideIn(
          key: key,
          duration: AppMotionDurations.medium,
          child: FamilyInvolvementStep(
            requiresFamilyApproval: state.data?.requiresFamilyApproval,
            familyApprovalDetails: state.data?.familyApprovalDetails,
            onInvolvementUpdated: (requiresApproval, details) {
              ref.read(matrimonyOnboardingProvider.notifier).updateFamilyInvolvement(
                requiresApproval,
                familyApprovalDetails: details,
              );
            },
            onNext: () => _handleNext(),
          ),
        );
      case MatrimonyConstants.completionStep:
        return FadeSlideIn(
          key: key,
          duration: AppMotionDurations.medium,
          child: CompletionStep(
            onboardingData: state.data,
            onComplete: () => _handleComplete(),
            onBack: () => _handleBack(),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomActions(MatrimonyOnboardingState state, MatrimonyOnboardingNotifier notifier, BuildContext context) {
    final currentStep = state.currentStep;
    if (currentStep == null) return const SizedBox.shrink();

    // Handle special cases for certain steps
    switch (currentStep.id) {
      case MatrimonyConstants.welcomeStep:
      case MatrimonyConstants.completionStep:
        return const SizedBox.shrink(); // These steps handle their own actions
      default:
        return Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              if (!state.isFirstStep)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => notifier.previousStep(),
                    child: const Text('Back'),
                  ),
                ),
              if (!state.isFirstStep) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: notifier.validateCurrentStep()
                      ? () => notifier.nextStep()
                      : null,
                  child: Text(state.isLastStep ? 'Review' : 'Next'),
                ),
              ),
            ],
          ),
        );
    }
  }

  void _handleNext() {
    final notifier = ref.read(matrimonyOnboardingProvider.notifier);
    if (notifier.validateCurrentStep()) {
      notifier.nextStep();
    }
  }

  void _handleBack() {
    ref.read(matrimonyOnboardingProvider.notifier).previousStep();
  }

  Future<void> _handleComplete() async {
    final notifier = ref.read(matrimonyOnboardingProvider.notifier);
    await notifier.completeOnboarding();
    if (!mounted) return;

    final latestState = ref.read(matrimonyOnboardingProvider);
    if (latestState.isCompleted) {
      context.go('/home');
    }
  }
}
