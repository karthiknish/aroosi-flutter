import 'package:aroosi_flutter/features/profiles/models.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/models.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/constants.dart';

/// Utility class to integrate matrimony onboarding preferences with search filters
class MatrimonySearchIntegration {
  /// Convert matrimony onboarding data to search filters
  static SearchFilters fromMatrimonyOnboarding(MatrimonyOnboardingData? onboardingData) {
    if (onboardingData == null) return const SearchFilters();

    final partnerPreferences = onboardingData.partnerPreferences;
    
    return SearchFilters(
      // Basic filters from partner preferences
      minAge: partnerPreferences?.minAge,
      maxAge: partnerPreferences?.maxAge,
      
      // Cultural filters from onboarding
      marriageIntention: onboardingData.marriageIntentionId,
      
      // Education filters from partner preferences
      education: partnerPreferences?.preferredEducation.isNotEmpty == true
          ? partnerPreferences!.preferredEducation.first
          : null,
      
      // Language filters from partner preferences
      languages: partnerPreferences?.preferredLanguages,
      
      // Religion filters from partner preferences
      religion: partnerPreferences?.preferredReligions.isNotEmpty == true
          ? partnerPreferences!.preferredReligions.first
          : null,
      
      // Matrimony-specific filters
      requiresFamilyApproval: onboardingData.requiresFamilyApproval,
      mustBeReligious: partnerPreferences?.mustBeReligious,
      mustWantChildren: partnerPreferences?.mustWantChildren,
      mustBeNeverMarried: partnerPreferences?.mustBeNeverMarried,
      
      // Set default sort to relevance for matrimony searches
      sort: 'relevance',
    );
  }

  /// Get display text for marriage intention
  static String getMarriageIntentionDisplay(String? intentionId) {
    if (intentionId == null) return 'Any';
    
    final intention = MarriageIntentionOptions.options
        .where((i) => i.id == intentionId)
        .firstOrNull;
    
    return intention?.title ?? 'Any';
  }

  /// Get display text for religious preference
  static String getReligiousPreferenceDisplay(String? preferenceId) {
    if (preferenceId == null) return 'Any';
    
    final preference = ReligiousPreferenceOptions.options
        .where((p) => p.id == preferenceId)
        .firstOrNull;
    
    return preference?.title ?? 'Any';
  }

  /// Create search filter presets based on common matrimony preferences
  static List<SearchFilters> getMatrimonyPresets() {
    return [
      // Traditional marriage preset
      SearchFilters(
        marriageIntention: 'serious_marriage',
        religion: 'islam',
        mustBeReligious: true,
        requiresFamilyApproval: true,
        sort: 'relevance',
      ),
      
      // Modern professional preset
      SearchFilters(
        marriageIntention: 'companionate_marriage',
        education: 'Bachelor\'s Degree',
        minIncome: 50000,
        sort: 'relevance',
      ),
      
      // Religious compatibility preset
      SearchFilters(
        marriageIntention: 'religious_marriage',
        mustBeReligious: true,
        sort: 'relevance',
      ),
      
      // Family-oriented preset
      SearchFilters(
        marriageIntention: 'marriage_with_family',
        requiresFamilyApproval: true,
        mustWantChildren: true,
        sort: 'relevance',
      ),
    ];
  }

  /// Get preset display name
  static String getPresetDisplayName(SearchFilters preset, int index) {
    switch (index) {
      case 0:
        return 'Traditional Marriage';
      case 1:
        return 'Modern Professional';
      case 2:
        return 'Religious Compatibility';
      case 3:
        return 'Family-Oriented';
      default:
        return 'Custom Preset';
    }
  }

  /// Get preset description
  static String getPresetDescription(SearchFilters preset, int index) {
    switch (index) {
      case 0:
        return 'Focus on traditional values and family approval';
      case 1:
        return 'Educated professionals with stable income';
      case 2:
        return 'Strong religious compatibility and shared values';
      case 3:
        return 'Family involvement and desire for children';
      default:
        return 'Custom search preferences';
    }
  }

  /// Check if filters match matrimony criteria
  static bool isMatrimonySearch(SearchFilters filters) {
    return filters.marriageIntention != null ||
           filters.requiresFamilyApproval != null ||
           filters.mustBeReligious != null ||
           filters.mustWantChildren != null ||
           filters.mustBeNeverMarried != null;
  }

  /// Enhance search filters with matrimony-specific logic
  static SearchFilters enhanceForMatrimony(SearchFilters filters) {
    // If this is a matrimony search, ensure relevance sorting
    if (isMatrimonySearch(filters) && filters.sort == null) {
      return filters.copyWith(sort: 'relevance');
    }
    
    // If family approval is required, prioritize family values
    if (filters.requiresFamilyApproval == true && filters.familyValues == null) {
      return filters.copyWith(familyValues: 'traditional');
    }
    
    // If must be religious, set religious practice to at least moderately practicing
    if (filters.mustBeReligious == true && filters.religiousPractice == null) {
      return filters.copyWith(religiousPractice: 'moderately_practicing');
    }
    
    return filters;
  }

  /// Get search suggestions based on matrimony preferences
  static List<String> getSearchSuggestions(MatrimonyOnboardingData? onboardingData) {
    if (onboardingData == null) return [];
    
    final suggestions = <String>[];
    
    // Add suggestions based on marriage intention
    if (onboardingData.marriageIntentionId != null) {
      final intention = MarriageIntentionOptions.options
          .where((i) => i.id == onboardingData.marriageIntentionId)
          .firstOrNull;
      
      if (intention != null) {
        switch (intention.id) {
          case 'serious_marriage':
            suggestions.addAll(['committed', 'long-term', 'marriage-minded']);
            break;
          case 'marriage_with_family':
            suggestions.addAll(['family-oriented', 'traditional', 'culturally-rooted']);
            break;
          case 'religious_marriage':
            suggestions.addAll(['religious', 'faithful', 'spiritual']);
            break;
          case 'companionate_marriage':
            suggestions.addAll(['partnership', 'friendship', 'companionship']);
            break;
        }
      }
    }
    
    // Add suggestions based on family values
    if (onboardingData.familyValueIds.isNotEmpty) {
      suggestions.addAll(['family-values', 'respectful', 'supportive']);
    }
    
    // Add suggestions based on religious preference
    if (onboardingData.religiousPreferenceId != null) {
      final preference = ReligiousPreferenceOptions.options
          .where((p) => p.id == onboardingData.religiousPreferenceId)
          .firstOrNull;
      
      if (preference != null) {
        switch (preference.id) {
          case 'very_religious':
            suggestions.addAll(['devout', 'practicing', 'faithful']);
            break;
          case 'moderately_religious':
            suggestions.addAll(['balanced', 'moderate', 'spiritual']);
            break;
          case 'spiritual_not_religious':
            suggestions.addAll(['spiritual', 'mindful', 'conscious']);
            break;
        }
      }
    }
    
    return suggestions.toSet().toList(); // Remove duplicates
  }
}
