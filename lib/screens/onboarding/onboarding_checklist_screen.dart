import 'package:flutter/material.dart';
import 'package:aroosi_flutter/theme/theme.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';

class OnboardingChecklistScreen extends StatefulWidget {
  const OnboardingChecklistScreen({super.key});

  @override
  State<OnboardingChecklistScreen> createState() =>
      _OnboardingChecklistScreenState();
}

class _OnboardingChecklistScreenState extends State<OnboardingChecklistScreen> {
  final _steps = [
    {
      'title': 'Upload a profile photo',
      'description': 'This will help others recognize you.',
      'icon': Icons.photo,
      'isCompleted': false,
    },
    {
      'title': 'Share a short bio',
      'description': 'Tell us about yourself in a few words.',
      'icon': Icons.info,
      'isCompleted': false,
    },
    {
      'title': 'Select your interests',
      'description': 'Choose topics you are interested in.',
      'icon': Icons.interests,
      'isCompleted': false,
    },
    {
      'title': 'Complete cultural assessment',
      'description': 'Help us understand your cultural preferences.',
      'icon': Icons.language,
      'isCompleted': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textTheme = theme.textTheme;

    return AppScaffold(
      title: 'Getting Started',
      usePadding: false,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Row(
              children: [
                CircularProgressIndicator(
                  value: 0.5,
                  backgroundColor: theme.colorScheme.surface,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '50% Complete',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Complete your profile to get better matches',
                        style: textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _steps.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final step = _steps[index];
                final isCompleted = step['isCompleted'] as bool;

                return Card(
                  elevation: 0,
                  color: isCompleted
                      ? theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        )
                      : theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isCompleted
                          ? Colors.transparent
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: isCompleted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      step['title'] as String,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      step['description'] as String,
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: isCompleted
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                    onTap: () {
                      if (!isCompleted) {
                        // Navigate to step
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: FilledButton(
              onPressed: () {
                // Continue to next incomplete step
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Continue Setup'),
            ),
          ),
        ],
      ),
    );
  }
}
