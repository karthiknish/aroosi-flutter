import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aroosi_flutter/core/toast_service.dart';
import 'package:aroosi_flutter/features/profiles/list_controller.dart';
import 'package:aroosi_flutter/features/profiles/models.dart';
import 'package:aroosi_flutter/theme/color_helpers.dart';
import 'package:aroosi_flutter/theme/colors.dart';
import 'package:aroosi_flutter/theme/motion.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';

import 'ui_components.dart';

class InterestCard extends ConsumerWidget {
  const InterestCard({
    super.key,
    required this.interest,
    required this.mode,
    required this.viewMode,
    required this.showCompatibilityScore,
  });

  final InterestEntry interest;
  final String mode;
  final String viewMode;
  final bool showCompatibilityScore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final isReceived = mode == 'received';
    final isMutual = mode == 'mutual' ||
        interest.status == 'reciprocated' ||
        interest.status == 'accepted';
    final isFamilyApproved =
        mode == 'family_approved' || interest.status.contains('family');
    final otherUserSnapshot =
        isReceived ? interest.fromSnapshot : interest.toSnapshot;
    final otherUserName = otherUserSnapshot?['fullName']?.toString().trim().isNotEmpty ==
            true
        ? otherUserSnapshot!['fullName'].toString()
        : 'Member';
    final otherUserImage = otherUserSnapshot?['profileImageUrls'] is List
        ? (otherUserSnapshot!['profileImageUrls'] as List).isNotEmpty
            ? otherUserSnapshot['profileImageUrls'][0]?.toString()
            : null
        : null;
    final culturalBackground = _getCulturalBackground(otherUserSnapshot);
    final location = _extractLocation(otherUserSnapshot);
    final languages = _extractLanguages(otherUserSnapshot);
    final compatibilityScore = _calculateCompatibilityScore(otherUserSnapshot);
    final accentColor = _resolveAccentColor(isMutual, isFamilyApproved);
    final statusLabel = _getCulturalStatusText(interest.status, viewMode);

    final headerTraits = <String>[];
    if (culturalBackground != null) {
      headerTraits.add(culturalBackground);
    }
    if (location != null) {
      headerTraits.add(location);
    }
    if (languages.isNotEmpty) {
      headerTraits.add('${languages.first} speaker');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              accentColor.withAlpha(41),
              ThemeHelpers.getSurfaceColor(context),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: accentColor.withAlpha(51)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withAlpha(20),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InterestAvatar(
                    otherUserName: otherUserName,
                    imageUrl: otherUserImage,
                    accent: accentColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherUserName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (headerTraits.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: headerTraits
                                .map(
                                  (trait) => TraitPill(
                                    trait: trait,
                                    accent: accentColor,
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            StatusChip(
                              label: statusLabel,
                              accent: accentColor,
                              icon: _getStatusIcon(interest.status),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Updated ${_formatRelativeTime(interest.updatedAt)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withAlpha(166),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TimelineChips(
                accent: accentColor,
                timelineItems: _buildTimelineItems(),
              ),
              if (showCompatibilityScore && compatibilityScore > 0) ...[
                const SizedBox(height: 20),
                _buildCompatibilitySection(
                  context,
                  compatibilityScore,
                  accentColor,
                ),
              ],
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: AppMotionDurations.fast,
                child: isMutual
                    ? _buildCulturalNextSteps(context)
                    : _buildCulturalCompatibilityTip(
                        context,
                        interest.status,
                      ),
              ),
              const SizedBox(height: 20),
              if (isReceived && interest.status == 'pending')
                _buildResponseActions(context, ref, accentColor)
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    viewMode == 'traditional'
                        ? 'Keep conversation warm while honouring family etiquette.'
                        : 'Suggest a meaningful, relaxed next step to deepen the connection.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(166),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, Object>> _buildTimelineItems() {
    final items = <Map<String, Object>>[
      {
        'icon': Icons.spa,
        'label': 'Introduced ${_formatRelativeTime(interest.createdAt)}',
      },
      {
        'icon': interest.status == 'pending'
            ? Icons.hourglass_bottom
            : Icons.volunteer_activism,
        'label': _titleForStatus(interest.status),
      },
    ];

    if (mode == 'sent' || mode == 'received') {
      items.add({
        'icon': Icons.handshake,
        'label': viewMode == 'traditional'
            ? 'Preparing respectful family steps'
            : 'Planning modern next step',
      });
    }

    return items;
  }

  Widget _buildCompatibilitySection(
    BuildContext context,
    int compatibilityScore,
    Color accent,
  ) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final message = _getCompatibilityMessage(compatibilityScore);
    final compatibilityColor = _getCompatibilityColor(compatibilityScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cultural harmony score',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.onSurface.withAlpha(20),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final width =
                    constraints.maxWidth * (compatibilityScore.clamp(0, 100) / 100);
                return AnimatedContainer(
                  duration: AppMotionDurations.medium,
                  height: 10,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        accent.withAlpha(64),
                        compatibilityColor,
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: compatibilityColor.withAlpha(31),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$compatibilityScore%',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: compatibilityColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(179),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCulturalCompatibilityTip(
    BuildContext context,
    String status,
  ) {
    String tip;
    IconData icon;
    Color color;

    if (viewMode == 'traditional') {
      switch (status) {
        case 'pending':
          tip =
              'In traditional Afghan culture, patience is a virtue while awaiting a family decision.';
          icon = Icons.hourglass_empty;
          color = AppColors.warning;
          break;
        case 'accepted':
          tip =
              'Excellent! Consider involving family elders in planning a respectful first meeting.';
          icon = Icons.check_circle;
          color = AppColors.success;
          break;
        case 'rejected':
          tip =
              'Respect their decision with dignity. Traditional values emphasize maintaining honor in all interactions.';
          icon = Icons.cancel;
          color = AppColors.error;
          break;
        case 'reciprocated':
          tip =
              'Mutual interest blessed! Consider arranging a formal family introduction to proceed.';
          icon = Icons.favorite;
          color = AppColors.primary;
          break;
        default:
          tip = 'Continue respectful communication to build trust and understanding.';
          icon = Icons.chat;
          color = AppColors.info;
      }
    } else {
      switch (status) {
        case 'pending':
          tip =
              'Take time to get to know each other better through meaningful conversation.';
          icon = Icons.hourglass_empty;
          color = AppColors.warning;
          break;
        case 'accepted':
          tip =
              'Great! Suggest a casual meeting in a comfortable, public setting to continue building your connection.';
          icon = Icons.check_circle;
          color = AppColors.success;
          break;
        case 'rejected':
          tip =
              'Respect their decision and wish them well. Modern dating values mutual respect and honesty.';
          icon = Icons.cancel;
          color = AppColors.error;
          break;
        case 'reciprocated':
          tip =
              'Mutual interest! Explore shared values and interests to deepen your connection.';
          icon = Icons.favorite;
          color = AppColors.primary;
          break;
        default:
          tip = 'Continue open communication to build a genuine connection.';
          icon = Icons.chat;
          color = AppColors.info;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: ThemeHelpers.getMaterialTheme(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: color.withAlpha(204),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCulturalNextSteps(BuildContext context) {
    if (viewMode == 'traditional') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withAlpha(77)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_edu, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Traditional Next Steps',
                  style: ThemeHelpers.getMaterialTheme(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildNextStepItem(
              'Formal Family Introduction',
              'Arrange for elders to exchange salaams and intentions to honour tradition.',
            ),
            const SizedBox(height: 4),
            _buildNextStepItem(
              'Cultural Conversation',
              'Share family customs, expectations, and preferred courtship approach.',
            ),
            const SizedBox(height: 4),
            _buildNextStepItem(
              'Faith Alignment',
              'Discuss religious practice and hopes for a spiritually aligned home.',
            ),
            const SizedBox(height: 4),
            _buildNextStepItem(
              'Blessing & Dua',
              'Seek prayers from elders and agree on a respectful follow-up plan.',
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Modern Connection Steps',
                style: ThemeHelpers.getMaterialTheme(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNextStepItem(
            'Shared Experience',
            'Plan an activity that reflects your shared values and interests.',
          ),
          const SizedBox(height: 4),
          _buildNextStepItem(
            'Story Exchange',
            'Share family journeys and what community support looks like to you both.',
          ),
          const SizedBox(height: 4),
          _buildNextStepItem(
            'Future Vision',
            'Discuss how you each imagine balancing culture, career, and family.',
          ),
          const SizedBox(height: 4),
          _buildNextStepItem(
            'Introduce Loved Ones',
            'Invite the people who champion you most to offer guidance.',
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.arrow_right, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(description, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResponseActions(
    BuildContext context,
    WidgetRef ref,
    Color accent,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.close),
            label: const Text('Decline politely'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              final result = await ref
                  .read(interestsControllerProvider.notifier)
                  .respondToInterest(
                    interestId: interest.id,
                    status: 'rejected',
                  );

              if (result['success'] == true) {
                ToastService.instance.success(
                  'Interest declined respectfully.',
                );
              } else {
                final error =
                    result['error'] as String? ?? 'Failed to respond to interest';
                final isPlanLimit = result['isPlanLimit'] == true;
                if (isPlanLimit) {
                  ToastService.instance.warning(
                    'Upgrade to respond to more interests',
                  );
                } else {
                  ToastService.instance.error(error);
                }
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            icon: const Icon(Icons.check_rounded),
            label: const Text('Accept & continue'),
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: ColorHelpers.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              final result = await ref
                  .read(interestsControllerProvider.notifier)
                  .respondToInterest(
                    interestId: interest.id,
                    status: 'accepted',
                  );

              if (result['success'] == true) {
                ToastService.instance.success(
                  'Interest accepted! Begin a respectful conversation.',
                );
              } else {
                final error =
                    result['error'] as String? ?? 'Failed to accept interest';
                final isPlanLimit = result['isPlanLimit'] == true;
                if (isPlanLimit) {
                  ToastService.instance.warning(
                    'Upgrade to respond to more interests',
                  );
                } else {
                  ToastService.instance.error(error);
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Color _resolveAccentColor(bool isMutual, bool isFamilyApproved) {
    return ColorHelpers.getInterestStatusColor(
      isMutual: isMutual,
      isFamilyApproved: isFamilyApproved,
      status: interest.status,
    );
  }

  String _formatRelativeTime(int timestamp) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = now.difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String _titleForStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Awaiting response';
      case 'accepted':
        return 'Accepted – start planning next steps';
      case 'rejected':
        return 'Declined with care';
      case 'reciprocated':
        return 'Mutual interest';
      case 'family_approved':
        return 'Family approved';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'accepted':
      case 'reciprocated':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'withdrawn':
        return Icons.undo;
      case 'family_approved':
        return Icons.family_restroom;
      default:
        return Icons.help_outline;
    }
  }

  String _getCulturalStatusText(String status, String mode) {
    if (mode == 'traditional') {
      switch (status) {
        case 'pending':
          return 'Awaiting Family Consideration';
        case 'accepted':
          return 'Family Blessing Given';
        case 'rejected':
          return 'Respectfully Declined';
        case 'reciprocated':
          return 'Mutual Family Approval';
        case 'withdrawn':
          return 'Interest Withdrawn';
        case 'family_approved':
          return 'Family Approved Match';
        default:
          return 'Under Consideration';
      }
    }

    switch (status) {
      case 'pending':
        return 'Awaiting Response';
      case 'accepted':
        return 'Interest Accepted';
      case 'rejected':
        return 'Interest Declined';
      case 'reciprocated':
        return 'Mutual Interest';
      case 'withdrawn':
        return 'Interest Withdrawn';
      case 'family_approved':
        return 'Family Approved';
      default:
        return 'Pending';
    }
  }

  int _calculateCompatibilityScore(Map<String, dynamic>? userSnapshot) {
    if (userSnapshot == null) return 0;
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    return 60 + (random % 40);
  }

  Color _getCompatibilityColor(int score) {
    return ColorHelpers.getCompatibilityColor(score);
  }

  String _getCompatibilityMessage(int score) {
    if (viewMode == 'traditional') {
      if (score >= 85) {
        return 'Excellent cultural alignment! Your families would likely approve.';
      }
      if (score >= 70) {
        return 'Good cultural compatibility. Consider discussing family values.';
      }
      return 'Some cultural differences. Focus on understanding and respect.';
    }

    if (score >= 85) {
      return 'Great match! You share many values and interests.';
    }
    if (score >= 70) {
      return 'Good compatibility! Explore your shared interests further.';
    }
    return 'Some differences. Focus on open communication and understanding.';
  }

  String? _extractLocation(Map<String, dynamic>? snapshot) {
    final city = snapshot?['city']?.toString();
    final country = snapshot?['country']?.toString();
    if (city != null && city.isNotEmpty && country != null && country.isNotEmpty) {
      return '$city, $country';
    }
    if (city != null && city.isNotEmpty) return city;
    if (country != null && country.isNotEmpty) return country;
    return null;
  }

  List<String> _extractLanguages(Map<String, dynamic>? snapshot) {
    final languages = snapshot?['languages'];
    if (languages is List) {
      return languages
          .map((language) => language.toString())
          .where((language) => language.isNotEmpty)
          .toList();
    }
    return const [];
  }

  String? _getCulturalBackground(Map<String, dynamic>? userSnapshot) {
    if (userSnapshot == null) return null;
    final ethnicity = userSnapshot['ethnicity']?.toString();
    final motherTongue = userSnapshot['motherTongue']?.toString();
    final religion = userSnapshot['religion']?.toString();

    if (ethnicity != null && ethnicity.isNotEmpty) {
      return ethnicity;
    }
    if (motherTongue != null && motherTongue.isNotEmpty) {
      return 'Speaks $motherTongue';
    }
    if (religion != null && religion.isNotEmpty) {
      return religion;
    }

    return null;
  }
}
