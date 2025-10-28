import 'dart:io';

enum TransactionType {
  pemasukan,
  pengeluaran,
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? imagePath;
  final TransactionType type;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.imagePath,
    required this.type,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    
    final String category = json['category'];
    TransactionType derivedType = TransactionType.pengeluaran; 


    if (category.toLowerCase() == 'gaji' || category.toLowerCase() == 'bonus') {
      derivedType = TransactionType.pemasukan;
    }

    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(), 
      category: category,
      date: DateTime.parse(json['date']), 
      imagePath: json['imagePath'],
      type: derivedType, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'imagePath': imagePath,
    };
  }
}