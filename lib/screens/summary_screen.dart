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
      final bool isWithinWeek =
          !txDate.isBefore(weekStart) && !txDate.isAfter(todayStart);

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Keuangan')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Sederhana',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _buildTotalsCard(
                context: context,
                title: 'Ringkasan Hari Ini',
                income: todayIncome,
                expense: todayExpense,
                currency: currency,
                gradientColors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.9),
                  colorScheme.secondaryContainer.withValues(alpha: 0.9),
                ],
              ),
              const SizedBox(height: 12),
              _buildTotalsCard(
                context: context,
                title: 'Ringkasan 7 Hari Terakhir',
                income: weekIncome,
                expense: weekExpense,
                currency: currency,
                gradientColors: [
                  colorScheme.secondaryContainer.withValues(alpha: 0.9),
                  colorScheme.surface.withValues(alpha: 0.9),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  '(Grafik sederhana bisa ditambahkan di sini)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalsCard({
    required BuildContext context,
    required String title,
    required double income,
    required double expense,
    required NumberFormat currency,
    required List<Color> gradientColors,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double netBalance = income - expense;
    final Color netColor = netBalance >= 0
        ? colorScheme.tertiary
        : colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 24,
            offset: Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currency.format(netBalance),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: netColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildMetricRow(
            context: context,
            label: 'Pemasukan',
            amount: income,
            color: colorScheme.tertiary,
            icon: Icons.arrow_upward,
            currency: currency,
          ),
          const SizedBox(height: 8),
          _buildMetricRow(
            context: context,
            label: 'Pengeluaran',
            amount: expense,
            color: colorScheme.error,
            icon: Icons.arrow_downward,
            currency: currency,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required BuildContext context,
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
    required NumberFormat currency,
  }) {
    final theme = Theme.of(context);

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
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ),
        Text(
          currency.format(amount),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
