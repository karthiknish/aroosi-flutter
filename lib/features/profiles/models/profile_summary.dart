part of 'package:aroosi_flutter/features/profiles/models.dart';

class ProfileSummary extends Equatable {
  const ProfileSummary({
    required this.id,
    required this.displayName,
    this.age,
    this.city,
    this.avatarUrl,
    this.isFavorite = false,
    this.isShortlisted = false,
    this.lastActive,
    this.compatibilityScore = 0,
  });

  final String id;
  final String displayName;
  final int? age;
  final String? city;
  final String? avatarUrl;
  final bool isFavorite;
  final bool isShortlisted;
  final DateTime? lastActive;
  final int compatibilityScore;

  ProfileSummary copyWith({
    String? id,
    String? displayName,
    int? age,
    String? city,
    String? avatarUrl,
    bool? isFavorite,
    bool? isShortlisted,
    DateTime? lastActive,
    int? compatibilityScore,
  }) => ProfileSummary(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        age: age ?? this.age,
        city: city ?? this.city,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isFavorite: isFavorite ?? this.isFavorite,
        isShortlisted: isShortlisted ?? this.isShortlisted,
        lastActive: lastActive ?? this.lastActive,
        compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      );

  static ProfileSummary fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] is Map<String, dynamic>
        ? (json['profile'] as Map).cast<String, dynamic>()
        : null;

    final id = _firstNonEmpty([
          json['userId'],
          json['id'],
          json['_id'],
          json['profileId'],
          profile?['id'],
          profile?['_id'],
        ])?.toString() ??
        '';

    final displayName = _firstNonEmpty([
      profile?['fullName'],
      json['fullName'],
      json['name'],
      profile?['displayName'],
    ])?.toString().trim();

    final city = _firstNonEmpty([
      profile?['city'],
      json['city'],
      profile?['location'],
    ])?.toString();

    final avatar = _resolveAvatarUrl(json, profile);

    final dynamic ageRawCandidate = json['age'] ?? profile?['age'];
    int? explicitAge;
    if (ageRawCandidate is int) {
      explicitAge = ageRawCandidate;
    } else if (ageRawCandidate is String) {
      explicitAge = int.tryParse(ageRawCandidate.trim());
    }

    final dob = _firstNonEmpty([
      profile?['dateOfBirth'],
      profile?['dob'],
      json['dateOfBirth'],
      json['dob'],
    ])?.toString();
    final calculatedAge = _ageFromDob(dob) ?? explicitAge;

    final lastActiveRaw = _firstNonEmpty([
      json['lastActive'],
      profile?['lastActive'],
    ])?.toString();

    final compatibilityScore = () {
      for (final candidate in [
        json['compatibilityScore'],
        json['compatibility_score'],
        profile?['compatibilityScore'],
        profile?['compatibility_score'],
      ]) {
        final asInt = _asInt(candidate);
        if (asInt != null) {
          return asInt;
        }
      }
      return 0;
    }();

    return ProfileSummary(
      id: id,
      displayName: (displayName == null || displayName.isEmpty)
          ? 'Unknown'
          : displayName,
      age: calculatedAge,
      city: city?.isEmpty ?? true ? null : city,
      avatarUrl: avatar,
      isFavorite: json['isFavorite'] == true || json['favorite'] == true,
      isShortlisted:
          json['isShortlisted'] == true || json['shortlisted'] == true,
      lastActive:
          lastActiveRaw != null ? DateTime.tryParse(lastActiveRaw) : null,
      compatibilityScore: compatibilityScore,
    );
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        age,
        city,
        avatarUrl,
        isFavorite,
        isShortlisted,
        lastActive,
        compatibilityScore,
      ];
}

String? _firstNonEmpty(Iterable<dynamic> values) {
  for (final value in values) {
    if (value == null) continue;
    final str = value.toString();
    if (str.trim().isEmpty) continue;
    return str;
  }
  return null;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

int? _ageFromDob(String? isoString) {
  if (isoString == null || isoString.isEmpty) return null;
  final dob = DateTime.tryParse(isoString);
  if (dob == null) return null;
  final now = DateTime.now();
  int age = now.year - dob.year;
  final hasHadBirthday =
      now.month > dob.month || (now.month == dob.month && now.day >= dob.day);
  if (!hasHadBirthday) age -= 1;
  if (age < 0) return null;
  return age;
}

String? _resolveAvatarUrl(
  Map<String, dynamic> json,
  Map<String, dynamic>? profile,
) {
  String? fromList(List<dynamic>? list) {
    if (list == null) return null;
    for (final entry in list) {
      if (entry == null) continue;
      final url = entry.toString();
      if (url.trim().isNotEmpty) return url;
    }
    return null;
  }

  final urls = [
    fromList(json['profileImageUrls'] as List<dynamic>?),
    fromList(profile?['profileImageUrls'] as List<dynamic>?),
    fromList(json['images'] as List<dynamic>?),
    fromList(profile?['images'] as List<dynamic>?),
    json['avatar']?.toString(),
    json['avatarUrl']?.toString(),
    profile?['avatar']?.toString(),
    profile?['avatarUrl']?.toString(),
  ];
  return _firstNonEmpty(urls);
}
