import 'package:flutter/material.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/constants.dart';
import 'package:aroosi_flutter/l10n/app_localizations.dart';

class ReligiousPreferencesStep extends StatelessWidget {
  final String? selectedPreferenceId;
  final Function(String) onPreferenceSelected;
  final VoidCallback onNext;

  const ReligiousPreferencesStep({
    super.key,
    this.selectedPreferenceId,
    required this.onPreferenceSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          Text(
            'How important is religion in your marriage?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Religious compatibility is key for many successful marriages',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Religious preference options
          Expanded(
            child: ListView.builder(
              itemCount: ReligiousPreferenceOptions.options.length,
              itemBuilder: (context, index) {
                final preference = ReligiousPreferenceOptions.options[index];
                final isSelected = preference.id == selectedPreferenceId;
                
                return _buildPreferenceCard(
                  context,
                  preference,
                  isSelected,
                  () => onPreferenceSelected(preference.id),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Next button
          if (selectedPreferenceId != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreferenceCard(
    BuildContext context,
    ReligiousPreference preference,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withAlpha(50),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              color: isSelected
                  ? theme.colorScheme.primary.withAlpha(20)
                  : theme.colorScheme.surface,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(30),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Radio button with icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          _getIconForPreference(preference.id),
                          size: 20,
                          color: theme.colorScheme.onPrimary,
                        )
                      : Icon(
                          _getIconForPreference(preference.id),
                          size: 20,
                          color: theme.colorScheme.outline,
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preference.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preference.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForPreference(String preferenceId) {
    switch (preferenceId) {
      case 'very_religious':
        return Icons.mosque;
      case 'moderately_religious':
        return Icons.balance;
      case 'culturally_religious':
        return Icons.culture;
      case 'spiritual_not_religious':
        return Icons.spa;
      case 'not_religious':
        return Icons.public;
      default:
        return Icons.help_outline;
    }
  }
}
