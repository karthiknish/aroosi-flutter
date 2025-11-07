import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/models.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/matrimony_onboarding_repository.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/constants.dart';

/// Provider for matrimony onboarding repository
final matrimonyOnboardingRepositoryProvider = Provider<MatrimonyOnboardingRepository>((ref) {
  return MatrimonyOnboardingRepository();
});

/// Notifier for matrimony onboarding state
class MatrimonyOnboardingNotifier extends Notifier<MatrimonyOnboardingState> {
  MatrimonyOnboardingRepository get _repository => ref.read(matrimonyOnboardingRepositoryProvider);

  @override
  MatrimonyOnboardingState build() {
    final steps = MatrimonyStepInfo.allSteps.map((stepInfo) => MatrimonyOnboardingStep(
      id: stepInfo.id,
      title: stepInfo.title,
      subtitle: stepInfo.subtitle,
      description: stepInfo.description,
      index: stepInfo.index,
      isCompleted: false,
    )).toList();

    return MatrimonyOnboardingState(
      steps: steps,
      currentStepIndex: 0,
      data: const MatrimonyOnboardingData(),
    );
  }

  /// Initialize onboarding with existing data
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final existingData = await _repository.loadMatrimonyOnboardingData();
      if (existingData != null) {
        state = state.copyWith(
          data: existingData,
          isLoading: false,
        );
        _updateStepCompletion();
      } else {
        state = state.copyWith(
          data: const MatrimonyOnboardingData(),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load onboarding data: $e',
        isLoading: false,
      );
    }
  }

  /// Navigate to next step
  void nextStep() {
    if (MatrimonyOnboardingStateExtensions(state).isLastStep) return;
    
    state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
  }

  /// Navigate to previous step
  void previousStep() {
    if (MatrimonyOnboardingStateExtensions(state).isFirstStep) return;
    
    state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
  }

  /// Go to specific step
  void goToStep(int index) {
    if (index >= 0 && index < state.steps.length) {
      state = state.copyWith(currentStepIndex: index);
    }
  }

  /// Update marriage intention
  void updateMarriageIntention(String marriageIntentionId) {
    final updatedData = state.data?.copyWith(marriageIntentionId: marriageIntentionId) ?? 
                       MatrimonyOnboardingData(marriageIntentionId: marriageIntentionId);
    
    state = state.copyWith(data: updatedData);
    _updateStepCompletion();
    _saveProgress();
  }

  /// Update family values
  void updateFamilyValues(List<String> familyValueIds) {
    final updatedData = state.data?.copyWith(familyValueIds: familyValueIds) ?? 
                       MatrimonyOnboardingData(familyValueIds: familyValueIds);
    
    state = state.copyWith(data: updatedData);
    _updateStepCompletion();
    _saveProgress();
  }

  /// Update religious preference
  void updateReligiousPreference(String religiousPreferenceId) {
    final updatedData = state.data?.copyWith(religiousPreferenceId: religiousPreferenceId) ?? 
                       MatrimonyOnboardingData(religiousPreferenceId: religiousPreferenceId);
    
    state = state.copyWith(data: updatedData);
    _updateStepCompletion();
    _saveProgress();
  }

  /// Update partner preferences
  void updatePartnerPreferences(PartnerPreferences partnerPreferences) {
    final updatedData = state.data?.copyWith(partnerPreferences: partnerPreferences) ?? 
                       MatrimonyOnboardingData(partnerPreferences: partnerPreferences);
    
    state = state.copyWith(data: updatedData);
    _updateStepCompletion();
    _saveProgress();
  }

  /// Update family involvement
  void updateFamilyInvolvement(bool requiresFamilyApproval, {String? familyApprovalDetails}) {
    final updatedData = state.data?.copyWith(
      requiresFamilyApproval: requiresFamilyApproval,
      familyApprovalDetails: familyApprovalDetails,
    ) ?? MatrimonyOnboardingData(
      requiresFamilyApproval: requiresFamilyApproval,
      familyApprovalDetails: familyApprovalDetails,
    );
    
    state = state.copyWith(data: updatedData);
    _updateStepCompletion();
    _saveProgress();
  }

  /// Validate current step
  bool validateCurrentStep() {
    final currentStepId = MatrimonyOnboardingStateExtensions(state).currentStep?.id;
    if (currentStepId == null) return false;

    switch (currentStepId) {
      case MatrimonyConstants.welcomeStep:
        return true; // Welcome step doesn't require validation
      case MatrimonyConstants.marriageIntentionsStep:
        return state.data?.marriageIntentionId != null;
      case MatrimonyConstants.familyValuesStep:
        return state.data?.familyValueIds.isNotEmpty == true;
      case MatrimonyConstants.religiousPreferencesStep:
        return state.data?.religiousPreferenceId != null;
      case MatrimonyConstants.partnerPreferencesStep:
        return state.data?.partnerPreferences != null;
      case MatrimonyConstants.familyInvolvementStep:
        return state.data?.requiresFamilyApproval != null;
      case MatrimonyConstants.completionStep:
        return _isAllStepsCompleted();
      default:
        return false;
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    if (!_isAllStepsCompleted()) {
      state = state.copyWith(error: 'Please complete all steps before finishing');
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      await _repository.markOnboardingCompleted();
      state = state.copyWith(
        isCompleted: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to complete onboarding: $e',
        isLoading: false,
      );
    }
  }

  /// Reset onboarding
  Future<void> resetOnboarding() async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.resetOnboardingData();
      state = MatrimonyOnboardingState(
        steps: MatrimonyStepInfo.allSteps.map((stepInfo) => MatrimonyOnboardingStep(
          id: stepInfo.id,
          title: stepInfo.title,
          subtitle: stepInfo.subtitle,
          description: stepInfo.description,
          index: stepInfo.index,
          isCompleted: false,
        )).toList(),
        currentStepIndex: 0,
        data: const MatrimonyOnboardingData(),
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to reset onboarding: $e',
        isLoading: false,
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Update step completion status based on current data
  void _updateStepCompletion() {
    final updatedSteps = state.steps.map((step) {
      bool isCompleted = false;
      
      switch (step.id) {
        case MatrimonyConstants.welcomeStep:
          isCompleted = true; // Always completed
          break;
        case MatrimonyConstants.marriageIntentionsStep:
          isCompleted = state.data?.marriageIntentionId != null;
          break;
        case MatrimonyConstants.familyValuesStep:
          isCompleted = state.data?.familyValueIds.isNotEmpty == true;
          break;
        case MatrimonyConstants.religiousPreferencesStep:
          isCompleted = state.data?.religiousPreferenceId != null;
          break;
        case MatrimonyConstants.partnerPreferencesStep:
          isCompleted = state.data?.partnerPreferences != null;
          break;
        case MatrimonyConstants.familyInvolvementStep:
          isCompleted = state.data?.requiresFamilyApproval != null;
          break;
        case MatrimonyConstants.completionStep:
          isCompleted = _isAllStepsCompleted();
          break;
      }
      
      return step.copyWith(isCompleted: isCompleted);
    }).toList();

    state = state.copyWith(steps: updatedSteps);
  }

  /// Check if all steps are completed
  bool _isAllStepsCompleted() {
    final data = state.data;
    if (data == null) return false;

    return data.marriageIntentionId != null &&
           data.familyValueIds.isNotEmpty &&
           data.religiousPreferenceId != null &&
           data.partnerPreferences != null &&
           data.requiresFamilyApproval != null;
  }

  /// Save progress to repository
  Future<void> _saveProgress() async {
    try {
      if (state.data != null) {
        await _repository.saveMatrimonyOnboardingData(state.data!);
      }
    } catch (e) {
      // Don't update state on save error to avoid disrupting UI
      // Could add retry logic or show toast notification
    }
  }
}

/// Provider for matrimony onboarding state
final matrimonyOnboardingProvider = NotifierProvider<MatrimonyOnboardingNotifier, MatrimonyOnboardingState>(
  MatrimonyOnboardingNotifier.new,
);

/// Extension for easy access to current step data
extension MatrimonyOnboardingStateExtension on MatrimonyOnboardingState {
  MatrimonyOnboardingStep? get currentStep {
    if (currentStepIndex >= 0 && currentStepIndex < steps.length) {
      return steps[currentStepIndex];
    }
    return null;
  }

  bool get isFirstStep => currentStepIndex == 0;
  bool get isLastStep => currentStepIndex == steps.length - 1;
  double get progress => steps.isEmpty ? 0.0 : (currentStepIndex + 1) / steps.length;
  int get completedSteps => steps.where((step) => step.isCompleted).length;
}
