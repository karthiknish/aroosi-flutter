import 'package:dio/dio.dart';
import 'package:aroosi_flutter/core/offline_service.dart';
import 'package:aroosi_flutter/core/api_client.dart';
import 'package:aroosi_flutter/utils/debug_logger.dart';
import 'package:uuid/uuid.dart';

/// Interceptor that queues failed requests when offline and retries them when online
class OfflineQueueInterceptor extends Interceptor {
  final OfflineService _offlineService = OfflineService();
  final _uuid = const Uuid();
  static const int _maxRetries = 3;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only queue requests that failed due to network issues
    if (_isNetworkError(err)) {
      final isOnline = await _offlineService.isOnline();
      
      if (!isOnline) {
        // Queue the request for retry when online
        await _queueRequest(err);
        handler.next(err);
        return;
      }
    }
    
    handler.next(err);
  }

  bool _isNetworkError(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.type == DioExceptionType.unknown && 
         err.error?.toString().toLowerCase().contains('network') == true);
  }

  Future<void> _queueRequest(DioException err) async {
    try {
      final requestOptions = err.requestOptions;
      final requestId = _uuid.v4();
      
      await _offlineService.queueRequest(
        id: requestId,
        method: requestOptions.method,
        url: requestOptions.uri.toString(),
        headers: requestOptions.headers,
        body: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
      );
      
      logDebug('Request queued for retry: ${requestOptions.method} ${requestOptions.uri}');
    } catch (e) {
      logDebug('Failed to queue request', error: e);
    }
  }

  /// Process queued requests when connection is restored
  Future<void> processQueue() async {
    final isOnline = await _offlineService.isOnline();
    if (!isOnline) {
      logDebug('Still offline, skipping queue processing');
      return;
    }

    final queuedRequests = _offlineService.getQueuedRequests();
    if (queuedRequests.isEmpty) {
      logDebug('No queued requests to process');
      return;
    }

    logDebug('Processing ${queuedRequests.length} queued requests');

    for (final request in queuedRequests) {
      final requestId = request['id'] as String;
      final retryCount = request['retryCount'] as int;
      
      // Skip requests that have exceeded max retries
      if (retryCount >= _maxRetries) {
        logDebug('Request exceeded max retries, removing: $requestId');
        await _offlineService.removeQueuedRequest(requestId);
        continue;
      }

      try {
        await _retryRequest(request);
        await _offlineService.removeQueuedRequest(requestId);
        logDebug('Queued request processed successfully: $requestId');
      } catch (e) {
        await _offlineService.incrementRetryCount(requestId);
        logDebug('Failed to process queued request: $requestId', error: e);
      }
    }
  }

  Future<void> _retryRequest(Map<String, dynamic> request) async {
    final dio = ApiClient.dio;
    final method = request['method'] as String;
    final url = request['url'] as String;
    final headers = request['headers'] as Map<String, dynamic>;
    final body = request['body'];
    final queryParameters = request['queryParameters'] as Map<String, dynamic>;

    final options = Options(
      method: method,
      headers: headers,
    );

    switch (method.toUpperCase()) {
      case 'GET':
        await dio.get(url, options: options, queryParameters: queryParameters);
        break;
      case 'POST':
        await dio.post(url, data: body, options: options, queryParameters: queryParameters);
        break;
      case 'PUT':
        await dio.put(url, data: body, options: options, queryParameters: queryParameters);
        break;
      case 'PATCH':
        await dio.patch(url, data: body, options: options, queryParameters: queryParameters);
        break;
      case 'DELETE':
        await dio.delete(url, options: options, queryParameters: queryParameters);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }
}

