import 'dart:convert';
import 'dart:typed_data';

enum TransactionType { pemasukan, pengeluaran }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? imagePath;
  final String? imageBase64;
  final TransactionType type;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.imagePath,
    this.imageBase64,
    required this.type,
  });

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
      imageBase64: (json['imageBase64'] as String?)?.trim().isEmpty == true
          ? null
          : json['imageBase64'] as String?,
      type: resolvedType,
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
      'imageBase64': imageBase64,
      'type': type.name,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? imagePath,
    String? imageBase64,
    TransactionType? type,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      imageBase64: imageBase64 ?? this.imageBase64,
      type: type ?? this.type,
    );
  }

  Uint8List? get imageBytes {
    if (imageBase64 == null || imageBase64!.isEmpty) {
      return null;
    }
    try {
      return base64Decode(imageBase64!);
    } catch (_) {
      return null;
    }
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
        imageBase64 == other.imageBase64 &&
        type == other.type;
  }

  @override
  int get hashCode => Object.hash(id, title, amount, category, date, imagePath, imageBase64, type);

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
