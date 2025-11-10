import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aroosi_flutter/core/toast_service.dart';
import 'package:aroosi_flutter/features/auth/auth_controller.dart';
import 'package:aroosi_flutter/features/profiles/profiles_repository.dart';
import 'package:aroosi_flutter/theme/colors.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/utils/debug_logger.dart';

part 'edit_profile/form_sections.dart';
part 'edit_profile/form_actions.dart';
part 'edit_profile/form_constants.dart';

// NOTE: The current UserProfile model is minimal (fullName, email, plan, etc.).
// Many detailed demographic fields used in aroosi-mobile are NOT yet part of
// this Flutter model. The form below collects a superset so we can send partial
// updates once backend & model expand. For now, bootstrap only supported fields
// (fullName) and leave others empty. Future work: extend UserProfile and hydrate
// initial values for all editable properties.

/// Full parity edit profile screen (subset of aroosi-mobile fields) with
/// grouped sections. This keeps the UI straightforward while backend support
/// catches up with the richer profile model.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

abstract class _EditProfileStateBase extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'UK');
  final _heightFeetCtrl = TextEditingController();
  final _heightInchesCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _annualIncomeCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _religionCtrl = TextEditingController();
  final _motherTongueCtrl = TextEditingController();
  final _ethnicityCtrl = TextEditingController();
  final _partnerAgeMinCtrl = TextEditingController();
  final _partnerAgeMaxCtrl = TextEditingController();
  final _partnerCitiesCtrl = TextEditingController();
  final _interestInputCtrl = TextEditingController();

  // Multi-select sets
  final Set<String> _partnerCities = <String>{};
  final Set<String> _interests = <String>{};

  // Simple dropdown value holders
  String? _gender;
  String? _preferredGender;
  String? _maritalStatus;
  String? _diet;
  String? _smoking;
  String? _drinking;
  String? _physicalStatus;
  String? _profileFor;
  bool _hideFromFreeUsers = false;

  DateTime? _dob;
  bool _saving = false;
  bool _hasBootstrapped = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _aboutCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _heightFeetCtrl.dispose();
    _heightInchesCtrl.dispose();
    _educationCtrl.dispose();
    _occupationCtrl.dispose();
    _annualIncomeCtrl.dispose();
    _phoneCtrl.dispose();
    _religionCtrl.dispose();
    _motherTongueCtrl.dispose();
    _ethnicityCtrl.dispose();
    _partnerAgeMinCtrl.dispose();
    _partnerAgeMaxCtrl.dispose();
    _partnerCitiesCtrl.dispose();
    _interestInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _showOptionPicker(
    BuildContext context,
    String title,
    List<String> options,
    String? currentValue,
    void Function(String?) onChanged,
  ) async {
    if (options.isEmpty) return;
    FocusScope.of(context).unfocus();
    var tempValue = currentValue ?? options.first;
    final controller = FixedExtentScrollController(
      initialItem:
          currentValue != null && options.contains(currentValue)
              ? options.indexOf(currentValue)
              : 0,
    );

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(ctx),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            title,
                            style: CupertinoTheme.of(ctx)
                                .textTheme
                                .navTitleTextStyle,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        child: const Text('Done'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          onChanged(tempValue);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: 32.0,
                    scrollController: controller,
                    onSelectedItemChanged: (int index) {
                      tempValue = options[index];
                    },
                    children: options
                        .map((option) => Center(child: Text(option)))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 25, now.month, now.day);
    final firstDate = DateTime(now.year - 80, 1, 1);
    final lastDate = DateTime(now.year - 18, 12, 31);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Date of Birth',
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  String _dobLabel() {
    if (_dob == null) return 'Select date of birth';
    final date = _dob!;
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context);
}

class _EditProfileScreenState extends _EditProfileStateBase
    with _EditProfileFormSections, _EditProfileFormActions {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapFromProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final saveBtn = FilledButton.icon(
      onPressed: _saving ? null : _save,
      icon: _saving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save_outlined),
      label: Text(_saving ? 'Saving...' : 'Save Changes'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicSection(context),
                  _buildLocationSection(context),
                  _buildPhysicalSection(context),
                  _buildProfessionalSection(context),
                  _buildCulturalSection(context),
                  _buildContactSection(context),
                  _buildPartnerPreferencesSection(context),
                  _buildInterestsSection(context),
                  _buildPrivacySection(context, saveBtn),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
