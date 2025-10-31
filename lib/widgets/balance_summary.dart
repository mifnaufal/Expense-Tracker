import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceSummary extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;

  const BalanceSummary({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final String balanceText = currencyFormatter.format(totalBalance);
    final String incomeText = currencyFormatter.format(totalIncome);
    final String expenseText = currencyFormatter.format(totalExpense);

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Saldo',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              balanceText,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: totalBalance >= 0 ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildIncomeExpenseColumn(
                    'Pemasukan',
                    incomeText,
                    Colors.green,
                    alignment: CrossAxisAlignment.start,
                    textAlign: TextAlign.left,
                    headerAlignment: MainAxisAlignment.start,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildIncomeExpenseColumn(
                    'Pengeluaran',
                    expenseText,
                    Colors.red,
                    alignment: CrossAxisAlignment.end,
                    textAlign: TextAlign.right,
                    headerAlignment: MainAxisAlignment.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseColumn(
    String title,
    String amount,
    Color color, {
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
    TextAlign textAlign = TextAlign.left,
    MainAxisAlignment headerAlignment = MainAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisAlignment: headerAlignment,
          children: [
            Icon(
              title == 'Pemasukan'
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: color,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: textAlign,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}