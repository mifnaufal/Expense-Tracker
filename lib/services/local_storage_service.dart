import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionResult {
  final List<TransactionModel> transactions;
  final String storagePath;
  final String? payload;

  TransactionResult({
    required this.transactions,
    required this.storagePath,
    this.payload,
  });
}

class LocalStorageService {
  static const String _fileName = 'transactions.json';

  // ======== READ DATA ========
  Future<List<TransactionModel>> readData() async {
    try {
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

      final String jsonString =
          json.encode(transactions.map((tx) => tx.toJson()).toList());

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
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      throw Exception('Failed to add transaction');
    }
  }

  // ======== UPDATE DATA ========
  Future<TransactionResult> updateTransaction(TransactionModel updatedTx) async {
    try {
      final transactions = await readData();
      final index = transactions.indexWhere((tx) => tx.id == updatedTx.id);

      if (index != -1) {
        transactions[index] = updatedTx;
      }

      final String jsonString =
          json.encode(transactions.map((tx) => tx.toJson()).toList());

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

      final String jsonString =
          json.encode(transactions.map((tx) => tx.toJson()).toList());

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
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      throw Exception('Failed to delete transaction');
    }
  }

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
  }

  // ======== PRIVATE HELPERS ========
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }
}
