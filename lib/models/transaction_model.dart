import 'dart:convert';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? imagePath;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.imagePath,
  });

  // Convert dari JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      imagePath: json['imagePath'],
    );
  }

  // Convert ke JSON
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

  static List<TransactionModel> listFromJson(String jsonString) {
    final List<dynamic> data = json.decode(jsonString);
    return data.map((item) => TransactionModel.fromJson(item)).toList();
  }

  static String listToJson(List<TransactionModel> transactions) {
    final List<Map<String, dynamic>> data =
        transactions.map((item) => item.toJson()).toList();
    return json.encode(data);
  }
}
