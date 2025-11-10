import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aroosi_flutter/utils/debug_logger.dart';

/// Service for managing offline data persistence and request queuing
class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  static const String _offlineQueueBoxName = 'offline_queue';
  static const String _cacheBoxName = 'app_cache';
  static const String _cachePrefix = 'cache_';
  
  Box? _queueBox;
  Box? _cacheBox;
  bool _isInitialized = false;

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();
      
      _queueBox = await Hive.openBox(_offlineQueueBoxName);
      _cacheBox = await Hive.openBox(_cacheBoxName);
      
      _isInitialized = true;
      logDebug('OfflineService initialized successfully');
    } catch (e) {
      logDebug('Failed to initialize OfflineService', error: e);
      rethrow;
    }
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      logDebug('Failed to check connectivity', error: e);
      return false;
    }
  }

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream => Connectivity()
      .onConnectivityChanged
      .map((result) => result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet));

  /// Cache data with a key and optional TTL (time to live in seconds)
  Future<void> cacheData<T>({
    required String key,
    required T data,
    int? ttlSeconds,
  }) async {
    if (!_isInitialized || _cacheBox == null) {
      logDebug('OfflineService not initialized, skipping cache');
      return;
    }

    try {
      final cacheEntry = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': ttlSeconds,
      };
      
      await _cacheBox!.put(_cachePrefix + key, jsonEncode(cacheEntry));
      logDebug('Data cached: $key');
    } catch (e) {
      logDebug('Failed to cache data: $key', error: e);
    }
  }

  /// Retrieve cached data
  T? getCachedData<T>(String key) {
    if (!_isInitialized || _cacheBox == null) return null;

    try {
      final cached = _cacheBox!.get(_cachePrefix + key);
      if (cached == null) return null;

      final cacheEntry = jsonDecode(cached as String) as Map<String, dynamic>;
      final timestamp = cacheEntry['timestamp'] as int;
      final ttl = cacheEntry['ttl'] as int?;
      
      // Check if cache is expired
      if (ttl != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (age > ttl * 1000) {
          _cacheBox!.delete(_cachePrefix + key);
          return null;
        }
      }
      
      return cacheEntry['data'] as T;
    } catch (e) {
      logDebug('Failed to get cached data: $key', error: e);
      return null;
    }
  }

  /// Clear cached data for a specific key
  Future<void> clearCache(String key) async {
    if (!_isInitialized || _cacheBox == null) return;
    
    try {
      await _cacheBox!.delete(_cachePrefix + key);
      logDebug('Cache cleared: $key');
    } catch (e) {
      logDebug('Failed to clear cache: $key', error: e);
    }
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    if (!_isInitialized || _cacheBox == null) return;
    
    try {
      final keys = _cacheBox!.keys
          .where((key) => key.toString().startsWith(_cachePrefix))
          .toList();
      
      for (final key in keys) {
        await _cacheBox!.delete(key);
      }
      
      logDebug('All cache cleared');
    } catch (e) {
      logDebug('Failed to clear all cache', error: e);
    }
  }

  /// Queue a failed request for retry when online
  Future<void> queueRequest({
    required String id,
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (!_isInitialized || _queueBox == null) {
      logDebug('OfflineService not initialized, skipping queue');
      return;
    }

    try {
      final request = {
        'id': id,
        'method': method,
        'url': url,
        'headers': headers ?? {},
        'body': body != null ? jsonEncode(body) : null,
        'queryParameters': queryParameters ?? {},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'retryCount': 0,
      };
      
      await _queueBox!.put(id, jsonEncode(request));
      logDebug('Request queued: $method $url');
    } catch (e) {
      logDebug('Failed to queue request', error: e);
    }
  }

  /// Get all queued requests
  List<Map<String, dynamic>> getQueuedRequests() {
    if (!_isInitialized || _queueBox == null) return [];

    try {
      return _queueBox!.values.map((value) {
        final request = jsonDecode(value as String) as Map<String, dynamic>;
        return {
          ...request,
          'body': request['body'] != null 
              ? jsonDecode(request['body'] as String) 
              : null,
        };
      }).toList();
    } catch (e) {
      logDebug('Failed to get queued requests', error: e);
      return [];
    }
  }

  /// Remove a request from the queue
  Future<void> removeQueuedRequest(String id) async {
    if (!_isInitialized || _queueBox == null) return;
    
    try {
      await _queueBox!.delete(id);
      logDebug('Request removed from queue: $id');
    } catch (e) {
      logDebug('Failed to remove queued request: $id', error: e);
    }
  }

  /// Clear all queued requests
  Future<void> clearQueue() async {
    if (!_isInitialized || _queueBox == null) return;
    
    try {
      await _queueBox!.clear();
      logDebug('Queue cleared');
    } catch (e) {
      logDebug('Failed to clear queue', error: e);
    }
  }

  /// Increment retry count for a queued request
  Future<void> incrementRetryCount(String id) async {
    if (!_isInitialized || _queueBox == null) return;
    
    try {
      final value = _queueBox!.get(id);
      if (value == null) return;
      
      final request = jsonDecode(value as String) as Map<String, dynamic>;
      request['retryCount'] = (request['retryCount'] as int) + 1;
      
      await _queueBox!.put(id, jsonEncode(request));
    } catch (e) {
      logDebug('Failed to increment retry count: $id', error: e);
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _queueBox?.close();
      await _cacheBox?.close();
      _isInitialized = false;
      logDebug('OfflineService disposed');
    } catch (e) {
      logDebug('Failed to dispose OfflineService', error: e);
    }
  }
}

