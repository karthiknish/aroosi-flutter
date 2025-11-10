import 'package:flutter/material.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/models.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/constants.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';

class PartnerPreferencesStep extends StatefulWidget {
  final PartnerPreferences? partnerPreferences;
  final Function(PartnerPreferences) onPreferencesUpdated;
  final VoidCallback onNext;

  const PartnerPreferencesStep({
    super.key,
    this.partnerPreferences,
    required this.onPreferencesUpdated,
    required this.onNext,
  });

  @override
  State<PartnerPreferencesStep> createState() => _PartnerPreferencesStepState();
}

class _PartnerPreferencesStepState extends State<PartnerPreferencesStep> {
  late int _minAge;
  late int _maxAge;
  late List<String> _preferredEducation;
  late List<String> _preferredLocations;
  late List<String> _preferredReligions;
  late List<String> _preferredLanguages;
  late bool _mustBeReligious;
  late bool _mustWantChildren;
  late bool _mustBeNeverMarried;

  @override
  void initState() {
    super.initState();
    _initializeFromExisting();
  }

  void _initializeFromExisting() {
    final existing = widget.partnerPreferences;
    _minAge = existing?.minAge ?? 18;
    _maxAge = existing?.maxAge ?? 100;
    _preferredEducation = existing?.preferredEducation ?? [];
    _preferredLocations = existing?.preferredLocations ?? [];
    _preferredReligions = existing?.preferredReligions ?? [];
    _preferredLanguages = existing?.preferredLanguages ?? [];
    _mustBeReligious = existing?.mustBeReligious ?? false;
    _mustWantChildren = existing?.mustWantChildren ?? false;
    _mustBeNeverMarried = existing?.mustBeNeverMarried ?? false;
  }

  void _updatePreferences() {
    final preferences = PartnerPreferences(
      minAge: _minAge,
      maxAge: _maxAge,
      preferredEducation: _preferredEducation,
      preferredLocations: _preferredLocations,
      preferredReligions: _preferredReligions,
      preferredLanguages: _preferredLanguages,
      mustBeReligious: _mustBeReligious,
      mustWantChildren: _mustWantChildren,
      mustBeNeverMarried: _mustBeNeverMarried,
    );
    widget.onPreferencesUpdated(preferences);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          Text(
            'Describe your ideal life partner',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Help us understand who you\'re looking for in a marriage partner',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Age range
                  _buildSectionTitle('Age Range'),
                  _buildAgeRangeSelector(),
                  
                  const SizedBox(height: 24),
                  
                  // Education
                  _buildSectionTitle('Education'),
                  _buildMultiSelect(
                    'Preferred Education Levels',
                    _preferredEducation,
                    EducationOptions.options,
                    (values) {
                      setState(() {
                        _preferredEducation = values;
                      });
                      _updatePreferences();
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Religion
                  _buildSectionTitle('Religion'),
                  _buildMultiSelect(
                    'Preferred Religions',
                    _preferredReligions,
                    PartnerReligionOptions.options,
                    (values) {
                      setState(() {
                        _preferredReligions = values;
                      });
                      _updatePreferences();
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Languages
                  _buildSectionTitle('Languages'),
                  _buildMultiSelect(
                    'Preferred Languages',
                    _preferredLanguages,
                    LanguageOptions.options,
                    (values) {
                      setState(() {
                        _preferredLanguages = values;
                      });
                      _updatePreferences();
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Important preferences
                  _buildSectionTitle('Important Preferences'),
                  _buildImportantPreferences(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Next button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isValid() ? widget.onNext : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continue',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAgeRangeSelector() {
    final theme = ThemeHelpers.getMaterialTheme(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Age: $_minAge - $_maxAge years',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Min age slider
          Text('Minimum Age', style: theme.textTheme.bodySmall),
          Slider(
            value: _minAge.toDouble(),
            min: MatrimonyConstants.minimumAge.toDouble(),
            max: _maxAge.toDouble() - 1,
            divisions: 50,
            onChanged: (value) {
              setState(() {
                _minAge = value.round();
              });
              _updatePreferences();
            },
          ),
          
          // Max age slider
          Text('Maximum Age', style: theme.textTheme.bodySmall),
          Slider(
            value: _maxAge.toDouble(),
            min: _minAge + 1.0,
            max: MatrimonyConstants.maximumAge.toDouble(),
            divisions: 50,
            onChanged: (value) {
              setState(() {
                _maxAge = value.round();
              });
              _updatePreferences();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelect(
    String title,
    List<String> selectedValues,
    List<String> options,
    Function(List<String>) onChanged,
  ) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title (${selectedValues.length} selected)',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedValues.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  final updatedValues = List<String>.from(selectedValues);
                  if (selected) {
                    updatedValues.add(option);
                  } else {
                    updatedValues.remove(option);
                  }
                  onChanged(updatedValues);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantPreferences() {
    final theme = ThemeHelpers.getMaterialTheme(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        children: [
          _buildCheckboxTile(
            'Must be religious',
            'Partner should be religious',
            _mustBeReligious,
            (value) {
              setState(() {
                _mustBeReligious = value ?? false;
              });
              _updatePreferences();
            },
          ),
          
          _buildCheckboxTile(
            'Must want children',
            'Partner should want children',
            _mustWantChildren,
            (value) {
              setState(() {
                _mustWantChildren = value ?? false;
              });
              _updatePreferences();
            },
          ),
          
          _buildCheckboxTile(
            'Never married before',
            'Partner should not have been married',
            _mustBeNeverMarried,
            (value) {
              setState(() {
                _mustBeNeverMarried = value ?? false;
              });
              _updatePreferences();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(
    String title,
    String subtitle,
    bool value,
    Function(bool?) onChanged,
  ) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: CheckboxListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  bool _isValid() {
    return _minAge >= MatrimonyConstants.minimumAge &&
           _maxAge <= MatrimonyConstants.maximumAge &&
           _minAge < _maxAge;
  }
}
