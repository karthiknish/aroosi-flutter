part of 'package:aroosi_flutter/features/profiles/models.dart';

/// Family approval workflow for traditional matchmaking.
class FamilyApprovalRequest extends Equatable {
  const FamilyApprovalRequest({
    required this.id,
    required this.requesterId,
    required this.targetUserId,
    required this.status,
    required this.createdAt,
    required this.message,
    this.familyMemberId,
    this.familyMemberName,
    this.familyMemberRelation,
    this.response,
    this.respondedAt,
    this.approved = false,
  });

  final String id;
  final String requesterId;
  final String targetUserId;
  final String status; // 'pending', 'approved', 'rejected', 'cancelled'
  final int createdAt;
  final String message;
  final String? familyMemberId;
  final String? familyMemberName;
  final String? familyMemberRelation;
  final String? response;
  final int? respondedAt;
  final bool approved;

  FamilyApprovalRequest copyWith({
    String? id,
    String? requesterId,
    String? targetUserId,
    String? status,
    int? createdAt,
    String? message,
    String? familyMemberId,
    String? familyMemberName,
    String? familyMemberRelation,
    String? response,
    int? respondedAt,
    bool? approved,
  }) => FamilyApprovalRequest(
        id: id ?? this.id,
        requesterId: requesterId ?? this.requesterId,
        targetUserId: targetUserId ?? this.targetUserId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        message: message ?? this.message,
        familyMemberId: familyMemberId ?? this.familyMemberId,
        familyMemberName: familyMemberName ?? this.familyMemberName,
        familyMemberRelation:
            familyMemberRelation ?? this.familyMemberRelation,
        response: response ?? this.response,
        respondedAt: respondedAt ?? this.respondedAt,
        approved: approved ?? this.approved,
      );

  static FamilyApprovalRequest fromJson(Map<String, dynamic> json) =>
      FamilyApprovalRequest(
        id: json['id']?.toString() ?? '',
        requesterId: json['requesterId']?.toString() ?? '',
        targetUserId: json['targetUserId']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        createdAt: json['createdAt'] is int
            ? json['createdAt']
            : DateTime.now().millisecondsSinceEpoch,
        message: json['message']?.toString() ?? '',
        familyMemberId: json['familyMemberId']?.toString(),
        familyMemberName: json['familyMemberName']?.toString(),
        familyMemberRelation: json['familyMemberRelation']?.toString(),
        response: json['response']?.toString(),
        respondedAt:
            json['respondedAt'] is int ? json['respondedAt'] : null,
        approved: json['approved'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'requesterId': requesterId,
        'targetUserId': targetUserId,
        'status': status,
        'createdAt': createdAt,
        'message': message,
        if (familyMemberId != null) 'familyMemberId': familyMemberId,
        if (familyMemberName != null) 'familyMemberName': familyMemberName,
        if (familyMemberRelation != null)
          'familyMemberRelation': familyMemberRelation,
        if (response != null) 'response': response,
        if (respondedAt != null) 'respondedAt': respondedAt,
        'approved': approved,
      };

  @override
  List<Object?> get props => [
        id,
        requesterId,
        targetUserId,
        status,
        createdAt,
        message,
        familyMemberId,
        familyMemberName,
        familyMemberRelation,
        response,
        respondedAt,
        approved,
      ];
}
