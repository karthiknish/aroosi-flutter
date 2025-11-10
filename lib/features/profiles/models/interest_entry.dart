part of 'package:aroosi_flutter/features/profiles/models.dart';

class InterestEntry extends Equatable {
  const InterestEntry({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.fromSnapshot,
    this.toSnapshot,
  });

  final String id;
  final String fromUserId;
  final String toUserId;
  final String status; // 'pending', 'accepted', 'rejected', 'reciprocated', 'withdrawn'
  final int createdAt; // epoch millis
  final int updatedAt; // epoch millis
  final Map<String, dynamic>? fromSnapshot;
  final Map<String, dynamic>? toSnapshot;

  InterestEntry copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? status,
    int? createdAt,
    int? updatedAt,
    Map<String, dynamic>? fromSnapshot,
    Map<String, dynamic>? toSnapshot,
  }) => InterestEntry(
        id: id ?? this.id,
        fromUserId: fromUserId ?? this.fromUserId,
        toUserId: toUserId ?? this.toUserId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        fromSnapshot: fromSnapshot ?? this.fromSnapshot,
        toSnapshot: toSnapshot ?? this.toSnapshot,
      );

  static InterestEntry fromJson(Map<String, dynamic> json) => InterestEntry(
        id: json['id']?.toString() ?? '',
        fromUserId: json['fromUserId']?.toString() ?? '',
        toUserId: json['toUserId']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        createdAt: json['createdAt'] is int
            ? json['createdAt']
            : int.tryParse(json['createdAt']?.toString() ?? '') ??
                DateTime.now().millisecondsSinceEpoch,
        updatedAt: json['updatedAt'] is int
            ? json['updatedAt']
            : int.tryParse(json['updatedAt']?.toString() ?? '') ??
                DateTime.now().millisecondsSinceEpoch,
        fromSnapshot: json['fromSnapshot'] as Map<String, dynamic>?,
        toSnapshot: json['toSnapshot'] as Map<String, dynamic>?,
      );

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        toUserId,
        status,
        createdAt,
        updatedAt,
        fromSnapshot,
        toSnapshot,
      ];
}
