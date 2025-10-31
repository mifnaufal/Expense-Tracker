<<<<<<< HEAD


// ignore: unused_import
import 'dart:io';


enum TransactionType {
  pemasukan,
  pengeluaran,
}
=======
enum TransactionType { pemasukan, pengeluaran }
>>>>>>> 87c6702623d3eba141274ba17434d417848531b3

class TransactionModel {
  final String id;
  final String title;
  final double amount;
<<<<<<< HEAD
  final String category; 
  final DateTime date;
  final String? imagePath; 
  final TransactionType type; 
=======
  final String category;
  final DateTime date;
  final String? imagePath;
  final TransactionType type;
>>>>>>> 87c6702623d3eba141274ba17434d417848531b3

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.imagePath,
    required this.type,
  });

<<<<<<< HEAD

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
=======
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final String rawCategory = (json['category'] ?? '') as String;
    final String? rawType = json['type'] as String?;
    final TransactionType resolvedType = _tryParseType(rawType) ?? _deriveTypeFromCategory(rawCategory);

    return TransactionModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: (json['title'] ?? '') as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: rawCategory,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      imagePath: (json['imagePath'] as String?)?.trim().isEmpty == true
          ? null
          : json['imagePath'] as String?,
      type: resolvedType,
>>>>>>> 87c6702623d3eba141274ba17434d417848531b3
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
<<<<<<< HEAD
      'date': date.toIso8601String(), 
      'imagePath': imagePath,
=======
      'date': date.toIso8601String(),
      'imagePath': imagePath,
      'type': type.name,
>>>>>>> 87c6702623d3eba141274ba17434d417848531b3
    };
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? imagePath,
    TransactionType? type,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      type: type ?? this.type,
    );
  }

  @override
  String toString() =>
      'TransactionModel(id: $id, title: $title, amount: $amount, category: $category, date: $date, type: ${type.name})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TransactionModel) return false;
    return id == other.id &&
        title == other.title &&
        amount == other.amount &&
        category == other.category &&
        date == other.date &&
        imagePath == other.imagePath &&
        type == other.type;
  }

  @override
  int get hashCode => Object.hash(id, title, amount, category, date, imagePath, type);

  static TransactionType? _tryParseType(String? rawType) {
    if (rawType == null) return null;
    try {
      return TransactionType.values.firstWhere((type) => type.name == rawType);
    } catch (_) {
      return null;
    }
  }

  static TransactionType _deriveTypeFromCategory(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('gaji') ||
        lowerCategory.contains('bonus') ||
        lowerCategory.contains('income') ||
        lowerCategory.contains('pendapatan')) {
      return TransactionType.pemasukan;
    }
    return TransactionType.pengeluaran;
  }
}
