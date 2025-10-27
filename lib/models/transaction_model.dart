// lib/models/transaction_model.dart

import 'dart:io';

// Enum ini tetap kita pakai untuk logic UI (misal warna & ikon)
enum TransactionType {
  pemasukan,
  pengeluaran,
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category; // SesuAI JSON: "Makanan", "Transportasi"
  final DateTime date;
  final String? imagePath; // SesuAI JSON: "imagePath": null
  final TransactionType type; // Ini kita derive dari category

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.imagePath,
    required this.type,
  });

  // Factory constructor untuk membuat instance dari Map (JSON)
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    
    // Tentukan Tipe (pemasukan/pengeluaran) berdasarkan Kategori
    // Kita buat asumsi di sini
    final String category = json['category'];
    TransactionType derivedType = TransactionType.pengeluaran; // Default pengeluaran

    // Tambahkan kategori lain yang termasuk pemasukan
    if (category.toLowerCase() == 'gaji' || category.toLowerCase() == 'bonus') {
      derivedType = TransactionType.pemasukan;
    }

    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(), // Konversi aman dari int/double
      category: category,
      date: DateTime.parse(json['date']), // Parsing string tanggal ISO 8601
      imagePath: json['imagePath'],
      type: derivedType, // Masukkan tipe yang sudah kita tentukan
    );
  }

  // Method untuk konversi instance ke Map (JSON)
  // (Berguna saat nanti mengimplementasikan 'save')
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(), // Simpan sebagai string ISO 8601
      'imagePath': imagePath,
      // 'type' tidak perlu disimpan karena di-derive dari 'category'
    };
  }
}