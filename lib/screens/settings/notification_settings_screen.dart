import 'package:flutter/material.dart';
import 'package:aroosi_flutter/theme/theme.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _newMatches = true;
  bool _messages = true;
  bool _profileViews = true;
  bool _appUpdates = true;
  bool _marketing = false;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textTheme = theme.textTheme;

    return AppScaffold(
      title: 'Notifications',
      usePadding: false,
      child: ListView(
        children: [
          _buildSectionHeader(theme, 'Activity'),
          SwitchListTile(
            title: const Text('New Matches'),
            subtitle: const Text('Get notified when you have a new match'),
            value: _newMatches,
            onChanged: (value) {
              setState(() {
                _newMatches = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Messages'),
            subtitle: const Text('Get notified when you receive a message'),
            value: _messages,
            onChanged: (value) {
              setState(() {
                _messages = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Profile Views'),
            subtitle: const Text('Get notified when someone views your profile'),
            value: _profileViews,
            onChanged: (value) {
              setState(() {
                _profileViews = value;
              });
            },
          ),
          const Divider(),
          _buildSectionHeader(theme, 'App Updates'),
          SwitchListTile(
            title: const Text('New Features'),
            subtitle: const Text('Get notified about new features and updates'),
            value: _appUpdates,
            onChanged: (value) {
              setState(() {
                _appUpdates = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Marketing'),
            subtitle: const Text('Receive marketing emails and promotions'),
            value: _marketing,
            onChanged: (value) {
              setState(() {
                _marketing = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
