part of 'package:aroosi_flutter/features/profiles/models.dart';

/// Cultural and religious profile information for compatibility matching.
class CulturalProfile extends Equatable {
  const CulturalProfile({
    required this.religion,
    required this.religiousPractice,
    required this.motherTongue,
    required this.languages,
    required this.familyValues,
    required this.marriageViews,
    required this.traditionalValues,
    required this.familyApprovalImportance,
    this.religionImportance = 5,
    this.cultureImportance = 5,
    this.familyBackground,
    this.ethnicity,
  });

  final String? religion; // islam, christianity, hinduism, etc.
  final String? religiousPractice; // very_practicing, moderately_practicing, not_practicing, etc.
  final String? motherTongue; // native language
  final List<String> languages; // languages spoken
  final String? familyValues; // traditional, modern, mixed
  final String? marriageViews; // love_marriage, arranged_marriage, both
  final String? traditionalValues; // importance of traditions
  final String? familyApprovalImportance; // very_important, somewhat_important, not_important
  final int religionImportance; // 1-10 scale
  final int cultureImportance; // 1-10 scale
  final String? familyBackground; // description of family
  final String? ethnicity; // ethnic background

  CulturalProfile copyWith({
    String? religion,
    String? religiousPractice,
    String? motherTongue,
    List<String>? languages,
    String? familyValues,
    String? marriageViews,
    String? traditionalValues,
    String? familyApprovalImportance,
    int? religionImportance,
    int? cultureImportance,
    String? familyBackground,
    String? ethnicity,
  }) => CulturalProfile(
        religion: religion ?? this.religion,
        religiousPractice: religiousPractice ?? this.religiousPractice,
        motherTongue: motherTongue ?? this.motherTongue,
        languages: languages ?? this.languages,
        familyValues: familyValues ?? this.familyValues,
        marriageViews: marriageViews ?? this.marriageViews,
        traditionalValues: traditionalValues ?? this.traditionalValues,
        familyApprovalImportance:
            familyApprovalImportance ?? this.familyApprovalImportance,
        religionImportance: religionImportance ?? this.religionImportance,
        cultureImportance: cultureImportance ?? this.cultureImportance,
        familyBackground: familyBackground ?? this.familyBackground,
        ethnicity: ethnicity ?? this.ethnicity,
      );

  static CulturalProfile fromJson(Map<String, dynamic> json) => CulturalProfile(
        religion: json['religion']?.toString(),
        religiousPractice: json['religiousPractice']?.toString(),
        motherTongue: json['motherTongue']?.toString(),
        languages: (json['languages'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        familyValues: json['familyValues']?.toString(),
        marriageViews: json['marriageViews']?.toString(),
        traditionalValues: json['traditionalValues']?.toString(),
        familyApprovalImportance: json['familyApprovalImportance']?.toString(),
        religionImportance:
            json['religionImportance'] is int ? json['religionImportance'] : 5,
        cultureImportance:
            json['cultureImportance'] is int ? json['cultureImportance'] : 5,
        familyBackground: json['familyBackground']?.toString(),
        ethnicity: json['ethnicity']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (religion != null) 'religion': religion,
        if (religiousPractice != null) 'religiousPractice': religiousPractice,
        if (motherTongue != null) 'motherTongue': motherTongue,
        'languages': languages,
        if (familyValues != null) 'familyValues': familyValues,
        if (marriageViews != null) 'marriageViews': marriageViews,
        if (traditionalValues != null) 'traditionalValues': traditionalValues,
        if (familyApprovalImportance != null)
          'familyApprovalImportance': familyApprovalImportance,
        'religionImportance': religionImportance,
        'cultureImportance': cultureImportance,
        if (familyBackground != null) 'familyBackground': familyBackground,
        if (ethnicity != null) 'ethnicity': ethnicity,
      };

  @override
  List<Object?> get props => [
        religion,
        religiousPractice,
        motherTongue,
        languages,
        familyValues,
        marriageViews,
        traditionalValues,
        familyApprovalImportance,
        religionImportance,
        cultureImportance,
        familyBackground,
        ethnicity,
      ];
}
