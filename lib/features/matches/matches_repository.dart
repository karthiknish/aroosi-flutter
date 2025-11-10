import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aroosi_flutter/features/matches/models.dart';
import 'package:aroosi_flutter/features/profiles/models.dart';

abstract class MatchesRepository {
  Stream<List<Match>> streamMatches(String userID);
  Future<ProfileSummary?> fetchProfile(String id);
}

class FirestoreMatchesRepository implements MatchesRepository {
  final CollectionReference _matchesCollection = FirebaseFirestore.instance.collection('matches');
  final CollectionReference _profilesCollection = FirebaseFirestore.instance.collection('profiles');

  @override
  Stream<List<Match>> streamMatches(String userID) {
    return _matchesCollection
        .where('participantIDs', arrayContains: userID)
        .orderBy('lastUpdatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _mapDocumentToMatch(doc))
            .where((match) => match.isActive)
            .toList());
  }

  @override
  Future<ProfileSummary?> fetchProfile(String id) async {
    try {
      final doc = await _profilesCollection.doc(id).get();
      if (!doc.exists) return null;
      
      final data = doc.data() as Map<String, dynamic>;
      return ProfileSummary(
        id: doc.id,
        displayName: data['fullName'] ?? data['displayName'] ?? '',
        age: data['age'] ?? 0,
        city: data['city'] ?? '',
        avatarUrl: data['profilePhotoUrl'],
      );
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Match _mapDocumentToMatch(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Match(
      id: doc.id,
      participantIDs: List<String>.from(data['participantIDs'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp).toDate(),
      lastMessagePreview: data['lastMessagePreview'],
      totalMessages: data['totalMessages'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Future<void> updateLastMessage(String matchID, String messagePreview) async {
    try {
      await _matchesCollection.doc(matchID).update({
        'lastMessagePreview': messagePreview,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
        'totalMessages': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to update last message: $e');
    }
  }

  Future<String> createMatch(String userID1, String userID2) async {
    try {
      final docRef = await _matchesCollection.add({
        'participantIDs': [userID1, userID2],
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'totalMessages': 0,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create match: $e');
    }
  }
}
