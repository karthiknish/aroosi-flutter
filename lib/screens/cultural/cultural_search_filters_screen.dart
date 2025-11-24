import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aroosi_flutter/features/profiles/models.dart';
import 'package:aroosi_flutter/features/cultural/cultural_constants.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';
import 'package:aroosi_flutter/widgets/primary_button.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/theme/theme.dart';

class CulturalSearchFiltersScreen extends ConsumerStatefulWidget {
  final SearchFilters currentFilters;
  final Function(SearchFilters) onFiltersChanged;

  const CulturalSearchFiltersScreen({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  ConsumerState<CulturalSearchFiltersScreen> createState() => _CulturalSearchFiltersScreenState();
}

class _CulturalSearchFiltersScreenState extends ConsumerState<CulturalSearchFiltersScreen> {
  // Local state for filters
  String? _religion;
  String? _religiousPractice;
  String? _motherTongue;
  final Set<String> _languages = {};
  String? _familyValues;
  String? _marriageViews;
  String? _ethnicity;
  int? _minReligionImportance;
  int? _maxReligionImportance;
  int? _minCultureImportance;
  int? _maxCultureImportance;

  @override
  void initState() {
    super.initState();
    // Initialize with current filters
    _religion = widget.currentFilters.religion;
    _religiousPractice = widget.currentFilters.religiousPractice;
    _motherTongue = widget.currentFilters.motherTongue;
    _languages.addAll(widget.currentFilters.languages ?? []);
    _familyValues = widget.currentFilters.familyValues;
    _marriageViews = widget.currentFilters.marriageViews;
    _ethnicity = widget.currentFilters.ethnicity;
    _minReligionImportance = widget.currentFilters.minReligionImportance;
    _maxReligionImportance = widget.currentFilters.maxReligionImportance;
    _minCultureImportance = widget.currentFilters.minCultureImportance;
    _maxCultureImportance = widget.currentFilters.maxCultureImportance;
  }

  void _applyFilters() {
    final updatedFilters = widget.currentFilters.copyWith(
      religion: _religion,
      religiousPractice: _religiousPractice,
      motherTongue: _motherTongue,
      languages: _languages.isNotEmpty ? _languages.toList() : null,
      familyValues: _familyValues,
      marriageViews: _marriageViews,
      ethnicity: _ethnicity,
      minReligionImportance: _minReligionImportance,
      maxReligionImportance: _maxReligionImportance,
      minCultureImportance: _minCultureImportance,
      maxCultureImportance: _maxCultureImportance,
    );

    widget.onFiltersChanged(updatedFilters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _religion = null;
      _religiousPractice = null;
      _motherTongue = null;
      _languages.clear();
      _familyValues = null;
      _marriageViews = null;
      _ethnicity = null;
      _minReligionImportance = null;
      _maxReligionImportance = null;
      _minCultureImportance = null;
      _maxCultureImportance = null;
    });
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> options,
    required void Function(String?) onChanged,
    required String Function(String) displayName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThemeHelpers.getMaterialTheme(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: ThemeHelpers.getMaterialTheme(context).colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            underline: const SizedBox.shrink(),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Any'),
              ),
              ...options.where((option) => option.isNotEmpty).map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(displayName(option)),
                );
              }),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectFilter({
    required String label,
    required Set<String> selectedValues,
    required List<String> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThemeHelpers.getMaterialTheme(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(option.replaceAll('_', ' ').toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedValues.add(option);
                  } else {
                    selectedValues.remove(option);
                  }
                });
              },
              backgroundColor: ThemeHelpers.getMaterialTheme(context).colorScheme.surfaceContainerHighest,
              selectedColor: ThemeHelpers.getMaterialTheme(context).colorScheme.primaryContainer,
              checkmarkColor: ThemeHelpers.getMaterialTheme(context).colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImportanceRangeFilter({
    required String label,
    required int? minValue,
    required int? maxValue,
    required void Function(int?) onMinChanged,
    required void Function(int?) onMaxChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThemeHelpers.getMaterialTheme(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Minimum', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: ThemeHelpers.getMaterialTheme(context).colorScheme.outline.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<int>(
                      value: minValue,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      underline: const SizedBox.shrink(),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Any'),
                        ),
                        ...List.generate(10, (i) => i + 1).map((value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          );
                        }),
                      ],
                      onChanged: onMinChanged,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Maximum', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: ThemeHelpers.getMaterialTheme(context).colorScheme.outline.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<int>(
                      value: maxValue,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      underline: const SizedBox.shrink(),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Any'),
                        ),
                        ...List.generate(10, (i) => i + 1).map((value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          );
                        }),
                      ],
                      onChanged: onMaxChanged,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);

    return AppScaffold(
      title: 'Cultural Filters',
      usePadding: false,
      actions: [
        TextButton(
          onPressed: _clearFilters,
          child: const Text('Clear'),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(Spacing.lg),
              children: [
                _buildDropdownFilter(
                  label: 'Religion',
                  value: _religion,
                  options: religionOptions,
                  onChanged: (val) => setState(() => _religion = val),
                  displayName: getReligionDisplayName,
                ),
                const SizedBox(height: Spacing.lg),
                _buildDropdownFilter(
                  label: 'Religious Practice',
                  value: _religiousPractice,
                  options: religiousPracticeOptions,
                  onChanged: (val) => setState(() => _religiousPractice = val),
                  displayName: getReligiousPracticeDisplayName,
                ),
                const SizedBox(height: Spacing.lg),
                _buildDropdownFilter(
                  label: 'Ethnicity',
                  value: _ethnicity,
                  options: ethnicityOptions,
                  onChanged: (val) => setState(() => _ethnicity = val),
                  displayName: (val) => val.replaceAll('_', ' ').toUpperCase(),
                ),
                const SizedBox(height: Spacing.lg),
                _buildDropdownFilter(
                  label: 'Mother Tongue',
                  value: _motherTongue,
                  options: motherTongueOptions,
                  onChanged: (val) => setState(() => _motherTongue = val),
                  displayName: (val) => val.replaceAll('_', ' ').toUpperCase(),
                ),
                const SizedBox(height: Spacing.lg),
                _buildMultiSelectFilter(
                  label: 'Languages Spoken',
                  selectedValues: _languages,
                  options: languagesSpokenOptions,
                ),
                const SizedBox(height: Spacing.lg),
                _buildDropdownFilter(
                  label: 'Family Values',
                  value: _familyValues,
                  options: familyValuesOptions,
                  onChanged: (val) => setState(() => _familyValues = val),
                  displayName: getFamilyValuesDisplayName,
                ),
                const SizedBox(height: Spacing.lg),
                _buildDropdownFilter(
                  label: 'Marriage Views',
                  value: _marriageViews,
                  options: marriageViewsOptions,
                  onChanged: (val) => setState(() => _marriageViews = val),
                  displayName: getMarriageViewsDisplayName,
                ),
                const SizedBox(height: Spacing.lg),
                _buildImportanceRangeFilter(
                  label: 'Religion Importance (1-10)',
                  minValue: _minReligionImportance,
                  maxValue: _maxReligionImportance,
                  onMinChanged: (val) => setState(() => _minReligionImportance = val),
                  onMaxChanged: (val) => setState(() => _maxReligionImportance = val),
                ),
                const SizedBox(height: Spacing.lg),
                _buildImportanceRangeFilter(
                  label: 'Culture Importance (1-10)',
                  minValue: _minCultureImportance,
                  maxValue: _maxCultureImportance,
                  onMinChanged: (val) => setState(() => _minCultureImportance = val),
                  onMaxChanged: (val) => setState(() => _maxCultureImportance = val),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: PrimaryButton(
              onPressed: _applyFilters,
              label: 'Apply Filters',
            ),
          ),
        ],
      ),
    );
  }
}
