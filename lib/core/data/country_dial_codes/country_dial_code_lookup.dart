part of 'package:aroosi_flutter/core/data/country_dial_codes.dart';

const CountryDialCode _kDefaultCountryDialCode = CountryDialCode(
  value: 'United States',
  label: 'United States',
  dialCode: '+1',
  flag: '🇺🇸',
);

/// Lookup helper by dial code prefix (returns the first match when duplicates exist such as +1).
CountryDialCode? findCountryByDialCode(String dialCode) {
  return kCountryDialCodes.firstWhere(
    (c) => c.dialCode == dialCode,
    orElse: () => _kDefaultCountryDialCode,
  );
}

/// Case-insensitive country lookup by either value or label fields.
CountryDialCode? findCountryByName(String name) {
  final lower = name.toLowerCase();
  try {
    return kCountryDialCodes.firstWhere(
      (c) => c.value.toLowerCase() == lower || c.label.toLowerCase() == lower,
    );
  } catch (_) {
    return null;
  }
}
