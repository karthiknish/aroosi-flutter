import 'package:flutter/material.dart';
import 'package:aroosi_flutter/theme/colors.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aroosi_flutter/utils/debug_logger.dart';
import 'package:aroosi_flutter/core/push_notification_service.dart';
import 'package:aroosi_flutter/core/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aroosi_flutter/widgets/error_states.dart';
import 'package:aroosi_flutter/widgets/offline_states.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _pushEnabled = false;
  bool _isLoading = true;
  String? _error;
  late PushNotificationService _pushService;
  
  // Granular notification preferences
  bool _newMatchesEnabled = true;
  bool _messagesEnabled = true;
  bool _profileViewsEnabled = true;
  bool _appUpdatesEnabled = true;
  
  // Quiet hours settings
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _pushService = ref.read(pushNotificationServiceProvider);
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final enabled = await _pushService.isNotificationEnabled();
      await _loadGranularPreferences();
      await _loadQuietHoursSettings();
      
      if (mounted) {
        setState(() {
          _pushEnabled = enabled;
          _isLoading = false;
        });
      }
    } catch (e) {
      logDebug('Error loading notification settings', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }
  
  Future<void> _loadGranularPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _newMatchesEnabled = prefs.getBool('notification_new_matches') ?? true;
        _messagesEnabled = prefs.getBool('notification_messages') ?? true;
        _profileViewsEnabled = prefs.getBool('notification_profile_views') ?? true;
        _appUpdatesEnabled = prefs.getBool('notification_app_updates') ?? true;
      });
    } catch (e) {
      logDebug('Error loading granular preferences', error: e);
    }
  }
  
  Future<void> _loadQuietHoursSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? false;
      final startHour = prefs.getInt('quiet_hours_start_hour') ?? 22;
      final startMinute = prefs.getInt('quiet_hours_start_minute') ?? 0;
      final endHour = prefs.getInt('quiet_hours_end_hour') ?? 8;
      final endMinute = prefs.getInt('quiet_hours_end_minute') ?? 0;
      
      setState(() {
        _quietHoursEnabled = quietHoursEnabled;
        _quietHoursStart = TimeOfDay(hour: startHour, minute: startMinute);
        _quietHoursEnd = TimeOfDay(hour: endHour, minute: endMinute);
      });
    } catch (e) {
      logDebug('Error loading quiet hours settings', error: e);
    }
  }
  
  Future<void> _saveGranularPreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
      
      // Also save to Firestore for cross-device sync
      final user = _pushService.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('notifications')
            .set({key: value}, SetOptions(merge: true));
      }
    } catch (e) {
      logDebug('Error saving granular preference', error: e);
    }
  }
  
  Future<void> _saveQuietHoursSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('quiet_hours_enabled', _quietHoursEnabled);
      await prefs.setInt('quiet_hours_start_hour', _quietHoursStart.hour);
      await prefs.setInt('quiet_hours_start_minute', _quietHoursStart.minute);
      await prefs.setInt('quiet_hours_end_hour', _quietHoursEnd.hour);
      await prefs.setInt('quiet_hours_end_minute', _quietHoursEnd.minute);
      
      // Also save to Firestore for cross-device sync
      final user = _pushService.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('notifications')
            .set({
              'quiet_hours_enabled': _quietHoursEnabled,
              'quiet_hours_start_hour': _quietHoursStart.hour,
              'quiet_hours_start_minute': _quietHoursStart.minute,
              'quiet_hours_end_hour': _quietHoursEnd.hour,
              'quiet_hours_end_minute': _quietHoursEnd.minute,
            }, SetOptions(merge: true));
      }
    } catch (e) {
      logDebug('Error saving quiet hours settings', error: e);
    }
  }

  Future<void> _togglePushNotifications(bool value) async {
    setState(() {
      _pushEnabled = value;
    });

    try {
      if (value && !_pushService.hasUserConsent) {
        // Show consent dialog if user hasn't given consent yet
        final consent = await _pushService.showNotificationConsentDialog(
          context,
        );
        if (!consent) {
          // User denied consent, revert toggle
          if (mounted) {
            setState(() {
              _pushEnabled = false;
            });
          }
          return;
        }
      }

      await _pushService.setNotificationEnabled(value);

      if (mounted) {
        final colorScheme = ThemeHelpers.getMaterialTheme(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Push notifications enabled'
                  : 'Push notifications disabled',
            ),
            backgroundColor: value
                ? AppColors.success
                : colorScheme.surfaceContainerHighest,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      logDebug('Error toggling push notifications', error: e);
      if (mounted) {
        setState(() {
          _pushEnabled = !value; // Revert on error
        });
        final colorScheme = ThemeHelpers.getMaterialTheme(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to change notification settings'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final colorScheme = theme.colorScheme;
    final textColor = ThemeHelpers.getTextColor(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: theme.textTheme.titleLarge?.copyWith(color: textColor),
        ),
        backgroundColor: ThemeHelpers.getSurfaceColor(context),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withValues(alpha: 0.12),
                colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Builder(
                  builder: (context) {
                    final error = _error!;
                    final isOfflineError =
                        error.toLowerCase().contains('network') ||
                        error.toLowerCase().contains('connection') ||
                        error.toLowerCase().contains('timeout') ||
                        error.toLowerCase().contains('offline');

                    return isOfflineError
                        ? OfflineState(
                            title: 'Connection Lost',
                            subtitle: 'Unable to load notification settings',
                            description: 'Check your internet connection and try again',
                            onRetry: _loadNotificationSettings,
                          )
                        : ErrorState(
                            title: 'Failed to Load Settings',
                            subtitle: 'Something went wrong',
                            errorMessage: error,
                            onRetryPressed: _loadNotificationSettings,
                          );
                  },
                )
              : SingleChildScrollView(
              padding: Responsive.screenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildAPNsDisclosure(),
                  const SizedBox(height: 32),
                  _buildNotificationTypes(),
                  const SizedBox(height: 32),
                  _buildGranularNotificationSettings(),
                  const SizedBox(height: 32),
                  _buildQuietHoursSettings(),
                  const SizedBox(height: 32),
                  _buildAppNotificationSettings(),
                ],
              ),
            ),
    );
  }

  Widget _buildAPNsDisclosure() {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.apple, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Apple Push Notification Service (APNs)',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Aroosi uses Apple\'s Push Notification service to deliver important app notifications. We only use APNs for:',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            '• New matches and likes',
            '• Messages from other users',
            '• Profile activity notifications',
            '• Important app updates and security alerts',
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                item,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your privacy is protected. We do not collect personal data through APNs beyond what\'s necessary for notification delivery.',
            style: textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypes() {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final colorScheme = theme.colorScheme;
    final textColor = ThemeHelpers.getTextColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Push Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SwitchListTile(
            title: Row(
              children: [
                Icon(Icons.notifications_active, color: colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                const Text('Enable Push Notifications'),
              ],
            ),
            subtitle: Text(
              'Get notified about matches, messages, and activity',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            value: _pushEnabled,
            onChanged: _togglePushNotifications,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withValues(alpha: 0.25),
          ),
        ),
        const SizedBox(height: 16),
        if (!_pushService.hasUserConsent)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.warning,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tap enable to see what notifications we use and provide consent',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildGranularNotificationSettings() {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final colorScheme = theme.colorScheme;
    final textColor = ThemeHelpers.getTextColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Preferences',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildNotificationToggle(
                icon: Icons.favorite,
                title: 'New Matches',
                description: 'Get notified when someone matches with you',
                color: colorScheme.primary,
                value: _newMatchesEnabled,
                onChanged: (value) {
                  setState(() {
                    _newMatchesEnabled = value;
                  });
                  _saveGranularPreference('notification_new_matches', value);
                },
              ),
              _buildDivider(),
              _buildNotificationToggle(
                icon: Icons.chat,
                title: 'Messages',
                description: 'Never miss important conversations',
                color: AppColors.info,
                value: _messagesEnabled,
                onChanged: (value) {
                  setState(() {
                    _messagesEnabled = value;
                  });
                  _saveGranularPreference('notification_messages', value);
                },
              ),
              _buildDivider(),
              _buildNotificationToggle(
                icon: Icons.visibility,
                title: 'Profile Views',
                description: 'Know when someone views your profile',
                color: AppColors.success,
                value: _profileViewsEnabled,
                onChanged: (value) {
                  setState(() {
                    _profileViewsEnabled = value;
                  });
                  _saveGranularPreference('notification_profile_views', value);
                },
              ),
              _buildDivider(),
              _buildNotificationToggle(
                icon: Icons.announcement,
                title: 'App Updates',
                description: 'Important safety and feature announcements',
                color: AppColors.warning,
                value: _appUpdatesEnabled,
                onChanged: (value) {
                  setState(() {
                    _appUpdatesEnabled = value;
                  });
                  _saveGranularPreference('notification_app_updates', value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final colorScheme = theme.colorScheme;

    return SwitchListTile(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      value: value && _pushEnabled,
      onChanged: _pushEnabled ? onChanged : null,
      activeThumbColor: color,
      activeTrackColor: color.withValues(alpha: 0.25),
    );
  }

  Widget _buildDivider() {
    final colorScheme = ThemeHelpers.getMaterialTheme(context).colorScheme;
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: colorScheme.outlineVariant,
    );
  }

  Widget _buildQuietHoursSettings() {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final colorScheme = theme.colorScheme;
    final textColor = ThemeHelpers.getTextColor(context);
    const quietAccent = AppColors.auroraIris;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiet Hours',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Disable notifications during specific hours',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Row(
                  children: [
                    const Icon(Icons.bedtime, color: quietAccent, size: 20),
                    const SizedBox(width: 12),
                    const Text('Enable Quiet Hours'),
                  ],
                ),
                subtitle: Text(
                  _quietHoursEnabled
                      ? 'Quiet from ${_quietHoursStart.format(context)} to ${_quietHoursEnd.format(context)}'
                      : 'Turn on to set quiet hours',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _quietHoursEnabled && _pushEnabled,
                onChanged: _pushEnabled ? (value) {
                  setState(() {
                    _quietHoursEnabled = value;
                  });
                  _saveQuietHoursSettings();
                } : null,
                activeThumbColor: quietAccent,
                activeTrackColor: quietAccent.withValues(alpha: 0.25),
              ),
              if (_quietHoursEnabled) ...[
                _buildDivider(),
                ListTile(
                  title: const Text('Start Time'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: quietAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _quietHoursStart.format(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: quietAccent,
                      ),
                    ),
                  ),
                  onTap: _pushEnabled ? () => _selectTime(context, true) : null,
                ),
                _buildDivider(),
                ListTile(
                  title: const Text('End Time'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: quietAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _quietHoursEnd.format(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: quietAccent,
                      ),
                    ),
                  ),
                  onTap: _pushEnabled ? () => _selectTime(context, false) : null,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _quietHoursStart : _quietHoursEnd,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStartTime) {
          _quietHoursStart = picked;
        } else {
          _quietHoursEnd = picked;
        }
      });
      _saveQuietHoursSettings();
    }
  }

  Widget _buildAppNotificationSettings() {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final colorScheme = theme.colorScheme;
    final textColor = ThemeHelpers.getTextColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Types',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        ...[
          {
            'icon': Icons.favorite,
            'title': 'Matches & Likes',
            'description':
                'When someone matches with you or likes your profile',
            'color': colorScheme.primary,
          },
          {
            'icon': Icons.chat,
            'title': 'Messages',
            'description': 'New messages from your matches',
            'color': AppColors.info,
          },
          {
            'icon': Icons.visibility,
            'title': 'Profile Views',
            'description': 'When someone views your profile',
            'color': AppColors.success,
          },
          {
            'icon': Icons.announcement,
            'title': 'App Updates',
            'description': 'Important announcements and security updates',
            'color': AppColors.warning,
          },
        ].map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _pushEnabled ? 'Active' : 'Disabled',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _pushEnabled
                        ? AppColors.success
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
