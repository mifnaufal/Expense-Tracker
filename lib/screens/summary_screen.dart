import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

class SummaryScreen extends StatelessWidget {
  final List<TransactionModel> transactions;

  const SummaryScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 6));

    double todayIncome = 0;
    double todayExpense = 0;
    double weekIncome = 0;
    double weekExpense = 0;

    for (final tx in transactions) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);

      final bool isToday = _isSameDay(txDate, todayStart);
      final bool isWithinWeek = !txDate.isBefore(weekStart) && !txDate.isAfter(todayStart);

      if (isToday) {
        if (tx.type == TransactionType.pemasukan) {
          todayIncome += tx.amount;
        } else {
          todayExpense += tx.amount;
        }
      }

      if (isWithinWeek) {
        if (tx.type == TransactionType.pemasukan) {
          weekIncome += tx.amount;
        } else {
          weekExpense += tx.amount;
        }
      }
    }

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Ringkasan Keuangan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Sederhana',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 20),
              _buildTotalsCard(
                title: 'Ringkasan Hari Ini',
                income: todayIncome,
                expense: todayExpense,
                currency: currency,
              ),
              SizedBox(height: 12),
              _buildTotalsCard(
                title: 'Ringkasan 7 Hari Terakhir',
                income: weekIncome,
                expense: weekExpense,
                currency: currency,
              ),
              SizedBox(height: 30),
              Center(
                child: Text(
                  '(Grafik sederhana bisa ditambahkan di sini)',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
              // (Opsional: Tambahkan package 'charts_flutter' untuk grafik)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalsCard({
    required String title,
    required double income,
    required double expense,
    required NumberFormat currency,
  }) {
    final double netBalance = income - expense;
    final Color netColor = netBalance >= 0 ? Colors.green : Colors.red;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              currency.format(netBalance),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: netColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              label: 'Pemasukan',
              amount: income,
              color: Colors.green,
              icon: Icons.arrow_upward,
              currency: currency,
            ),
            const SizedBox(height: 8),
            _buildMetricRow(
              label: 'Pengeluaran',
              amount: expense,
              color: Colors.red,
              icon: Icons.arrow_downward,
              currency: currency,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
    required NumberFormat currency,
  }) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          currency.format(amount),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}