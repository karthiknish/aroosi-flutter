part of 'package:aroosi_flutter/screens/main/edit_profile_screen.dart';

mixin _EditProfileFormActions on _EditProfileStateBase {
  List<String> _validateFormLevel() {
    final errors = <String>[];
    final minAge = int.tryParse(_partnerAgeMinCtrl.text);
    final maxAge = int.tryParse(_partnerAgeMaxCtrl.text);
    if (minAge != null && (minAge < 18 || minAge > 80)) {
      errors.add('Partner min age must be between 18 and 80');
    }
    if (maxAge != null && (maxAge < 18 || maxAge > 80)) {
      errors.add('Partner max age must be between 18 and 80');
    }
    if (minAge != null && maxAge != null && minAge > maxAge) {
      errors.add('Partner min age cannot exceed max age');
    }

    final feet = int.tryParse(_heightFeetCtrl.text);
    final inches = int.tryParse(_heightInchesCtrl.text);
    if ((feet != null && feet > 0) || (inches != null && inches > 0)) {
      if (feet == null || feet < 3 || feet > 7) {
        errors.add('Height feet must be between 3 and 7');
      }
      if (inches != null && (inches < 0 || inches > 11)) {
        errors.add('Height inches must be between 0 and 11');
      }
    }
    return errors;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final formErrors = _validateFormLevel();
    if (formErrors.isNotEmpty) {
      ToastService.instance.error(formErrors.join('\n'));
      return;
    }
    setState(() => _saving = true);

    final Map<String, dynamic> updates = {};
    void put(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      updates[key] = value;
    }

    put('fullName', _nameCtrl.text.trim());
    put('aboutMe', _aboutCtrl.text.trim());
    put('city', _cityCtrl.text.trim());
    put('country', _countryCtrl.text.trim());
    final cm = _toCentimeters(
      _heightFeetCtrl.text.trim(),
      _heightInchesCtrl.text.trim(),
    );
    if (cm != null) put('height', cm);
    put('education', _educationCtrl.text.trim());
    put('occupation', _occupationCtrl.text.trim());
    if (_annualIncomeCtrl.text.trim().isNotEmpty) {
      final income = int.tryParse(_annualIncomeCtrl.text.trim());
      if (income != null) put('annualIncome', income);
    }
    put('phoneNumber', _phoneCtrl.text.trim());
    put('religion', _religionCtrl.text.trim());
    put('motherTongue', _motherTongueCtrl.text.trim());
    put('ethnicity', _ethnicityCtrl.text.trim());
    put('gender', _gender);
    put('preferredGender', _preferredGender);
    put('maritalStatus', _maritalStatus);
    put('diet', _diet);
    put('smoking', _smoking);
    put('drinking', _drinking);
    put('physicalStatus', _physicalStatus);
    put('profileFor', _profileFor);
    put('hideFromFreeUsers', _hideFromFreeUsers);
    if (_dob != null) {
      put('dateOfBirth', _dob!.toIso8601String());
    }
    if (_partnerAgeMinCtrl.text.isNotEmpty) {
      final v = int.tryParse(_partnerAgeMinCtrl.text);
      if (v != null) put('partnerPreferenceAgeMin', v);
    }
    if (_partnerAgeMaxCtrl.text.isNotEmpty) {
      final v = int.tryParse(_partnerAgeMaxCtrl.text);
      if (v != null) put('partnerPreferenceAgeMax', v);
    }
    if (_partnerCities.isNotEmpty) {
      put('partnerPreferenceCity', _partnerCities.toList());
    }
    if (_interests.isNotEmpty) {
      put('interests', _interests.toList());
    }

    try {
      await ref.read(profilesRepositoryProvider).updateProfile(updates);
      await ref.read(authControllerProvider.notifier).refreshProfileOnly();
      if (mounted) {
        ToastService.instance.success('Profile updated');
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (mounted) {
        ToastService.instance.error('Failed: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _bootstrapFromProfile() {
    if (_hasBootstrapped) return;
    final authState = ref.read(authControllerProvider);
    final profile = authState.profile;
    if (profile == null) {
      logDebug('edit_profile: profile unavailable during bootstrap');
      return;
    }
    _hasBootstrapped = true;

    setState(() {
      _nameCtrl.text = profile.fullName ?? '';
      _aboutCtrl.text = profile.aboutMe ?? '';
      _cityCtrl.text = profile.city ?? '';
      _countryCtrl.text = profile.country ?? _countryCtrl.text;
      _educationCtrl.text = profile.education ?? '';
      _occupationCtrl.text = profile.occupation ?? '';
      _annualIncomeCtrl.text =
          profile.annualIncome != null ? profile.annualIncome.toString() : '';
      _phoneCtrl.text = profile.phoneNumber ?? '';
      _religionCtrl.text = profile.religion ?? '';
      _motherTongueCtrl.text = profile.motherTongue ?? '';
      _ethnicityCtrl.text = profile.ethnicity ?? '';
      _gender = profile.gender;
      _preferredGender = profile.preferredGender;
      _maritalStatus = profile.maritalStatus;
      _diet = profile.diet;
      _smoking = profile.smoking;
      _drinking = profile.drinking;
      _physicalStatus = profile.physicalStatus;
      _profileFor = profile.profileFor;
      _hideFromFreeUsers = profile.hideFromFreeUsers ?? false;
      _dob = profile.dateOfBirth;

      if (profile.partnerPreferenceAgeMin != null) {
        _partnerAgeMinCtrl.text = profile.partnerPreferenceAgeMin.toString();
      }
      if (profile.partnerPreferenceAgeMax != null) {
        _partnerAgeMaxCtrl.text = profile.partnerPreferenceAgeMax.toString();
      }

      _partnerCities
        ..clear()
        ..addAll(profile.partnerPreferenceCity ?? const []);
      _interests
        ..clear()
        ..addAll((profile.interests ?? const []).map((e) => e.toLowerCase()));

      final height = profile.height;
      if (height != null) {
        final totalInches = height / 2.54;
        final feet = totalInches ~/ 12;
        final inches = (totalInches - feet * 12).round();
        _heightFeetCtrl.text = feet.toString();
        _heightInchesCtrl.text = inches.toString();
      }
    });
  }

  int? _toCentimeters(String feet, String inches) {
    final ft = int.tryParse(feet);
    final inch = int.tryParse(inches);
    if (ft == null && inch == null) return null;
    final totalInches = (ft ?? 0) * 12 + (inch ?? 0);
    if (totalInches <= 0) return null;
    return (totalInches * 2.54).round();
  }
}
