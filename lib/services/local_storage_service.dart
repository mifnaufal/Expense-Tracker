import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:expense_tracker/models/transaction_model.dart';

class LocalStorageService {
  static const String fileName = 'transactions.json';

  // Mendapatkan path file lokal
  static Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  // Membaca data dari JSON
  static Future<List<TransactionModel>> readTransactions() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        // Jika file belum ada, buat dengan isi awal
        await file.writeAsString('[]');
        return [];
      }

      final contents = await file.readAsString();
      return TransactionModel.listFromJson(contents);
    } catch (e) {
      return [];
    }
  }

  // Menulis data ke JSON
  static Future<void> writeTransactions(List<TransactionModel> transactions) async {
    final file = await _getLocalFile();
    final jsonString = TransactionModel.listToJson(transactions);
    await file.writeAsString(jsonString);
  }
}
