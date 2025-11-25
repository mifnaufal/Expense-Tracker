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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final String balanceText = currencyFormatter.format(totalBalance);
    final String incomeText = currencyFormatter.format(totalIncome);
    final String expenseText = currencyFormatter.format(totalExpense);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.95),
            colorScheme.secondaryContainer.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 30,
            offset: Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Saldo',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            balanceText,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildIncomeExpenseColumn(
                  context,
                  title: 'Pemasukan',
                  amount: incomeText,
                  color: colorScheme.tertiary,
                  icon: Icons.arrow_upward,
                  alignment: CrossAxisAlignment.start,
                  textAlign: TextAlign.left,
                  headerAlignment: MainAxisAlignment.start,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIncomeExpenseColumn(
                  context,
                  title: 'Pengeluaran',
                  amount: expenseText,
                  color: colorScheme.error,
                  icon: Icons.arrow_downward,
                  alignment: CrossAxisAlignment.end,
                  textAlign: TextAlign.right,
                  headerAlignment: MainAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseColumn(
    BuildContext context, {
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
    TextAlign textAlign = TextAlign.left,
    MainAxisAlignment headerAlignment = MainAxisAlignment.start,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisAlignment: headerAlignment,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.75,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          amount,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
          textAlign: textAlign,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
