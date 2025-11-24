import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aroosi_flutter/features/matches/matches_provider.dart';
import 'package:aroosi_flutter/features/matches/models.dart';
import 'package:aroosi_flutter/features/profiles/models.dart';
import 'package:aroosi_flutter/features/auth/auth_controller.dart';
import 'package:aroosi_flutter/core/safety_service.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';
import 'package:aroosi_flutter/theme/motion.dart';
import 'package:aroosi_flutter/widgets/animations/motion.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  final String matchID;

  const MatchDetailScreen({
    super.key,
    required this.matchID,
  });

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  ReportReason? _selectedReportReason;
  final TextEditingController _reportDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset unread count when viewing match details
      ref.read(matchesProvider.notifier).updateUnreadCount(widget.matchID, 0);
    });
  }

  @override
  void dispose() {
    _reportDescriptionController.dispose();
    super.dispose();
  }

  String _getReportReasonText(ReportReason reason) {
    switch (reason) {
      case ReportReason.inappropriateContent:
        return 'Inappropriate Content';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.spam:
        return 'Spam or Scam';
      case ReportReason.fakeProfile:
        return 'Fake Profile';
      case ReportReason.underageUser:
        return 'Underage User';
      case ReportReason.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchesState = ref.watch(matchesProvider);
    final user = ref.watch(authControllerProvider);

    if (user.profile == null) {
      return const AppScaffold(
        title: 'Match Details',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final matchItem = matchesState.items.firstWhere(
      (item) => item.id == widget.matchID,
      orElse: () => MatchListItem(
        id: widget.matchID,
        match: Match(
          id: widget.matchID,
          participantIDs: [user.profile?.id ?? '', ''],
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        ),
      ),
    );

    return AppScaffold(
      title: matchItem.counterpartProfile?.displayName ?? 'Match',
      usePadding: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.chat),
          onPressed: () {
            context.push('/matches/${widget.matchID}/chat');
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'report':
                _showReportDialog(matchItem);
                break;
              case 'block':
                _showBlockDialog(matchItem);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  const Icon(Icons.flag),
                  const SizedBox(width: 8),
                  Text('Report User'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  const Icon(Icons.block),
                  const SizedBox(width: 8),
                  Text('Block User'),
                ],
              ),
            ),
          ],
        ),
      ],
      child: FadeThrough(
        delay: AppMotionDurations.fast,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (matchItem.counterpartProfile != null)
                _ProfileSection(profile: matchItem.counterpartProfile!),
              _MatchInfoSection(matchItem: matchItem),
              _ActionButtons(
                matchItem: matchItem,
                onChatPressed: () {
                  context.push('/matches/${widget.matchID}/chat');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog(MatchListItem matchItem) {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Report User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to report this user?'),
            const SizedBox(height: 16),
            Text(
              'Please select a reason for reporting:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...ReportReason.values.map((reason) {
              final isSelected = _selectedReportReason == reason;
              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(_getReportReasonText(reason)),
                onTap: () {
                  setState(() {
                    _selectedReportReason = reason;
                  });
                },
              );
            }),
            const SizedBox(height: 8),
            TextField(
              controller: _reportDescriptionController,
              decoration: InputDecoration(
                labelText: 'Additional details (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              setState(() {
                _selectedReportReason = null;
                _reportDescriptionController.clear();
              });
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              
              if (_selectedReportReason == null) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Please select a reason for reporting'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final safetyService = ref.read(safetyServiceProvider);
              final success = await safetyService.reportUser(
                reportedUserId: matchItem.id,
                reason: _selectedReportReason!,
                description: _reportDescriptionController.text.trim(),
                relatedContentId: widget.matchID,
              );

              if (!mounted) return;

              if (success) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Report submitted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Navigate back after successful report
                router.pop();
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to submit report. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              if (!mounted) return;
              setState(() {
                _selectedReportReason = null;
                _reportDescriptionController.clear();
              });
            },
            child: Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(MatchListItem matchItem) {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Block User'),
        content: Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              
              final safetyService = ref.read(safetyServiceProvider);
              final success = await safetyService.blockUser(matchItem.id);

              if (!mounted) return;

              if (success) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('User blocked successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Navigate back after successful block
                router.pop();
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to block user. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Block'),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final ProfileSummary profile;

  const _ProfileSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile photo
          CircleAvatar(
            radius: 60,
            backgroundImage: profile.avatarUrl != null
                ? NetworkImage(profile.avatarUrl!)
                : null,
            child: profile.avatarUrl == null
                ? Text(
                    profile.displayName.isNotEmpty
                        ? profile.displayName[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          
          // Name and verification
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.displayName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // if (profile.isVerified) ...[
              //   const SizedBox(width: 8),
              //   Icon(
              //     Icons.verified,
              //     size: 20,
              //     color: theme.colorScheme.primary,
              //   ),
              // ],
            ],
          ),
          const SizedBox(height: 8),
          
          // Basic info
          Text(
            _formatBasicInfo(profile),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Occupation and education
          // if (profile.occupation.isNotEmpty || profile.education.isNotEmpty) ...[
          //   Text(
          //     profile.occupation.isNotEmpty ? profile.occupation : profile.education,
          //     style: theme.textTheme.bodyMedium?.copyWith(
          //       color: theme.colorScheme.onSurfaceVariant,
          //     ),
          //     textAlign: TextAlign.center,
          //   ),
          // ],
          const SizedBox(height: 8),
          
          // Cultural and religious info
          // if (profile.religiousPreference?.isNotEmpty == true ||
          //     profile.culturalBackground?.isNotEmpty == true) ...[
          //   Wrap(
          //     spacing: 8,
          //     runSpacing: 4,
          //     alignment: WrapAlignment.center,
          //     children: [
          //       if (profile.religiousPreference?.isNotEmpty == true)
          //         Chip(
          //           label: Text(profile.religiousPreference!),
          //           backgroundColor: theme.colorScheme.surfaceVariant,
          //         ),
          //       if (profile.culturalBackground?.isNotEmpty == true)
          //         Chip(
          //           label: Text(profile.culturalBackground!),
          //           backgroundColor: theme.colorScheme.surfaceVariant,
          //         ),
          //     ],
          //   ),
          // ],
        ],
      ),
    );
  }

  String _formatBasicInfo(ProfileSummary profile) {
    final parts = <String>[];
    if (profile.age != null && profile.age! > 0) parts.add('${profile.age}');
    if (profile.city?.isNotEmpty == true) parts.add(profile.city!);
    return parts.join(' • ');
  }
}

class _MatchInfoSection extends StatelessWidget {
  final MatchListItem matchItem;

  const _MatchInfoSection({
    required this.matchItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _InfoRow(
            icon: Icons.calendar_today,
            label: 'Matched On',
            value: DateFormat('MMM d, yyyy').format(matchItem.match.createdAt),
          ),
          const SizedBox(height: 12),
          
          _InfoRow(
            icon: Icons.message,
            label: 'Total Messages',
            value: matchItem.match.totalMessages.toString(),
          ),
          const SizedBox(height: 12),
          
          _InfoRow(
            icon: Icons.update,
            label: 'Last Active',
            value: _formatLastActive(matchItem.match.lastUpdatedAt),
          ),
          
          if (matchItem.lastMessagePreview?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.chat_bubble_outline,
              label: 'Last Message',
              value: matchItem.lastMessagePreview!,
            ),
          ],
        ],
      ),
    );
  }

  String _formatLastActive(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final MatchListItem matchItem;
  final VoidCallback onChatPressed;

  const _ActionButtons({
    required this.matchItem,
    required this.onChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onChatPressed,
              icon: const Icon(Icons.chat),
              label: Text('Send Message'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
