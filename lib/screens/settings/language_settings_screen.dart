import 'package:flutter/material.dart';
import 'package:aroosi_flutter/theme/theme.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  _LanguageSettingsScreenState createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'English';

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'nativeName': 'English'},
    {'name': 'فارسی', 'nativeName': 'Persian'},
    {'name': 'العربية', 'nativeName': 'Arabic'},
    // Add more languages here
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textTheme = theme.textTheme;

    return AppScaffold(
      title: 'Language',
      usePadding: false,
      child: ListView.separated(
        itemCount: _languages.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final language = _languages[index];
          final isSelected = language['name'] == _selectedLanguage;

          return ListTile(
            title: Text(
              language['name']!,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              language['nativeName']!,
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing:
                isSelected
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
            onTap: () {
              setState(() {
                _selectedLanguage = language['name']!;
              });
            },
          );
        },
      ),
    );
  }
}
