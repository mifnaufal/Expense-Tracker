import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Custom exceptions for better error handling
class BackendException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic originalError;

  const BackendException(
    this.message, {
    this.code,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'BackendException: $message${code != null ? ' (Code: $code)' : ''}${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class BackendUnavailableException extends BackendException {
  const BackendUnavailableException(String message, {dynamic originalError})
      : super(message, code: 'BACKEND_UNAVAILABLE', originalError: originalError);
}

class BackendTimeoutException extends BackendException {
  const BackendTimeoutException(String message, {dynamic originalError})
      : super(message, code: 'BACKEND_TIMEOUT', originalError: originalError);
}

class BackendResponseException extends BackendException {
  const BackendResponseException(String message, int statusCode, {dynamic originalError})
      : super(message, code: 'BACKEND_RESPONSE_ERROR', statusCode: statusCode, originalError: originalError);
}

/// Configuration for backend operations
class BackendConfig {
  final Duration healthCheckTimeout;
  final Duration operationTimeout;
  final Duration healthCacheDuration;
  final int maxRetries;
  final Duration retryDelay;
  final Map<String, String> defaultHeaders;
  final bool enableRetry;

  const BackendConfig({
    this.healthCheckTimeout = const Duration(milliseconds: 800),
    this.operationTimeout = const Duration(seconds: 5),
    this.healthCacheDuration = const Duration(seconds: 10),
    this.maxRetries = 3,
    this.retryDelay = const Duration(milliseconds: 500),
    this.defaultHeaders = const {'content-type': 'application/json'},
    this.enableRetry = true,
  });
}

/// Response wrapper for better type safety
class BackendResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;
  final Map<String, String>? headers;

  const BackendResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
    this.headers,
  });

  factory BackendResponse.success(T data, {int? statusCode, Map<String, String>? headers}) {
    return BackendResponse(
      success: true,
      data: data,
      statusCode: statusCode,
      headers: headers,
    );
  }

  factory BackendResponse.error(String error, {int? statusCode, Map<String, String>? headers}) {
    return BackendResponse(
      success: false,
      error: error,
      statusCode: statusCode,
      headers: headers,
    );
  }
}

/// Enhanced BackendClient with additional features
class BackendClient {
  static bool _disableDefaultClient = false;

  BackendClient._(this.baseUrl, {http.Client? client, BackendConfig? config})
      : _client = client ?? http.Client(),
        _config = config ?? const BackendConfig();

  factory BackendClient(String baseUrl, {http.Client? client, BackendConfig? config}) {
    return BackendClient._(baseUrl.trim(), client: client, config: config);
  }

  static BackendClient? tryCreate({http.Client? client, BackendConfig? config}) {
    if (_disableDefaultClient) {
      return null;
    }
    const envUrl = String.fromEnvironment('EXPENSE_BACKEND_URL', defaultValue: '');
    final trimmed = envUrl.trim();
    if (trimmed.isEmpty) {
      if (kReleaseMode) {
        return null;
      }
      return BackendClient(_defaultUrl, client: client, config: config);
    }
    return BackendClient(trimmed, client: client, config: config);
  }

  @visibleForTesting
  static void disableDefaultClientForTesting([bool disable = true]) {
    _disableDefaultClient = disable;
  }

  static const String _defaultUrl = 'http://localhost:1234';

  final String baseUrl;
  final http.Client _client;
  final BackendConfig _config;

  bool? _available;
  DateTime? _lastHealthCheck;
  String? _lastStoragePath;
  Timer? _healthCheckTimer;

  String get storagePath => _lastStoragePath ?? Uri.parse(baseUrl).toString();

  /// Initialize the client and start periodic health checks
  void initialize() {
    _startPeriodicHealthCheck();
  }

  /// Dispose resources
  void dispose() {
    _healthCheckTimer?.cancel();
    if (!kIsWeb) {
      _client.close();
    }
  }

  /// Start periodic health checks
  void _startPeriodicHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(
      _config.healthCacheDuration,
      (_) => isAvailable,
    );
  }

  /// Check if the backend is available with caching
  Future<bool> get isAvailable async {
    final now = DateTime.now();
    if (_lastHealthCheck != null && _available != null) {
      final age = now.difference(_lastHealthCheck!);
      if (age < _config.healthCacheDuration) {
        return _available!;
      }
    }

    return _awaitHealthCheck();
  }

  /// Perform a health check
  Future<bool> _awaitHealthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(_config.healthCheckTimeout);
      _available = response.statusCode == 200;
    } catch (e) {
      debugPrint('Backend health check failed: $e');
      _available = false;
    }
    _lastHealthCheck = DateTime.now();
    return _available ?? false;
  }

  /// Fetch transactions with retry logic
  Future<BackendResponse<String>> fetchTransactions({Map<String, String>? headers}) async {
    if (!await isAvailable) {
      throw const BackendUnavailableException('Backend is not available');
    }

    final uri = Uri.parse('$baseUrl/transactions');
    final requestHeaders = {..._config.defaultHeaders, ...?headers};

    return _executeWithRetry<String>(
      () async {
        final response = await _client.get(
          uri,
          headers: requestHeaders,
        ).timeout(_config.operationTimeout);

        if (response.statusCode == 200) {
          _lastStoragePath = uri.toString();
          return BackendResponse.success(response.body, statusCode: response.statusCode);
        } else {
          throw BackendResponseException(
            'Failed to fetch transactions',
            response.statusCode,
          );
        }
      },
      'fetchTransactions',
    );
  }

  /// Persist transactions with retry logic
  Future<BackendResponse<String>> persistTransactions(
    String payload, {
    Map<String, String>? headers,
  }) async {
    if (!await isAvailable) {
      throw const BackendUnavailableException('Backend is not available');
    }

    final uri = Uri.parse('$baseUrl/transactions');
    final requestHeaders = {
      ..._config.defaultHeaders,
      'content-type': 'text/plain; charset=utf-8',
      ...?headers,
    };

    return _executeWithRetry<String>(
      () async {
        final response = await _client.post(
          uri,
          headers: requestHeaders,
          body: payload,
        ).timeout(_config.operationTimeout);

        if (response.statusCode == 200) {
          try {
            final data = jsonDecode(response.body) as Map<String, dynamic>?;
            final path = (data?['path'] as String?) ?? uri.toString();
            _lastStoragePath = path;
            return BackendResponse.success(path, statusCode: response.statusCode);
          } catch (e) {
            // If parsing fails, just use the URI as the path
            _lastStoragePath = uri.toString();
            return BackendResponse.success(uri.toString(), statusCode: response.statusCode);
          }
        } else {
          throw BackendResponseException(
            'Failed to persist transactions',
            response.statusCode,
          );
        }
      },
      'persistTransactions',
    );
  }

  /// Generic method to execute operations with retry logic
  Future<BackendResponse<T>> _executeWithRetry<T>(
    Future<BackendResponse<T>> Function() operation,
    String operationName,
  ) async {
    if (!_config.enableRetry) {
      return await operation();
    }

    BackendException? lastException;

    for (int attempt = 0; attempt <= _config.maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        lastException = e is BackendException ? e : BackendException(e.toString());

        if (attempt < _config.maxRetries) {
          debugPrint('$operationName failed (attempt ${attempt + 1}/${_config.maxRetries + 1}): $e');
          await Future.delayed(_config.retryDelay * (attempt + 1));
        }
      }
    }

    throw lastException!;
  }

  /// Send a custom request to the backend
  Future<BackendResponse<String>> sendRequest(
    String endpoint,
    String method, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    if (!await isAvailable) {
      throw const BackendUnavailableException('Backend is not available');
    }

    final uri = Uri.parse('$baseUrl/$endpoint');
    final requestHeaders = {..._config.defaultHeaders, ...?headers};

    return _executeWithRetry<String>(
      () async {
        late http.Response response;

        switch (method.toUpperCase()) {
          case 'GET':
            response = await _client.get(uri, headers: requestHeaders).timeout(_config.operationTimeout);
            break;
          case 'POST':
            response = await _client.post(uri, headers: requestHeaders, body: body).timeout(_config.operationTimeout);
            break;
          case 'PUT':
            response = await _client.put(uri, headers: requestHeaders, body: body).timeout(_config.operationTimeout);
            break;
          case 'DELETE':
            response = await _client.delete(uri, headers: requestHeaders).timeout(_config.operationTimeout);
            break;
          default:
            throw BackendException('Unsupported HTTP method: $method');
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return BackendResponse.success(response.body, statusCode: response.statusCode);
        } else {
          throw BackendResponseException(
            'Request failed with status ${response.statusCode}',
            response.statusCode,
          );
        }
      },
      'sendRequest',
    );
  }

  /// Upload a file to the backend
  Future<BackendResponse<String>> uploadFile(
    String filePath,
    List<int> fileBytes, {
    Map<String, String>? headers,
  }) async {
    if (!await isAvailable) {
      throw const BackendUnavailableException('Backend is not available');
    }

    final uri = Uri.parse('$baseUrl/upload');
    final request = http.MultipartRequest('POST', uri);
    
    // Add headers
    request.headers.addAll({..._config.defaultHeaders, ...?headers});
    
    // Add file
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: filePath.split('/').last,
    ));

    return _executeWithRetry<String>(
      () async {
        final streamedResponse = await request.send().timeout(_config.operationTimeout);
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return BackendResponse.success(response.body, statusCode: response.statusCode);
        } else {
          throw BackendResponseException(
            'File upload failed with status ${response.statusCode}',
            response.statusCode,
          );
        }
      },
      'uploadFile',
    );
  }

  /// Get backend statistics
  Future<BackendResponse<Map<String, dynamic>>> getStats({Map<String, String>? headers}) async {
    if (!await isAvailable) {
      throw const BackendUnavailableException('Backend is not available');
    }

    final uri = Uri.parse('$baseUrl/stats');
    final requestHeaders = {..._config.defaultHeaders, ...?headers};

    return _executeWithRetry<Map<String, dynamic>>(
      () async {
        final response = await _client.get(
          uri,
          headers: requestHeaders,
        ).timeout(_config.operationTimeout);

        if (response.statusCode == 200) {
          try {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            return BackendResponse.success(data, statusCode: response.statusCode);
          } catch (e) {
            throw BackendException('Failed to parse stats response: $e');
          }
        } else {
          throw BackendResponseException(
            'Failed to get stats',
            response.statusCode,
          );
        }
      },
      'getStats',
    );
  }
}