import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aroosi_flutter/features/admin/admin_service.dart';
import 'package:aroosi_flutter/core/performance_service.dart';
import 'package:aroosi_flutter/core/error_handler.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';

/// Admin dashboard screen for monitoring app performance and data
/// 
/// Provides comprehensive admin functionality with role-based access:
/// - Real-time performance monitoring with optimization recommendations
/// - User statistics and comprehensive user management
/// - Safety reports monitoring and user suspension capabilities
/// - System health status and performance alerts
/// - Paginated user list with search and filtering
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  final PerformanceService _performanceService = PerformanceService();
  final ErrorHandler _errorHandler = ErrorHandler();

  late TabController _tabController;
  AdminRole? _userRole;
  bool _isLoading = true;
  bool _isUsersLoading = false;
  Map<String, dynamic> _userStats = {};
  Map<String, dynamic> _performanceData = {};
  Map<String, dynamic> _safetyReports = {};
  Map<String, dynamic> _systemHealth = {};
  List<String> _performanceAlerts = [];
  List<Map<String, dynamic>> _performanceRecommendations = [];
  
  // User management state
  List<Map<String, dynamic>> _usersList = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  String _searchQuery = '';
  String _filterByStatus = 'all';
  final String _sortBy = 'createdAt';
  final bool _sortDescending = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // Added users tab
    _initializeAdmin();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text != _searchQuery) {
      _searchQuery = _searchController.text;
      _debouncedLoadUsers();
    }
  }

  void _debouncedLoadUsers() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == _searchController.text) {
        _loadUsersList();
      }
    });
  }

  Future<void> _initializeAdmin() async {
    try {
      // Check admin access
      final isAdmin = await _adminService.isAdminUser();
      if (!isAdmin) {
        _redirectToHome();
        return;
      }

      // Get user role
      final role = await _adminService.getAdminRole();
      setState(() {
        _userRole = role;
        _isLoading = false;
      });

      // Load dashboard data
      await _loadDashboardData();

      // Load performance recommendations
      await _loadPerformanceRecommendations();

      // Log admin access
      await _adminService.logAdminAction(
        action: 'dashboard_access',
        details: 'Admin dashboard accessed',
      );
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'initializeAdmin',
        stackTrace: stackTrace,
      );
      _redirectToHome();
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      final results = await Future.wait([
        _adminService.getUserStatistics(),
        _adminService.getPerformanceData(),
        _adminService.getSafetyReports(),
        _adminService.getSystemHealth(),
      ]);

      final alerts = _performanceService.getPerformanceAlerts();

      setState(() {
        _userStats = results[0];
        _performanceData = results[1];
        _safetyReports = results[2];
        _systemHealth = results[3];
        _performanceAlerts = alerts;
      });
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'loadDashboardData',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _loadPerformanceRecommendations() async {
    try {
      final recommendations = await _adminService.getPerformanceRecommendations();
      setState(() {
        _performanceRecommendations = recommendations['recommendations'] ?? [];
      });
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'loadPerformanceRecommendations',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _loadUsersList() async {
    if (!AdminPermissions.hasPermission(_userRole!, 'view_user_stats')) return;

    setState(() {
      _isUsersLoading = true;
    });

    try {
      final result = await _adminService.getUsersList(
        page: _currentPage,
        limit: 20,
        sortBy: _sortBy,
        descending: _sortDescending,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        filterByStatus: _filterByStatus != 'all' ? _filterByStatus : null,
      );

      setState(() {
        _usersList = result['users'] ?? [];
        _totalPages = result['total_pages'] ?? 1;
        _totalCount = result['total_count'] ?? 0;
        _isUsersLoading = false;
      });
    } catch (e, stackTrace) {
      _errorHandler.handleException(
        e,
        context: 'loadUsersList',
        stackTrace: stackTrace,
      );
      setState(() {
        _isUsersLoading = false;
      });
    }
  }

  void _redirectToHome() {
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadDashboardData();
              _loadPerformanceRecommendations();
              if (_tabController.index == 1) { // Users tab
                _loadUsersList();
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_data',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Data'),
                ),
              ),
              const PopupMenuItem(
                value: 'performance_optimization',
                child: ListTile(
                  leading: Icon(Icons.speed),
                  title: Text('Performance Optimization'),
                ),
              ),
              if (_userRole == AdminRole.superAdmin)
                const PopupMenuItem(
                  value: 'manage_admins',
                  child: ListTile(
                    leading: Icon(Icons.admin_panel_settings),
                    title: Text('Manage Admins'),
                  ),
                ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.speed), text: 'Performance'),
            Tab(icon: Icon(Icons.security), text: 'Safety'),
            Tab(icon: Icon(Icons.trending_up), text: 'Optimization'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUsersTab(),
          _buildPerformanceTab(),
          _buildSafetyTab(),
          _buildOptimizationTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_performanceAlerts.isNotEmpty) ...[
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Performance Alerts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._performanceAlerts.map((alert) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(alert),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Users', '${_userStats['total_users'] ?? 0}', Icons.people)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Active Users', '${_userStats['active_users'] ?? 0}', Icons.person_outline)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Avg Response', '${_performanceData['average_response_time'] ?? 0}ms', Icons.speed)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Error Rate', '${((_performanceData['error_rate'] ?? 0) * 100).toStringAsFixed(1)}%', Icons.error_outline)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Pending Reports', '${_safetyReports['pending_reports'] ?? 0}', Icons.report)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('System Health', '${_systemHealth['uptime_percentage'] ?? 0}%', Icons.health_and_safety)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'System Status',
              style: ThemeHelpers.getMaterialTheme(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _buildSystemStatusCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: ThemeHelpers.getMaterialTheme(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: ThemeHelpers.getMaterialTheme(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusRow('Database', _systemHealth['database_status'] ?? 'unknown'),
            _buildStatusRow('Authentication', _systemHealth['auth_status'] ?? 'unknown'),
            _buildStatusRow('Storage', _systemHealth['storage_status'] ?? 'unknown'),
            const SizedBox(height: 12),
            Text(
              'Last Backup: ${_formatDateTime(_systemHealth['last_backup'])}',
              style: ThemeHelpers.getMaterialTheme(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String status) {
    final isHealthy = status == 'healthy';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.check_circle : Icons.error,
            color: isHealthy ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: isHealthy ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: ThemeHelpers.getMaterialTheme(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Average Response Time', '${_performanceData['average_response_time'] ?? 0}ms'),
                  _buildDetailRow('Error Rate', '${((_performanceData['error_rate'] ?? 0) * 100).toStringAsFixed(2)}%'),
                  _buildDetailRow('Active Sessions', '${_performanceData['active_sessions'] ?? 0}'),
                  const SizedBox(height: 16),
                  const Text('Slow Operations', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...(_performanceData['slow_operations'] as List<dynamic>? ?? []).map((op) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('${op['operation']}: ${op['avg_time']}ms'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Safety Reports',
            style: ThemeHelpers.getMaterialTheme(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Total Reports', '${_safetyReports['total_reports'] ?? 0}'),
                  _buildDetailRow('Pending Reports', '${_safetyReports['pending_reports'] ?? 0}'),
                  _buildDetailRow('Recent Reports (7 days)', '${_safetyReports['recent_reports'] ?? 0}'),
                  _buildDetailRow('Last Updated', _formatDateTime(_safetyReports['last_updated'])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (AdminPermissions.hasPermission(_userRole!, 'manage_reports'))
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to reports management
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reports management coming soon')),
                );
              },
              icon: const Icon(Icons.manage_search),
              label: const Text('Manage Reports'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'Unknown';
    try {
      final dt = dateTime is String ? DateTime.parse(dateTime) : dateTime as DateTime;
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'export_data':
        await _exportData();
        break;
      case 'performance_optimization':
        _tabController.animateTo(4); // Navigate to optimization tab
        break;
      case 'manage_admins':
        if (_userRole == AdminRole.superAdmin) {
          await _showManageAdminsDialog();
        }
        break;
      case 'logout':
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        break;
    }
  }

  void _handleUserAction(String userId, String action) async {
    switch (action) {
      case 'view_details':
        await _showUserDetails(userId);
        break;
      case 'suspend':
        await _showSuspendUserDialog(userId);
        break;
    }
  }

  Future<void> _showUserDetails(String userId) async {
    try {
      final userDetails = await _adminService.getUserDetails(userId);
      if (!mounted) {
        return;
      }
      if (userDetails == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${userDetails['firstName']} ${userDetails['lastName']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Email: ${userDetails['email']}'),
                Text('Phone: ${userDetails['phoneNumber'] ?? 'Not provided'}'),
                Text('Gender: ${userDetails['gender'] ?? 'Not specified'}'),
                Text('Subscription: ${userDetails['subscriptionTier']}'),
                Text('Verified: ${userDetails['isVerified'] ? 'Yes' : 'No'}'),
                Text('Profile Complete: ${userDetails['profileCompleted'] ? 'Yes' : 'No'}'),
                Text('Report Count: ${userDetails['reportCount']}'),
                Text('Matches Count: ${userDetails['matchesCount']}'),
                const SizedBox(height: 16),
                const Text('Recent Reports:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...userDetails['reports'].take(5).map((report) => 
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('- ${report['reason'] ?? 'No reason'}'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user details: ${e.toString()}')),
      );
    }
  }

  Future<void> _showSuspendUserDialog(String userId) async {
    final reasonController = TextEditingController();
    final isPermanent = ValueNotifier<bool>(false);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for suspension:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Suspension reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: isPermanent,
              builder: (context, permanent, child) {
                return CheckboxListTile(
                  title: const Text('Permanent Ban'),
                  subtitle: const Text('This cannot be undone'),
                  value: permanent,
                  onChanged: (value) {
                    isPermanent.value = value ?? false;
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isPermanent.value ? 'Ban User' : 'Suspend User'),
          ),
        ],
      ),
    );

    if (result == true && reasonController.text.isNotEmpty) {
      final success = await _adminService.suspendUser(
        userId,
        reasonController.text,
        permanent: isPermanent.value,
      );

      if (!mounted) {
        reasonController.dispose();
        isPermanent.dispose();
        return;
      }

      final messenger = ScaffoldMessenger.of(context);

      if (success) {
        messenger.showSnackBar(
          SnackBar(content: Text(isPermanent.value ? 'User banned successfully' : 'User suspended successfully')),
        );
        _loadUsersList(); // Refresh the list
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Failed to suspend user')),
        );
      }
    }

    reasonController.dispose();
    isPermanent.dispose();
  }

  Widget _buildUsersTab() {
    if (!AdminPermissions.hasPermission(_userRole!, 'view_user_stats')) {
      return const Center(
        child: Text('You do not have permission to view user data'),
      );
    }

    return Column(
      children: [
        // Search and filter controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search users by email...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _filterByStatus,
                    onChanged: (value) {
                      setState(() {
                        _filterByStatus = value!;
                        _currentPage = 1;
                      });
                      _loadUsersList();
                    },
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Users')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'new', child: Text('New Users')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: $_totalCount users',
                    style: ThemeHelpers.getMaterialTheme(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Page $_currentPage of $_totalPages',
                    style: ThemeHelpers.getMaterialTheme(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Users list
        Expanded(
          child: _isUsersLoading
              ? const Center(child: CircularProgressIndicator())
              : _usersList.isEmpty
                  ? const Center(child: Text('No users found'))
                  : ListView.builder(
                      itemCount: _usersList.length,
                      itemBuilder: (context, index) {
                        final user = _usersList[index];
                        return _buildUserCard(user);
                      },
                    ),
        ),
        // Pagination controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 1
                    ? () {
                        setState(() {
                          _currentPage--;
                        });
                        _loadUsersList();
                      }
                    : null,
              ),
              Text('Page $_currentPage'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages
                    ? () {
                        setState(() {
                          _currentPage++;
                        });
                        _loadUsersList();
                      }
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            (user['firstName'] as String? ?? '').isNotEmpty 
                ? (user['firstName'] as String)[0].toUpperCase()
                : 'U',
          ),
        ),
        title: Text('${user['firstName']} ${user['lastName']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email']),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(user['subscriptionTier'] ?? 'free'),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 8),
                if (user['isVerified'] == true)
                  const Chip(
                    label: Text('Verified'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                const SizedBox(width: 8),
                if (user['profileCompleted'] == true)
                  const Chip(
                    label: Text('Complete'),
                    backgroundColor: Colors.blue,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Reports: ${user['reportCount'] ?? 0}'),
                Text('Matches: ${user['matchCount'] ?? 0}'),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (action) => _handleUserAction(user['id'], action),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view_details',
                  child: ListTile(
                    leading: Icon(Icons.info),
                    title: Text('View Details'),
                  ),
                ),
                if (AdminPermissions.hasPermission(_userRole!, 'manage_users'))
                  const PopupMenuItem(
                    value: 'suspend',
                    child: ListTile(
                      leading: Icon(Icons.block),
                      title: Text('Suspend User'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Optimization Recommendations',
            style: ThemeHelpers.getMaterialTheme(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (_performanceRecommendations.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No performance issues detected'),
              ),
            )
          else
            ..._performanceRecommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value;
              final priority = recommendation['priority'] as String;
              final priorityColor = priority == 'high' 
                  ? Colors.red 
                  : priority == 'medium' 
                      ? Colors.orange 
                      : Colors.blue;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: priorityColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              priority.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              recommendation['category'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Issue: ${recommendation['issue']}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text('Recommendation: ${recommendation['recommendation']}'),
                      const SizedBox(height: 8),
                      Text('Impact: ${recommendation['impact']}'),
                      const SizedBox(height: 8),
                      Text('Effort: ${recommendation['effort']}'),
                      const SizedBox(height: 16),
                      if (_userRole == AdminRole.superAdmin)
                        ElevatedButton(
                          onPressed: () async {
                            final success = await _adminService.applyOptimization('opt_$index');
                            if (!mounted) return;
                            final messenger = ScaffoldMessenger.of(context);
                            if (success) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Optimization applied successfully')),
                              );
                            } else {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Failed to apply optimization')),
                              );
                            }
                          },
                          child: const Text('Apply Optimization'),
                        ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      await _adminService.logAdminAction(
        action: 'export_data',
        details: 'Admin exported dashboard data',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data export initiated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _showManageAdminsDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Admins'),
        content: const Text('Admin management interface coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
