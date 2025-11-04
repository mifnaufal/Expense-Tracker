import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'web_storage_stub.dart' if (dart.library.html) 'web_storage_web.dart';

import '../models/transaction_model.dart';
import 'backend_client.dart';

typedef TransactionCrudResult = ({
  List<TransactionModel> transactions,
  String serialized,
  String storagePath,
});

typedef _TransactionWriteResult = ({String serialized, String storagePath});

class LocalStorageService {
  LocalStorageService({BackendClient? backendClient})
    : _backendClient = backendClient ?? BackendClient.tryCreate();

  final BackendClient? _backendClient;

  bool get _backendEnabled => _backendClient != null;

  static const String _transactionsAssetPath = 'data/transactions.json';
  static const String _storagePrefsKey = 'transactions_cache_v2';
  static const String _projectDataFileName = 'transactions.store';

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

  Future<List<TransactionModel>> readData() async {
    try {
  final backendPayload = await _fetchBackendPayload();
      if (backendPayload != null) {
        if (backendPayload.trim().isEmpty) {
          final seedTransactions = await _loadSeedTransactions();
          if (seedTransactions.isNotEmpty) {
            final serialized = _serializeTransactions(seedTransactions);
            await _backendClient?.persistTransactions(serialized);
          }
          return seedTransactions;
        }
        return _deserializeTransactions(backendPayload);
      }

      if (kIsWeb) {
        return await _readFromWebStorage();
      }

      final file = await _getLocalFile();
      final rawContent = await file.readAsString();
      if (rawContent.trim().isEmpty) {
        final seedTransactions = await _loadSeedTransactions();
        if (seedTransactions.isNotEmpty) {
          await _writeData(seedTransactions);
        }
        return seedTransactions;
      }

      return _deserializeTransactions(rawContent);
    } catch (e) {
      debugPrint('Error reading transactions: $e');
      return [];
    }
  }

  Future<TransactionCrudResult> addTransaction(
    TransactionModel transaction,
  ) async {
    final transactions = await readData();
    final updatedTransactions = [...transactions, transaction];
    final writeResult = await _writeData(updatedTransactions);
    return (
      transactions: updatedTransactions,
      serialized: writeResult.serialized,
      storagePath: writeResult.storagePath,
    );
  }

  Future<TransactionCrudResult> updateTransaction(
    TransactionModel updatedTransaction,
  ) async {
    final transactions = await readData();
    final index = transactions.indexWhere(
      (tx) => tx.id == updatedTransaction.id,
    );
    if (index == -1) {
      throw Exception('Transaction with id ${updatedTransaction.id} not found');
    }

    final List<TransactionModel> updatedTransactions = List.of(transactions);
    updatedTransactions[index] = updatedTransaction;
    final writeResult = await _writeData(updatedTransactions);
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
    final writeResult = await _writeData(updatedTransactions);
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

    for (final delay in attemptDelays) {
      if (delay > Duration.zero) {
        await Future.delayed(delay);
      }

      final payload = await _backendClient!.fetchTransactions();
      if (payload != null) {
        return payload;
      }
    }

    return null;
  }

  Future<({String payload, String storagePath})> exportTransactions() async {
    final transactions = await readData();
    final serialized = _serializeTransactions(transactions);

    if (_backendEnabled) {
      final path = await _backendClient?.persistTransactions(serialized);
      return (
        payload: serialized,
        storagePath: path ?? _backendClient!.storagePath,
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
      final serialized = _serializeTransactions(transactions);

      if (_backendEnabled) {
        final backendPath = await _backendClient?.persistTransactions(
          serialized,
        );
        if (backendPath != null) {
          return (serialized: serialized, storagePath: backendPath);
        }
      }

      if (kIsWeb) {
        await _writeToWebStorage(serialized);
        return (
          serialized: serialized,
          storagePath: 'web-local-storage:$_storagePrefsKey',
        );
      }

      final file = await _getLocalFile();
      await file.writeAsString(serialized, flush: true);
      return (serialized: serialized, storagePath: file.path);
    } catch (e) {
      debugPrint('Error writing transactions: $e');
      rethrow;
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

    return _deserializeTransactions(rawContent);
  }

  Future<void> _writeToWebStorage(String serialized) async {
    await webStorageWrite(_storagePrefsKey, serialized);
  }

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
    } catch (e) {
      debugPrint('Failed to load seed transactions: $e');
      return [];
    }
  }

  List<TransactionModel> _deserializeTransactions(String rawContent) {
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
  }

  String _serializeTransactions(List<TransactionModel> transactions) {
    final sortedTransactions = List<TransactionModel>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    return sortedTransactions.map(_serializeTransaction).join('\n');
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
  }

  String _decodeField(String encoded) {
    final bytes = base64Url.decode(encoded);
    return utf8.decode(bytes);
  }

  String convertTransactionsToPayload(List<TransactionModel> transactions) {
    return _serializeTransactions(transactions);
  }
}
