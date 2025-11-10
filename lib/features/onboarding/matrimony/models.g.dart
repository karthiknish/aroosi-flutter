// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MarriageIntentionImpl _$$MarriageIntentionImplFromJson(
  Map<String, dynamic> json,
) => _$MarriageIntentionImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$$MarriageIntentionImplToJson(
  _$MarriageIntentionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
};

_$FamilyValueImpl _$$FamilyValueImplFromJson(Map<String, dynamic> json) =>
    _$FamilyValueImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$$FamilyValueImplToJson(_$FamilyValueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
    };

_$ReligiousPreferenceImpl _$$ReligiousPreferenceImplFromJson(
  Map<String, dynamic> json,
) => _$ReligiousPreferenceImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$$ReligiousPreferenceImplToJson(
  _$ReligiousPreferenceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
};

_$PartnerPreferencesImpl _$$PartnerPreferencesImplFromJson(
  Map<String, dynamic> json,
) => _$PartnerPreferencesImpl(
  minAge: (json['minAge'] as num?)?.toInt() ?? 18,
  maxAge: (json['maxAge'] as num?)?.toInt() ?? 100,
  preferredEducation:
      (json['preferredEducation'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  preferredLocations:
      (json['preferredLocations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  preferredReligions:
      (json['preferredReligions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  preferredLanguages:
      (json['preferredLanguages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  minHeight: json['minHeight'] as String?,
  maxHeight: json['maxHeight'] as String?,
  mustBeReligious: json['mustBeReligious'] as bool? ?? false,
  mustWantChildren: json['mustWantChildren'] as bool? ?? false,
  mustBeNeverMarried: json['mustBeNeverMarried'] as bool? ?? false,
);

Map<String, dynamic> _$$PartnerPreferencesImplToJson(
  _$PartnerPreferencesImpl instance,
) => <String, dynamic>{
  'minAge': instance.minAge,
  'maxAge': instance.maxAge,
  'preferredEducation': instance.preferredEducation,
  'preferredLocations': instance.preferredLocations,
  'preferredReligions': instance.preferredReligions,
  'preferredLanguages': instance.preferredLanguages,
  'minHeight': instance.minHeight,
  'maxHeight': instance.maxHeight,
  'mustBeReligious': instance.mustBeReligious,
  'mustWantChildren': instance.mustWantChildren,
  'mustBeNeverMarried': instance.mustBeNeverMarried,
};

_$MatrimonyOnboardingDataImpl _$$MatrimonyOnboardingDataImplFromJson(
  Map<String, dynamic> json,
) => _$MatrimonyOnboardingDataImpl(
  marriageIntentionId: json['marriageIntentionId'] as String?,
  familyValueIds:
      (json['familyValueIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  religiousPreferenceId: json['religiousPreferenceId'] as String?,
  partnerPreferences: json['partnerPreferences'] == null
      ? null
      : PartnerPreferences.fromJson(
          json['partnerPreferences'] as Map<String, dynamic>,
        ),
  requiresFamilyApproval: json['requiresFamilyApproval'] as bool?,
  familyApprovalDetails: json['familyApprovalDetails'] as String?,
);

Map<String, dynamic> _$$MatrimonyOnboardingDataImplToJson(
  _$MatrimonyOnboardingDataImpl instance,
) => <String, dynamic>{
  'marriageIntentionId': instance.marriageIntentionId,
  'familyValueIds': instance.familyValueIds,
  'religiousPreferenceId': instance.religiousPreferenceId,
  'partnerPreferences': instance.partnerPreferences,
  'requiresFamilyApproval': instance.requiresFamilyApproval,
  'familyApprovalDetails': instance.familyApprovalDetails,
};

_$MatrimonyOnboardingStepImpl _$$MatrimonyOnboardingStepImplFromJson(
  Map<String, dynamic> json,
) => _$MatrimonyOnboardingStepImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  subtitle: json['subtitle'] as String,
  description: json['description'] as String,
  index: (json['index'] as num).toInt(),
  isCompleted: json['isCompleted'] as bool,
);

Map<String, dynamic> _$$MatrimonyOnboardingStepImplToJson(
  _$MatrimonyOnboardingStepImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'description': instance.description,
  'index': instance.index,
  'isCompleted': instance.isCompleted,
};

_$MatrimonyOnboardingStateImpl _$$MatrimonyOnboardingStateImplFromJson(
  Map<String, dynamic> json,
) => _$MatrimonyOnboardingStateImpl(
  steps:
      (json['steps'] as List<dynamic>?)
          ?.map(
            (e) => MatrimonyOnboardingStep.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  currentStepIndex: (json['currentStepIndex'] as num?)?.toInt() ?? 0,
  data: json['data'] == null
      ? null
      : MatrimonyOnboardingData.fromJson(json['data'] as Map<String, dynamic>),
  isLoading: json['isLoading'] as bool? ?? false,
  error: json['error'] as String?,
  isCompleted: json['isCompleted'] as bool? ?? false,
);

Map<String, dynamic> _$$MatrimonyOnboardingStateImplToJson(
  _$MatrimonyOnboardingStateImpl instance,
) => <String, dynamic>{
  'steps': instance.steps,
  'currentStepIndex': instance.currentStepIndex,
  'data': instance.data,
  'isLoading': instance.isLoading,
  'error': instance.error,
  'isCompleted': instance.isCompleted,
};
