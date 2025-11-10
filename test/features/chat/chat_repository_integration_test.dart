import 'package:aroosi_flutter/core/firebase_service.dart';
import 'package:aroosi_flutter/features/chat/chat_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late FirebaseService service;
  late ChatRepository repository;

  const userA = 'user-a';
  const userB = 'user-b';

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(mockUser: MockUser(uid: userA), signedIn: true);
    service = FirebaseService();
    service.configureForTesting(auth: auth, firestore: firestore);
    repository = ChatRepository(firebase: service);

    await firestore.collection('users').doc(userA).set({
      'displayName': 'Test User A',
      'profileImageUrls': ['https://example.com/a.png'],
      'isOnline': true,
      'lastActiveAt': Timestamp.fromDate(DateTime.now()),
    });

    await firestore.collection('users').doc(userB).set({
      'displayName': 'Test User B',
      'profileImageUrls': ['https://example.com/b.png'],
      'isOnline': true,
      'lastActiveAt': Timestamp.fromDate(DateTime.now()),
    });
  });

  tearDown(() {
    FirebaseService().resetTestingOverrides();
  });

  test('getConversations returns partner info and unread counts', () async {
    final conversationId = await service.createConversation([userA, userB]);
    final now = DateTime(2025, 1, 1, 12);

    await firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': 'Hello there',
      'lastMessageFrom': userB,
      'lastMessageAt': Timestamp.fromDate(now),
      'unreadCount': {userA: 1, userB: 0},
    });

    await firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc('msg-1')
        .set({
      'id': 'msg-1',
      'conversationId': conversationId,
      'fromUserId': userB,
      'toUserId': userA,
      'text': 'Hello there',
      'type': 'text',
      'createdAt': Timestamp.fromDate(now),
      'read': false,
    });

    final conversations = await repository.getConversations();

    expect(conversations, hasLength(1));
    final summary = conversations.first;
    expect(summary.partnerId, userB);
    expect(summary.partnerName, 'Test User B');
    expect(summary.partnerAvatarUrl, 'https://example.com/b.png');
    expect(summary.unreadCount, 1);
    expect(summary.lastMessageText, 'Hello there');
  });

  test('deleteMessage removes message and refreshes conversation metadata', () async {
    final conversationId = await service.createConversation([userA, userB]);
    final convoRef = firestore.collection('conversations').doc(conversationId);

    final firstTime = DateTime(2025, 1, 1, 10);
    final secondTime = DateTime(2025, 1, 1, 12);

    await convoRef.update({
      'unreadCount': {userA: 2, userB: 0},
      'lastMessage': 'Second message',
      'lastMessageFrom': userB,
      'lastMessageAt': Timestamp.fromDate(secondTime),
    });

    await convoRef.collection('messages').doc('m1').set({
      'id': 'm1',
      'conversationId': conversationId,
      'fromUserId': userB,
      'toUserId': userA,
      'text': 'First message',
      'type': 'text',
      'createdAt': Timestamp.fromDate(firstTime),
      'read': false,
    });

    await convoRef.collection('messages').doc('m2').set({
      'id': 'm2',
      'conversationId': conversationId,
      'fromUserId': userB,
      'toUserId': userA,
      'text': 'Second message',
      'type': 'text',
      'createdAt': Timestamp.fromDate(secondTime),
      'read': false,
    });

    await repository.deleteMessage(conversationId: conversationId, messageId: 'm2');

    final messagesSnapshot = await convoRef.collection('messages').get();
    expect(messagesSnapshot.docs.map((doc) => doc.id), contains('m1'));
    expect(messagesSnapshot.docs.map((doc) => doc.id), isNot(contains('m2')));

    final updatedConversation = await convoRef.get();
    final data = updatedConversation.data()!;
    expect(data['lastMessage'], 'First message');
    expect((data['lastMessageAt'] as Timestamp).toDate(), firstTime);
    final unreadMap = data['unreadCount'] as Map<String, dynamic>;
    expect(unreadMap[userA], 1); // Only the first message remains unread.
  });

  test('markAsRead clears unread count and flags messages', () async {
    final conversationId = await service.createConversation([userA, userB]);
    final convoRef = firestore.collection('conversations').doc(conversationId);

    await convoRef.update({
      'unreadCount': {userA: 1, userB: 0},
      'lastMessage': 'Unread message',
      'lastMessageFrom': userB,
      'lastMessageAt': Timestamp.fromDate(DateTime(2025, 1, 1, 12)),
    });

    await convoRef.collection('messages').doc('unread').set({
      'id': 'unread',
      'conversationId': conversationId,
      'fromUserId': userB,
      'toUserId': userA,
      'text': 'Unread message',
      'type': 'text',
      'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1, 12)),
      'read': false,
    });

    await repository.markAsRead(conversationId);

    final messageSnapshot = await convoRef.collection('messages').doc('unread').get();
    expect(messageSnapshot.data()!['read'], isTrue);

    final conversationData = (await convoRef.get()).data()!;
    final unreadMap = conversationData['unreadCount'] as Map<String, dynamic>;
    expect(unreadMap[userA], 0);
  });
}
