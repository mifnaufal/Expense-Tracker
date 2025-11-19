import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

class SummaryScreen extends StatefulWidget {
  final List<TransactionModel> transactions;

  const SummaryScreen({super.key, required this.transactions});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 6));
    final monthStart = DateTime(now.year, now.month, 1);

    double todayIncome = 0;
    double todayExpense = 0;
    double weekIncome = 0;
    double weekExpense = 0;
    double monthIncome = 0;
    double monthExpense = 0;

    // Group transactions by day for the week
    Map<String, double> dailyIncome = {};
    Map<String, double> dailyExpense = {};

    for (final tx in widget.transactions) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final String dayKey = DateFormat('EEE').format(txDate);

      final bool isToday = _isSameDay(txDate, todayStart);
      final bool isWithinWeek = !txDate.isBefore(weekStart) && !txDate.isAfter(todayStart);
      final bool isWithinMonth = !txDate.isBefore(monthStart) && !txDate.isAfter(todayStart);

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
          dailyIncome[dayKey] = (dailyIncome[dayKey] ?? 0) + tx.amount;
        } else {
          weekExpense += tx.amount;
          dailyExpense[dayKey] = (dailyExpense[dayKey] ?? 0) + tx.amount;
        }
      }

      if (isWithinMonth) {
        if (tx.type == TransactionType.pemasukan) {
          monthIncome += tx.amount;
        } else {
          monthExpense += tx.amount;
        }
      }
    }

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Ringkasan Keuangan',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and date range
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ringkasan Keuangan',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Periode: ${DateFormat('d MMMM').format(weekStart)} - ${DateFormat('d MMMM yyyy').format(todayStart)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Summary Cards
                  Text(
                    'Ringkasan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    context: context,
                    title: 'Hari Ini',
                    income: todayIncome,
                    expense: todayExpense,
                    currency: currency,
                    icon: Icons.today_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    context: context,
                    title: '7 Hari Terakhir',
                    income: weekIncome,
                    expense: weekExpense,
                    currency: currency,
                    icon: Icons.date_range_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    context: context,
                    title: 'Bulan Ini',
                    income: monthIncome,
                    expense: monthExpense,
                    currency: currency,
                    icon: Icons.calendar_month_outlined,
                  ),

                  // Simple Chart Section
                  if (widget.transactions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Grafik 7 Hari Terakhir',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildSimpleChart(
                      context: context,
                      dailyIncome: dailyIncome,
                      dailyExpense: dailyExpense,
                      currency: currency,
                    ),
                  ],

                  // Empty State
                  if (widget.transactions.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.analytics_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada data transaksi',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tambahkan transaksi untuk melihat ringkasan keuangan Anda',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required double income,
    required double expense,
    required NumberFormat currency,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double netBalance = income - expense;
    final Color netColor = netBalance >= 0 ? Colors.green : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: netColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    netBalance >= 0 ? 'Surplus' : 'Defisit',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: netColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              currency.format(netBalance),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: netColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context: context,
                    label: 'Pemasukan',
                    amount: income,
                    color: Colors.green,
                    icon: Icons.arrow_upward,
                    currency: currency,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context: context,
                    label: 'Pengeluaran',
                    amount: expense,
                    color: Colors.red,
                    icon: Icons.arrow_downward,
                    currency: currency,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required BuildContext context,
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
    required NumberFormat currency,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            currency.format(amount),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart({
    required BuildContext context,
    required Map<String, double> dailyIncome,
    required Map<String, double> dailyExpense,
    required NumberFormat currency,
  }) {
    final theme = Theme.of(context);
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    
    // Find max value for scaling
    double maxValue = 0;
    for (final day in days) {
      final income = dailyIncome[day] ?? 0;
      final expense = dailyExpense[day] ?? 0;
      maxValue = maxValue > income ? maxValue : income;
      maxValue = maxValue > expense ? maxValue : expense;
    }
    
    if (maxValue == 0) maxValue = 1; // Prevent division by zero

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(context, 'Pemasukan', Colors.green),
              _buildLegendItem(context, 'Pengeluaran', Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) {
                final income = dailyIncome[day] ?? 0;
                final expense = dailyExpense[day] ?? 0;
                final incomeHeight = income / maxValue * 100;
                final expenseHeight = expense / maxValue * 100;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 12,
                          height: incomeHeight,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Container(
                          width: 12,
                          height: expenseHeight,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      day,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}