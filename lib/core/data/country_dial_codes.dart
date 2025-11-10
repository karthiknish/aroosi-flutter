/// Country dial codes data mirrored from the React Native project.
/// Source shape: { value, label, dialCode, flag }.
/// Stored here as a const list for fast, synchronous access (no async load needed).
/// Phone numbers should be stored in canonical E.164-like format: +country code national number.
/// UI will allow selecting a country (flag + dialCode) and entering the national significant number only.
library;

part 'country_dial_codes/country_dial_code_model.dart';
part 'country_dial_codes/country_dial_code_data.dart';
part 'country_dial_codes/country_dial_code_lookup.dart';

const List<CountryDialCode> kCountryDialCodes = kCountryDialCodesData;
