import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aroosi_flutter/theme/motion.dart';
import 'package:aroosi_flutter/theme/theme.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/widgets/animations/motion.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';

class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textTheme = theme.textTheme;

    return AppScaffold(
      title: 'Welcome',
      usePadding: false,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: Spacing.xxl),
            Text(
              'You\'re All Set!',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.md),
            Text(
              'Your profile is now complete. You can start exploring matches and connecting with others.',
              style: textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xxl),
            FilledButton(
              onPressed: () {
                // Navigate to home
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Start Exploring'),
            ),
          ],
        ),
      ),
    );
  }
}
