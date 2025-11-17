import 'dart:convert';
import 'dart:typed_data';

enum TransactionType { pemasukan, pengeluaran }

/// Extension to provide additional functionality for TransactionType
extension TransactionTypeExtension on TransactionType {
  /// Get the display name for the transaction type
  String get displayName {
    switch (this) {
      case TransactionType.pemasukan:
        return 'Pemasukan';
      case TransactionType.pengeluaran:
        return 'Pengeluaran';
    }
  }

  /// Get the icon associated with the transaction type
  String get icon {
    switch (this) {
      case TransactionType.pemasukan:
        return '↑';
      case TransactionType.pengeluaran:
        return '↓';
    }
  }

  /// Get the color code for the transaction type (can be used with Flutter Color class)
  String get colorCode {
    switch (this) {
      case TransactionType.pemasukan:
        return '#4CAF50'; // Green
      case TransactionType.pengeluaran:
        return '#F44336'; // Red
    }
  }
}

/// Extension to provide additional functionality for DateTime
extension DateTimeExtension on DateTime {
  /// Check if this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if this date is within the last 7 days
  bool get isThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return isAfter(weekAgo) && !isAfter(now);
  }

  /// Check if this date is within the current month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Format the date in a user-friendly way
  String format({bool includeTime = false}) {
    if (isToday) {
      return 'Hari ini';
    } else if (isThisWeek) {
      final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      return days[weekday - 1];
    } else {
      return '${day}/${month}/${year}';
    }
  }
}

/// Model class representing a financial transaction
class TransactionModel {
  /// Unique identifier for the transaction
  final String id;
  
  /// Title or description of the transaction
  final String title;
  
  /// Amount of money in the transaction
  final double amount;
  
  /// Category of the transaction (e.g., 'Makanan', 'Transport', etc.)
  final String category;
  
  /// Date when the transaction occurred
  final DateTime date;
  
  /// Path to the image file (for mobile platforms)
  final String? imagePath;
  
  /// Base64 encoded image data (for web platform)
  final String? imageBase64;
  
  /// Type of transaction (income or expense)
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

  /// Creates a TransactionModel from a JSON map
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    try {
      final String rawCategory = (json['category'] ?? '') as String;
      final String? rawType = json['type'] as String?;
      final TransactionType resolvedType =
          _tryParseType(rawType) ?? _deriveTypeFromCategory(rawCategory);

      return TransactionModel(
        id: json['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
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
    } catch (e) {
      // Return a default transaction if JSON parsing fails
      return TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Error Transaction',
        amount: 0.0,
        category: 'Error',
        date: DateTime.now(),
        type: TransactionType.pengeluaran,
      );
    }
  }

  /// Converts the TransactionModel to a JSON map
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

  /// Creates a copy of this TransactionModel with the specified fields replaced
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

  /// Returns the image as bytes if available
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

  /// Checks if the transaction has an associated image
  bool get hasImage => (imagePath != null && imagePath!.isNotEmpty) || 
                      (imageBase64 != null && imageBase64!.isNotEmpty);

  /// Returns the formatted amount with currency symbol
  String get formattedAmount {
    final prefix = type == TransactionType.pemasukan ? '+ Rp' : '- Rp';
    return '$prefix ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    )}';
  }

  /// Returns the amount as a formatted currency string without sign
  String get formattedAmountWithoutSign {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    )}';
  }

  /// Checks if the transaction occurred today
  bool get isToday => date.isToday;

  /// Checks if the transaction occurred within the last 7 days
  bool get isThisWeek => date.isThisWeek;

  /// Checks if the transaction occurred within the current month
  bool get isThisMonth => date.isThisMonth;

  /// Validates the transaction data
  bool get isValid {
    return title.isNotEmpty && 
           amount > 0 && 
           category.isNotEmpty;
  }

  /// Returns a string representation of the transaction
  @override
  String toString() =>
      'TransactionModel(id: $id, title: $title, amount: $amount, category: $category, date: $date, type: ${type.name})';

  /// Compares two TransactionModel instances for equality
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

  /// Returns the hash code for this TransactionModel
  @override
  int get hashCode => Object.hash(
    id,
    title,
    amount,
    category,
    date,
    imagePath,
    imageBase64,
    type,
  );

  /// Tries to parse a string into a TransactionType
  static TransactionType? _tryParseType(String? rawType) {
    if (rawType == null) return null;
    try {
      return TransactionType.values.firstWhere(
        (t) => t.name == rawType || t.toString().split('.').last == rawType,
      );
    } catch (_) {
      return null;
    }
  }

  /// Derives the transaction type from the category name
  static TransactionType _deriveTypeFromCategory(String category) {
    final lower = category.toLowerCase();
    
    // Income categories
    const incomeKeywords = [
      'gaji', 'bonus', 'income', 'pendapatan', 'hadiah', 'investasi',
      'pemasukan', 'terima', 'uang masuk', 'bayaran', 'upah'
    ];
    
    // Check if any income keyword is in the category
    for (final keyword in incomeKeywords) {
      if (lower.contains(keyword)) {
        return TransactionType.pemasukan;
      }
    }
    
    // Default to expense
    return TransactionType.pengeluaran;
  }

  /// Creates a new transaction with minimal required fields
  factory TransactionModel.create({
    required String title,
    required double amount,
    required String category,
    required TransactionType type,
    DateTime? date,
    String? imagePath,
    String? imageBase64,
  }) {
    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
      imagePath: imagePath,
      imageBase64: imageBase64,
      type: type,
    );
  }

  /// Creates a sample transaction for testing purposes
  factory TransactionModel.sample({
    TransactionType type = TransactionType.pengeluaran,
    String category = 'Makanan',
    double amount = 50000,
  }) {
    return TransactionModel.create(
      title: 'Transaksi Contoh',
      amount: amount,
      category: category,
      type: type,
      date: DateTime.now(),
    );
  }
}

/// Extension to provide additional functionality for List<TransactionModel>
extension TransactionListExtension on List<TransactionModel> {
  /// Filters transactions by type
  List<TransactionModel> filterByType(TransactionType type) {
    return where((transaction) => transaction.type == type).toList();
  }

  /// Filters transactions by category
  List<TransactionModel> filterByCategory(String category) {
    return where((transaction) => 
        transaction.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  /// Filters transactions by date range
  List<TransactionModel> filterByDateRange(DateTime start, DateTime end) {
    return where((transaction) => 
        transaction.date.isAfter(start.subtract(const Duration(days: 1))) &&
        transaction.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  /// Calculates the total amount for all transactions
  double get totalAmount => fold(0.0, (sum, transaction) => sum + transaction.amount);

  /// Calculates the total amount for transactions of a specific type
  double totalByType(TransactionType type) {
    return where((transaction) => transaction.type == type)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Calculates the total income
  double get totalIncome => totalByType(TransactionType.pemasukan);

  /// Calculates the total expense
  double get totalExpense => totalByType(TransactionType.pengeluaran);

  /// Calculates the balance (income - expense)
  double get balance => totalIncome - totalExpense;

  /// Groups transactions by category
  Map<String, List<TransactionModel>> groupByCategory() {
    final Map<String, List<TransactionModel>> grouped = {};
    for (final transaction in this) {
      if (!grouped.containsKey(transaction.category)) {
        grouped[transaction.category] = [];
      }
      grouped[transaction.category]!.add(transaction);
    }
    return grouped;
  }

  /// Groups transactions by month
  Map<String, List<TransactionModel>> groupByMonth() {
    final Map<String, List<TransactionModel>> grouped = {};
    for (final transaction in this) {
      final monthKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(transaction);
    }
    return grouped;
  }

  /// Sorts transactions by date (newest first)
  List<TransactionModel> sortByDate({bool descending = true}) {
    final sorted = List<TransactionModel>.from(this);
    sorted.sort((a, b) => descending 
        ? b.date.compareTo(a.date) 
        : a.date.compareTo(b.date));
    return sorted;
  }

  /// Sorts transactions by amount (highest first)
  List<TransactionModel> sortByAmount({bool descending = true}) {
    final sorted = List<TransactionModel>.from(this);
    sorted.sort((a, b) => descending 
        ? b.amount.compareTo(a.amount) 
        : a.amount.compareTo(b.amount));
    return sorted;
  }
}