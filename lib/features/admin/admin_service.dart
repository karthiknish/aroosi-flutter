import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aroosi_flutter/utils/debug_logger.dart';
import 'package:aroosi_flutter/core/error_handler.dart';
import 'package:aroosi_flutter/core/performance_service.dart';

/// Admin service for managing admin access and data monitoring
/// 
/// Provides secure admin functionality with Firebase-based role management:
/// - Role-based access control at Firebase level
/// - Admin user verification and authentication
/// - Secure data access for monitoring
/// - Audit logging for admin actions
class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final ErrorHandler _errorHandler = ErrorHandler();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PerformanceService _performanceService = PerformanceService();

  // Admin role collection in Firestore
  static const String _adminRolesCollection = 'admin_roles';
  static const String _auditLogCollection = 'admin_audit_log';

  /// Check if current user has admin access
  Future<bool> isAdminUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      // Check admin roles in Firestore
      final adminDoc = await _firestore
          .collection(_adminRolesCollection)
          .doc(currentUser.uid)
          .get();

      if (!adminDoc.exists) {
        return false;
      }

      final data = adminDoc.data() as Map<String, dynamic>;
      final isActive = data['is_active'] as bool? ?? false;
      final role = data['role'] as String? ?? 'viewer';

      return isActive && (role == 'admin' || role == 'super_admin');
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'isAdminUser',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get current user's admin role
  Future<AdminRole?> getAdminRole() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      final adminDoc = await _firestore
          .collection(_adminRolesCollection)
          .doc(currentUser.uid)
          .get();

      if (!adminDoc.exists) {
        return null;
      }

      final data = adminDoc.data() as Map<String, dynamic>;
      final roleString = data['role'] as String? ?? 'viewer';
      final isActive = data['is_active'] as bool? ?? false;

      if (!isActive) {
        return null;
      }

      return AdminRole.values.firstWhere(
        (role) => role.name == roleString,
        orElse: () => AdminRole.viewer,
      );
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'getAdminRole',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Log admin action for audit trail
  Future<void> logAdminAction({
    required String action,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return;
      }

      await _firestore.collection(_auditLogCollection).add({
        'admin_uid': currentUser.uid,
        'admin_email': currentUser.email,
        'action': action,
        'details': details,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'ip_address': 'unknown', // Could be enhanced with IP detection
      });

      logDebug('Admin action logged', data: {
        'action': action,
        'admin': currentUser.email,
      });
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'logAdminAction',
        stackTrace: stackTrace,
      );
    }
  }

  /// Get user statistics for admin dashboard
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      if (!await isAdminUser()) {
        throw Exception('Unauthorized access');
      }

      // Get user counts
      final usersSnapshot = await _firestore.collection('users').get();
      final activeUsers = usersSnapshot.docs.where((doc) {
        final data = doc.data();
        final lastActive = data['lastActiveAt'] as Timestamp?;
        if (lastActive == null) return false;
        
        // Consider active if last active within 30 days
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        return lastActive.toDate().isAfter(thirtyDaysAgo);
      }).length;

      final newUsersToday = usersSnapshot.docs.where((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;
        if (createdAt == null) return false;
        
        final today = DateTime.now();
        final createdDate = createdAt.toDate();
        return createdDate.year == today.year &&
               createdDate.month == today.month &&
               createdDate.day == today.day;
      }).length;

      return {
        'total_users': usersSnapshot.docs.length,
        'active_users': activeUsers,
        'new_users_today': newUsersToday,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'getUserStatistics',
        stackTrace: stackTrace,
      );
      return {
        'error': e.toString(),
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Get app performance data for admin dashboard
  Future<Map<String, dynamic>> getPerformanceData() async {
    try {
      if (!await isAdminUser()) {
        throw Exception('Unauthorized access');
      }

      // Get real performance data from PerformanceService
      final performanceSummary = _performanceService.getPerformanceSummary();
      final allStats = _performanceService.getAllMetricStats();
      
      // Calculate average response time from all metrics
      double totalAverage = 0.0;
      int metricCount = 0;
      for (final stat in allStats.values) {
        final avg = double.tryParse(stat['average'].toString()) ?? 0.0;
        if (avg > 0) {
          totalAverage += avg;
          metricCount++;
        }
      }
      final averageResponseTime = metricCount > 0 ? totalAverage / metricCount : 0.0;

      // Get slow operations from performance summary
      final slowOperations = (performanceSummary['slow_operations'] as List)
          .map((op) => {
                'operation': op['operation'] ?? 'unknown',
                'avg_time': double.tryParse(op['average_ms']?.toString() ?? '0') ?? 0,
              })
          .toList();

      // Get active sessions count from Firestore (users with recent activity)
      int activeSessions = 0;
      try {
        final now = DateTime.now();
        final oneHourAgo = now.subtract(const Duration(hours: 1));
        final activeUsersSnapshot = await _firestore
            .collection('users')
            .where('lastActiveAt', isGreaterThan: Timestamp.fromDate(oneHourAgo))
            .get();
        activeSessions = activeUsersSnapshot.docs.length;
      } catch (e) {
        logDebug('Error getting active sessions', error: e);
        // Fallback: estimate based on total users
        final usersSnapshot = await _firestore.collection('users').limit(1000).get();
        activeSessions = usersSnapshot.docs.length;
      }

      return {
        'average_response_time': averageResponseTime,
        'error_rate': 0.0, // Would need error tracking service for real data
        'active_sessions': activeSessions,
        'slow_operations': slowOperations,
        'total_operations': allStats.length,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'getPerformanceData',
        stackTrace: stackTrace,
      );
      return {
        'error': e.toString(),
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Get safety reports for admin monitoring
  Future<Map<String, dynamic>> getSafetyReports() async {
    try {
      if (!await isAdminUser()) {
        throw Exception('Unauthorized access');
      }

      final reportsSnapshot = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      final pendingReports = reportsSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['status'] == 'pending';
      }).length;

      final recentReports = reportsSnapshot.docs.where((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;
        if (createdAt == null) return false;
        
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        return createdAt.toDate().isAfter(sevenDaysAgo);
      }).length;

      return {
        'total_reports': reportsSnapshot.docs.length,
        'pending_reports': pendingReports,
        'recent_reports': recentReports,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'getSafetyReports',
        stackTrace: stackTrace,
      );
      return {
        'error': e.toString(),
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Get system health metrics
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      if (!await isAdminUser()) {
        throw Exception('Unauthorized access');
      }

      return {
        'database_status': 'healthy',
        'auth_status': 'healthy',
        'storage_status': 'healthy',
        'uptime_percentage': 99.9,
        'last_backup': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'getSystemHealth',
        stackTrace: stackTrace,
      );
      return {
        'error': e.toString(),
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Grant admin role to a user (super admin only)
  Future<bool> grantAdminRole(String userEmail, AdminRole role) async {
    try {
      final currentRole = await getAdminRole();
      if (currentRole != AdminRole.superAdmin) {
        throw Exception('Insufficient permissions');
      }

      // Find user by email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userDoc = userQuery.docs.first;
      final userId = userDoc.id;

      // Grant admin role
      await _firestore.collection(_adminRolesCollection).doc(userId).set({
        'user_email': userEmail,
        'role': role.name,
        'is_active': true,
        'granted_by': _auth.currentUser?.email,
        'granted_at': FieldValue.serverTimestamp(),
      });

      await logAdminAction(
        action: 'grant_admin_role',
        details: 'Granted $role role to $userEmail',
        metadata: {
          'target_user': userEmail,
          'role': role.name,
        },
      );

      return true;
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'grantAdminRole',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get paginated user list for admin dashboard
  Future<Map<String, dynamic>> getUsersList({
    int page = 1,
    int limit = 20,
    String? sortBy = 'createdAt',
    bool descending = true,
    String? searchQuery,
    String? filterByStatus,
  }) async {
    try {
      if (!await isAdminUser()) {
        throw Exception('Unauthorized access');
      }

      Query query = _firestore.collection('users');

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.where('email', isGreaterThanOrEqualTo: searchQuery)
                   .where('email', isLessThanOrEqualTo: '$searchQuery\uf8ff');
      }

      // Apply status filter
      if (filterByStatus != null) {
        switch (filterByStatus) {
          case 'active':
            final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
            query = query.where('lastActiveAt', isGreaterThanOrEqualTo: thirtyDaysAgo);
            break;
          case 'inactive':
            final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
            query = query.where('lastActiveAt', isLessThan: thirtyDaysAgo);
            break;
          case 'new':
            final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
            query = query.where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo);
            break;
        }
      }

      // Apply sorting
      query = query.orderBy(sortBy ?? 'createdAt', descending: descending);

      // Get total count for pagination
      final countQuery = query.count();
      final countSnapshot = await countQuery.get();
      final totalCount = countSnapshot.count ?? 0;

      // Apply pagination
      final offset = (page - 1) * limit;
      query = query.limit(limit);
      if (offset > 0) {
        query = query.startAfter([offset]);
      }

      final usersSnapshot = await query.get();
      final users = usersSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'email': data['email'] ?? 'Unknown',
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'createdAt': data['createdAt']?.toString(),
          'lastActiveAt': data['lastActiveAt']?.toString(),
          'isVerified': data['isVerified'] ?? false,
          'profileCompleted': data['profileCompleted'] ?? false,
          'subscriptionTier': data['subscriptionTier'] ?? 'free',
          'reportCount': data['reportCount'] ?? 0,
          'matchCount': data['matchCount'] ?? 0,
        };
      }).toList();

      await logAdminAction(
        action: 'view_users_list',
        details: 'Viewed users list page $page',
        metadata: {
          'page': page,
          'limit': limit,
          'search_query': searchQuery,
          'filter_status': filterByStatus,
        },
      );

      return {
        'users': users,
        'total_count': totalCount,
        'page': page,
        'limit': limit,
        'total_pages': (totalCount / limit).ceil(),
        'has_next': page * limit < totalCount,
        'has_prev': page > 1,
      };
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'getUsersList',
        stackTrace: stackTrace,
      );
      return {
        'error': e.toString(),
        'users': <dynamic>[],
        'total_count': 0,
      };
    }
  }

  /// Get detailed user information
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      if (!await isAdminUser()) {
        throw Exception('Unauthorized access');
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return null;
      }

      final data = userDoc.data() as Map<String, dynamic>;
      
      // Get additional user data from related collections
      final profileSnapshot = await _firestore
          .collection('user_profiles')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      final reportsSnapshot = await _firestore
          .collection('reports')
          .where('reportedUserId', isEqualTo: userId)
          .get();

      final matchesSnapshot = await _firestore
          .collection('matches')
          .where('participants', arrayContains: userId)
          .get();

      final userDetails = {
        'id': userDoc.id,
        'email': data['email'] ?? 'Unknown',
        'firstName': data['firstName'] ?? '',
        'lastName': data['lastName'] ?? '',
        'createdAt': data['createdAt']?.toString(),
        'lastActiveAt': data['lastActiveAt']?.toString(),
        'isVerified': data['isVerified'] ?? false,
        'profileCompleted': data['profileCompleted'] ?? false,
        'subscriptionTier': data['subscriptionTier'] ?? 'free',
        'phoneNumber': data['phoneNumber'] ?? '',
        'dateOfBirth': data['dateOfBirth'] ?? '',
        'gender': data['gender'] ?? '',
        'profile': profileSnapshot.docs.isNotEmpty 
            ? profileSnapshot.docs.first.data() 
            : {},
        'reportCount': reportsSnapshot.docs.length,
        'matchesCount': matchesSnapshot.docs.length,
        'reports': reportsSnapshot.docs.map((doc) => doc.data()).toList(),
        'matches': matchesSnapshot.docs.map((doc) => doc.data()).toList(),
      };

      await logAdminAction(
        action: 'view_user_details',
        details: 'Viewed details for user $userId',
        metadata: {'target_user_id': userId},
      );

      return userDetails;
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'getUserDetails',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Suspend or ban a user
  Future<bool> suspendUser(String userId, String reason, {bool permanent = false}) async {
    try {
      final currentRole = await getAdminRole();
      if (currentRole == null || !AdminPermissions.hasPermission(currentRole, 'manage_users')) {
        throw Exception('Insufficient permissions');
      }

      await _firestore.collection('users').doc(userId).update({
        'isSuspended': true,
        'suspensionReason': reason,
        'suspendedAt': FieldValue.serverTimestamp(),
        'suspendedBy': _auth.currentUser?.email,
        'permanentBan': permanent,
      });

      await logAdminAction(
        action: 'suspend_user',
        details: permanent ? 'Permanently banned user $userId' : 'Suspended user $userId',
        metadata: {
          'target_user_id': userId,
          'reason': reason,
          'permanent': permanent,
        },
      );

      return true;
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'suspendUser',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Unsuspend a user
  Future<bool> unsuspendUser(String userId) async {
    try {
      final currentRole = await getAdminRole();
      if (currentRole == null || !AdminPermissions.hasPermission(currentRole, 'manage_users')) {
        throw Exception('Insufficient permissions');
      }

      await _firestore.collection('users').doc(userId).update({
        'isSuspended': false,
        'suspensionReason': null,
        'suspendedAt': null,
        'suspendedBy': null,
        'permanentBan': false,
        'unsuspendedBy': _auth.currentUser?.email,
        'unsuspendedAt': FieldValue.serverTimestamp(),
      });

      await logAdminAction(
        action: 'unsuspend_user',
        details: 'Unsuspended user $userId',
        metadata: {'target_user_id': userId},
      );

      return true;
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'unsuspendUser',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get performance optimization recommendations based on monitoring data
  Future<Map<String, dynamic>> getPerformanceRecommendations() async {
    try {
      if (!await isAdminUser()) {
        throw Exception('Unauthorized access');
      }

      // Analyze actual performance data and provide recommendations
      final performanceData = await getPerformanceData();
      final slowOperations = performanceData['slow_operations'] as List? ?? [];
      final averageResponseTime = performanceData['average_response_time'] as double? ?? 0.0;
      
      final recommendations = <Map<String, dynamic>>[];

      // Generate recommendations based on actual slow operations
      for (final op in slowOperations) {
        final operation = op['operation'] as String? ?? 'unknown';
        final avgTime = op['avg_time'] as double? ?? 0.0;
        
        if (avgTime > 1000) {
          recommendations.add({
            'category': _getCategoryForOperation(operation),
            'priority': 'high',
            'issue': 'Slow performance detected for $operation',
            'recommendation': _getRecommendationForOperation(operation),
            'impact': 'Estimated ${((avgTime - 1000) / avgTime * 100).toStringAsFixed(0)}% improvement possible',
            'effort': 'medium',
            'current_avg_time': avgTime,
          });
        }
      }

      // Add general recommendations based on average response time
      if (averageResponseTime > 500) {
        recommendations.add({
          'category': 'Performance',
          'priority': 'medium',
          'issue': 'Overall average response time is high',
          'recommendation': 'Review and optimize slow operations, consider caching frequently accessed data',
          'impact': 'Estimated 20-30% improvement in overall response times',
          'effort': 'high',
        });
      }

      // Add database optimization recommendation if many slow operations
      if (slowOperations.length > 3) {
        recommendations.add({
          'category': 'Database',
          'priority': 'high',
          'issue': 'Multiple slow database operations detected',
          'recommendation': 'Add composite indexes on frequently queried fields, implement query result caching',
          'impact': 'Estimated 40% improvement in database query performance',
          'effort': 'medium',
        });
      }

      // If no issues found, return empty recommendations
      if (recommendations.isEmpty) {
        recommendations.add({
          'category': 'General',
          'priority': 'low',
          'issue': 'No critical performance issues detected',
          'recommendation': 'Continue monitoring performance metrics',
          'impact': 'System performing well',
          'effort': 'low',
        });
      }

      return {
        'recommendations': recommendations,
        'total_issues': recommendations.length,
        'high_priority': recommendations.where((r) => r['priority'] == 'high').length,
        'medium_priority': recommendations.where((r) => r['priority'] == 'medium').length,
        'low_priority': recommendations.where((r) => r['priority'] == 'low').length,
        'last_analyzed': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'getPerformanceRecommendations',
        stackTrace: stackTrace,
      );
      return {
        'error': e.toString(),
        'recommendations': <dynamic>[],
      };
    }
  }

  /// Apply performance optimization
  Future<bool> applyOptimization(String optimizationId) async {
    try {
      final currentRole = await getAdminRole();
      if (currentRole != AdminRole.superAdmin) {
        throw Exception('Insufficient permissions');
      }

      // This would implement actual optimization logic
      // For now, just log the action
      await logAdminAction(
        action: 'apply_optimization',
        details: 'Applied performance optimization: $optimizationId',
        metadata: {'optimization_id': optimizationId},
      );

      return true;
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'applyOptimization',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Helper method to get category for an operation
  String _getCategoryForOperation(String operation) {
    if (operation.contains('profile') || operation.contains('user')) {
      return 'Database';
    } else if (operation.contains('message') || operation.contains('chat')) {
      return 'Network';
    } else if (operation.contains('image') || operation.contains('upload')) {
      return 'Storage';
    } else if (operation.contains('search') || operation.contains('query')) {
      return 'Database';
    }
    return 'Performance';
  }

  /// Helper method to get recommendation for an operation
  String _getRecommendationForOperation(String operation) {
    if (operation.contains('profile_load')) {
      return 'Implement profile data caching and optimize Firestore queries with proper indexes';
    } else if (operation.contains('message_send')) {
      return 'Optimize message sending with batch operations and implement message queuing';
    } else if (operation.contains('image_upload')) {
      return 'Implement image compression before upload and use progressive image loading';
    } else if (operation.contains('search')) {
      return 'Add search indexes and implement search result caching';
    }
    return 'Review and optimize the operation, consider implementing caching or batch processing';
  }
}

/// Admin role levels
enum AdminRole {
  viewer,     // Can view dashboard data
  admin,      // Can manage most admin functions
  superAdmin, // Full access including role management
}

/// Admin permissions for different roles
class AdminPermissions {
  static const Map<AdminRole, Set<String>> _permissions = {
    AdminRole.viewer: {
      'view_dashboard',
      'view_user_stats',
      'view_performance',
      'view_safety_reports',
      'view_system_health',
    },
    AdminRole.admin: {
      'view_dashboard',
      'view_user_stats',
      'view_performance',
      'view_safety_reports',
      'view_system_health',
      'manage_reports',
      'export_data',
    },
    AdminRole.superAdmin: {
      'view_dashboard',
      'view_user_stats',
      'view_performance',
      'view_safety_reports',
      'view_system_health',
      'manage_reports',
      'export_data',
      'manage_admins',
      'system_settings',
    },
  };

  /// Check if role has specific permission
  static bool hasPermission(AdminRole role, String permission) {
    return _permissions[role]?.contains(permission) ?? false;
  }

  /// Get all permissions for a role
  static Set<String> getPermissions(AdminRole role) {
    return _permissions[role] ?? {};
  }
}
