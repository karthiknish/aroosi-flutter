part of 'package:aroosi_flutter/features/profiles/models.dart';

class MatchEntry extends Equatable {
  const MatchEntry({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.status,
    required this.createdAt,
    required this.conversationId,
    this.lastMessageText,
    this.lastMessageAt,
    this.otherUserId,
    this.otherUserName,
    this.otherUserImage,
    this.unreadCount = 0,
    this.isMutual = false,
    this.isBlocked = false,
  });

  final String id;
  final String user1Id;
  final String user2Id;
  final String status;
  final int createdAt; // epoch millis
  final String conversationId;
  final String? lastMessageText;
  final int? lastMessageAt;
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserImage;
  final int unreadCount;
  final bool isMutual;
  final bool isBlocked;

  MatchEntry copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    String? status,
    int? createdAt,
    String? conversationId,
    String? lastMessageText,
    int? lastMessageAt,
    String? otherUserId,
    String? otherUserName,
    String? otherUserImage,
    int? unreadCount,
    bool? isMutual,
    bool? isBlocked,
  }) => MatchEntry(
        id: id ?? this.id,
        user1Id: user1Id ?? this.user1Id,
        user2Id: user2Id ?? this.user2Id,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        conversationId: conversationId ?? this.conversationId,
        lastMessageText: lastMessageText ?? this.lastMessageText,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        otherUserId: otherUserId ?? this.otherUserId,
        otherUserName: otherUserName ?? this.otherUserName,
        otherUserImage: otherUserImage ?? this.otherUserImage,
        unreadCount: unreadCount ?? this.unreadCount,
        isMutual: isMutual ?? this.isMutual,
        isBlocked: isBlocked ?? this.isBlocked,
      );

  static MatchEntry fromJson(Map<String, dynamic> json) {
    final userId = json['userId']?.toString() ?? json['id']?.toString() ?? '';
    final fullName = json['fullName']?.toString() ?? '';
    final profileImageUrls = json['profileImageUrls'] as List<dynamic>? ?? [];
    final avatarUrl =
        profileImageUrls.isNotEmpty ? profileImageUrls.first.toString() : null;

    return MatchEntry(
      id: userId.isNotEmpty ? 'match_$userId' : json['id']?.toString() ?? '',
      user1Id: userId,
      user2Id: userId,
      status: 'matched',
      createdAt: json['createdAt'] is int
          ? json['createdAt']
          : int.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now().millisecondsSinceEpoch,
      conversationId: '',
      lastMessageText: json['lastMessageText']?.toString(),
      lastMessageAt: json['lastMessageAt'] is int
          ? json['lastMessageAt']
          : int.tryParse(json['lastMessageAt']?.toString() ?? ''),
      otherUserId: userId,
      otherUserName: fullName,
      otherUserImage: avatarUrl,
      unreadCount: json['unreadCount'] is int ? json['unreadCount'] : 0,
      isMutual: json['isMutual'] == true || json['mutual'] == true,
      isBlocked: json['isBlocked'] == true || json['blocked'] == true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        user1Id,
        user2Id,
        status,
        createdAt,
        conversationId,
        lastMessageText,
        lastMessageAt,
        otherUserId,
        otherUserName,
        otherUserImage,
        unreadCount,
        isMutual,
        isBlocked,
      ];
}
