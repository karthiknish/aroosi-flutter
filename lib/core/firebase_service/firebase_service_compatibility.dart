part of 'package:aroosi_flutter/core/firebase_service.dart';

extension FirebaseServiceCompatibility on FirebaseService {
  Future<void> saveCompatibilityResponse({
    required String userId,
    required Map<String, dynamic> responses,
    required DateTime completedAt,
  }) async {
    try {
      await compatibilityResponsesRef.doc(userId).set({
        'userId': userId,
        'responses': responses,
        'completedAt': Timestamp.fromDate(completedAt),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      logDebug('Error saving compatibility response', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCompatibilityResponse(String userId) async {
    try {
      final doc = await compatibilityResponsesRef.doc(userId).get();
      if (!doc.exists) {
        return null;
      }

      final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
      final responsesRaw = data['responses'];
      final normalizedResponses = <String, dynamic>{};
      if (responsesRaw is Map) {
        responsesRaw.forEach((key, value) {
          if (value is List) {
            normalizedResponses[key.toString()] =
                value.map((item) => item.toString()).toList();
          } else if (value != null) {
            normalizedResponses[key.toString()] = value.toString();
          }
        });
      }

      return {
        'userId': data['userId']?.toString() ?? userId,
        'responses': normalizedResponses,
        'completedAt': _asDateTime(data['completedAt']) ?? DateTime.now(),
      };
    } catch (e) {
      logDebug('Error getting compatibility response', error: e);
      return null;
    }
  }

  Future<List<String>> getCompatibilityPartnerIds(String userId) async {
    final partnerIds = <String>{};

    try {
      final snapshot = await matchesRef
          .where('participantIDs', arrayContains: userId)
          .get();
      for (final doc in snapshot.docs) {
        final participants = doc['participantIDs'];
        if (participants is List) {
          for (final participant in participants) {
            final value = participant?.toString();
            if (value != null && value.isNotEmpty && value != userId) {
              partnerIds.add(value);
            }
          }
        }
      }
    } catch (e) {
      logDebug('participantIDs match lookup failed', error: e);
    }

    try {
      final snapshot = await matchesRef
          .where('userId', isEqualTo: userId)
          .get();
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final otherUserId = data['matchedUserId']?.toString() ??
            data['user2Id']?.toString() ??
            data['otherUserId']?.toString();
        if (otherUserId != null &&
            otherUserId.isNotEmpty &&
            otherUserId != userId) {
          partnerIds.add(otherUserId);
        }
      }
    } catch (e) {
      logDebug('userId match lookup failed', error: e);
    }

    return partnerIds.toList();
  }

  Future<void> saveCompatibilityScore({
    required String userId1,
    required String userId2,
    required double overallScore,
    required Map<String, double> categoryScores,
    required DateTime calculatedAt,
    Map<String, dynamic>? detailedBreakdown,
  }) async {
    try {
      final key = _pairKey(userId1, userId2);
      await compatibilityScoresRef.doc(key).set({
        'userIds': [userId1, userId2],
        'overallScore': overallScore,
        'categoryScores': categoryScores,
        if (detailedBreakdown != null) 'detailedBreakdown': detailedBreakdown,
        'calculatedAt': Timestamp.fromDate(calculatedAt),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      logDebug('Error saving compatibility score', error: e);
    }
  }

  Future<void> saveCompatibilityReport({
    required String reportId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await compatibilityReportsRef.doc(reportId).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      logDebug('Error saving compatibility report', error: e);
    }
  }

  Future<void> updateCompatibilityScoreCache({
    required String userId,
    required String partnerId,
    required double overallScore,
  }) async {
    final normalizedScore = overallScore.isFinite
        ? overallScore.round().clamp(0, 100)
        : 0;
    final payload = {
      'compatibilityScores.$partnerId': normalizedScore,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await usersRef.doc(userId).set(payload, SetOptions(merge: true));
    } catch (e) {
      logDebug('Error caching compatibility score on user', error: e);
    }

    try {
      await profilesRef.doc(userId).set(payload, SetOptions(merge: true));
    } catch (e) {
      logDebug('Error caching compatibility score on profile', error: e);
    }
  }
}
