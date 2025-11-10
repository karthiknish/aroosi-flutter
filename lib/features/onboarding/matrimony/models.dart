import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

/// Marriage intention types
@freezed
class MarriageIntention with _$MarriageIntention {
  const factory MarriageIntention({
    required String id,
    required String title,
    required String description,
  }) = _MarriageIntention;

  factory MarriageIntention.fromJson(Map<String, dynamic> json) => _$MarriageIntentionFromJson(json);
}

/// Family value types
@freezed
class FamilyValue with _$FamilyValue {
  const factory FamilyValue({
    required String id,
    required String title,
    required String description,
  }) = _FamilyValue;

  factory FamilyValue.fromJson(Map<String, dynamic> json) => _$FamilyValueFromJson(json);
}

/// Religious preference levels
@freezed
class ReligiousPreference with _$ReligiousPreference {
  const factory ReligiousPreference({
    required String id,
    required String title,
    required String description,
  }) = _ReligiousPreference;

  factory ReligiousPreference.fromJson(Map<String, dynamic> json) => _$ReligiousPreferenceFromJson(json);
}

/// Partner preferences
@freezed
class PartnerPreferences with _$PartnerPreferences {
  const factory PartnerPreferences({
    @Default(18) int minAge,
    @Default(100) int maxAge,
    @Default([]) List<String> preferredEducation,
    @Default([]) List<String> preferredLocations,
    @Default([]) List<String> preferredReligions,
    @Default([]) List<String> preferredLanguages,
    String? minHeight,
    String? maxHeight,
    @Default(false) bool mustBeReligious,
    @Default(false) bool mustWantChildren,
    @Default(false) bool mustBeNeverMarried,
  }) = _PartnerPreferences;

  factory PartnerPreferences.fromJson(Map<String, dynamic> json) => _$PartnerPreferencesFromJson(json);
}

/// Matrimony onboarding data
@freezed
class MatrimonyOnboardingData with _$MatrimonyOnboardingData {
  const factory MatrimonyOnboardingData({
    String? marriageIntentionId,
    @Default([]) List<String> familyValueIds,
    String? religiousPreferenceId,
    PartnerPreferences? partnerPreferences,
    bool? requiresFamilyApproval,
    String? familyApprovalDetails,
  }) = _MatrimonyOnboardingData;

  factory MatrimonyOnboardingData.fromJson(Map<String, dynamic> json) => _$MatrimonyOnboardingDataFromJson(json);
}

/// Matrimony onboarding step
@freezed
class MatrimonyOnboardingStep with _$MatrimonyOnboardingStep {
  const factory MatrimonyOnboardingStep({
    required String id,
    required String title,
    required String subtitle,
    required String description,
    required int index,
    required bool isCompleted,
  }) = _MatrimonyOnboardingStep;

  factory MatrimonyOnboardingStep.fromJson(Map<String, dynamic> json) => _$MatrimonyOnboardingStepFromJson(json);
}

/// Matrimony onboarding state
@freezed
class MatrimonyOnboardingState with _$MatrimonyOnboardingState {
  const factory MatrimonyOnboardingState({
    @Default([]) List<MatrimonyOnboardingStep> steps,
    @Default(0) int currentStepIndex,
    MatrimonyOnboardingData? data,
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool isCompleted,
  }) = _MatrimonyOnboardingState;

  factory MatrimonyOnboardingState.fromJson(Map<String, dynamic> json) => _$MatrimonyOnboardingStateFromJson(json);
}

extension MatrimonyOnboardingStateExtensions on MatrimonyOnboardingState {
  MatrimonyOnboardingStep? get currentStep {
    if (currentStepIndex >= 0 && currentStepIndex < steps.length) {
      return steps[currentStepIndex];
    }
    return null;
  }

  bool get isFirstStep => currentStepIndex == 0;
  bool get isLastStep => currentStepIndex == steps.length - 1;
  double get progress => steps.isEmpty ? 0.0 : (currentStepIndex + 1) / steps.length;
}
