import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/models.dart';

/// Repository for matrimony onboarding data
class MatrimonyOnboardingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save matrimony onboarding data for current user
  Future<void> saveMatrimonyOnboardingData(MatrimonyOnboardingData data) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('matrimony_preferences')
          .doc('onboarding')
          .set(data.toJson());

      // Also update main user profile with relevant matrimony data
      await _firestore.collection('users').doc(userId).update({
        'matrimonyPreferences': data.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': true,
        'onboardingType': 'matrimony',
      });
    } catch (e) {
      throw Exception('Failed to save matrimony onboarding data: $e');
    }
  }

  /// Load matrimony onboarding data for current user
  Future<MatrimonyOnboardingData?> loadMatrimonyOnboardingData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return null;
      }

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('matrimony_preferences')
          .doc('onboarding')
          .get();

      if (doc.exists) {
        return MatrimonyOnboardingData.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      // Return null on error to allow fresh start
      return null;
    }
  }

  /// Get matrimony onboarding progress for current user
  Future<Map<String, dynamic>> getOnboardingProgress() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return {};
      }

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('matrimony_preferences')
          .doc('onboarding')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return {
          'hasMarriageIntention': data['marriageIntentionId'] != null,
          'hasFamilyValues': (data['familyValueIds'] as List?)?.isNotEmpty == true,
          'hasReligiousPreference': data['religiousPreferenceId'] != null,
          'hasPartnerPreferences': data['partnerPreferences'] != null,
          'hasFamilyInvolvement': data['requiresFamilyApproval'] != null,
          'isCompleted': data['isCompleted'] == true,
        };
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Update specific onboarding step
  Future<void> updateOnboardingStep(String stepId, dynamic data) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('matrimony_preferences')
          .doc('onboarding')
          .update({
        stepId: data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update onboarding step: $e');
    }
  }

  /// Mark onboarding as completed
  Future<void> markOnboardingCompleted() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('matrimony_preferences')
          .doc('onboarding')
          .update({
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Update main user profile
      await _firestore.collection('users').doc(userId).update({
        'onboardingCompleted': true,
        'onboardingType': 'matrimony',
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark onboarding as completed: $e');
    }
  }

  /// Reset onboarding data (for testing or re-onboarding)
  Future<void> resetOnboardingData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('matrimony_preferences')
          .doc('onboarding')
          .delete();

      // Update main user profile
      await _firestore.collection('users').doc(userId).update({
        'onboardingCompleted': false,
        'onboardingType': null,
        'onboardingCompletedAt': null,
      });
    } catch (e) {
      throw Exception('Failed to reset onboarding data: $e');
    }
  }

  /// Get user's matrimony preferences for matching
  Future<MatrimonyOnboardingData?> getUserMatrimonyPreferences() async {
    return loadMatrimonyOnboardingData();
  }

  /// Stream matrimony onboarding data changes
  Stream<MatrimonyOnboardingData?> streamMatrimonyOnboardingData() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('matrimony_preferences')
        .doc('onboarding')
        .snapshots()
        .map((doc) => doc.exists ? MatrimonyOnboardingData.fromJson(doc.data()!) : null);
  }
}
