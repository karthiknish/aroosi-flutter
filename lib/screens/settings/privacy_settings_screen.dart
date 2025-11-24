import 'package:flutter/material.dart';
import 'package:aroosi_flutter/theme/theme.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _profileVisibility = true;
  bool _showOnlineStatus = true;
  bool _showLastActive = true;
  bool _allowSearch = true;
  String _photoVisibility = 'Public';

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textTheme = theme.textTheme;

    return AppScaffold(
      title: 'Privacy',
      usePadding: false,
      child: ListView(
        children: [
          _buildSectionHeader(theme, 'Profile Visibility'),
          SwitchListTile(
            title: const Text('Public Profile'),
            subtitle: const Text('Allow others to see your profile'),
            value: _profileVisibility,
            onChanged: (value) {
              setState(() {
                _profileVisibility = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Show Online Status'),
            subtitle: const Text('Let others know when you are online'),
            value: _showOnlineStatus,
            onChanged: (value) {
              setState(() {
                _showOnlineStatus = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Show Last Active'),
            subtitle: const Text('Display when you were last active'),
            value: _showLastActive,
            onChanged: (value) {
              setState(() {
                _showLastActive = value;
              });
            },
          ),
          const Divider(),
          _buildSectionHeader(theme, 'Search & Discovery'),
          SwitchListTile(
            title: const Text('Allow Search'),
            subtitle: const Text('Allow people to find you by name'),
            value: _allowSearch,
            onChanged: (value) {
              setState(() {
                _allowSearch = value;
              });
            },
          ),
          ListTile(
            title: const Text('Photo Visibility'),
            subtitle: Text(_photoVisibility),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showPhotoVisibilityDialog(context);
            },
          ),
          const Divider(),
          _buildSectionHeader(theme, 'Data & Security'),
          ListTile(
            title: const Text('Blocked Users'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to blocked users
            },
          ),
          ListTile(
            title: const Text('Request Data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Request data export
            },
          ),
          ListTile(
            title: const Text('Delete Account'),
            textColor: theme.colorScheme.error,
            onTap: () {
              // Show delete account confirmation
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showPhotoVisibilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Photo Visibility'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Public'),
                onTap: () {
                  setState(() {
                    _photoVisibility = 'Public';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Friends Only'),
                onTap: () {
                  setState(() {
                    _photoVisibility = 'Friends Only';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Private'),
                onTap: () {
                  setState(() {
                    _photoVisibility = 'Private';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
