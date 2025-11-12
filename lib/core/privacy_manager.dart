import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'att_service.dart';
import 'analytics_service.dart';
import '../widgets/privacy_tracking_dialog.dart';

/// Service for managing privacy and tracking compliance
class PrivacyManager {
  static final PrivacyManager _instance = PrivacyManager._internal();
  factory PrivacyManager() => _instance;
  PrivacyManager._internal();

  final AppTrackingTransparencyService _attService = AppTrackingTransparencyService();

  bool _isInitialized = false;
  bool _hasRequestedPermission = false;
  bool _isAppInBackground = false;

  /// Initialize privacy services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize ATT service and apply initial SDK state
      await _attService.initialize();
      await _updateSdkCollectionStates();

      // Initialize analytics service (will respect ATT permissions)
      await AnalyticsService().initialize();
      await _updateSdkCollectionStates(includeAnalytics: true);

      // Load saved preference
      final prefs = await SharedPreferences.getInstance();
      _hasRequestedPermission = prefs.getBool('has_requested_att_permission') ?? false;
      
      // Listen for ATT status changes and update analytics accordingly
      _attService.addStatusListener(_onAttStatusChanged);
      
      _isInitialized = true;
      debugPrint('PrivacyManager initialized');
    } catch (e) {
      debugPrint('Error initializing PrivacyManager: $e');
    }
  }

  /// Handle ATT status changes
  void _onAttStatusChanged() {
    // Update SDK collection status when ATT permission changes
    unawaited(_updateSdkCollectionStates(includeAnalytics: true));
  }

  /// Check if ATT permission is needed
  bool needsAttPermission() {
    return _attService.shouldShowAttRequest() && !_hasRequestedPermission;
  }

  /// Show ATT permission dialog
  Future<bool> requestAttPermission() async {
    _hasRequestedPermission = true;
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_requested_att_permission', true);
    final granted = await _attService.requestTrackingPermission();

    await _updateSdkCollectionStates(includeAnalytics: true);
    return granted;
  }

  /// Check if tracking is authorized
  bool get isTrackingAuthorized => _attService.isTrackingAuthorized;

  /// Show privacy tracking dialog
  Future<bool> showPrivacyDialog() async {
    final context = navigatorKey.currentContext;
    if (context == null) return false;

    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) => const PrivacyTrackingDialog(),
    ) ?? false;
  }

  /// Show privacy settings dialog
  Future<void> showPrivacySettings() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    await showDialog(
      context: context,
      builder: (dialogContext) => const PrivacySettingsDialog(),
    );
  }

  /// Respond to lifecycle changes to throttle background telemetry
  void handleAppLifecycleState(AppLifecycleState state) {
    final wasBackground = _isAppInBackground;
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInBackground = false;
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _isAppInBackground = true;
        break;
    }

    if (wasBackground != _isAppInBackground) {
      unawaited(_updateSdkCollectionStates());
    }
  }

  /// Reset privacy preferences (for testing)
  Future<void> resetPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_requested_att_permission');
    _hasRequestedPermission = false;
  }

  Future<void> _updateSdkCollectionStates({bool includeAnalytics = false}) async {
    final isAuthorized = !Platform.isIOS || _attService.isTrackingAuthorized;
    final allowDiagnostics = isAuthorized && !_isAppInBackground;

    try {
      await FirebasePerformance.instance.setPerformanceCollectionEnabled(allowDiagnostics);
    } catch (e) {
      debugPrint('Failed to update Firebase Performance state: $e');
    }

    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(isAuthorized);
    } catch (e) {
      debugPrint('Failed to update Crashlytics state: $e');
    }

    try {
      await FirebaseAnalytics.instance.setConsent(
        adStorageConsentGranted: isAuthorized,
        analyticsStorageConsentGranted: isAuthorized,
      );
    } catch (e) {
      debugPrint('Failed to update Firebase Analytics consent: $e');
    }

    if (includeAnalytics) {
      await AnalyticsService().updateAnalyticsStatus();
    }
  }
}

/// Provider for privacy management
final privacyManagerProvider = Provider<PrivacyManager>((ref) {
  return PrivacyManager();
});

/// Global navigator key for showing dialogs outside of widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
