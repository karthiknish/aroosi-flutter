import 'package:flutter/material.dart';
import 'package:aroosi_flutter/theme/theme.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final List<Map<String, String>> _blockedUsers = [
    {'name': 'User 1', 'date': 'Blocked on Jan 1, 2024'},
    {'name': 'User 2', 'date': 'Blocked on Dec 15, 2023'},
    {'name': 'User 3', 'date': 'Blocked on Nov 20, 2023'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textTheme = theme.textTheme;

    return AppScaffold(
      title: 'Blocked Users',
      usePadding: false,
      child:
          _blockedUsers.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.block,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'No blocked users',
                      style: textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.separated(
                itemCount: _blockedUsers.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = _blockedUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      child: Text(user['name']![0]),
                    ),
                    title: Text(user['name']!),
                    subtitle: Text(user['date']!),
                    trailing: TextButton(
                      onPressed: () {
                        _showUnblockDialog(context, user['name']!);
                      },
                      child: const Text('Unblock'),
                    ),
                  );
                },
              ),
    );
  }

  void _showUnblockDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Unblock $userName?'),
            content: Text(
              'They will be able to see your profile and send you messages.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _blockedUsers.removeWhere((u) => u['name'] == userName);
                  });
                  Navigator.pop(context);
                },
                child: const Text('Unblock'),
              ),
            ],
          ),
    );
  }
}

