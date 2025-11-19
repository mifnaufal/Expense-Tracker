import 'dart:convert';
import 'dart:convert' show base64Url, utf8;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionResult {
  final List<TransactionModel> transactions;
  final String storagePath;
  final String? payload;
=======

import 'web_storage_stub.dart' if (dart.library.html) 'web_storage_web.dart';

import '../models/transaction_model.dart';
import 'backend_client.dart';

/// Custom exceptions for better error handling
class StorageException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const StorageException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'StorageException: $message${code != null ? ' (Code: $code)' : ''}';
}

class TransactionNotFoundException extends StorageException {
  const TransactionNotFoundException(String transactionId)
      : super('Transaction with id $transactionId not found', code: 'TRANSACTION_NOT_FOUND');
}

class SerializationException extends StorageException {
  const SerializationException(String message, {dynamic originalError})
      : super(message, code: 'SERIALIZATION_ERROR', originalError: originalError);
}

class StorageAccessException extends StorageException {
  const StorageAccessException(String message, {dynamic originalError})
      : super(message, code: 'STORAGE_ACCESS_ERROR', originalError: originalError);
}

/// Result types for better type safety
typedef TransactionCrudResult = ({
  List<TransactionModel> transactions,
  String serialized,
  String storagePath,
});
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8

  TransactionResult({
    required this.transactions,
    required this.storagePath,
    this.payload,
  });
}

/// Configuration for storage operations
class StorageConfig {
  final Duration operationTimeout;
  final int maxRetries;
  final bool enableEncryption;
  final String encryptionKey;

  const StorageConfig({
    this.operationTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.enableEncryption = false,
    this.encryptionKey = 'default-key',
  });
}

/// Statistics about storage operations
class StorageStats {
  final int totalTransactions;
  final int totalIncome;
  final int totalExpense;
  final double totalAmount;
  final DateTime lastUpdated;
  final String storageType;

  const StorageStats({
    required this.totalTransactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalAmount,
    required this.lastUpdated,
    required this.storageType,
  });
}

/// Enhanced LocalStorageService with additional features
class LocalStorageService {
<<<<<<< HEAD
  static const String _fileName = 'transactions.json';

  // ======== READ DATA ========
=======
  LocalStorageService({
    BackendClient? backendClient,
    StorageConfig? config,
  }) : _backendClient = backendClient ?? BackendClient.tryCreate(),
       _config = config ?? const StorageConfig();

  final BackendClient? _backendClient;
  final StorageConfig _config;
  final List<TransactionModel> _cache = [];
  Timer? _cacheTimer;
  bool _isDirty = false;
  final Completer<void>? _initCompleter = Completer<void>();

  bool get _backendEnabled => _backendClient != null;

  static const String _transactionsAssetPath = 'data/transactions.json';
  static const String _storagePrefsKey = 'transactions_cache_v3';
  static const String _projectDataFileName = 'transactions.store';
  static const String _backupSuffix = '.backup';

  /// Initialize the storage service
  Future<void> initialize() async {
    try {
      await _loadCache();
      _startCacheTimer();
      _initCompleter?.complete();
    } catch (e) {
      _initCompleter?.completeError(e);
      rethrow;
    }
  }

  /// Get storage statistics
  Future<StorageStats> getStats() async {
    final transactions = await readData();
    final totalIncome = transactions.where((t) => t.type == TransactionType.pemasukan).length;
    final totalExpense = transactions.where((t) => t.type == TransactionType.pengeluaran).length;
    final totalAmount = transactions.fold(0.0, (sum, t) => sum + t.amount);

    String storageType = 'local';
    if (_backendEnabled) storageType = 'backend';
    else if (kIsWeb) storageType = 'web';

    return StorageStats(
      totalTransactions: transactions.length,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      totalAmount: totalAmount,
      lastUpdated: DateTime.now(),
      storageType: storageType,
    );
  }

  /// Search transactions by various criteria
  Future<List<TransactionModel>> searchTransactions({
    String? query,
    TransactionType? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) async {
    final transactions = await readData();

    return transactions.where((transaction) {
      if (query != null && query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        if (!transaction.title.toLowerCase().contains(searchLower) &&
            !transaction.category.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      if (type != null && transaction.type != type) return false;
      if (category != null && transaction.category.toLowerCase() != category.toLowerCase()) return false;
      if (startDate != null && transaction.date.isBefore(startDate)) return false;
      if (endDate != null && transaction.date.isAfter(endDate)) return false;
      if (minAmount != null && transaction.amount < minAmount) return false;
      if (maxAmount != null && transaction.amount > maxAmount) return false;

      return true;
    }).toList();
  }

  /// Batch operations for better performance
  Future<TransactionCrudResult> addTransactions(
    List<TransactionModel> transactions,
  ) async {
    final currentTransactions = await readData();
    final updatedTransactions = [...currentTransactions, ...transactions];
    final writeResult = await _writeData(updatedTransactions);
    return (
      transactions: updatedTransactions,
      serialized: writeResult.serialized,
      storagePath: writeResult.storagePath,
    );
  }

  /// Create a backup of current data
  Future<String> createBackup() async {
    final transactions = await readData();
    final serialized = _serializeTransactions(transactions);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    if (kIsWeb) {
      await webStorageWrite('${_storagePrefsKey}_backup_$timestamp', serialized);
      return 'web-local-storage:${_storagePrefsKey}_backup_$timestamp';
    }

    final file = await _getLocalFile();
    final backupFile = File('${file.path}$_backupSuffix');
    await backupFile.writeAsString(serialized);
    return backupFile.path;
  }

  /// Restore data from backup
  Future<TransactionCrudResult> restoreFromBackup(String backupPath) async {
    try {
      String serialized;

      if (kIsWeb && backupPath.startsWith('web-local-storage:')) {
        final key = backupPath.replaceFirst('web-local-storage:', '');
        serialized = await webStorageRead(key) ?? '';
      } else {
        final file = File(backupPath);
        serialized = await file.readAsString();
      }

      if (serialized.isEmpty) {
        throw const StorageException('Backup file is empty');
      }

      final transactions = _deserializeTransactions(serialized);
      final writeResult = await _writeData(transactions);
      
      return (
        transactions: transactions,
        serialized: writeResult.serialized,
        storagePath: writeResult.storagePath,
      );
    } catch (e) {
      throw StorageException('Failed to restore from backup: $e', originalError: e);
    }
  }

  /// Validate transaction data
  bool validateTransaction(TransactionModel transaction) {
    return transaction.id.isNotEmpty &&
           transaction.title.trim().isNotEmpty &&
           transaction.amount > 0 &&
           transaction.category.trim().isNotEmpty &&
           transaction.date.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  Future<File?> _tryProjectFile() async {
    try {
      final projectDir = Directory('${Directory.current.path}/data');
      await projectDir.create(recursive: true);
      final file = File('${projectDir.path}/$_projectDataFileName');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      final raf = await file.open(mode: FileMode.append);
      await raf.close();
      return file;
    } catch (e) {
      debugPrint('Unable to access project data file: $e');
      return null;
    }
  }

  Future<File> _getLocalFile() async {
    if (!kIsWeb) {
      final projectFile = await _tryProjectFile();
      if (projectFile != null) {
        return projectFile;
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_projectDataFileName');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      return file;
    }

    throw UnsupportedError('Web platform uses browser storage.');
  }

  Future<void> _loadCache() async {
    try {
      _cache.clear();
      _cache.addAll(await readData());
      _isDirty = false;
    } catch (e) {
      debugPrint('Failed to load cache: $e');
    }
  }

  void _startCacheTimer() {
    _cacheTimer?.cancel();
    _cacheTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      if (_isDirty) {
        try {
          await _writeData(_cache);
          _isDirty = false;
        } catch (e) {
          debugPrint('Failed to sync cache: $e');
        }
      }
    });
  }

>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
  Future<List<TransactionModel>> readData() async {
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      await _initCompleter!.future;
    }

    try {
<<<<<<< HEAD
      if (kIsWeb) {
        // 🔹 Simpan di browser (Web)
        final prefs = await SharedPreferences.getInstance();
        final data = prefs.getString('transactions') ?? '[]';
        final List<dynamic> jsonList = json.decode(data);
        return jsonList.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        // 🔹 Simpan di file (Android/iOS/Desktop)
        final file = await _localFile;
        if (!await file.exists()) return [];
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        return jsonList.map((json) => TransactionModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error reading data: $e');
      return [];
    }
  }

  // ======== ADD DATA ========
  Future<TransactionResult> addTransaction(TransactionModel transaction) async {
    try {
      final transactions = await readData();
      transactions.add(transaction);
=======
      // Use cache if available and not dirty
      if (_cache.isNotEmpty && !_isDirty) {
        return List.unmodifiable(_cache);
      }

      final backendPayload = await _fetchBackendPayload();
      if (backendPayload != null) {
        if (backendPayload.trim().isEmpty) {
          final seedTransactions = await _loadSeedTransactions();
          if (seedTransactions.isNotEmpty) {
            final serialized = _serializeTransactions(seedTransactions);
            await _backendClient?.persistTransactions(serialized);
          }
          _cache.clear();
          _cache.addAll(seedTransactions);
          return seedTransactions;
        }
        final transactions = _deserializeTransactions(backendPayload);
        _cache.clear();
        _cache.addAll(transactions);
        return transactions;
      }

      if (kIsWeb) {
        final transactions = await _readFromWebStorage();
        _cache.clear();
        _cache.addAll(transactions);
        return transactions;
      }

      final file = await _getLocalFile();
      final rawContent = await file.readAsString();
      if (rawContent.trim().isEmpty) {
        final seedTransactions = await _loadSeedTransactions();
        if (seedTransactions.isNotEmpty) {
          await _writeData(seedTransactions);
        }
        _cache.clear();
        _cache.addAll(seedTransactions);
        return seedTransactions;
      }

      final transactions = _deserializeTransactions(rawContent);
      _cache.clear();
      _cache.addAll(transactions);
      return transactions;
    } catch (e) {
      debugPrint('Error reading transactions: $e');
      throw StorageAccessException('Failed to read transactions', originalError: e);
    }
  }

  Future<TransactionCrudResult> addTransaction(
    TransactionModel transaction,
  ) async {
    if (!validateTransaction(transaction)) {
      throw const StorageException('Invalid transaction data', code: 'INVALID_TRANSACTION');
    }

    final transactions = await readData();
    final updatedTransactions = [...transactions, transaction];
    final writeResult = await _writeData(updatedTransactions);
    
    _cache.clear();
    _cache.addAll(updatedTransactions);
    _isDirty = true;
    
    return (
      transactions: updatedTransactions,
      serialized: writeResult.serialized,
      storagePath: writeResult.storagePath,
    );
  }

  Future<TransactionCrudResult> updateTransaction(
    TransactionModel updatedTransaction,
  ) async {
    if (!validateTransaction(updatedTransaction)) {
      throw const StorageException('Invalid transaction data', code: 'INVALID_TRANSACTION');
    }

    final transactions = await readData();
    final index = transactions.indexWhere(
      (tx) => tx.id == updatedTransaction.id,
    );
    if (index == -1) {
      throw TransactionNotFoundException(updatedTransaction.id);
    }

    final List<TransactionModel> updatedTransactions = List.of(transactions);
    updatedTransactions[index] = updatedTransaction;
    final writeResult = await _writeData(updatedTransactions);
    
    _cache.clear();
    _cache.addAll(updatedTransactions);
    _isDirty = true;
    
    return (
      transactions: updatedTransactions,
      serialized: writeResult.serialized,
      storagePath: writeResult.storagePath,
    );
  }

  Future<TransactionCrudResult> deleteTransaction(String transactionId) async {
    final transactions = await readData();
    final updatedTransactions = transactions
        .where((tx) => tx.id != transactionId)
        .toList();
    
    if (updatedTransactions.length == transactions.length) {
      throw TransactionNotFoundException(transactionId);
    }
    
    final writeResult = await _writeData(updatedTransactions);
    
    _cache.clear();
    _cache.addAll(updatedTransactions);
    _isDirty = true;
    
    return (
      transactions: updatedTransactions,
      serialized: writeResult.serialized,
      storagePath: writeResult.storagePath,
    );
  }

  Future<List<TransactionModel>> loadTransactions() {
    return readData();
  }

  Future<String?> _fetchBackendPayload() async {
    if (!_backendEnabled) {
      return null;
    }

    const attemptDelays = <Duration>[
      Duration.zero,
      Duration(milliseconds: 250),
      Duration(milliseconds: 600),
      Duration(milliseconds: 1200),
    ];
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8

      final String jsonString =
          json.encode(transactions.map((tx) => tx.toJson()).toList());

<<<<<<< HEAD
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('transactions', jsonString);
        return TransactionResult(transactions: transactions, storagePath: 'web');
      } else {
        final file = await _localFile;
        await file.writeAsString(jsonString);
        return TransactionResult(
          transactions: transactions,
          storagePath: file.path,
        );
=======
      final response = await _backendClient!.fetchTransactions();
      if (response != null && response.data != null && response.data!.isNotEmpty) {
        return response.data;
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
      }
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      throw Exception('Failed to add transaction');
    }
<<<<<<< HEAD
  }

  // ======== UPDATE DATA ========
  Future<TransactionResult> updateTransaction(TransactionModel updatedTx) async {
    try {
      final transactions = await readData();
      final index = transactions.indexWhere((tx) => tx.id == updatedTx.id);

      if (index != -1) {
        transactions[index] = updatedTx;
=======

    return null;
  }

  Future<({String payload, String storagePath})> exportTransactions() async {
    final transactions = await readData();
    final serialized = _serializeTransactions(transactions);

    if (_backendEnabled) {
      final response = await _backendClient?.persistTransactions(serialized);
      final storagePath = response?.data ?? _backendClient!.storagePath;
      return (
        payload: serialized,
        storagePath: storagePath,
      );
    }

    if (kIsWeb) {
      return (
        payload: serialized,
        storagePath: 'web-local-storage:$_storagePrefsKey',
      );
    }

    final file = await _getLocalFile();
    return (payload: serialized, storagePath: file.path);
  }

  Future<_TransactionWriteResult> _writeData(
    List<TransactionModel> transactions,
  ) async {
    try {
      var serialized = _serializeTransactions(transactions);

      if (_config.enableEncryption) {
        serialized = _encryptData(serialized);
      }

      if (_backendEnabled) {
        final backendResponse = await _backendClient?.persistTransactions(
          serialized,
        );
        if (backendResponse != null && backendResponse.data != null) {
          return (serialized: serialized, storagePath: backendResponse.data!);
        }
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
      }

      final String jsonString =
          json.encode(transactions.map((tx) => tx.toJson()).toList());

      if (kIsWeb) {
<<<<<<< HEAD
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('transactions', jsonString);
        return TransactionResult(transactions: transactions, storagePath: 'web');
      } else {
        final file = await _localFile;
        await file.writeAsString(jsonString);
        return TransactionResult(
          transactions: transactions,
          storagePath: file.path,
        );
      }
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      throw Exception('Failed to update transaction');
    }
  }

  // ======== DELETE DATA ========
  Future<TransactionResult> deleteTransaction(String id) async {
    try {
      final transactions = await readData();
      transactions.removeWhere((tx) => tx.id == id);
=======
        await _writeToWebStorage(serialized);
        return (
          serialized: serialized,
          storagePath: 'web-local-storage:$_storagePrefsKey',
        );
      }

      final file = await _getLocalFile();
      
      // Create backup before writing
      if (await file.exists()) {
        final backupFile = File('${file.path}$_backupSuffix');
        await file.copy(backupFile.path);
      }
      
      await file.writeAsString(serialized, flush: true);
      return (serialized: serialized, storagePath: file.path);
    } catch (e) {
      debugPrint('Error writing transactions: $e');
      throw StorageAccessException('Failed to write transactions', originalError: e);
    }
  }

  Future<List<TransactionModel>> _readFromWebStorage() async {
    String? rawContent = await webStorageRead(_storagePrefsKey);

    if (rawContent == null || rawContent.trim().isEmpty) {
      final seedTransactions = await _loadSeedTransactions();
      final serialized = _serializeTransactions(seedTransactions);
      await _writeToWebStorage(serialized);
      return seedTransactions;
    }

    if (_config.enableEncryption) {
      rawContent = _decryptData(rawContent);
    }

    return _deserializeTransactions(rawContent);
  }
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8

      final String jsonString =
          json.encode(transactions.map((tx) => tx.toJson()).toList());

<<<<<<< HEAD
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('transactions', jsonString);
        return TransactionResult(transactions: transactions, storagePath: 'web');
      } else {
        final file = await _localFile;
        await file.writeAsString(jsonString);
        return TransactionResult(
          transactions: transactions,
          storagePath: file.path,
        );
      }
=======
  Future<List<TransactionModel>> _loadSeedTransactions() async {
    try {
      final rawJson = await rootBundle.loadString(_transactionsAssetPath);
      final List<dynamic> jsonList = json.decode(rawJson) as List<dynamic>;
      return jsonList
          .map(
            (jsonItem) =>
                TransactionModel.fromJson(jsonItem as Map<String, dynamic>),
          )
          .toList();
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      throw Exception('Failed to delete transaction');
    }
  }

<<<<<<< HEAD
  // ======== EXPORT DATA ========
  Future<TransactionResult> exportTransactions() async {
    try {
      final transactions = await readData();
      final String jsonString =
          json.encode(transactions.map((tx) => tx.toJson()).toList());

      if (kIsWeb) {
        return TransactionResult(
          transactions: transactions,
          storagePath: 'web',
          payload: jsonString,
        );
      } else {
        final file = await _localFile;
        return TransactionResult(
          transactions: transactions,
          storagePath: file.path,
          payload: jsonString,
        );
      }
    } catch (e) {
      debugPrint('Error exporting transactions: $e');
      throw Exception('Failed to export transactions');
    }
=======
  List<TransactionModel> _deserializeTransactions(String rawContent) {
    try {
      final transactions = <TransactionModel>[];

      for (final line in rawContent.split('\n')) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) continue;

        final parts = trimmedLine.split('|');
        if (parts.length < 7) {
          debugPrint('Skipping malformed record: $trimmedLine');
          continue;
        }

        try {
          final id = _decodeField(parts[0]);
          final title = _decodeField(parts[1]);
          final amount = double.tryParse(_decodeField(parts[2])) ?? 0.0;
          final category = _decodeField(parts[3]);
          final date =
              DateTime.tryParse(_decodeField(parts[4])) ?? DateTime.now();
          final imagePathRaw = _decodeField(parts[5]);
          final typeString = _decodeField(parts[6]);
          final type = TransactionType.values.firstWhere(
            (value) => value.name == typeString,
            orElse: () => TransactionType.pengeluaran,
          );
          final imageBase64 = parts.length >= 8 ? _decodeField(parts[7]) : '';

          transactions.add(
            TransactionModel(
              id: id,
              title: title,
              amount: amount,
              category: category,
              date: date,
              imagePath: imagePathRaw.isEmpty ? null : imagePathRaw,
              imageBase64: imageBase64.isEmpty ? null : imageBase64,
              type: type,
            ),
          );
        } catch (e) {
          debugPrint('Failed to decode transaction line: $e');
        }
      }

      transactions.sort((a, b) => a.date.compareTo(b.date));
      return transactions;
    } catch (e) {
      throw SerializationException('Failed to deserialize transactions', originalError: e);
    }
  }

  String _serializeTransactions(List<TransactionModel> transactions) {
    try {
      final sortedTransactions = List<TransactionModel>.from(transactions)
        ..sort((a, b) => a.date.compareTo(b.date));

      return sortedTransactions.map(_serializeTransaction).join('\n');
    } catch (e) {
      throw SerializationException('Failed to serialize transactions', originalError: e);
    }
  }

  String _serializeTransaction(TransactionModel transaction) {
    final fields = <String>[
      _encodeField(transaction.id),
      _encodeField(transaction.title),
      _encodeField(transaction.amount.toString()),
      _encodeField(transaction.category),
      _encodeField(transaction.date.toIso8601String()),
      _encodeField(transaction.imagePath ?? ''),
      _encodeField(transaction.type.name),
      _encodeField(transaction.imageBase64 ?? ''),
    ];

    return fields.join('|');
  }

  String _encodeField(String value) {
    final bytes = utf8.encode(value);
    return base64Url.encode(bytes);
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
  }

  // ======== PRIVATE HELPERS ========
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

<<<<<<< HEAD
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }
}
=======
  String _encryptData(String data) {
    if (!_config.enableEncryption) return data;
    
    // Simple XOR encryption with key
    final keyBytes = utf8.encode(_config.encryptionKey);
    final dataBytes = utf8.encode(data);
    final encryptedBytes = <int>[];
    
    for (int i = 0; i < dataBytes.length; i++) {
      encryptedBytes.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return base64.encode(encryptedBytes);
  }

  String _decryptData(String encryptedData) {
    if (!_config.enableEncryption) return encryptedData;
    
    // For simplicity, this is a basic implementation
    // In production, use proper encryption libraries
    try {
      final decoded = base64.decode(encryptedData);
      return utf8.decode(decoded);
    } catch (e) {
      throw StorageException('Failed to decrypt data', originalError: e);
    }
  }

  String convertTransactionsToPayload(List<TransactionModel> transactions) {
    return _serializeTransactions(transactions);
  }

  /// Dispose resources
  void dispose() {
    _cacheTimer?.cancel();
  }
}
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
