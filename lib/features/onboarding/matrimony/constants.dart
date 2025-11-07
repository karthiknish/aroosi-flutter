import 'package:flutter/material.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/models.dart';

/// Constants for matrimony onboarding
class MatrimonyConstants {
  // Step IDs
  static const String welcomeStep = 'welcome';
  static const String marriageIntentionsStep = 'marriage_intentions';
  static const String familyValuesStep = 'family_values';
  static const String religiousPreferencesStep = 'religious_preferences';
  static const String partnerPreferencesStep = 'partner_preferences';
  static const String familyInvolvementStep = 'family_involvement';
  static const String completionStep = 'completion';

  // Validation constants
  static const int minimumAge = 18;
  static const int maximumAge = 100;
  static const int minimumAboutMeLength = 50;
  static const int maximumAboutMeLength = 500;
  static const int maximumPreferredLocations = 5;
  static const int maximumPreferredLanguages = 3;
}

/// Marriage intention options
class MarriageIntentionOptions {
  static const List<MarriageIntention> options = [
    MarriageIntention(
      id: 'serious_marriage',
      title: 'Serious Marriage',
      description: 'Looking for a lifelong committed marriage partner',
    ),
    MarriageIntention(
      id: 'marriage_with_family',
      title: 'Marriage with Family Involvement',
      description: 'Seeking marriage with active family participation and approval',
    ),
    MarriageIntention(
      id: 'religious_marriage',
      title: 'Religious Marriage',
      description: 'Looking for marriage following religious traditions and values',
    ),
    MarriageIntention(
      id: 'companionate_marriage',
      title: 'Companionate Marriage',
      description: 'Seeking a partnership built on friendship and mutual respect',
    ),
  ];
}

/// Family value options
class FamilyValueOptions {
  static const List<FamilyValue> options = [
    FamilyValue(
      id: 'family_first',
      title: 'Family First',
      description: 'Family decisions and priorities come first',
    ),
    FamilyValue(
      id: 'traditional_values',
      title: 'Traditional Values',
      description: 'Following cultural and family traditions',
    ),
    FamilyValue(
      id: 'elders_respect',
      title: 'Respect for Elders',
      description: 'Deep respect for parents and elder family members',
    ),
    FamilyValue(
      id: 'family_support',
      title: 'Family Support System',
      description: 'Strong family support in important life decisions',
    ),
    FamilyValue(
      id: 'cultural_heritage',
      title: 'Cultural Heritage',
      description: 'Preserving and celebrating cultural heritage',
    ),
    FamilyValue(
      id: 'intergenerational_living',
      title: 'Intergenerational Living',
      description: 'Living with or near extended family members',
    ),
  ];
}

/// Religious preference options
class ReligiousPreferenceOptions {
  static const List<ReligiousPreference> options = [
    ReligiousPreference(
      id: 'very_religious',
      title: 'Very Religious',
      description: 'Religion is central to daily life and decisions',
    ),
    ReligiousPreference(
      id: 'moderately_religious',
      title: 'Moderately Religious',
      description: 'Religious practices are important but balanced with modern life',
    ),
    ReligiousPreference(
      id: 'culturally_religious',
      title: 'Culturally Religious',
      description: 'Following religious traditions for cultural connection',
    ),
    ReligiousPreference(
      id: 'spiritual_not_religious',
      title: 'Spiritual Not Religious',
      description: 'Spiritual values without strict religious adherence',
    ),
    ReligiousPreference(
      id: 'not_religious',
      title: 'Not Religious',
      description: 'Secular lifestyle with respect for others\' beliefs',
    ),
  ];
}

/// Education level options
class EducationOptions {
  static const List<String> options = [
    'High School',
    'Some College',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD/Doctorate',
    'Professional Degree',
    'Trade/Vocational',
  ];
}

/// Language options
class LanguageOptions {
  static const List<String> options = [
    'English',
    'Pashto',
    'Dari',
    'Urdu',
    'Farsi',
    'Hindi',
    'Arabic',
    'Spanish',
    'French',
    'German',
    'Other',
  ];
}

/// Religion options for partner preferences
class PartnerReligionOptions {
  static const List<String> options = [
    'Islam',
    'Christianity',
    'Hinduism',
    'Sikhism',
    'Judaism',
    'Buddhism',
    'Spiritual',
    'No Preference',
    'Other',
  ];
}

/// Step information for matrimony onboarding
class MatrimonyStepInfo {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final int index;

  const MatrimonyStepInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.index,
  });

  static const List<MatrimonyStepInfo> allSteps = [
    MatrimonyStepInfo(
      id: MatrimonyConstants.welcomeStep,
      title: 'Welcome to Matrimony',
      subtitle: 'Begin your journey to meaningful marriage',
      description: 'We\'ll help you find a compatible life partner through our thoughtful matrimony process',
      icon: Icons.favorite,
      index: 0,
    ),
    MatrimonyStepInfo(
      id: MatrimonyConstants.marriageIntentionsStep,
      title: 'Marriage Intentions',
      subtitle: 'What type of marriage are you seeking?',
      description: 'Help us understand your marriage goals to find the right match',
      icon: Icons.favorite_border,
      index: 1,
    ),
    MatrimonyStepInfo(
      id: MatrimonyConstants.familyValuesStep,
      title: 'Family Values',
      subtitle: 'What role does family play in your life?',
      description: 'Family values are important in matrimony - share what matters to you',
      icon: Icons.family_restroom,
      index: 2,
    ),
    MatrimonyStepInfo(
      id: MatrimonyConstants.religiousPreferencesStep,
      title: 'Religious Preferences',
      subtitle: 'How important is religion in your marriage?',
      description: 'Religious compatibility is key for many successful marriages',
      icon: Icons.mosque,
      index: 3,
    ),
    MatrimonyStepInfo(
      id: MatrimonyConstants.partnerPreferencesStep,
      title: 'Partner Preferences',
      subtitle: 'Describe your ideal life partner',
      description: 'Help us understand who you\'re looking for in a marriage partner',
      icon: Icons.person_search,
      index: 4,
    ),
    MatrimonyStepInfo(
      id: MatrimonyConstants.familyInvolvementStep,
      title: 'Family Involvement',
      subtitle: 'Should your family be involved in the process?',
      description: 'Many cultures value family involvement in marriage decisions',
      icon: Icons.groups,
      index: 5,
    ),
    MatrimonyStepInfo(
      id: MatrimonyConstants.completionStep,
      title: 'Ready to Begin',
      subtitle: 'Your matrimony profile is almost complete',
      description: 'Review your preferences and start your journey to finding love',
      icon: Icons.check_circle,
      index: 6,
    ),
  ];

  static MatrimonyStepInfo getStep(int index) {
    if (index >= 0 && index < allSteps.length) {
      return allSteps[index];
    }
    return allSteps.first;
  }

  static MatrimonyStepInfo getStepById(String id) {
    return allSteps.firstWhere(
      (step) => step.id == id,
      orElse: () => allSteps.first,
    );
  }
}
