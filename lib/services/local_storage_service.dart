// lib/services/local_storage_service.dart

import 'dart:convert'; // Untuk json.decode
import 'package:flutter/services.dart' show rootBundle; // Untuk baca asset
import '../models/transaction_model.dart';
// import 'dart:io'; // (Dibutuhkan nanti untuk 'save')
// import 'package:path_provider/path_provider.dart'; // (Dibutuhkan nanti untuk 'save')

class LocalStorageService {
  
  // Path ke file asset JSON
  final String _transactionsAssetPath = 'data/transactions.json';

  /// Membaca daftar transaksi dari file 'data/transactions.json' di assets.
  Future<List<TransactionModel>> loadTransactions() async {
    try {
      // 1. Baca file JSON sebagai String dari assets
      final String jsonString = await rootBundle.loadString(_transactionsAssetPath);
      
      // 2. Decode String JSON menjadi List<dynamic>
      final List<dynamic> jsonList = json.decode(jsonString) as List;
      
      // 3. Ubah setiap item di List menjadi TransactionModel
      List<TransactionModel> transactions = jsonList.map((jsonItem) {
        return TransactionModel.fromJson(jsonItem as Map<String, dynamic>);
      }).toList();
      
      return transactions;

    } catch (e) {
      // Tangani error jika file tidak ditemukan atau format JSON salah
      print('Error loading transactions from asset: $e');
      return []; // Kembalikan list kosong jika gagal
    }
  }

  /// Menyimpan daftar transaksi ke device storage.
  /// (Belum diimplementasi penuh)
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    // PENTING: Kita tidak bisa MENULIS KEMBALI ke folder 'assets'.
    // 'Assets' bersifat read-only setelah aplikasi di-build.
    
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
  }
}