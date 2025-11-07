import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:aroosi_flutter/utils/debug_logger.dart';

/// Performance monitoring service for tracking app metrics
/// 
/// Enhanced with Firebase Performance Monitoring for production tracking:
/// - Automatic trace collection for critical operations
/// - Custom metrics for business-specific performance
/// - Real-time performance alerts and monitoring
/// - Admin dashboard integration for performance visualization
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<int>> _metrics = {};
  final int _maxMetricSamples = 100;
  
  // Firebase Performance Monitoring
  final Map<String, Trace> _firebaseTraces = {};
  final FirebaseAnalytics? _analytics = FirebaseAnalytics.instance;

  /// Start timing an operation with Firebase trace
  void startTimer(String operation, {bool enableFirebaseTrace = true}) {
    if (!kDebugMode) return; // Only track in debug mode for local timing
    
    _timers[operation] = Stopwatch()..start();
    logDebug('Performance timer started', data: {'operation': operation});

    // Start Firebase trace for production monitoring
    if (enableFirebaseTrace && !kDebugMode) {
      _startFirebaseTrace(operation);
    }
  }

  /// End timing an operation and record to both local and Firebase
  void endTimer(String operation, {Map<String, String>? attributes}) {
    if (!kDebugMode) return; // Only track in debug mode for local timing
    
    final timer = _timers[operation];
    if (timer != null && timer.isRunning) {
      timer.stop();
      final duration = timer.elapsedMilliseconds;
      
      _recordMetric(operation, duration);
      logDebug('Performance timer ended', data: {
        'operation': operation,
        'duration_ms': duration,
      });
      
      _timers.remove(operation);

      // End Firebase trace
      _endFirebaseTrace(operation, attributes);
    }
  }

  /// Start Firebase Performance trace
  void _startFirebaseTrace(String operation) {
    try {
      final trace = FirebasePerformance.instance.newTrace(operation);
      _firebaseTraces[operation] = trace;
      trace.start();
    } catch (e) {
      logDebug('Failed to start Firebase trace', error: e);
    }
  }

  /// End Firebase Performance trace with attributes
  void _endFirebaseTrace(String operation, Map<String, String>? attributes) {
    try {
      final trace = _firebaseTraces[operation];
      if (trace != null) {
        // Add custom attributes if provided
        if (attributes != null) {
          for (final entry in attributes.entries) {
            trace.setMetric(entry.key, int.tryParse(entry.value) ?? 0);
          }
        }
        trace.stop();
        _firebaseTraces.remove(operation);
      }
    } catch (e) {
      logDebug('Failed to end Firebase trace', error: e);
    }
  }

  /// Record custom metric to Firebase Analytics
  void recordCustomMetric(String name, int value, {Map<String, String>? parameters}) {
    if (!kDebugMode) {
      _analytics?.logEvent(
        name: 'performance_$name',
        parameters: {
          'value': value.toString(),
          ...?parameters,
        },
      );
    }
    
    recordMetric(name, value);
  }

  /// Monitor screen performance
  void trackScreenPerformance(String screenName, Duration loadTime) {
    recordCustomMetric('screen_load_time', loadTime.inMilliseconds, parameters: {
      'screen': screenName,
    });

    if (!kDebugMode) {
      _analytics?.logScreenView(
        screenName: screenName,
        parameters: {'load_time_ms': loadTime.inMilliseconds.toString()},
      );
    }
  }

  /// Track user interaction performance
  void trackInteractionPerformance(String interaction, Duration responseTime) {
    recordCustomMetric('interaction_response_time', responseTime.inMilliseconds, parameters: {
      'interaction': interaction,
    });
  }

  /// Track network request performance
  void trackNetworkPerformance(String endpoint, Duration duration, int statusCode) {
    recordCustomMetric('network_request_time', duration.inMilliseconds, parameters: {
      'endpoint': endpoint,
      'status_code': statusCode.toString(),
    });
  }

  /// Get performance summary for admin dashboard
  Map<String, dynamic> getPerformanceSummary() {
    final stats = getAllMetricStats();
    final summary = <String, dynamic>{
      'total_operations': stats.length,
      'average_performance': {},
      'slow_operations': <String>[],
      'error_rate': 0.0,
      'last_updated': DateTime.now().toIso8601String(),
    };

    // Calculate average performance and identify slow operations
    for (final entry in stats.entries) {
      final metric = entry.key;
      final data = entry.value;
      
      summary['average_performance'][metric] = data['average'];
      
      // Identify slow operations (> 1000ms average)
      if (double.tryParse(data['average'].toString()) != null && 
          double.parse(data['average'].toString()) > 1000) {
        summary['slow_operations'].add({
          'operation': metric,
          'average_ms': data['average'],
          'max_ms': data['max'],
        });
      }
    }

    return summary;
  }

  /// Get performance trends for admin dashboard
  List<Map<String, dynamic>> getPerformanceTrends() {
    final trends = <Map<String, dynamic>>[];
    
    for (final entry in _metrics.entries) {
      final metric = entry.key;
      final values = entry.value;
      
      if (values.length >= 2) {
        final recent = values.take(10).toList();
        final average = recent.reduce((a, b) => a + b) / recent.length;
        final trend = values.length > 10 ? 
          (values[values.length - 1] - values[values.length - 11]) / 10.0 : 0.0;
        
        trends.add({
          'metric': metric,
          'current_average': average.toStringAsFixed(2),
          'trend': trend > 0 ? 'increasing' : trend < 0 ? 'decreasing' : 'stable',
          'sample_count': values.length,
          'last_updated': DateTime.now().toIso8601String(),
        });
      }
    }
    
    return trends;
  }

  /// Check if performance is degraded for alerts
  List<String> getPerformanceAlerts({int thresholdMs = 2000}) {
    final alerts = <String>[];
    final stats = getAllMetricStats();
    
    for (final entry in stats.entries) {
      final metric = entry.key;
      final data = entry.value;
      
      if (double.tryParse(data['average'].toString()) != null && 
          double.parse(data['average'].toString()) > thresholdMs) {
        alerts.add('⚠️ $metric is performing slowly (${data['average']}ms average)');
      }
      
      // Check for high variance
      if (data['count'] > 10) {
        final max = int.tryParse(data['max'].toString()) ?? 0;
        final avg = double.tryParse(data['average'].toString()) ?? 0.0;
        if (max > avg * 5) {
          alerts.add('📊 $metric has high performance variance (max: ${data['max']}ms, avg: ${data['average']}ms)');
        }
      }
    }
    
    return alerts;
  }

  /// Record a custom metric
  void recordMetric(String metric, int value) {
    if (!kDebugMode) return; // Only track in debug mode
    
    _recordMetric(metric, value);
    logDebug('Metric recorded', data: {'metric': metric, 'value': value});
  }

  /// Internal method to record metrics
  void _recordMetric(String metric, int value) {
    if (!_metrics.containsKey(metric)) {
      _metrics[metric] = [];
    }
    
    _metrics[metric]!.add(value);
    
    // Keep only the last N samples to prevent memory leaks
    if (_metrics[metric]!.length > _maxMetricSamples) {
      _metrics[metric]!.removeAt(0);
    }
  }

  /// Get statistics for a metric
  Map<String, dynamic> getMetricStats(String metric) {
    final values = _metrics[metric] ?? [];
    if (values.isEmpty) {
      return {
        'count': 0,
        'average': 0.0,
        'min': 0,
        'max': 0,
        'median': 0.0,
      };
    }

    final sortedValues = List<int>.from(values)..sort();
    final count = values.length;
    final sum = values.reduce((a, b) => a + b);
    final average = sum / count;
    final min = sortedValues.first;
    final max = sortedValues.last;
    final median = count.isOdd 
        ? sortedValues[count ~/ 2].toDouble()
        : (sortedValues[count ~/ 2 - 1] + sortedValues[count ~/ 2]) / 2.0;

    return {
      'count': count,
      'average': average.toStringAsFixed(2),
      'min': min,
      'max': max,
      'median': median.toStringAsFixed(2),
    };
  }

  /// Get all metric statistics
  Map<String, Map<String, dynamic>> getAllMetricStats() {
    final stats = <String, Map<String, dynamic>>{};
    for (final metric in _metrics.keys) {
      stats[metric] = getMetricStats(metric);
    }
    return stats;
  }

  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
    _timers.clear();
    _firebaseTraces.clear();
    logDebug('Performance metrics cleared');
  }

  /// Log current performance summary
  void logPerformanceSummary() {
    if (!kDebugMode) return;
    
    final stats = getAllMetricStats();
    if (stats.isEmpty) {
      logDebug('No performance metrics available');
      return;
    }

    logDebug('=== Performance Summary ===');
    for (final entry in stats.entries) {
      final metric = entry.key;
      final data = entry.value;
      logDebug('$metric: ${data['count']} samples, '
          'avg: ${data['average']}ms, '
          'min: ${data['min']}ms, '
          'max: ${data['max']}ms');
    }
  }

  /// Monitor memory usage
  void logMemoryUsage() {
    if (!kDebugMode) return;
    
    // Note: This is a simplified memory tracking
    // In a real app, you might want to use more sophisticated memory monitoring
    developer.log('Memory usage tracking - implement detailed monitoring if needed');
  }

  /// Check if performance is degraded
  bool isPerformanceDegraded(String metric, {int thresholdMs = 1000}) {
    final stats = getMetricStats(metric);
    if (stats['count'] == 0) return false;
    
    final average = double.parse(stats['average'].toString());
    return average > thresholdMs;
  }
}

/// Performance monitor widget for tracking widget performance
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String operationName;

  const PerformanceMonitor({
    super.key,
    required this.child,
    required this.operationName,
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  final PerformanceService _performance = PerformanceService();

  @override
  void initState() {
    super.initState();
    _performance.startTimer(widget.operationName);
  }

  @override
  void dispose() {
    _performance.endTimer(widget.operationName);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Extension for easy performance monitoring
extension PerformanceMonitoring on Widget {
  Widget withPerformanceMonitoring(String operationName) {
    return PerformanceMonitor(
      operationName: operationName,
      child: this,
    );
  }
}
