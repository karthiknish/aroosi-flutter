import 'package:aroosi_flutter/core/firebase_service.dart';
import 'package:aroosi_flutter/utils/debug_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_models.dart';

class ChatRepository {
  ChatRepository({FirebaseService? firebase})
      : _firebase = firebase ?? FirebaseService();

  final FirebaseService _firebase;

  Future<List<ChatMessage>> getMessages({
    required String conversationId,
    int? before, // epoch millis for pagination
    int? limit,
  }) async {
    try {
      final currentUser = _firebase.currentUser?.uid;
      final messages = await _firebase.getMessages(
        conversationId: conversationId,
        before: before,
        limit: limit,
      );

      final mapped = messages
          .map((message) => _mapToChatMessage(message, currentUser))
          .toList();

      mapped.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return mapped;
    } catch (e) {
      logDebug('Error getting messages', error: e);
      return [];
    }
  }

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    String? toUserId,
  }) async {
    // Get current user ID for fromUserId field
    final currentUser = _firebase.currentUser?.uid;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    await _firebase.sendMessage(
      conversationId: conversationId,
      text: text,
      fromUserId: currentUser,
      toUserId: toUserId,
    );

    // Get the created message to return proper ID
    final messages = await _firebase.getMessages(
      conversationId: conversationId,
      limit: 1,
    );
    
    if (messages.isNotEmpty) {
      return _mapToChatMessage(messages.first, currentUser);
    }

    // Fallback if message not found immediately
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      fromUserId: currentUser,
      toUserId: toUserId,
      text: text,
      type: 'text',
      createdAt: DateTime.now(),
    );
  }

  // Delete a message
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    await _firebase.deleteMessageFromConversation(conversationId, messageId);
  }

  Future<void> markAsRead(String conversationId) async {
    final currentUser = _firebase.currentUser?.uid;
    if (currentUser == null) return;
    await _firebase.markConversationAsRead(
      conversationId: conversationId,
      userId: currentUser,
    );
  }

  Future<List<ConversationSummary>> getConversations() async {
    try {
      final currentUser = _firebase.currentUser?.uid;
      if (currentUser == null) {
        return [];
      }

      final rawConversations = await _firebase.getConversationsForUser(currentUser);
      if (rawConversations.isEmpty) {
        return [];
      }

      final partnerIds = rawConversations
          .map((conv) => _otherParticipant(conv['participants'], currentUser))
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      final profileMap = await _firebase.getUserProfilesByIds(partnerIds);

      final summaries = rawConversations.map((conv) {
        final partnerId = _otherParticipant(conv['participants'], currentUser) ?? '';
        final profile = profileMap[partnerId] ?? {};
        final unreadRaw = Map<String, dynamic>.from(conv['unreadCount'] ?? <String, dynamic>{});
        final unreadCount = (unreadRaw[currentUser] is num)
            ? (unreadRaw[currentUser] as num).toInt()
            : 0;
        final lastMessageAt = _parseDate(conv['lastMessageAt']) ?? _parseDate(conv['createdAt']);

        return ConversationSummary(
          id: conv['id']?.toString() ?? '',
          partnerId: partnerId,
          partnerName: _extractDisplayName(profile) ?? 'Unknown',
          partnerAvatarUrl: _extractPrimaryAvatar(profile),
          lastMessageText: conv['lastMessage']?.toString(),
          lastMessageAt: lastMessageAt,
          unreadCount: unreadCount,
          isOnline: profile['isOnline'] == true,
          lastSeen: _parseDate(profile['lastActiveAt']),
        );
      }).toList();

      summaries.sort((a, b) {
        final aDate = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return summaries;
    } catch (e) {
      logDebug('Error getting conversations', error: e);
      return [];
    }
  }

  Future<String> createConversation({
    required List<String> participantIds,
  }) async {
    try {
      return await _firebase.createConversation(participantIds);
    } catch (e) {
      throw Exception('Failed to create conversation: ${e.toString()}');
    }
  }

  // Typing indicator (no-op over HTTP; typically handled via realtime)
  Future<void> sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  }) async {
    // Intentionally a no-op. Hook up to realtime service when available.
    return;
  }

  // Delivery receipts (no-op placeholder)
  Future<void> sendDeliveryReceipt({
    required String messageId,
    required String status, // e.g., 'delivered' | 'read'
  }) async {
    // No REST endpoint; server infers from read events. Keep for parity.
    return;
  }

  // Image message upload
  Future<ChatMessage> uploadImageMessage({
    required String conversationId,
    required List<int> bytes,
    String filename = 'image.jpg',
    String contentType = 'image/jpeg',
    String? toUserId,
  }) async {
    try {
      final currentUser = _firebase.currentUser?.uid;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Upload image to Firebase Storage
      final imageUrl = await _firebase.uploadChatImageBytes(
        conversationId: conversationId,
        bytes: bytes,
        filename: filename,
        contentType: contentType,
      );

      // Create message in Firestore
      await _firebase.sendMessage(
        conversationId: conversationId,
        text: 'Image message',
        fromUserId: currentUser,
        toUserId: toUserId,
        type: 'image',
        imageUrl: imageUrl,
      );

      // Get the created message to return proper ID
      final messages = await _firebase.getMessages(
        conversationId: conversationId,
        limit: 1,
      );
      
      if (messages.isNotEmpty) {
        return _mapToChatMessage(messages.first, currentUser);
      }

      // Fallback if message not found immediately
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        fromUserId: currentUser,
        toUserId: toUserId,
        text: 'Image message',
        type: 'image',
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  Future<String> getVoiceMessageUrl(String messageId) async {
    try {
      // Get message from Firestore to retrieve audioUrl
      // Search through conversations where current user is a participant
      final currentUser = _firebase.currentUser?.uid;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Query conversations where user is a participant
      final conversationsSnapshot = await _firebase.conversationsRef
          .where('participants', arrayContains: currentUser)
          .get();

      for (final convDoc in conversationsSnapshot.docs) {
        final messages = await _firebase.getMessages(
          conversationId: convDoc.id,
          limit: 100,
        );
        final message = messages.firstWhere(
          (msg) => msg['id'] == messageId,
          orElse: () => <String, dynamic>{},
        );
        if (message.isNotEmpty && message['audioUrl'] != null) {
          return message['audioUrl'] as String;
        }
      }
      throw Exception('Voice message not found');
    } catch (e) {
      throw Exception('Failed to get voice message URL: ${e.toString()}');
    }
  }

  Future<ChatMessage> sendVoiceMessage({
    required String conversationId,
    required List<int> bytes,
    required int durationSeconds,
    String filename = 'voice-message.m4a',
    String contentType = 'audio/m4a',
    String? toUserId,
  }) async {
    try {
      final currentUser = _firebase.currentUser?.uid;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Upload voice message to Firebase Storage
      final audioUrl = await _firebase.uploadVoiceMessage(
        conversationId: conversationId,
        bytes: bytes,
        filename: filename,
        contentType: contentType,
      );

      // Create message in Firestore
      await _firebase.sendMessage(
        conversationId: conversationId,
        text: 'Voice message (${_formatDuration(durationSeconds)})',
        fromUserId: currentUser,
        toUserId: toUserId,
        type: 'voice',
        audioUrl: audioUrl,
        duration: durationSeconds,
      );

      // Get the created message to return proper ID
      final messages = await _firebase.getMessages(
        conversationId: conversationId,
        limit: 1,
      );
      
      if (messages.isNotEmpty) {
        return _mapToChatMessage(messages.first, currentUser);
      }

      // Fallback if message not found immediately
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        fromUserId: currentUser,
        toUserId: toUserId,
        text: 'Voice message (${_formatDuration(durationSeconds)})',
        type: 'voice',
        audioUrl: audioUrl,
        duration: durationSeconds,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to send voice message: ${e.toString()}');
    }
  }

  // Alias for uploadImageMessage for compatibility
  Future<ChatMessage> uploadImageMessageMultipart({
    required String conversationId,
    required List<int> bytes,
    String filename = 'image.jpg',
    String contentType = 'image/jpeg',
    String? toUserId,
  }) async {
    return uploadImageMessage(
      conversationId: conversationId,
      bytes: bytes,
      filename: filename,
      contentType: contentType,
      toUserId: toUserId,
    );
  }

  Future<Map<String, String>> getBatchProfileImages(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};

    try {
      final profileMap = await _firebase.getUserProfilesByIds(userIds);
      final result = <String, String>{};
      profileMap.forEach((id, profile) {
        final image = _extractPrimaryAvatar(profile);
        if (image != null && image.isNotEmpty) {
          result[id] = image;
        }
      });
      return result;
    } catch (e) {
      return {};
    }
  }

  // Unread counts across matches/conversations
  Future<Map<String, dynamic>> getUnreadCounts() async {
    try {
      final currentUser = _firebase.currentUser?.uid;
      if (currentUser == null) {
        return {};
      }

      // Get all conversations for the current user
      final conversations = await getConversations();
      
      Map<String, int> conversationCounts = {};
      int totalUnread = 0;

      // Count unread messages in each conversation
      for (final conversation in conversations) {
        final unreadCount = conversation.unreadCount;
        
        if (unreadCount > 0) {
          conversationCounts[conversation.id] = unreadCount;
          totalUnread += unreadCount;
        }
      }

      return {
        'total': totalUnread,
        'conversations': conversationCounts,
      };
    } catch (e) {
      // Return empty counts on error
      return {};
    }
  }

  // Mark specific messages as read
  Future<void> markMessagesAsRead(List<String> messageIds) async {
    if (messageIds.isEmpty) return;
    final currentUser = _firebase.currentUser?.uid;
    if (currentUser == null) return;
    await _firebase.markMessagesAsReadByIds(
      messageIds: messageIds,
      userId: currentUser,
    );
  }

  // Conversation events (optional parity)
  Future<List<dynamic>> getConversationEvents(String conversationId) async {
    return <dynamic>[];
  }

  // Presence API
  Future<Map<String, dynamic>> getPresence(String userId) async {
    try {
      final doc = await _firebase.getUserDocument(userId);
      if (doc == null) {
        return {'isOnline': false};
      }

      final lastSeen = _parseDate(doc['lastActiveAt']);
      final isOnlineFlag = doc['isOnline'] == true;
      final recentlyActive = lastSeen != null
          ? DateTime.now().difference(lastSeen) <= const Duration(minutes: 5)
          : false;

      return {
        'isOnline': isOnlineFlag || recentlyActive,
        if (lastSeen != null) 'lastSeen': lastSeen.millisecondsSinceEpoch,
      };
    } catch (e) {
      return {'isOnline': false};
    }
  }

  // Reaction methods
  Future<void> addReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
  }) async {
    final currentUser = _firebase.currentUser?.uid;
    if (currentUser == null) return;
    await _firebase.addReactionToMessage(
      conversationId: conversationId,
      messageId: messageId,
      emoji: emoji,
      userId: currentUser,
    );
  }

  Future<void> removeReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
  }) async {
    final currentUser = _firebase.currentUser?.uid;
    if (currentUser == null) return;
    await _firebase.removeReactionFromMessage(
      conversationId: conversationId,
      messageId: messageId,
      emoji: emoji,
      userId: currentUser,
    );
  }

  // Helper methods
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${remainingSeconds}s';
  }

  ChatMessage _mapToChatMessage(
    Map<String, dynamic> message,
    String? currentUser,
  ) {
    final normalized = Map<String, dynamic>.from(message);

    final created = normalized['createdAt'];
    final createdAt = _parseDate(created) ?? DateTime.now();
    normalized['createdAt'] = createdAt.toIso8601String();

    normalized['isMine'] =
        currentUser != null && normalized['fromUserId']?.toString() == currentUser;
    normalized['isRead'] = normalized['read'] == true;

    normalized['reactions'] ??= <String, List<String>>{};

    return ChatMessage.fromJson(normalized);
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  String? _extractDisplayName(Map<String, dynamic> profile) {
    return profile['displayName']?.toString() ??
        profile['fullName']?.toString() ??
        profile['name']?.toString();
  }

  String? _extractPrimaryAvatar(Map<String, dynamic> profile) {
    final urls = profile['profileImageUrls'];
    final primary = (urls is List && urls.isNotEmpty) ? urls.first : null;
    return primary?.toString() ??
        profile['photoUrl']?.toString() ??
        profile['avatarUrl']?.toString();
  }

  String? _otherParticipant(dynamic participants, String currentUser) {
    if (participants is List) {
      for (final item in participants) {
        final id = item?.toString();
        if (id != null && id.isNotEmpty && id != currentUser) {
          return id;
        }
      }
    }
    return null;
  }
}
