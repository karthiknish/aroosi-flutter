part of 'package:aroosi_flutter/features/profiles/models.dart';

class ShortlistEntry extends Equatable {
  const ShortlistEntry({
    required this.userId,
    required this.createdAt,
    this.fullName,
    this.profileImageUrls,
    this.note,
  });

  final String userId;
  final int createdAt; // epoch millis
  final String? fullName;
  final List<String>? profileImageUrls;
  final String? note;

  ShortlistEntry copyWith({
    String? userId,
    int? createdAt,
    String? fullName,
    List<String>? profileImageUrls,
    String? note,
  }) => ShortlistEntry(
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        fullName: fullName ?? this.fullName,
        profileImageUrls: profileImageUrls ?? this.profileImageUrls,
        note: note ?? this.note,
      );

  static ShortlistEntry fromJson(Map<String, dynamic> json) => ShortlistEntry(
        userId: json['userId']?.toString() ?? '',
        createdAt: json['createdAt'] is int
            ? json['createdAt']
            : int.tryParse(json['createdAt']?.toString() ?? '') ??
                DateTime.now().millisecondsSinceEpoch,
        fullName: json['fullName']?.toString(),
        profileImageUrls: json['profileImageUrls'] is List
            ? (json['profileImageUrls'] as List)
                .map((e) => e.toString())
                .toList()
            : null,
        note: json['note']?.toString(),
      );

  @override
  List<Object?> get props => [
        userId,
        createdAt,
        fullName,
        profileImageUrls,
        note,
      ];
}
