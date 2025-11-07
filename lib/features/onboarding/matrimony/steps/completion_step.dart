import 'package:flutter/material.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/models.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/constants.dart';
import 'package:aroosi_flutter/l10n/app_localizations.dart';

class CompletionStep extends StatelessWidget {
  final MatrimonyOnboardingData? onboardingData;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const CompletionStep({
    super.key,
    this.onboardingData,
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (onboardingData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          
          // Success illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withAlpha(100),
                  Colors.lightGreen.withAlpha(100),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Success message
          Text(
            'Your Matrimony Profile is Ready!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Thank you for completing your matrimony preferences. We\'ll now use this information to find compatible matches for you.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Summary of preferences
          _buildPreferencesSummary(context, onboardingData!),
          
          const Spacer(flex: 2),
          
          // Action buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Start Finding Matches',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Review Preferences',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Next steps info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(20),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'What happens next?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• We\'ll start showing you compatible matches\n• You can browse and connect with potential partners\n• Your preferences can be updated anytime in settings',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPreferencesSummary(BuildContext context, MatrimonyOnboardingData data) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Preferences Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Marriage intention
          _buildSummaryItem(
            context,
            'Marriage Intention',
            _getMarriageIntentionTitle(data.marriageIntentionId),
            Icons.favorite,
          ),
          
          // Family values
          if (data.familyValueIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSummaryItem(
              context,
              'Family Values',
              '${data.familyValueIds.length} selected',
              Icons.family_restroom,
            ),
          ],
          
          // Religious preference
          if (data.religiousPreferenceId != null) ...[
            const SizedBox(height: 12),
            _buildSummaryItem(
              context,
              'Religious Preference',
              _getReligiousPreferenceTitle(data.religiousPreferenceId),
              Icons.mosque,
            ),
          ],
          
          // Partner preferences
          if (data.partnerPreferences != null) ...[
            const SizedBox(height: 12),
            _buildSummaryItem(
              context,
              'Partner Preferences',
              'Age ${data.partnerPreferences!.minAge}-${data.partnerPreferences!.maxAge}',
              Icons.person_search,
            ),
          ],
          
          // Family involvement
          const SizedBox(height: 12),
          _buildSummaryItem(
            context,
            'Family Involvement',
            data.requiresFamilyApproval ? 'Required' : 'Independent',
            data.requiresFamilyApproval ? Icons.groups : Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMarriageIntentionTitle(String? intentionId) {
    if (intentionId == null) return 'Not specified';
    
    final intention = MarriageIntentionOptions.options
        .where((i) => i.id == intentionId)
        .firstOrNull;
    
    return intention?.title ?? 'Not specified';
  }

  String _getReligiousPreferenceTitle(String? preferenceId) {
    if (preferenceId == null) return 'Not specified';
    
    final preference = ReligiousPreferenceOptions.options
        .where((p) => p.id == preferenceId)
        .firstOrNull;
    
    return preference?.title ?? 'Not specified';
  }
}
