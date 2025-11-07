import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../utils/debug_logger.dart';

/// Report reasons for user safety
enum ReportReason {
  inappropriateContent,
  harassment,
  spam,
  fakeProfile,
  underageUser,
  other,
}

/// Safety service for managing user reports and blocks
class SafetyService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  /// Report a user for inappropriate behavior
  Future<bool> reportUser({
    required String reportedUserId,
    required ReportReason reason,
    String? description,
    String? relatedContentId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        logDebug('Cannot report user: not authenticated');
        return false;
      }

      if (currentUser.uid == reportedUserId) {
        logDebug('Cannot report self');
        return false;
      }

      // Check if user already reported this person
      final existingReport = await _firestore
          .collection('reports')
          .where('reporterId', isEqualTo: currentUser.uid)
          .where('reportedUserId', isEqualTo: reportedUserId)
          .get();

      if (existingReport.docs.isNotEmpty) {
        logDebug('User already reported this person');
        return false;
      }

      final report = {
        'id': _uuid.v4(),
        'reporterId': currentUser.uid,
        'reportedUserId': reportedUserId,
        'reason': reason.name,
        'description': description?.trim() ?? '',
        'relatedContentId': relatedContentId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('reports').add(report);
      
      // Also auto-block the reported user for safety
      await blockUser(reportedUserId);
      
      logDebug('User reported successfully', data: {
        'reporterId': currentUser.uid,
        'reportedUserId': reportedUserId,
        'reason': reason.name,
      });
      
      return true;
    } catch (e) {
      logDebug('Error reporting user', error: e);
      return false;
    }
  }

  /// Block a user
  Future<bool> blockUser(String blockedUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        logDebug('Cannot block user: not authenticated');
        return false;
      }

      if (currentUser.uid == blockedUserId) {
        logDebug('Cannot block self');
        return false;
      }

      // Check if already blocked
      final existingBlock = await _firestore
          .collection('blocked_users')
          .where('userId', isEqualTo: currentUser.uid)
          .where('blockedUserId', isEqualTo: blockedUserId)
          .get();

      if (existingBlock.docs.isNotEmpty) {
        logDebug('User already blocked');
        return true;
      }

      final block = {
        'userId': currentUser.uid,
        'blockedUserId': blockedUserId,
        'blockedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('blocked_users').add(block);
      
      logDebug('User blocked successfully', data: {
        'userId': currentUser.uid,
        'blockedUserId': blockedUserId,
      });
      
      return true;
    } catch (e) {
      logDebug('Error blocking user', error: e);
      return false;
    }
  }

  /// Unblock a user
  Future<bool> unblockUser(String blockedUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        logDebug('Cannot unblock user: not authenticated');
        return false;
      }

      final existingBlock = await _firestore
          .collection('blocked_users')
          .where('userId', isEqualTo: currentUser.uid)
          .where('blockedUserId', isEqualTo: blockedUserId)
          .get();

      if (existingBlock.docs.isEmpty) {
        logDebug('User not found in blocked list');
        return false;
      }

      // Delete the block record
      await existingBlock.docs.first.reference.delete();
      
      logDebug('User unblocked successfully', data: {
        'userId': currentUser.uid,
        'blockedUserId': blockedUserId,
      });
      
      return true;
    } catch (e) {
      logDebug('Error unblocking user', error: e);
      return false;
    }
  }

  /// Check if a user is blocked
  Future<bool> isUserBlocked(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final blockQuery = await _firestore
          .collection('blocked_users')
          .where('userId', isEqualTo: currentUser.uid)
          .where('blockedUserId', isEqualTo: userId)
          .limit(1)
          .get();

      return blockQuery.docs.isNotEmpty;
    } catch (e) {
      logDebug('Error checking block status', error: e);
      return false;
    }
  }

  /// Get list of blocked users
  Future<List<String>> getBlockedUsers() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final blockQuery = await _firestore
          .collection('blocked_users')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('blockedAt', descending: true)
          .get();

      return blockQuery.docs
          .map((doc) => doc.data()['blockedUserId'] as String)
          .toList();
    } catch (e) {
      logDebug('Error getting blocked users', error: e);
      return [];
    }
  }

  /// Check if current user is blocked by another user
  Future<bool> isCurrentUserBlockedBy(String otherUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final blockQuery = await _firestore
          .collection('blocked_users')
          .where('userId', isEqualTo: otherUserId)
          .where('blockedUserId', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      return blockQuery.docs.isNotEmpty;
    } catch (e) {
      logDebug('Error checking if blocked by user', error: e);
      return false;
    }
  }

  /// Filter out blocked users from a list
  Future<List<String>> filterBlockedUsers(List<String> userIds) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return userIds;

      final blockedUsers = await getBlockedUsers();
      return userIds.where((id) => !blockedUsers.contains(id)).toList();
    } catch (e) {
      logDebug('Error filtering blocked users', error: e);
      return userIds;
    }
  }
}

/// Provider for safety service
final safetyServiceProvider = Provider<SafetyService>((ref) {
  return SafetyService();
});
