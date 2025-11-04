import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BackendClient {
  BackendClient._(this.baseUrl, {http.Client? client})
      : _client = client ?? http.Client();

  factory BackendClient(String baseUrl, {http.Client? client}) {
    return BackendClient._(baseUrl.trim(), client: client);
  }

  static BackendClient? tryCreate({http.Client? client}) {
    // Only enable the backend client when the environment explicitly sets
    // EXPENSE_BACKEND_URL. This prevents tests and local runs from
    // automatically creating an HttpClient and running timers when the
    // backend is not desired or available.
    const envUrl = String.fromEnvironment('EXPENSE_BACKEND_URL', defaultValue: '');
    final trimmed = envUrl.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return BackendClient(trimmed, client: client);
  }

  // Note: backend URL must be provided via EXPENSE_BACKEND_URL environment
  // variable to enable backend features. No default URL is used to avoid
  // creating network timers/clients during tests.

  final String baseUrl;
  final http.Client _client;

  bool? _available;
  DateTime? _lastHealthCheck;
  static const Duration _healthCacheDuration = Duration(seconds: 2);
  String? _lastStoragePath;

  String get storagePath => _lastStoragePath ?? Uri.parse(baseUrl).toString();

  Future<bool> get isAvailable async {
    final now = DateTime.now();
    if (_lastHealthCheck != null && _available != null) {
      final age = now.difference(_lastHealthCheck!);
      if (age < _healthCacheDuration) {
        return _available!;
      }
    }

    return _awaitHealthCheck();
  }

  Future<bool> _awaitHealthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(milliseconds: 800));
      _available = response.statusCode == 200;
    } catch (e) {
      debugPrint('Backend health check failed: $e');
      _available = false;
    }
    _lastHealthCheck = DateTime.now();
    return _available ?? false;
  }

  Future<String?> fetchTransactions() async {
    if (!await isAvailable) {
      return null;
    }

    final uri = Uri.parse('$baseUrl/transactions');
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        _lastStoragePath = uri.toString();
        return response.body;
      }
    } catch (e) {
      debugPrint('Backend fetch failed: $e');
      _available = null;
    }

    return null;
  }

  Future<String?> persistTransactions(String payload) async {
    if (!await isAvailable) {
      return null;
    }

    final uri = Uri.parse('$baseUrl/transactions');
    try {
      final response = await _client
          .post(
            uri,
            headers: {'content-type': 'text/plain; charset=utf-8'},
            body: payload,
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>?;
        final path = (data?['path'] as String?) ?? uri.toString();
        _lastStoragePath = path;
        return path;
      }
    } catch (e) {
      debugPrint('Backend write failed: $e');
      _available = null;
    }

    return null;
  }

  void dispose() {
    if (!kIsWeb) {
      _client.close();
    }
  }
}
