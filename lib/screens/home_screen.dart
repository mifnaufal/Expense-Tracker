import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final loadedTransactions = await _storageService.readData();
    if (!mounted) return;
    _setTransactions(loadedTransactions);
    _animationController.forward();
  }

  void _setTransactions(List<TransactionModel> transactions) {
    final sortedTransactions = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _transactions = sortedTransactions;
      _isLoading = false;
    });
  }

  double get _totalIncome => _transactions
      .where((tx) => tx.type == TransactionType.pemasukan)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get _totalExpense => _transactions
      .where((tx) => tx.type == TransactionType.pengeluaran)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get _totalBalance => _totalIncome - _totalExpense;

  Future<void> _addTransaction(TransactionModel newTx) async {
    try {
      final result = await _storageService.addTransaction(newTx);
      if (!mounted) return;
      _setTransactions(result.transactions);
      _showSnackBar('Transaksi berhasil ditambahkan ✅');
      _showPersistenceFeedback(
        'Transaksi berhasil ditambahkan',
        result.storagePath,
      );
    } catch (e) {
      _showSnackBar('Gagal menambahkan transaksi: $e');
    }
  }

  Future<void> _editTransaction(TransactionModel updatedTransaction) async {
    try {
      final result = await _storageService.updateTransaction(
        updatedTransaction,
      );
      if (!mounted) return;
      _setTransactions(result.transactions);
      _showSnackBar('Transaksi diperbarui ✅');
      _showPersistenceFeedback(
        'Transaksi berhasil diperbarui',
        result.storagePath,
      );
    } catch (e) {
      _showSnackBar('Gagal memperbarui transaksi: $e');
    }
  }

  Future<void> _deleteTransaction(String id) async {
    try {
      final result = await _storageService.deleteTransaction(id);
      if (!mounted) return;
      _setTransactions(result.transactions);
      _showSnackBar('Transaksi dihapus 🗑️');
      _showPersistenceFeedback(
        'Transaksi berhasil dihapus',
        result.storagePath,
      );
    } catch (e) {
      _showSnackBar('Gagal menghapus transaksi: $e');
    }
  }

  Future<void> _exportTransactions() async {
    try {
      final exportResult = await _storageService.exportTransactions();
      final payload = exportResult.payload ?? '';
      await Clipboard.setData(ClipboardData(text: payload));
      _showSnackBar('Data disalin ke clipboard 📋');
    } catch (e) {
      _showSnackBar('Gagal mengekspor transaksi: $e');
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

  void _navigateToSummaryScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => SummaryScreen(transactions: _transactions),
      ),
    );
  }

  void _confirmDeleteTransaction(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Transaksi'),
        content: Text(
          'Apakah kamu yakin ingin menghapus "${transaction.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteTransaction(transaction.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showPersistenceFeedback(String baseMessage, String storagePath) {
    final locationDescription = _describeStoragePath(storagePath);
    _showSnackBar('$baseMessage ($locationDescription)');
    debugPrint('Data disimpan di: $storagePath');
  }

  String _describeStoragePath(String storagePath) {
    if (storagePath.isEmpty) return 'lokasi tidak diketahui';
    final normalized = storagePath.trim();
    if (normalized.startsWith('http')) return 'tersimpan di backend';
    if (normalized.startsWith('web-local-storage'))
      return 'tersimpan di penyimpanan browser';
    return 'tersimpan lokal di $normalized';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balanceColor = _totalBalance >= 0
        ? Colors.green.shade400
        : Colors.orange.shade400;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
        title: Text(
          'Expense Tracker',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: _transactions.isEmpty ? null : _navigateToSummaryScreen,
            tooltip: 'Ringkasan',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: _exportTransactions,
            tooltip: 'Ekspor JSON',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Memuat data...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                color: theme.colorScheme.primary,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: BalanceSummary(
                            totalBalance: _totalBalance,
                            totalIncome: _totalIncome,
                            totalExpense: _totalExpense,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Transaksi Terakhir',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _transactions.isEmpty
                                    ? null
                                    : _navigateToSummaryScreen,
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                label: const Text('Lihat Semua'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_transactions.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_outlined,
                                    size: 64,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Belum ada transaksi.',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tekan tombol + untuk menambahkan transaksi pertama Anda',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _navigateToAddScreen,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Tambah Transaksi'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final transaction = _transactions[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TransactionCard(
                                  transaction: transaction,
                                  onEdit: () =>
                                      _navigateToEditScreen(transaction),
                                  onDelete: () =>
                                      _confirmDeleteTransaction(transaction),
                                ),
                              );
                            }, childCount: _transactions.length),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddScreen,
        tooltip: 'Tambah Transaksi',
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        backgroundColor: balanceColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
