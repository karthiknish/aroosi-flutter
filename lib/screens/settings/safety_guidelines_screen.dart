import 'package:flutter/material.dart';
import 'package:aroosi_flutter/theme/theme.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';

class SafetyGuidelinesScreen extends StatelessWidget {
  const SafetyGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textTheme = theme.textTheme;

    return AppScaffold(
      title: 'Safety Guidelines',
      usePadding: false,
      child: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Text(
            'Safety Guidelines',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'Your safety is our top priority. Please follow these guidelines to ensure a safe and positive experience on Aroosi.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: Spacing.xl),

          _buildSection(
            title: 'Online Safety',
            content: '''
• Keep conversations on the platform until you feel comfortable.
• Be mindful when sharing personal information like your address, phone number, or financial details.
• Trust your instincts. If something feels off, it probably is.
• Report any suspicious behavior or harassment immediately.
''',
            theme: theme,
            icon: Icons.security,
          ),

          _buildSection(
            title: 'Meeting in Person',
            content: '''
• Meet in a public place for the first few times.
• Tell a friend or family member where you are going and who you are meeting.
• Arrange your own transportation to and from the meeting place.
• Keep your phone charged and with you at all times.
''',
            theme: theme,
            icon: Icons.people,
          ),

          _buildSection(
            title: 'Financial Safety',
            content: '''
• Never send money to someone you haven't met in person.
• Be wary of requests for financial assistance or investment opportunities.
• Protect your banking and credit card information.
• Report any users who ask for money or financial details.
''',
            theme: theme,
            icon: Icons.attach_money,
          ),

          _buildSection(
            title: 'Reporting & Blocking',
            content: '''
• Use the "Report" feature to flag inappropriate behavior or content.
• Block users who make you feel uncomfortable or violate our guidelines.
• We take all reports seriously and investigate them promptly.
• Your report is confidential and will not be shared with the reported user.
''',
            theme: theme,
            icon: Icons.report_problem,
          ),

          const SizedBox(height: Spacing.xl),
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    'If you are in immediate danger, please contact your local emergency services.',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required ThemeData theme,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: Spacing.sm),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
