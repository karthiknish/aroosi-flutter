part of 'package:aroosi_flutter/screens/main/edit_profile_screen.dart';

mixin _EditProfileFormSections on _EditProfileStateBase {
  BoxDecoration cupertinoDecoration(
    BuildContext context, {
    bool hasError = false,
  }) {
    return BoxDecoration(
      color: ThemeHelpers.getSurfaceColor(context),
      border: Border.all(
        color: hasError ? AppColors.error : AppColors.primary,
        width: hasError ? 2.0 : 1.0,
      ),
      borderRadius: BorderRadius.circular(10.0),
    );
  }

  Padding cupertinoFieldPadding(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }

  Widget _buildBasicSection(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textStyle = theme.textTheme.bodyLarge;
    final labelStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    return _sectionCard('Basic', [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Full Name', style: labelStyle),
          const SizedBox(height: 8),
          Container(
            decoration: cupertinoDecoration(context),
            child: cupertinoFieldPadding(
              CupertinoTextField(
                controller: _nameCtrl,
                placeholder: 'Enter your full name',
                placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                style: textStyle,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date of Birth', style: labelStyle),
          const SizedBox(height: 8),
          Container(
            decoration: cupertinoDecoration(context),
            child: cupertinoFieldPadding(
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _pickDob,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dobLabel(),
                      style: textStyle?.copyWith(
                        color: _dob == null ? AppColors.muted : AppColors.text,
                      ),
                    ),
                    const Icon(CupertinoIcons.calendar, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      _chipSelector(
        label: 'Gender',
        options: genderOptions,
        value: _gender,
        onChanged: (v) => setState(() => _gender = v),
      ),
      _chipSelector(
        label: 'Preferred Gender',
        options: preferredGenderOptions,
        value: _preferredGender,
        onChanged: (v) => setState(() => _preferredGender = v),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About Me', style: labelStyle),
          const SizedBox(height: 8),
          Container(
            decoration: cupertinoDecoration(context),
            child: cupertinoFieldPadding(
              CupertinoTextField(
                controller: _aboutCtrl,
                placeholder: 'Tell us about yourself',
                placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                style: textStyle,
                maxLines: 4,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildLocationSection(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textStyle = theme.textTheme.bodyLarge;
    final labelStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    return _sectionCard('Location', [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('City', style: labelStyle),
          const SizedBox(height: 8),
          Container(
            decoration: cupertinoDecoration(context),
            child: cupertinoFieldPadding(
              CupertinoTextField(
                controller: _cityCtrl,
                placeholder: 'Enter your city',
                placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                style: textStyle,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Country', style: labelStyle),
          const SizedBox(height: 8),
          Container(
            decoration: cupertinoDecoration(context),
            child: cupertinoFieldPadding(
              CupertinoTextField(
                controller: _countryCtrl,
                placeholder: 'Enter your country',
                placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                style: textStyle,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildPhysicalSection(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textStyle = theme.textTheme.bodyLarge;
    final labelStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    return _sectionCard('Physical', [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Height - Feet', style: labelStyle),
                const SizedBox(height: 8),
                Container(
                  decoration: cupertinoDecoration(context),
                  child: cupertinoFieldPadding(
                    CupertinoTextField(
                      controller: _heightFeetCtrl,
                      keyboardType: TextInputType.number,
                      placeholder: 'Feet',
                      placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                      style: textStyle,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Height - Inches', style: labelStyle),
                const SizedBox(height: 8),
                Container(
                  decoration: cupertinoDecoration(context),
                  child: cupertinoFieldPadding(
                    CupertinoTextField(
                      controller: _heightInchesCtrl,
                      keyboardType: TextInputType.number,
                      placeholder: 'Inches',
                      placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                      style: textStyle,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      _chipSelector(
        label: 'Physical Status',
        options: physicalStatusOptions,
        value: _physicalStatus,
        onChanged: (v) => setState(() => _physicalStatus = v),
      ),
    ]);
  }

  Widget _buildProfessionalSection(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textStyle = theme.textTheme.bodyLarge;
    final labelStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    return _sectionCard('Professional', [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Education', style: labelStyle),
          const SizedBox(height: 8),
          Container(
            decoration: cupertinoDecoration(context),
            child: cupertinoFieldPadding(
              CupertinoTextField(
                controller: _educationCtrl,
                placeholder: 'Education level',
                placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                style: textStyle,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Occupation', style: labelStyle),
          const SizedBox(height: 8),
          Container(
            decoration: cupertinoDecoration(context),
            child: cupertinoFieldPadding(
              CupertinoTextField(
                controller: _occupationCtrl,
                placeholder: 'Occupation',
                placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                style: textStyle,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Annual Income (optional)', style: labelStyle),
          const SizedBox(height: 8),
          Container(
            decoration: cupertinoDecoration(context),
            child: cupertinoFieldPadding(
              CupertinoTextField(
                controller: _annualIncomeCtrl,
                keyboardType: TextInputType.number,
                placeholder: 'Income in USD',
                placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                style: textStyle,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildCulturalSection(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textStyle = theme.textTheme.bodyLarge;
    final labelStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    return _sectionCard('Cultural', [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Religion', style: labelStyle),
          const SizedBox(height: 8),
          Container(
            decoration: cupertinoDecoration(context),
            child: cupertinoFieldPadding(
              CupertinoTextField(
                controller: _religionCtrl,
                placeholder: 'Religion',
                placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                style: textStyle,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mother Tongue', style: labelStyle),
          const SizedBox(height: 8),
          Container(
            decoration: cupertinoDecoration(context),
            child: cupertinoFieldPadding(
              CupertinoTextField(
                controller: _motherTongueCtrl,
                placeholder: 'Mother tongue',
                placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                style: textStyle,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ethnicity', style: labelStyle),
          const SizedBox(height: 8),
          Container(
            decoration: cupertinoDecoration(context),
            child: cupertinoFieldPadding(
              CupertinoTextField(
                controller: _ethnicityCtrl,
                placeholder: 'Ethnicity',
                placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                style: textStyle,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      ),
      _chipSelector(
        label: 'Diet',
        options: dietOptions,
        value: _diet,
        onChanged: (v) => setState(() => _diet = v),
      ),
      _chipSelector(
        label: 'Smoking',
        options: smokingOptions,
        value: _smoking,
        onChanged: (v) => setState(() => _smoking = v),
      ),
      _chipSelector(
        label: 'Drinking',
        options: drinkingOptions,
        value: _drinking,
        onChanged: (v) => setState(() => _drinking = v),
      ),
    ]);
  }

  Widget _buildContactSection(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textStyle = theme.textTheme.bodyLarge;
    final labelStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    return _sectionCard('Contact', [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phone Number', style: labelStyle),
          const SizedBox(height: 8),
          Container(
            decoration: cupertinoDecoration(context),
            child: cupertinoFieldPadding(
              CupertinoTextField(
                controller: _phoneCtrl,
                placeholder: 'Phone number',
                keyboardType: TextInputType.phone,
                placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                style: textStyle,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildPartnerPreferencesSection(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textStyle = theme.textTheme.bodyLarge;
    final labelStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    return _sectionCard('Partner Preferences', [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preferred Age Min', style: labelStyle),
                const SizedBox(height: 8),
                Container(
                  decoration: cupertinoDecoration(context),
                  child: cupertinoFieldPadding(
                    CupertinoTextField(
                      controller: _partnerAgeMinCtrl,
                      keyboardType: TextInputType.number,
                      placeholder: 'Min age',
                      placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                      style: textStyle,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preferred Age Max', style: labelStyle),
                const SizedBox(height: 8),
                Container(
                  decoration: cupertinoDecoration(context),
                  child: cupertinoFieldPadding(
                    CupertinoTextField(
                      controller: _partnerAgeMaxCtrl,
                      keyboardType: TextInputType.number,
                      placeholder: 'Max age',
                      placeholderStyle: textStyle?.copyWith(color: AppColors.muted),
                      style: textStyle,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      _chipsEditable(
        label: 'Preferred Cities',
        values: _partnerCities,
        onAdd: _addPartnerCity,
        onRemove: _removePartnerCity,
        inputController: _partnerCitiesCtrl,
        hint: 'Add preferred city',
      ),
      _chipSelector(
        label: 'Marital Status',
        options: maritalStatusOptions,
        value: _maritalStatus,
        onChanged: (v) => setState(() => _maritalStatus = v),
      ),
      _chipSelector(
        label: 'Profile For',
        options: profileForOptions,
        value: _profileFor,
        onChanged: (v) => setState(() => _profileFor = v),
      ),
    ]);
  }

  Widget _buildInterestsSection(BuildContext context) {
    return _sectionCard('Interests', [
      _chipsEditable(
        label: 'Interests',
        values: _interests,
        onAdd: _addInterest,
        onRemove: _removeInterest,
        inputController: _interestInputCtrl,
        hint: 'Add interest',
        suggestions: defaultInterestSuggestions,
      ),
    ]);
  }

  Widget _buildPrivacySection(BuildContext context, Widget saveBtn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          title: const Text('Hide From Free Users'),
          value: _hideFromFreeUsers,
          onChanged: (v) => setState(() => _hideFromFreeUsers = v),
        ),
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerRight, child: saveBtn),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...children.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: c,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipSelector({
    required String label,
    required List<String> options,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final textStyle = theme.textTheme.bodyLarge;
    final labelStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 8),
        Container(
          decoration: cupertinoDecoration(context),
          child: cupertinoFieldPadding(
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () =>
                  _showOptionPicker(context, label, options, value, onChanged),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value ?? 'Select',
                    style: textStyle?.copyWith(
                      color: value == null ? AppColors.muted : AppColors.text,
                    ),
                  ),
                  const Icon(CupertinoIcons.chevron_down, size: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addPartnerCity(String city) {
    final value = city.trim();
    if (value.isEmpty) return;
    setState(() => _partnerCities.add(value));
  }

  void _removePartnerCity(String city) {
    setState(() => _partnerCities.remove(city));
  }

  void _addInterest(String interest) {
    final value = interest.trim();
    if (value.isEmpty) return;
    setState(() => _interests.add(value.toLowerCase()));
  }

  void _removeInterest(String interest) {
    setState(() => _interests.remove(interest));
  }

  Widget _chipsEditable({
    required String label,
    required Set<String> values,
    required void Function(String) onAdd,
    required void Function(String) onRemove,
    TextEditingController? inputController,
    String hint = 'Add item',
    List<String>? suggestions,
  }) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...values.map(
              (v) => SizedBox(
                height: 32,
                child: InputChip(label: Text(v), onDeleted: () => onRemove(v)),
              ),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                controller: inputController,
                decoration: InputDecoration(
                  hintText: hint,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  onAdd(value);
                  inputController?.clear();
                },
              ),
            ),
          ],
        ),
        if (suggestions != null && suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: suggestions.take(12).map((s) {
              final already = values.contains(s);
              return ActionChip(
                label: Text(s),
                backgroundColor: already
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                onPressed: already ? null : () => onAdd(s),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
