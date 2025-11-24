import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aroosi_flutter/features/auth/auth_controller.dart';
import 'package:aroosi_flutter/theme/theme.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/core/toast_service.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textTheme = theme.textTheme;

    return AppScaffold(
      title: 'Settings',
      usePadding: false,
      child: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          _buildSection(
            title: 'Account',
            children: [
              _ListTile(
                icon: Icons.person,
                title: 'Edit Profile',
                onTap: () => context.pushNamed('mainEditProfile'),
              ),
              _ListTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Settings',
                onTap: () => context.pushNamed('settingsPrivacy'),
              ),
              _ListTile(
                icon: Icons.security,
                title: 'Safety Guidelines',
                onTap: () => context.pushNamed('settingsSafety'),
              ),
            ],
          ),
          _buildSection(
            title: 'Preferences',
            children: [
              _ListTile(
                icon: Icons.notifications,
                title: 'Notifications',
                onTap: () => context.pushNamed('settingsNotifications'),
              ),
              _ListTile(
                icon: Icons.language,
                title: 'Language',
                onTap: () => context.pushNamed('settingsLanguage'),
              ),
              _ListTile(
                icon: Icons.block,
                title: 'Blocked Users',
                onTap: () => context.pushNamed('settingsBlockedUsers'),
              ),
            ],
          ),
          _buildSection(
            title: 'Support',
            children: [
              _ListTile(
                icon: Icons.help_outline,
                title: 'About',
                onTap: () => context.pushNamed('settingsAbout'),
              ),
              _ListTile(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: () => context.pushNamed('settingsTermsOfService'),
              ),
              _ListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => context.pushNamed('settingsPrivacyPolicy'),
              ),
              _ListTile(
                icon: Icons.contact_support,
                title: 'Contact Support',
                onTap: () => context.pushNamed('support'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            title: 'Danger Zone',
            children: [
              _ListTile(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                textColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () => _showDeleteAccountDialog(context, ref),
              ),
              _ListTile(
                icon: Icons.logout,
                title: 'Sign Out',
                textColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () => _showSignOutDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.text.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(authControllerProvider.notifier).logout();
                // Navigation is handled by the router listening to auth state
              } catch (e) {
                ToastService.instance.error('Failed to sign out: ${e.toString()}');
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    final reasonController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Delete Account',
            style: TextStyle(color: AppColors.error),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ This action cannot be undone!\n\nOnce you delete your account:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• All your profile data will be permanently deleted\n'
                  '• Messages and conversations will be removed\n'
                  '• Matches and connections will be lost\n'
                  '• Photos and personal information will be erased\n'
                  '• You will need to create a new account to return',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Enter your password to confirm',
                    border: OutlineInputBorder(),
                    hintText: 'Password',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for leaving (optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Tell us why you\'re leaving',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (passwordController.text.isEmpty) {
                        ToastService.instance.error('Please enter your password');
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        final authController = ref.read(
                          authControllerProvider.notifier,
                        );
                        await authController.deleteAccount(
                          password: passwordController.text,
                          reason: reasonController.text.trim().isEmpty
                              ? null
                              : reasonController.text.trim(),
                        );

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ToastService.instance.success(
                            'Your account has been deleted successfully',
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ToastService.instance.error(
                            'Failed to delete account: ${e.toString()}',
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? AppColors.text;
    final effectiveIconColor = iconColor ?? AppColors.muted;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: effectiveIconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: effectiveTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: AppColors.borderPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
