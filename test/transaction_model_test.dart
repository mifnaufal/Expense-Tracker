import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/models/transaction_model.dart';

void main() {
  group('TransactionModel serialization', () {
    test('toJson includes all persisted fields', () {
      final transaction = TransactionModel(
        id: 'tx-1',
        title: 'Gaji Bulan Oktober',
        amount: 5000000,
        category: 'Gaji',
        date: DateTime.utc(2025, 10, 1),
        imagePath: '/tmp/receipt.png',
        type: TransactionType.pemasukan,
      );

      final json = transaction.toJson();

      expect(json['id'], equals('tx-1'));
      expect(json['title'], equals('Gaji Bulan Oktober'));
      expect(json['amount'], equals(5000000));
      expect(json['category'], equals('Gaji'));
      expect(json['date'], equals('2025-10-01T00:00:00.000Z'));
      expect(json['imagePath'], equals('/tmp/receipt.png'));
      expect(json['type'], equals('pemasukan'));
    });

    test('fromJson uses explicit type when provided', () {
      final transaction = TransactionModel.fromJson({
        'id': '11',
        'title': 'Bonus Kinerja',
        'amount': 750000,
        'category': 'Bonus',
        'date': '2025-10-10T08:15:00.000Z',
        'imagePath': null,
        'type': 'pemasukan',
      });

      expect(transaction.type, equals(TransactionType.pemasukan));
      expect(transaction.category, equals('Bonus'));
      expect(transaction.amount, equals(750000));
    });

    test('fromJson derives type from category when missing', () {
      final transaction = TransactionModel.fromJson({
        'id': '22',
        'title': 'Makan malam',
        'amount': 120000,
        'category': 'Makanan',
        'date': '2025-10-15T19:00:00.000Z',
        'imagePath': null,
      });

      expect(transaction.type, equals(TransactionType.pengeluaran));
    });
  });

  test('copyWith overrides provided properties', () {
    final base = TransactionModel(
      id: '1',
      title: 'Transport ke kantor',
      amount: 20000,
      category: 'Transport',
      date: DateTime.utc(2025, 10, 20),
      type: TransactionType.pengeluaran,
    );

    final updated = base.copyWith(
      title: 'Transportasi ke kantor',
      amount: 25000,
    );

    expect(updated.title, equals('Transportasi ke kantor'));
    expect(updated.amount, equals(25000));
    expect(updated.category, equals('Transport'));
    expect(updated.id, equals('1'));
  });
}
