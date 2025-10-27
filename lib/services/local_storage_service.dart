import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:expense_tracker/models/transaction_model.dart';

class LocalStorageService {
  static const String fileName = 'transactions.json';

  static Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  static Future<List<TransactionModel>> readTransactions() async {
    final file = await _getLocalFile();

    if (!await file.exists()) {
      final jsonString = await rootBundle.loadString('data/transactions.json');
      await file.writeAsString(jsonString);
      return TransactionModel.listFromJson(jsonString);
    }

    final contents = await file.readAsString();
    return TransactionModel.listFromJson(contents);
  }

  static Future<void> writeTransactions(List<TransactionModel> transactions) async {
    final file = await _getLocalFile();
    final jsonString = TransactionModel.listToJson(transactions);
    await file.writeAsString(jsonString);
  }
}
