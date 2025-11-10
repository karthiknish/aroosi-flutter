import 'package:flutter/material.dart';

import 'package:aroosi_flutter/theme/colors.dart';
import 'package:aroosi_flutter/theme/motion.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';

class GuidedStep {
  const GuidedStep({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class JourneyModulesSection extends StatelessWidget {
  const JourneyModulesSection({
    super.key,
    required this.showIcebreakers,
    required this.showFamilyInvolvement,
    required this.showCourtshipJourney,
    required this.onIcebreakersChanged,
    required this.onFamilyInvolvementChanged,
    required this.onCourtshipJourneyChanged,
    required this.icebreakerPrompts,
    required this.familySteps,
    required this.courtshipSteps,
  });

  final bool showIcebreakers;
  final bool showFamilyInvolvement;
  final bool showCourtshipJourney;
  final ValueChanged<bool> onIcebreakersChanged;
  final ValueChanged<bool> onFamilyInvolvementChanged;
  final ValueChanged<bool> onCourtshipJourneyChanged;
  final List<String> icebreakerPrompts;
  final List<GuidedStep> familySteps;
  final List<GuidedStep> courtshipSteps;

  @override
  Widget build(BuildContext context) {
    final moduleChips = [
      _buildTogglePill(
        context,
        icon: Icons.psychology,
        title: showIcebreakers ? 'Icebreakers active' : 'Cultural icebreakers',
        description: 'Curated prompts for warm conversations',
        selected: showIcebreakers,
        accent: AppColors.primary,
        onChanged: onIcebreakersChanged,
      ),
      _buildTogglePill(
        context,
        icon: Icons.family_restroom,
        title:
            showFamilyInvolvement ? 'Family guides active' : 'Family involvement',
        description: 'Plan respectful steps with elders',
        selected: showFamilyInvolvement,
        accent: Colors.purple,
        onChanged: onFamilyInvolvementChanged,
      ),
      _buildTogglePill(
        context,
        icon: Icons.timeline,
        title: showCourtshipJourney ? 'Journey map active' : 'Courtship journey',
        description: 'Track milestones from salaam to nikkah',
        selected: showCourtshipJourney,
        accent: AppColors.secondary,
        onChanged: onCourtshipJourneyChanged,
      ),
    ];

    final moduleCards = <Widget>[];

    if (showIcebreakers) {
      moduleCards.add(
        _buildModuleCard(
          context,
          icon: Icons.chat_bubble_outline,
          accent: AppColors.primary,
          title: 'Cultural conversation sparks',
          description:
              'Use these respectful prompts once a connection is mutual to keep dialogue heartfelt.',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: icebreakerPrompts
                .map(
                  (prompt) => _buildPromptChip(
                    context,
                    label: prompt,
                    color: AppColors.primary,
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    if (showFamilyInvolvement) {
      moduleCards.add(
        _buildModuleCard(
          context,
          icon: Icons.groups,
          accent: Colors.purple,
          title: 'Family involvement playbook',
          description:
              'Invite elders respectfully at every milestone with gentle scripts and expectations.',
          child: Column(
            children: familySteps
                .map(
                  (step) => _buildJourneyStep(
                    context,
                    icon: step.icon,
                    title: step.title,
                    description: step.subtitle,
                    color: Colors.purple,
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    if (showCourtshipJourney) {
      moduleCards.add(
        _buildModuleCard(
          context,
          icon: Icons.route,
          accent: AppColors.secondary,
          title: 'Courtship journey map',
          description:
              'Visualise progress from respectful introductions to shared future planning.',
          child: Column(
            children: courtshipSteps
                .map(
                  (step) => _buildJourneyStep(
                    context,
                    icon: step.icon,
                    title: step.title,
                    description: step.subtitle,
                    color: AppColors.secondary,
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    final theme = ThemeHelpers.getMaterialTheme(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Journey modules',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: moduleChips),
        if (moduleCards.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...moduleCards.expand((card) => [card, const SizedBox(height: 16)]),
        ],
      ],
    );
  }

  Widget _buildTogglePill(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool selected,
    required Color accent,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    return GestureDetector(
      onTap: () => onChanged(!selected),
      child: AnimatedContainer(
        duration: AppMotionDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: const BoxConstraints(minWidth: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: selected
              ? LinearGradient(
                  colors: [accent.withAlpha(56), accent.withAlpha(31)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : theme.colorScheme.surface.withAlpha(229),
          border: Border.all(
            color: selected
                ? accent.withAlpha(89)
                : theme.colorScheme.outline.withAlpha(31),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accent.withAlpha(selected ? 51 : 31),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(166),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required IconData icon,
    required Color accent,
    required String title,
    required String description,
    required Widget child,
  }) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [accent.withAlpha(36), accent.withAlpha(13)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.withAlpha(51)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withAlpha(46),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(166),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(191),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyStep(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(166),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
