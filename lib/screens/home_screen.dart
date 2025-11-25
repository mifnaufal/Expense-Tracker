import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/transaction_model.dart';
import '../services/local_storage_service.dart';
import '../widgets/balance_summary.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';
import 'summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    // 3. Panggil fungsi load data saat screen pertama kali dibuka
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final loadedTransactions = await _storageService.readData();
    if (!mounted) return;

    _setTransactions(loadedTransactions);
  }

  void _setTransactions(List<TransactionModel> transactions) {
    final sortedTransactions = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _transactions = sortedTransactions;
      _isLoading = false;
    });
  }

  // (Fungsi kalkulasi saldo biarkan saja, akan otomatis pakai data baru)
  double get _totalIncome {
    return _transactions
        .where((tx) => tx.type == TransactionType.pemasukan)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _totalExpense {
    return _transactions
        .where((tx) => tx.type == TransactionType.pengeluaran)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _totalBalance {
    return _totalIncome - _totalExpense;
  }

  Future<void> _addTransaction(TransactionModel newTx) async {
    try {
      final result = await _storageService.addTransaction(newTx);
      if (!mounted) return;
      _setTransactions(result.transactions);
      _showPersistenceFeedback(
        'Transaksi berhasil ditambahkan',
        result.storagePath,
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('Gagal menambahkan transaksi: $e');
      _showSnackBar('Gagal menambahkan transaksi: $e');
    }
  }

  void _navigateToAddScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddTransactionScreen(onSubmit: _addTransaction),
      ),
    );
  }

  void _navigateToEditScreen(TransactionModel transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddTransactionScreen(
          initialTransaction: transaction,
          onSubmit: _editTransaction,
        ),
      ),
    );
  }

  Future<void> _editTransaction(TransactionModel updatedTransaction) async {
    try {
      final result = await _storageService.updateTransaction(
        updatedTransaction,
      );
      if (!mounted) return;
      _setTransactions(result.transactions);
      _showPersistenceFeedback(
        'Transaksi berhasil diperbarui',
        result.storagePath,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal memperbarui transaksi');
    }
  }

  Future<void> _deleteTransaction(String transactionId) async {
    try {
      final result = await _storageService.deleteTransaction(transactionId);
      if (!mounted) return;
      _setTransactions(result.transactions);
      _showPersistenceFeedback(
        'Transaksi berhasil dihapus',
        result.storagePath,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal menghapus transaksi');
    }
  }

  Future<void> _exportTransactions() async {
    try {
      final exportResult = await _storageService.exportTransactions();
      if (!mounted) return;

      await Clipboard.setData(ClipboardData(text: exportResult.payload));
      _showSnackBar('Data transaksi disalin ke clipboard');
      debugPrint('Lokasi penyimpanan saat ini: ${exportResult.storagePath}');
    } catch (e) {
      if (!mounted) return;
      debugPrint('Gagal mengekspor transaksi: $e');
      _showSnackBar('Gagal mengekspor transaksi: $e');
    }
  }

  void _confirmDeleteTransaction(TransactionModel transaction) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text(
          'Apakah kamu yakin ingin menghapus "${transaction.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteTransaction(transaction.id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showPersistenceFeedback(String baseMessage, String storagePath) {
    _showSnackBar('$baseMessage (tersimpan lokal)');
    debugPrint('Data disimpan di: $storagePath');
  }

  void _navigateToSummaryScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => SummaryScreen(transactions: _transactions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Tracker',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Pantau keuanganmu dalam satu tempat',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
        actions: [
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.secondaryContainer.withValues(
                alpha: 0.6,
              ),
            ),
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: _transactions.isEmpty ? null : _navigateToSummaryScreen,
            tooltip: 'Ringkasan',
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.secondaryContainer.withValues(
                alpha: 0.6,
              ),
            ),
            icon: const Icon(Icons.download_outlined),
            onPressed: _exportTransactions,
            tooltip: 'Ekspor JSON',
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: BalanceSummary(
                          totalBalance: _totalBalance,
                          totalIncome: _totalIncome,
                          totalExpense: _totalExpense,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Transaksi Terakhir', style: titleStyle),
                            TextButton(
                              onPressed: _transactions.isEmpty
                                  ? null
                                  : _navigateToSummaryScreen,
                              child: const Text('Lihat Semua'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_transactions.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'Belum ada transaksi.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 96),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final transaction = _transactions[index];
                            return TransactionCard(
                              transaction: transaction,
                              onEdit: () => _navigateToEditScreen(transaction),
                              onDelete: () =>
                                  _confirmDeleteTransaction(transaction),
                            );
                          }, childCount: _transactions.length),
                        ),
                      ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        tooltip: 'Tambah Transaksi',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
