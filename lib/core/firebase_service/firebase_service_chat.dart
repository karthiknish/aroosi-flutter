part of 'package:aroosi_flutter/core/firebase_service.dart';

extension FirebaseServiceChat on FirebaseService {
  Future<String> createConversation(List<String> participantIds) async {
    try {
      final unreadSeed = <String, int>{
        for (final id in participantIds) id: 0,
      };
      final doc = await conversationsRef.add({
        'participants': participantIds,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCount': unreadSeed,
      });
      return doc.id;
    } catch (e) {
      logDebug('Error creating conversation', error: e);
      rethrow;
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required String fromUserId,
    String? toUserId,
    String type = 'text',
    String? imageUrl,
    String? audioUrl,
    int? duration,
  }) async {
    try {
      final conversationRef = conversationsRef.doc(conversationId);
      final messageRef = conversationRef.collection('messages').doc();

      final messageData = <String, dynamic>{
        'id': messageRef.id,
        'conversationId': conversationId,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'text': text,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      };

      if (imageUrl != null) {
        messageData['imageUrl'] = imageUrl;
      }
      if (audioUrl != null) {
        messageData['audioUrl'] = audioUrl;
      }
      if (duration != null) {
        messageData['duration'] = duration;
      }

      await messageRef.set(messageData);

      await _firestoreInstance.runTransaction((txn) async {
        final conversationSnapshot = await txn.get(conversationRef);
        if (!conversationSnapshot.exists) {
          return;
        }

        final data = conversationSnapshot.data() as Map<String, dynamic>;
        final participants =
            List<String>.from(data['participants'] ?? <String>[]);
        final unreadRaw = Map<String, dynamic>.from(
          data['unreadCount'] ?? <String, dynamic>{},
        );
        final unread = <String, int>{
          for (final entry in unreadRaw.entries)
            entry.key: (entry.value is num)
                ? (entry.value as num).toInt()
                : 0,
        };

        for (final participant in participants) {
          if (participant == fromUserId) {
            unread[participant] = 0;
          } else {
            unread[participant] = (unread[participant] ?? 0) + 1;
          }
        }

        txn.update(conversationRef, {
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastMessage': text,
          'lastMessageFrom': fromUserId,
          'unreadCount': unread,
        });
      });
    } catch (e) {
      logDebug('Error sending message', error: e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMessages({
    required String conversationId,
    int? limit,
    int? before,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = conversationsRef
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: true);

      if (before != null) {
        query = query.startAfter(
          [Timestamp.fromMillisecondsSinceEpoch(before)],
        );
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      logDebug('Error getting messages', error: e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getConversationsForUser(
    String userId,
  ) async {
    try {
      Query query = conversationsRef.where('participants', arrayContains: userId);
      var orderedServerSide = true;

      try {
        query = query.orderBy('lastMessageAt', descending: true);
      } catch (_) {
        orderedServerSide = false;
      }

      final snapshot = await query.get();
      final conversations = snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();

      if (!orderedServerSide) {
        conversations.sort((a, b) {
          final aDate = _asDateTime(a['lastMessageAt']) ??
              _asDateTime(a['createdAt']);
          final bDate = _asDateTime(b['lastMessageAt']) ??
              _asDateTime(b['createdAt']);
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });
      }

      return conversations;
    } catch (e) {
      logDebug('Error getting conversations', error: e);
      return [];
    }
  }

  Future<Map<String, Map<String, dynamic>>> getUserProfilesByIds(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};
    final result = <String, Map<String, dynamic>>{};

    try {
      final chunks = _chunkList(userIds.toSet().toList(), 10);
      for (final chunk in chunks) {
        if (chunk.isEmpty) continue;
        final snapshot = await usersRef
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final doc in snapshot.docs) {
          result[doc.id] = doc.data() as Map<String, dynamic>;
        }
      }
    } catch (e) {
      logDebug('Error getting user profiles by ids', error: e);
    }

    return result;
  }

  Future<void> deleteMessageFromConversation(
    String conversationId,
    String messageId,
  ) async {
    final conversationRef = conversationsRef.doc(conversationId);
    final messageRef = conversationRef.collection('messages').doc(messageId);

    Map<String, dynamic>? removedMessage;

    try {
      await _firestoreInstance.runTransaction((txn) async {
        final messageSnap = await txn.get(messageRef);
        if (!messageSnap.exists) {
          return;
        }

        final conversationSnap = await txn.get(conversationRef);
        if (!conversationSnap.exists) {
          return;
        }

        removedMessage = messageSnap.data() as Map<String, dynamic>;
        txn.delete(messageRef);

        final data = conversationSnap.data() as Map<String, dynamic>;
        final unreadRaw = Map<String, dynamic>.from(
          data['unreadCount'] ?? <String, dynamic>{},
        );

        final toUser = removedMessage?['toUserId']?.toString();
        final wasRead = removedMessage?['read'] == true;
        if (!wasRead && toUser != null) {
          final current =
              (unreadRaw[toUser] is num) ? (unreadRaw[toUser] as num).toInt() : 0;
          unreadRaw[toUser] = current > 0 ? current - 1 : 0;
        }

        txn.update(conversationRef, {
          'unreadCount': unreadRaw,
        });
      });

      await _refreshConversationLastMessage(conversationRef);
    } catch (e) {
      logDebug('Error deleting message', error: e);
      rethrow;
    }
  }

  Future<int> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) async {
    final conversationRef = conversationsRef.doc(conversationId);
    var updated = 0;

    try {
      Query<Map<String, dynamic>> query = conversationRef
          .collection('messages')
          .where('read', isEqualTo: false)
          .where('toUserId', isEqualTo: userId)
          .limit(500);

      while (true) {
        final snapshot = await query.get();
        if (snapshot.docs.isEmpty) {
          break;
        }

        final batch = _firestoreInstance.batch();
        for (final doc in snapshot.docs) {
          batch.update(doc.reference, {'read': true});
        }
        await batch.commit();
        updated += snapshot.docs.length;

        if (snapshot.docs.length < 500) {
          break;
        }

        final lastDoc = snapshot.docs.last;
        query = query.startAfterDocument(lastDoc);
      }

      await conversationRef.update({'unreadCount.$userId': 0});
    } catch (e) {
      logDebug('Error marking conversation as read', error: e);
    }

    return updated;
  }

  Future<Map<String, int>> markMessagesAsReadByIds({
    required List<String> messageIds,
    required String userId,
  }) async {
    final result = <String, int>{};
    if (messageIds.isEmpty) return result;

    try {
      final chunks = _chunkList(messageIds.toSet().toList(), 10);
      for (final chunk in chunks) {
        final snapshot = await _firestoreInstance
            .collectionGroup('messages')
            .where('id', whereIn: chunk)
            .where('toUserId', isEqualTo: userId)
            .get();

        if (snapshot.docs.isEmpty) {
          continue;
        }

        final batch = _firestoreInstance.batch();
        for (final doc in snapshot.docs) {
          final data = doc.data();
          if (data['read'] == true) {
            continue;
          }
          batch.update(doc.reference, {'read': true});

          final conversationId = data['conversationId']?.toString() ??
              doc.reference.parent.parent?.id;
          if (conversationId != null) {
            result[conversationId] = (result[conversationId] ?? 0) + 1;
          }
        }
        await batch.commit();
      }

      for (final entry in result.entries) {
        final conversationRef = conversationsRef.doc(entry.key);
        await _firestoreInstance.runTransaction((txn) async {
          final snapshot = await txn.get(conversationRef);
          if (!snapshot.exists) {
            return;
          }
          final data = snapshot.data() as Map<String, dynamic>;
          final unreadRaw = Map<String, dynamic>.from(
            data['unreadCount'] ?? <String, dynamic>{},
          );
          final current =
              (unreadRaw[userId] is num) ? (unreadRaw[userId] as num).toInt() : 0;
          final next = current - entry.value;
          unreadRaw[userId] = next > 0 ? next : 0;
          txn.update(conversationRef, {'unreadCount': unreadRaw});
        });
      }
    } catch (e) {
      logDebug('Error marking messages as read by ids', error: e);
    }

    return result;
  }

  Future<void> addReactionToMessage({
    required String conversationId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    final messageRef = conversationsRef
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);

    try {
      await _firestoreInstance.runTransaction((txn) async {
        final snapshot = await txn.get(messageRef);
        if (!snapshot.exists) {
          throw Exception('Message not found');
        }
        final data = snapshot.data() as Map<String, dynamic>;
        final reactions = Map<String, dynamic>.from(
          data['reactions'] ?? <String, dynamic>{},
        );
        final currentList = List<String>.from(reactions[emoji] ?? <String>[]);
        if (!currentList.contains(userId)) {
          currentList.add(userId);
        }
        reactions[emoji] = currentList;
        txn.update(messageRef, {'reactions': reactions});
      });
    } catch (e) {
      logDebug('Error adding reaction', error: e);
      rethrow;
    }
  }

  Future<void> removeReactionFromMessage({
    required String conversationId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    final messageRef = conversationsRef
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);

    try {
      await _firestoreInstance.runTransaction((txn) async {
        final snapshot = await txn.get(messageRef);
        if (!snapshot.exists) {
          return;
        }
        final data = snapshot.data() as Map<String, dynamic>;
        final reactions = Map<String, dynamic>.from(
          data['reactions'] ?? <String, dynamic>{},
        );
        final currentList = List<String>.from(reactions[emoji] ?? <String>[]);
        currentList.removeWhere((entry) => entry == userId);
        if (currentList.isEmpty) {
          reactions.remove(emoji);
        } else {
          reactions[emoji] = currentList;
        }
        txn.update(messageRef, {'reactions': reactions});
      });
    } catch (e) {
      logDebug('Error removing reaction', error: e);
      rethrow;
    }
  }
}
