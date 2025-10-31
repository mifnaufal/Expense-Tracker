// lib/services/local_storage_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'web_storage_stub.dart'
  if (dart.library.html) 'web_storage_web.dart';

import '../models/transaction_model.dart';

class LocalStorageService {
  LocalStorageService._internal();

  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() => _instance;

  static const String _transactionsAssetPath = 'data/transactions.json';
  static const String _transactionsFileName = 'transactions.json';
  static const String _storagePrefsKey = 'transactions_cache_v1';

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_transactionsFileName');

    if (!await file.exists()) {
      await file.create(recursive: true);
      final seedData = await rootBundle.loadString(_transactionsAssetPath);
      await file.writeAsString(seedData);
    }

    return file;
  }

  List<TransactionModel> _parseTransactions(String rawContent) {
    final List<dynamic> jsonList = json.decode(rawContent) as List<dynamic>;
    return jsonList
        .map((jsonItem) => TransactionModel.fromJson(jsonItem as Map<String, dynamic>))
        .toList();
  }

  Future<List<TransactionModel>> _readFromWebStorage() async {
    String? rawContent = await webStorageRead(_storagePrefsKey);

<<<<<<< HEAD
 
  Future<List<TransactionModel>> loadTransactions() async {
=======
    if (rawContent == null) {
      rawContent = await rootBundle.loadString(_transactionsAssetPath);
      await webStorageWrite(_storagePrefsKey, rawContent);
    }

    if (rawContent.trim().isEmpty) {
      return [];
    }

    return _parseTransactions(rawContent);
  }

  Future<void> _writeToWebStorage(String jsonString) async {
    await webStorageWrite(_storagePrefsKey, jsonString);
  }

  Future<List<TransactionModel>> readData() async {
>>>>>>> 87c6702623d3eba141274ba17434d417848531b3
    try {
      if (kIsWeb) {
        return await _readFromWebStorage();
      }

      final file = await _getLocalFile();
      final rawContent = await file.readAsString();
      if (rawContent.trim().isEmpty) {
        return [];
      }

      return _parseTransactions(rawContent);
    } catch (e) {
<<<<<<< HEAD
      // Tangani error jika file tidak ditemukan atau format JSON salah
      print('Error loading transactions from asset: $e');
      return []; // Kembalikan list kosong jika gagal
    }
  }

 
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
  
    
    // TODO: Implementasi penyimpanan ke device.
    // 1. Dapatkan path direktori dokumen aplikasi (pakai package 'path_provider')
    //    final directory = await getApplicationDocumentsDirectory();
    //    final path = '${directory.path}/transactions.json';
    // 2. Ubah List<TransactionModel> ke List<Map>
    //    final List<Map<String, dynamic>> jsonList = 
    //        transactions.map((tx) => tx.toJson()).toList();
    // 3. Encode ke string JSON
    //    final String jsonString = json.encode(jsonList);
    // 4. Tulis string ke file
    //    final file = File(path);
    //    await file.writeAsString(jsonString);

    print('Simulasi menyimpan data... (Implementasi penuh butuh path_provider)');
=======
      debugPrint('Error reading transactions: $e');
      return [];
    }
  }

  Future<void> writeData(List<TransactionModel> transactions) async {
    try {
      final jsonList = transactions.map((tx) => tx.toJson()).toList();
      final jsonString = json.encode(jsonList);

      if (kIsWeb) {
        await _writeToWebStorage(jsonString);
        return;
      }

      final file = await _getLocalFile();
      await file.writeAsString(jsonString);
      await _persistSeedAsset(jsonString);
    } catch (e) {
      debugPrint('Error writing transactions: $e');
      rethrow;
    }
  }

  Future<List<TransactionModel>> addTransaction(TransactionModel transaction) async {
    final transactions = await readData();
    final updatedTransactions = [...transactions, transaction];
    await writeData(updatedTransactions);
    return updatedTransactions;
  }

  Future<({String json, bool wroteSeedFile})> exportTransactions({
    bool pretty = true,
    bool writeSeedFile = false,
  }) async {
    final transactions = await readData();
    final jsonReady = transactions.map((tx) => tx.toJson()).toList();
    final encoder = pretty ? const JsonEncoder.withIndent('  ') : const JsonEncoder();
    final jsonString = encoder.convert(jsonReady);

    bool wroteFile = false;
    if (writeSeedFile && !kIsWeb) {
      final seedFile = File('data/transactions.json');
      try {
        if (await seedFile.exists()) {
          await seedFile.writeAsString(jsonString);
          wroteFile = true;
        } else {
          debugPrint('Seed file not found at ${seedFile.path}. Skipping write.');
        }
      } catch (e) {
        debugPrint('Unable to write seed file: $e');
      }
    }

    return (json: jsonString, wroteSeedFile: wroteFile);
  }

  Future<List<TransactionModel>> updateTransaction(TransactionModel updatedTransaction) async {
    final transactions = await readData();
    final index = transactions.indexWhere((tx) => tx.id == updatedTransaction.id);
    if (index == -1) {
      throw Exception('Transaction with id ${updatedTransaction.id} not found');
    }

    final List<TransactionModel> updatedTransactions = List.of(transactions);
    updatedTransactions[index] = updatedTransaction;
    await writeData(updatedTransactions);
    return updatedTransactions;
  }

  Future<List<TransactionModel>> deleteTransaction(String transactionId) async {
    final transactions = await readData();
    final updatedTransactions = transactions.where((tx) => tx.id != transactionId).toList();
    await writeData(updatedTransactions);
    return updatedTransactions;
  }

  Future<List<TransactionModel>> loadTransactions() {
    return readData();
  }

  Future<void> _persistSeedAsset(String jsonString) async {
    if (kIsWeb) return;

    final seedFile = File('data/transactions.json');
    try {
      if (await seedFile.exists()) {
        await seedFile.writeAsString(jsonString);
      } else {
        debugPrint('Seed data file not found at ${seedFile.path}.');
      }
    } catch (e) {
      debugPrint('Unable to sync seed data file: $e');
    }
>>>>>>> 87c6702623d3eba141274ba17434d417848531b3
  }
}