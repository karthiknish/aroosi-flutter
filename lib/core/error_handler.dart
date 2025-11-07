import 'package:flutter/foundation.dart';
import 'package:aroosi_flutter/utils/debug_logger.dart';

/// Standardized error handling for the Aroosi app
/// 
/// This module provides a unified approach to error handling across the entire application.
/// It includes:
/// - [AppError] class for standardized error representation
/// - [AppResult] type for operations that can fail
/// - [ErrorHandler] singleton for centralized error processing
/// - Extension methods for easier Future and Stream error handling
/// 
/// Usage examples:
/// ```dart
/// // Create custom errors
/// final error = AppError.network(message: 'Connection failed');
/// 
/// // Handle operations that can fail
/// final result = await riskyOperation().toAppResult('context');
/// result.fold(
///   onSuccess: (data) => print('Success: $data'),
///   onError: (error) => print('Error: ${error.message}'),
/// );
/// 
/// // Handle exceptions directly
/// try {
///   await riskyOperation();
/// } catch (e, stackTrace) {
///   final error = ErrorHandler().handleException(e, context: 'operation', stackTrace: stackTrace);
/// }
/// ```
class AppError {
  final String code;
  final String message;
  final String? details;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final StackTrace? stackTrace;

  const AppError({
    required this.code,
    required this.message,
    this.details,
    this.severity = ErrorSeverity.medium,
    required this.timestamp,
    this.stackTrace,
  });

  factory AppError.network({
    required String message,
    String? details,
    StackTrace? stackTrace,
  }) {
    return AppError(
      code: 'NETWORK_ERROR',
      message: message,
      details: details,
      severity: ErrorSeverity.high,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
    );
  }

  factory AppError.validation({
    required String message,
    String? details,
  }) {
    return AppError(
      code: 'VALIDATION_ERROR',
      message: message,
      details: details,
      severity: ErrorSeverity.low,
      timestamp: DateTime.now(),
    );
  }

  factory AppError.authentication({
    required String message,
    String? details,
  }) {
    return AppError(
      code: 'AUTH_ERROR',
      message: message,
      details: details,
      severity: ErrorSeverity.high,
      timestamp: DateTime.now(),
    );
  }

  factory AppError.general({
    required String message,
    String? details,
    ErrorSeverity severity = ErrorSeverity.medium,
    StackTrace? stackTrace,
  }) {
    return AppError(
      code: 'GENERAL_ERROR',
      message: message,
      details: details,
      severity: severity,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() {
    return 'AppError(code: $code, message: $message, severity: $severity)';
  }
}

enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Result type for operations that can fail
class AppResult<T> {
  final T? data;
  final AppError? error;
  final bool isSuccess;

  const AppResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory AppResult.success(T data) {
    return AppResult._(data: data, isSuccess: true);
  }

  factory AppResult.failure(AppError error) {
    return AppResult._(error: error, isSuccess: false);
  }

  /// Map success data to a new type
  AppResult<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return AppResult.success(mapper(data as T));
      } catch (e, stackTrace) {
        return AppResult.failure(
          AppError.general(
            message: 'Mapping failed: ${e.toString()}',
            stackTrace: stackTrace,
          ),
        );
      }
    }
    return AppResult.failure(error!);
  }

  /// Chain operations
  AppResult<R> flatMap<R>(AppResult<R> Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return mapper(data as T);
      } catch (e, stackTrace) {
        return AppResult.failure(
          AppError.general(
            message: 'Chaining failed: ${e.toString()}',
            stackTrace: stackTrace,
          ),
        );
      }
    }
    return AppResult.failure(error!);
  }

  /// Handle both success and error cases
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onError,
  }) {
    if (isSuccess && data != null) {
      return onSuccess(data as T);
    }
    return onError(error!);
  }
}

/// Centralized error handler
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Handle and log errors consistently
  void handleError(AppError error) {
    _logError(error);
    _reportError(error);
  }

  /// Handle exceptions and convert to AppError
  AppError handleException(
    dynamic exception, {
    String? context,
    StackTrace? stackTrace,
  }) {
    final error = _convertToAppError(exception, context: context, stackTrace: stackTrace);
    handleError(error);
    return error;
  }

  /// Create standardized network error
  AppError createNetworkError(String message, {String? details}) {
    return AppError.network(message: message, details: details);
  }

  /// Create standardized validation error
  AppError createValidationError(String message, {String? details}) {
    return AppError.validation(message: message, details: details);
  }

  /// Create standardized authentication error
  AppError createAuthError(String message, {String? details}) {
    return AppError.authentication(message: message, details: details);
  }

  void _logError(AppError error) {
    final severity = error.severity.name.toUpperCase();
    logDebug(
      '[$severity] ${error.code}: ${error.message}',
      data: {
        'details': error.details,
        'timestamp': error.timestamp.toIso8601String(),
      },
      error: error.stackTrace,
    );
  }

  void _reportError(AppError error) {
    // In production, you might want to send errors to a service like Crashlytics
    if (kReleaseMode && error.severity.index >= ErrorSeverity.high.index) {
      // TODO: Integrate with crash reporting service
      logDebug('Critical error would be reported to crash service', data: {
        'error': error.toString(),
      });
    }
  }

  AppError _convertToAppError(
    dynamic exception, {
    String? context,
    StackTrace? stackTrace,
  }) {
    if (exception is AppError) {
      return exception;
    }

    final message = exception.toString();
    
    // Network related errors
    if (message.contains('SocketException') || 
        message.contains('Connection') ||
        message.contains('Timeout')) {
      return AppError.network(
        message: 'Network connection failed',
        details: context != null ? '$context: $message' : message,
        stackTrace: stackTrace,
      );
    }

    // Authentication related errors
    if (message.contains('authentication') ||
        message.contains('unauthorized') ||
        message.contains('token')) {
      return AppError.authentication(
        message: 'Authentication failed',
        details: context != null ? '$context: $message' : message,
      );
    }

    // Default to general error
    return AppError.general(
      message: 'An unexpected error occurred',
      details: context != null ? '$context: $message' : message,
    );
  }
}

/// Extension for easier error handling on Futures
extension ErrorHandling on Future {
  /// Convert Future to AppResult with automatic error handling
  Future<AppResult<T>> toAppResult<T>([String? context]) async {
    try {
      final result = await this;
      return AppResult.success(result as T);
    } catch (e, stackTrace) {
      final error = ErrorHandler().handleException(
        e,
        context: context,
        stackTrace: stackTrace,
      );
      return AppResult.failure(error);
    }
  }
}

/// Extension for easier error handling on Stream
extension StreamErrorHandling on Stream {
  /// Convert Stream events to AppResult
  Stream<AppResult<T>> toAppResultStream<T>([String? context]) {
    return map((event) => AppResult.success(event as T)).handleError((error, stackTrace) {
      final appError = ErrorHandler().handleException(
        error,
        context: context,
        stackTrace: stackTrace,
      );
      return AppResult.failure(appError);
    });
  }
}
