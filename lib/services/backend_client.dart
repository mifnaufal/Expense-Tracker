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
    const envUrl = String.fromEnvironment('EXPENSE_BACKEND_URL', defaultValue: '');
    final resolved = envUrl.trim().isNotEmpty ? envUrl.trim() : _defaultUrl;
    if (resolved.isEmpty) {
      return null;
    }
    return BackendClient(resolved, client: client);
  }

  static const String _defaultUrl = 'http://localhost:1234';

  final String baseUrl;
  final http.Client _client;

  bool? _available;
  String? _lastStoragePath;

  String get storagePath => _lastStoragePath ?? Uri.parse(baseUrl).toString();

  Future<bool> get isAvailable async {
    if (_available != null) {
      return _available!;
    }

    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(milliseconds: 800));
      _available = response.statusCode == 200;
    } catch (e) {
      debugPrint('Backend health check failed: $e');
      _available = false;
    }

    return _available!;
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
    }

    return null;
  }

  void dispose() {
    if (!kIsWeb) {
      _client.close();
    }
  }
}
