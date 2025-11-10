part of 'package:aroosi_flutter/core/data/country_dial_codes.dart';

/// Immutable country dial code entry.
class CountryDialCode {
  final String value; // Canonical country name / identifier
  final String label; // Display label
  final String dialCode; // Dialing prefix, e.g. +44
  final String flag; // Emoji flag

  const CountryDialCode({
    required this.value,
    required this.label,
    required this.dialCode,
    required this.flag,
  });
}
