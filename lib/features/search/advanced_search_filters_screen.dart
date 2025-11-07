import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aroosi_flutter/features/profiles/models.dart';
import 'package:aroosi_flutter/features/profiles/list_controller.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';
import 'package:aroosi_flutter/l10n/app_localizations.dart';

class AdvancedSearchFiltersScreen extends ConsumerStatefulWidget {
  final SearchFilters? initialFilters;

  const AdvancedSearchFiltersScreen({
    super.key,
    this.initialFilters,
  });

  @override
  ConsumerState<AdvancedSearchFiltersScreen> createState() => _AdvancedSearchFiltersScreenState();
}

class _AdvancedSearchFiltersScreenState extends ConsumerState<AdvancedSearchFiltersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late SearchFilters _filters;
  final _formKey = GlobalKey<FormState>();

  // Controllers for text inputs
  final _ageMinController = TextEditingController();
  final _ageMaxController = TextEditingController();
  final _incomeMinController = TextEditingController();
  final _incomeMaxController = TextEditingController();
  final _heightMinController = TextEditingController();
  final _heightMaxController = TextEditingController();
  final _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _filters = widget.initialFilters ?? const SearchFilters();
    _initializeControllers();
  }

  void _initializeControllers() {
    _ageMinController.text = _filters.minAge?.toString() ?? '';
    _ageMaxController.text = _filters.maxAge?.toString() ?? '';
    _incomeMinController.text = _filters.minIncome?.toString() ?? '';
    _incomeMaxController.text = _filters.maxIncome?.toString() ?? '';
    _heightMinController.text = _filters.minHeight ?? '';
    _heightMaxController.text = _filters.maxHeight ?? '';
    _queryController.text = _filters.query ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ageMinController.dispose();
    _ageMaxController.dispose();
    _incomeMinController.dispose();
    _incomeMaxController.dispose();
    _heightMinController.dispose();
    _heightMaxController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Advanced Search',
      child: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicTab(),
                _buildCulturalTab(),
                _buildEducationTab(),
                _buildPhysicalTab(),
                _buildLifestyleTab(),
                _buildMatrimonyTab(),
              ],
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(text: 'Basic'),
          Tab(text: 'Cultural'),
          Tab(text: 'Education'),
          Tab(text: 'Physical'),
          Tab(text: 'Lifestyle'),
          Tab(text: 'Matrimony'),
        ],
      ),
    );
  }

  Widget _buildBasicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Search Query'),
            TextFormField(
              controller: _queryController,
              decoration: const InputDecoration(
                hintText: 'Search by name, description...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _filters = _filters.copyWith(query: value.isEmpty ? null : value);
              },
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Age Range'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageMinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Age',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final age = int.tryParse(value);
                      _filters = _filters.copyWith(minAge: age);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _ageMaxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Age',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final age = int.tryParse(value);
                      _filters = _filters.copyWith(maxAge: age);
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Location'),
            _buildDropdownField(
              'Country',
              _filters.country,
              ['UK', 'USA', 'Canada', 'Germany', 'France', 'Other'],
              (value) => _filters = _filters.copyWith(country: value),
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              initialValue: _filters.city,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _filters = _filters.copyWith(city: value.isEmpty ? null : value);
              },
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Preferred Gender'),
            _buildDropdownField(
              'Gender',
              _filters.preferredGender,
              ['male', 'female', 'both', 'other'],
              (value) => _filters = _filters.copyWith(preferredGender: value),
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Sort By'),
            _buildDropdownField(
              'Sort Order',
              _filters.sort,
              ['recent', 'distance', 'newest', 'relevance'],
              (value) => _filters = _filters.copyWith(sort: value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCulturalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Religion'),
          _buildDropdownField(
            'Religion',
            _filters.religion,
            ['', 'islam', 'christianity', 'hinduism', 'sikhism', 'judaism', 'other'],
            (value) => _filters = _filters.copyWith(religion: value?.isEmpty == true ? null : value),
          ),
          
          const SizedBox(height: 16),
          
          _buildDropdownField(
            'Religious Practice',
            _filters.religiousPractice,
            ['', 'very_practicing', 'moderately_practicing', 'occasionally_practicing', 'not_practicing'],
            (value) => _filters = _filters.copyWith(religiousPractice: value?.isEmpty == true ? null : value),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('Language & Ethnicity'),
          _buildDropdownField(
            'Mother Tongue',
            _filters.motherTongue,
            ['', 'pashto', 'dari', 'urdu', 'english', 'farsi', 'hindi', 'other'],
            (value) => _filters = _filters.copyWith(motherTongue: value?.isEmpty == true ? null : value),
          ),
          
          const SizedBox(height: 16),
          
          _buildMultiSelectField(
            'Languages',
            _filters.languages ?? [],
            ['English', 'Pashto', 'Dari', 'Urdu', 'Farsi', 'Hindi', 'Arabic', 'Spanish', 'French', 'German'],
            (values) => _filters = _filters.copyWith(languages: values.isEmpty ? null : values),
          ),
          
          const SizedBox(height: 16),
          
          _buildDropdownField(
            'Ethnicity',
            _filters.ethnicity,
            ['', 'afghan', 'pakistani', 'indian', 'iranian', 'arab', 'caucasian', 'other'],
            (value) => _filters = _filters.copyWith(ethnicity: value?.isEmpty == true ? null : value),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('Family Values'),
          _buildDropdownField(
            'Family Values',
            _filters.familyValues,
            ['', 'traditional', 'moderate', 'liberal', 'progressive'],
            (value) => _filters = _filters.copyWith(familyValues: value?.isEmpty == true ? null : value),
          ),
          
          const SizedBox(height: 16),
          
          _buildDropdownField(
            'Marriage Views',
            _filters.marriageViews,
            ['', 'traditional', 'modern', 'balanced', 'liberal'],
            (value) => _filters = _filters.copyWith(marriageViews: value?.isEmpty == true ? null : value),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Education'),
          _buildDropdownField(
            'Education Level',
            _filters.education,
            ['', 'High School', 'Some College', 'Bachelor\'s Degree', 'Master\'s Degree', 'PhD/Doctorate', 'Professional Degree', 'Trade/Vocational'],
            (value) => _filters = _filters.copyWith(education: value?.isEmpty == true ? null : value),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('Profession'),
          TextFormField(
            initialValue: _filters.occupation,
            decoration: const InputDecoration(
              labelText: 'Occupation',
              hintText: 'e.g., Software Engineer, Doctor, Teacher',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _filters = _filters.copyWith(occupation: value.isEmpty ? null : value);
            },
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('Income Range'),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _incomeMinController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Min Income',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final income = int.tryParse(value);
                    _filters = _filters.copyWith(minIncome: income);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _incomeMaxController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max Income',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final income = int.tryParse(value);
                    _filters = _filters.copyWith(maxIncome: income);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Height'),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _heightMinController,
                  decoration: const InputDecoration(
                    labelText: 'Min Height',
                    hintText: 'e.g., 160cm',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _filters = _filters.copyWith(minHeight: value.isEmpty ? null : value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _heightMaxController,
                  decoration: const InputDecoration(
                    labelText: 'Max Height',
                    hintText: 'e.g., 180cm',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _filters = _filters.copyWith(maxHeight: value.isEmpty ? null : value);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('Physical Status'),
          _buildDropdownField(
            'Physical Status',
            _filters.physicalStatus,
            ['', 'normal', 'differently-abled'],
            (value) => _filters = _filters.copyWith(physicalStatus: value?.isEmpty == true ? null : value),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('Marital Status'),
          _buildDropdownField(
            'Marital Status',
            _filters.maritalStatus,
            ['', 'single', 'divorced', 'widowed', 'separated'],
            (value) => _filters = _filters.copyWith(maritalStatus: value?.isEmpty == true ? null : value),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Diet'),
          _buildDropdownField(
            'Diet Preference',
            _filters.diet,
            ['', 'vegetarian', 'non-vegetarian', 'vegan', 'halal', 'kosher'],
            (value) => _filters = _filters.copyWith(diet: value?.isEmpty == true ? null : value),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('Habits'),
          _buildDropdownField(
            'Smoking',
            _filters.smoking,
            ['', 'never', 'occasionally', 'socially', 'regularly'],
            (value) => _filters = _filters.copyWith(smoking: value?.isEmpty == true ? null : value),
          ),
          
          const SizedBox(height: 16),
          
          _buildDropdownField(
            'Drinking',
            _filters.drinking,
            ['', 'never', 'occasionally', 'socially', 'regularly'],
            (value) => _filters = _filters.copyWith(drinking: value?.isEmpty == true ? null : value),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrimonyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Marriage Intention'),
          _buildDropdownField(
            'Marriage Intention',
            _filters.marriageIntention,
            ['', 'serious_marriage', 'marriage_with_family', 'religious_marriage', 'companionate_marriage'],
            (value) => _filters = _filters.copyWith(marriageIntention: value?.isEmpty == true ? null : value),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('Important Preferences'),
          _buildCheckboxField(
            'Requires Family Approval',
            _filters.requiresFamilyApproval ?? false,
            (value) => _filters = _filters.copyWith(requiresFamilyApproval: value),
          ),
          
          _buildCheckboxField(
            'Must Be Religious',
            _filters.mustBeReligious ?? false,
            (value) => _filters = _filters.copyWith(mustBeReligious: value),
          ),
          
          _buildCheckboxField(
            'Must Want Children',
            _filters.mustWantChildren ?? false,
            (value) => _filters = _filters.copyWith(mustWantChildren: value),
          ),
          
          _buildCheckboxField(
            'Never Married Before',
            _filters.mustBeNeverMarried ?? false,
            (value) => _filters = _filters.copyWith(mustBeNeverMarried: value),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    
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

  Widget _buildDropdownField(String label, String? value, List<String> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option.isEmpty ? null : option,
          child: Text(option.isEmpty ? 'Any' : option),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildMultiSelectField(String label, List<String> selectedValues, List<String> options, Function(List<String>) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label (${selectedValues.length} selected)'),
        const SizedBox(height: 8),
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
    );
  }

  Widget _buildCheckboxField(String label, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (newValue) => onChanged(newValue ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildBottomActions() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withAlpha(50)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Reset filters to initial state
                setState(() {
                  _filters = widget.initialFilters ?? const SearchFilters();
                  _initializeControllers();
                });
              },
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Apply filters and navigate back
                ref.read(searchControllerProvider.notifier).search(_filters);
                context.pop();
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
