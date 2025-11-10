import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import '../utils/debug_logger.dart';

part 'firebase_service/firebase_service_auth.dart';
part 'firebase_service/firebase_service_compatibility.dart';
part 'firebase_service/firebase_service_chat.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  fb.FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;

  fb.FirebaseAuth get _authInstance => _auth ??= fb.FirebaseAuth.instance;
  FirebaseFirestore get _firestoreInstance => _firestore ??= FirebaseFirestore.instance;
  FirebaseStorage get _storageInstance => _storage ??= FirebaseStorage.instance;

  @visibleForTesting
  void configureForTesting({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) {
    if (auth != null) {
      _auth = auth;
    }
    if (firestore != null) {
      _firestore = firestore;
    }
    if (storage != null) {
      _storage = storage;
    }
  }

  @visibleForTesting
  void resetTestingOverrides() {
    _auth = null;
    _firestore = null;
    _storage = null;
  }

  fb.User? get currentUser => _authInstance.currentUser;

  // Firestore methods
    DocumentReference get userProfileRef => 
      _firestoreInstance.collection('users').doc(currentUser?.uid);

    CollectionReference get usersRef => _firestoreInstance.collection('users');

    CollectionReference get profilesRef => _firestoreInstance.collection('profiles');

    CollectionReference get conversationsRef => _firestoreInstance.collection('conversations');

    CollectionReference get matchesRef => _firestoreInstance.collection('matches');

    CollectionReference get interestsRef => _firestoreInstance.collection('interests');

    CollectionReference get reportsRef => _firestoreInstance.collection('reports');

    CollectionReference get blocksRef => _firestoreInstance.collection('blocks');

    CollectionReference get compatibilityResponsesRef =>
      _firestoreInstance.collection('compatibilityResponses');

    CollectionReference get compatibilityScoresRef =>
      _firestoreInstance.collection('compatibilityScores');

    CollectionReference get compatibilityReportsRef =>
      _firestoreInstance.collection('compatibilityReports');

  // Profile methods
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final doc = await userProfileRef.get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      logDebug('Error getting current user profile', error: e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfileById(String userId) async {
    try {
      final doc = await usersRef.doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      logDebug('Error getting profile by ID', error: e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> createProfile(Map<String, dynamic> profileData) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      
      profileData['userId'] = userId;
      profileData['createdAt'] = FieldValue.serverTimestamp();
      profileData['updatedAt'] = FieldValue.serverTimestamp();
      
      await usersRef.doc(userId).set(profileData);
      return profileData;
    } catch (e) {
      logDebug('Error creating profile', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> updates) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      await usersRef.doc(userId).update(updates);
      
      // Return updated profile
      return await getProfileById(userId);
    } catch (e) {
      logDebug('Error updating profile', error: e);
      rethrow;
    }
  }

  // Search and matching methods
  Future<List<Map<String, dynamic>>> searchProfiles({
    Map<String, dynamic>? filters,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = usersRef.limit(limit);
      
      if (filters != null) {
        // Apply filters based on available data
        if (filters['minAge'] != null) {
          query = query.where('age', isGreaterThanOrEqualTo: filters['minAge']);
        }
        if (filters['maxAge'] != null) {
          query = query.where('age', isLessThanOrEqualTo: filters['maxAge']);
        }
        if (filters['gender'] != null) {
          query = query.where('gender', isEqualTo: filters['gender']);
        }
        if (filters['location'] != null) {
          // Geopoint filtering would need additional implementation
        }
      }
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      logDebug('Error searching profiles', error: e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMatches({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      
      Query query = matchesRef
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'matched')
          .orderBy('matchedAt', descending: true)
          .limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      logDebug('Error getting matches', error: e);
      return [];
    }
  }

  // Interest methods
  Future<void> sendInterest(String toUserId) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      
      await interestsRef.add({
        'fromUserId': userId,
        'toUserId': toUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      logDebug('Error sending interest', error: e);
      rethrow;
    }
  }

  Future<void> respondToInterest(String interestId, String status) async {
    try {
      await interestsRef.doc(interestId).update({
        'status': status,
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      logDebug('Error responding to interest', error: e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getInterests({
    required String mode, // 'sent', 'received', 'mutual'
    int limit = 20,
  }) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      
      Query query;
      switch (mode) {
        case 'sent':
          query = interestsRef
              .where('fromUserId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .limit(limit);
          break;
        case 'received':
          query = interestsRef
              .where('toUserId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .limit(limit);
          break;
        case 'mutual':
          query = interestsRef
              .where('status', isEqualTo: 'accepted')
              .orderBy('createdAt', descending: true)
              .limit(limit);
          break;
        default:
          return [];
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = _asDateTime(data['createdAt'])?.millisecondsSinceEpoch;
        final updatedAt = _asDateTime(data['updatedAt'] ?? data['respondedAt'])?.millisecondsSinceEpoch;
        return {
          ...data,
          'id': doc.id,
          if (createdAt != null) 'createdAt': createdAt,
          if (updatedAt != null) 'updatedAt': updatedAt,
        };
      }).toList();
    } catch (e) {
      logDebug('Error getting interests', error: e);
      return [];
    }
  }

  Future<void> removeInterest({
    String? interestId,
    String? otherUserId,
  }) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      DocumentReference? targetRef;
      if (interestId != null && interestId.isNotEmpty) {
        targetRef = interestsRef.doc(interestId);
      } else if (otherUserId != null && otherUserId.isNotEmpty) {
        final snapshot = await interestsRef
            .where('fromUserId', isEqualTo: userId)
            .where('toUserId', isEqualTo: otherUserId)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          targetRef = snapshot.docs.first.reference;
        }
      }

      if (targetRef == null) {
        return;
      }

      await targetRef.delete();
    } catch (e) {
      logDebug('Error removing interest', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getInterestStatus({
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      Query baseQuery(String source, String target) {
        return interestsRef
            .where('fromUserId', isEqualTo: source)
            .where('toUserId', isEqualTo: target)
            .limit(1);
      }

      final primary = await baseQuery(fromUserId, toUserId).get();
      if (primary.docs.isNotEmpty) {
        final doc = primary.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
          'createdAt':
              _asDateTime(data['createdAt'])?.millisecondsSinceEpoch,
          'updatedAt':
              _asDateTime(data['updatedAt'] ?? data['respondedAt'])
                  ?.millisecondsSinceEpoch,
        };
      }

      final reverse = await baseQuery(toUserId, fromUserId).get();
      if (reverse.docs.isNotEmpty) {
        final doc = reverse.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
          'createdAt':
              _asDateTime(data['createdAt'])?.millisecondsSinceEpoch,
          'updatedAt':
              _asDateTime(data['updatedAt'] ?? data['respondedAt'])
                  ?.millisecondsSinceEpoch,
        };
      }
      return null;
    } catch (e) {
      logDebug('Error getting interest status', error: e);
      return null;
    }
  }

  Future<Set<String>> getSelectedInterests() async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final doc = await usersRef.doc(userId).get();
      if (!doc.exists) {
        return <String>{};
      }

      final data = doc.data() as Map<String, dynamic>;
      final rawList = data['selectedInterests'] ?? data['interests'];
      if (rawList is! List) {
        return <String>{};
      }

      return rawList
          .whereType<dynamic>()
          .map((entry) => entry.toString())
          .where((value) => value.isNotEmpty)
          .toSet();
    } catch (e) {
      logDebug('Error getting selected interests', error: e);
      return <String>{};
    }
  }

  Future<void> saveSelectedInterests(Set<String> interests) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final list = interests.where((e) => e.isNotEmpty).toList();
      await usersRef.doc(userId).set(
        {
          'selectedInterests': list,
          'interests': list,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      logDebug('Error saving selected interests', error: e);
      rethrow;
    }
  }

  // Shortlist methods
  Future<void> addToShortlist(String userId) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');
      
      await usersRef.doc(currentUserId).collection('shortlist').doc(userId).set({
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      logDebug('Error adding to shortlist', error: e);
      rethrow;
    }
  }

  Future<void> removeFromShortlist(String userId) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');
      
      await usersRef.doc(currentUserId).collection('shortlist').doc(userId).delete();
    } catch (e) {
      logDebug('Error removing from shortlist', error: e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getShortlist({int limit = 20}) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      
      final snapshot = await usersRef
          .doc(userId)
          .collection('shortlist')
          .orderBy('addedAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      logDebug('Error getting shortlist', error: e);
      return [];
    }
  }

  // Safety methods
  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      
      await reportsRef.add({
        'reporterId': userId,
        'reportedUserId': reportedUserId,
        'reason': reason,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      logDebug('Error reporting user', error: e);
      rethrow;
    }
  }

  Future<void> blockUser(String blockedUserId) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      
      await blocksRef.add({
        'blockerId': userId,
        'blockedUserId': blockedUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      logDebug('Error blocking user', error: e);
      rethrow;
    }
  }

  Future<void> unblockUser(String blockedUserId) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      
      final snapshot = await blocksRef
          .where('blockerId', isEqualTo: userId)
          .where('blockedUserId', isEqualTo: blockedUserId)
          .get();
      
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      logDebug('Error unblocking user', error: e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBlockedUsers() async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      
      final snapshot = await blocksRef
          .where('blockerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      logDebug('Error getting blocked users', error: e);
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    try {
      final doc = await usersRef.doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      logDebug('Error getting user document', error: e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getProfileImages({
    required String userId,
  }) async {
    try {
      final snapshot = await _profileImagesRef(userId)
          .orderBy('order')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          if (!data.containsKey('storageId') &&
              data['storagePath'] != null)
            'storageId': data['storagePath'],
        };
      }).toList();
    } catch (e) {
      logDebug('Error fetching profile images', error: e);
      return <Map<String, dynamic>>[];
    }
  }

  Future<Map<String, dynamic>> addProfileImageRecord({
    required String userId,
    required String url,
    required String storagePath,
  }) async {
    try {
      final collection = _profileImagesRef(userId);
      final snapshot = await collection
          .orderBy('order', descending: true)
          .limit(1)
          .get();

      final currentMaxOrder = snapshot.docs.isEmpty
          ? -1
          : (snapshot.docs.first.data()['order'] is num
              ? (snapshot.docs.first.data()['order'] as num).toInt()
              : snapshot.docs.length - 1);

      final nextOrder = currentMaxOrder + 1;
      final docRef = collection.doc();
      final payload = <String, dynamic>{
        'url': url,
        'thumbnailUrl': url,
        'storagePath': storagePath,
        'storageId': storagePath,
        'isPrimary': nextOrder == 0,
        'order': nextOrder,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(payload);
      await _syncUserProfileImageMetadata(userId);

      return {
        ...payload,
        'id': docRef.id,
      };
    } catch (e) {
      logDebug('Error adding profile image record', error: e);
      rethrow;
    }
  }

  Future<void> deleteProfileImage({
    required String userId,
    required String imageId,
  }) async {
    try {
      final collection = _profileImagesRef(userId);
      DocumentReference<Map<String, dynamic>>? targetRef;

      final directRef = collection.doc(imageId);
      final directSnapshot = await directRef.get();
      if (directSnapshot.exists) {
        targetRef = directRef;
      } else {
        final fallbackQuery = await collection
            .where('storageId', isEqualTo: imageId)
            .limit(1)
            .get();
        if (fallbackQuery.docs.isNotEmpty) {
          targetRef = fallbackQuery.docs.first.reference;
        }
      }

      if (targetRef == null) {
        return;
      }

        final snapshot = await targetRef.get();
        final data = snapshot.data();
        await targetRef.delete();

        String? storagePath;
        if (data is Map<String, dynamic>) {
          storagePath = data['storagePath']?.toString() ??
              data['storageId']?.toString();
        }
      if (storagePath != null && storagePath.isNotEmpty) {
        try {
          await _storageInstance.ref(storagePath).delete();
        } catch (storageError) {
          logDebug('Error deleting profile image storage object',
              error: storageError);
        }
      }

      await _normalizeProfileImageOrder(userId);
      await _syncUserProfileImageMetadata(userId);
    } catch (e) {
      logDebug('Error deleting profile image', error: e);
      rethrow;
    }
  }

  Future<void> reorderProfileImages({
    required String userId,
    required List<String> orderedIds,
  }) async {
    if (orderedIds.isEmpty) {
      return;
    }

    try {
      final collection = _profileImagesRef(userId);
      final batch = _firestoreInstance.batch();

      for (var i = 0; i < orderedIds.length; i++) {
        final id = orderedIds[i];
        final ref = collection.doc(id);
        batch.update(ref, {
          'order': i,
          'isPrimary': i == 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      await _normalizeProfileImageOrder(userId);
      await _syncUserProfileImageMetadata(userId);
    } catch (e) {
      logDebug('Error reordering profile images', error: e);
      rethrow;
    }
  }

  // Storage methods
  Future<Map<String, String>> uploadProfileImage(XFile file, String userId) async {
    try {
      final filename = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storageInstance
          .ref()
          .child('profile_images/$userId/$filename');
      final uploadTask = await ref.putFile(File(file.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return {
        'url': downloadUrl,
        'storagePath': uploadTask.ref.fullPath,
      };
    } catch (e) {
      logDebug('Error uploading profile image', error: e);
      rethrow;
    }
  }

  Future<String> uploadVoiceMessage({
    required String conversationId,
    required List<int> bytes,
    String filename = 'voice-message.m4a',
    String contentType = 'audio/m4a',
  }) async {
    try {
      final extension = filename.contains('.')
          ? filename.split('.').last
          : 'm4a';
      final ref = _storageInstance
          .ref()
          .child('voice_messages/$conversationId/${DateTime.now().millisecondsSinceEpoch}.$extension');
      final metadata = SettableMetadata(contentType: contentType);
      final uploadTask = await ref.putData(
        Uint8List.fromList(bytes),
        metadata,
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      logDebug('Error uploading voice message', error: e);
      rethrow;
    }
  }

  Future<String> uploadChatImage(String conversationId, XFile file) async {
    try {
      final ref = _storageInstance.ref().child('chat_images/$conversationId/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = await ref.putFile(File(file.path));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      logDebug('Error uploading chat image', error: e);
      rethrow;
    }
  }

  Future<String> uploadChatImageBytes({
    required String conversationId,
    required List<int> bytes,
    String filename = 'image.jpg',
    String contentType = 'image/jpeg',
  }) async {
    try {
      final extension = filename.split('.').last;
      final ref = _storageInstance.ref().child('chat_images/$conversationId/${DateTime.now().millisecondsSinceEpoch}.$extension');
      final metadata = SettableMetadata(contentType: contentType);
      final uploadTask = await ref.putData(Uint8List.fromList(bytes), metadata);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      logDebug('Error uploading chat image from bytes', error: e);
      rethrow;
    }
  }

  // Utility methods
  Future<bool> isEmailVerified() async {
    try {
      final user = currentUser;
      if (user == null) return false;
      
      // Reload user to get latest email verification status
      await user.reload();
      return user.emailVerified;
    } catch (e) {
      logDebug('Error checking email verification', error: e);
      return false;
    }
  }

  Future<void> resendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      logDebug('Error resending email verification', error: e);
      rethrow;
    }
  }

  CollectionReference<Map<String, dynamic>> _profileImagesRef(String userId) {
    return _firestoreInstance
        .collection('users')
        .doc(userId)
        .collection('profileImages');
  }

  Future<void> _normalizeProfileImageOrder(String userId) async {
    try {
      final collection = _profileImagesRef(userId);
      final snapshot = await collection.orderBy('order').get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      var hasUpdates = false;
      final batch = _firestoreInstance.batch();
      for (var i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        final currentOrder = data['order'] is num
            ? (data['order'] as num).toInt()
            : null;
        final isPrimary = data['isPrimary'] == true;
        final desiredPrimary = i == 0;
        if (currentOrder != i || isPrimary != desiredPrimary) {
          hasUpdates = true;
          batch.update(doc.reference, {
            'order': i,
            'isPrimary': desiredPrimary,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (hasUpdates) {
        await batch.commit();
      }
    } catch (e) {
      logDebug('Error normalizing profile image order', error: e);
    }
  }

  Future<void> _syncUserProfileImageMetadata(String userId) async {
    try {
      final collection = _profileImagesRef(userId);
      final snapshot = await collection.orderBy('order').get();
      final urls = <String>[];
      String? primaryUrl;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final url = data['url']?.toString();
        if (url == null || url.isEmpty) {
          continue;
        }
        urls.add(url);
        final isPrimary = data['isPrimary'] == true;
        if (primaryUrl == null && isPrimary) {
          primaryUrl = url;
        }
      }

      if (primaryUrl == null && urls.isNotEmpty) {
        primaryUrl = urls.first;
      }

      await usersRef.doc(userId).set(
        {
          'profileImageUrls': urls,
          'primaryImageUrl': primaryUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      logDebug('Error syncing profile image metadata', error: e);
    }
  }

  String _pairKey(String a, String b) {
    final entries = [a, b]..sort();
    return entries.join('_');
  }

  DateTime? _asDateTime(dynamic value) {
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

  List<List<T>> _chunkList<T>(List<T> items, int size) {
    if (items.isEmpty || size <= 0) return <List<T>>[];
    final chunks = <List<T>>[];
    for (var i = 0; i < items.length; i += size) {
      final end = (i + size) > items.length ? items.length : i + size;
      chunks.add(items.sublist(i, end));
    }
    return chunks;
  }

  Future<void> _refreshConversationLastMessage(
    DocumentReference conversationRef,
  ) async {
    final latestSnapshot = await conversationRef
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (latestSnapshot.docs.isEmpty) {
      await conversationRef.update({
        'lastMessage': null,
        'lastMessageAt': null,
        'lastMessageFrom': null,
      });
      return;
    }

    final latest = latestSnapshot.docs.first.data();
    await conversationRef.update({
      'lastMessage': latest['text'],
      'lastMessageAt': latest['createdAt'],
      'lastMessageFrom': latest['fromUserId'],
    });
  }
}
