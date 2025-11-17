import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceSummary extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final VoidCallback? onTap;

  const BalanceSummary({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    this.onTap,
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
    
    // Calculate percentage for progress bar
    final double total = totalIncome + totalExpense;
    final double incomePercentage = total > 0 ? (totalIncome / total) * 100 : 0;
    final double expensePercentage = total > 0 ? (totalExpense / total) * 100 : 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Total Saldo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: totalBalance >= 0 
                        ? colorScheme.tertiary.withValues(alpha: 0.2)
                        : colorScheme.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    totalBalance >= 0 ? 'Positif' : 'Negatif',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: totalBalance >= 0 
                          ? colorScheme.tertiary
                          : colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              balanceText,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            
            // Progress bar showing income vs expense ratio
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: (incomePercentage * 100).round(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: (expensePercentage * 100).round(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildIncomeExpenseColumn(
                    context,
                    title: 'Pemasukan',
                    amount: incomeText,
                    percentage: incomePercentage,
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
                    percentage: expensePercentage,
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
      ),
    );
  }

  Widget _buildIncomeExpenseColumn(
    BuildContext context, {
    required String title,
    required String amount,
    required double percentage,
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
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.75),
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
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
          ),
          textAlign: textAlign,
        ),
      ],
    );
  }
}