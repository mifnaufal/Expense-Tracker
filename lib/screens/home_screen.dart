import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';

=======
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
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
<<<<<<< HEAD
=======
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
=======
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
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

<<<<<<< HEAD
  double get _totalIncome => _transactions
      .where((tx) => tx.type == TransactionType.pemasukan)
      .fold(0.0, (sum, item) => sum + item.amount);
=======
  double get _totalIncome {
    return _transactions
        .where((tx) => tx.type == TransactionType.pemasukan)
        .fold(0.0, (sum, item) => sum + item.amount);
  }
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8

  double get _totalExpense => _transactions
      .where((tx) => tx.type == TransactionType.pengeluaran)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get _totalBalance => _totalIncome - _totalExpense;

  Future<void> _addTransaction(TransactionModel newTx) async {
    try {
      final result = await _storageService.addTransaction(newTx);
      if (!mounted) return;
      _setTransactions(result.transactions);
<<<<<<< HEAD
      _showSnackBar('Transaksi berhasil ditambahkan ✅');
=======
      _showPersistenceFeedback(
        'Transaksi berhasil ditambahkan',
        result.storagePath,
      );
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
    } catch (e) {
      _showSnackBar('Gagal menambahkan transaksi: $e');
    }
  }

<<<<<<< HEAD
=======
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

>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
  Future<void> _editTransaction(TransactionModel updatedTransaction) async {
    try {
      final result = await _storageService.updateTransaction(
        updatedTransaction,
      );
      if (!mounted) return;
      _setTransactions(result.transactions);
<<<<<<< HEAD
      _showSnackBar('Transaksi diperbarui ✅');
=======
      _showPersistenceFeedback(
        'Transaksi berhasil diperbarui',
        result.storagePath,
      );
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
    } catch (e) {
      _showSnackBar('Gagal memperbarui transaksi');
    }
  }

  Future<void> _deleteTransaction(String id) async {
    try {
      final result = await _storageService.deleteTransaction(id);
      if (!mounted) return;
      _setTransactions(result.transactions);
<<<<<<< HEAD
      _showSnackBar('Transaksi dihapus 🗑️');
=======
      _showPersistenceFeedback(
        'Transaksi berhasil dihapus',
        result.storagePath,
      );
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
    } catch (e) {
      _showSnackBar('Gagal menghapus transaksi');
    }
  }

  Future<void> _exportTransactions() async {
    try {
      final exportResult = await _storageService.exportTransactions();
      await Clipboard.setData(ClipboardData(text: exportResult.payload ?? ''));
      _showSnackBar('Data disalin ke clipboard 📋');
    } catch (e) {
      _showSnackBar('Gagal mengekspor transaksi');
    }
  }

  void _navigateToAddScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddTransactionScreen(onSubmit: _addTransaction),
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

  void _confirmDelete(TransactionModel tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Hapus Transaksi'),
<<<<<<< HEAD
        content: Text('Yakin ingin menghapus "${tx.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTransaction(tx.id);
=======
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
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
<<<<<<< HEAD
      ..showSnackBar(SnackBar(content: Text(msg)));
=======
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  void _showPersistenceFeedback(String baseMessage, String storagePath) {
    final locationDescription = _describeStoragePath(storagePath);
    _showSnackBar('$baseMessage ($locationDescription)');
    debugPrint('Data disimpan di: $storagePath');
  }

  String _describeStoragePath(String storagePath) {
    if (storagePath.isEmpty) {
      return 'lokasi tidak diketahui';
    }

    final normalized = storagePath.trim();
    if (normalized.startsWith('http')) {
      return 'tersimpan di backend';
    }

    if (normalized.startsWith('web-local-storage')) {
      return 'tersimpan di penyimpanan browser';
    }

    return 'tersimpan lokal di $normalized';
  }

  void _navigateToSummaryScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => SummaryScreen(transactions: _transactions),
      ),
    );
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final balanceColor = _totalBalance >= 0 ? Colors.green.shade400 : Colors.orange.shade400;
    final formattedBalance = _totalBalance.toStringAsFixed(0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('FinTrack', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart_rounded), onPressed: _navigateToSummaryScreen),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [balanceColor.withOpacity(0.9), balanceColor.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(color: balanceColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Saldo Saat Ini', style: GoogleFonts.poppins(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text(
                          'Rp $formattedBalance',
                          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Pemasukan: Rp ${_totalIncome.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white70)),
                            Text('Pengeluaran: Rp ${_totalExpense.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Transaksi Terakhir', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (_transactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('Belum ada transaksi.', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ..._transactions.map(
                      (tx) => TransactionCard(
                        transaction: tx,
                        onEdit: () => _navigateToAddScreen(),
                        onDelete: () => _confirmDelete(tx),
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddScreen,
        backgroundColor: balanceColor,
        label: const Text('Tambah Transaksi'),
        icon: const Icon(Icons.add),
=======
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
        title: Text(
          'Expense Tracker',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.bar_chart_outlined,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: _transactions.isEmpty ? null : _navigateToSummaryScreen,
              tooltip: 'Ringkasan',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.download_outlined,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: _exportTransactions,
              tooltip: 'Ekspor JSON',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
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
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                                style: titleStyle,
                              ),
                              TextButton.icon(
                                onPressed: _transactions.isEmpty
                                    ? null
                                    : _navigateToSummaryScreen,
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                label: const Text('Lihat Semua'),
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                ),
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 96),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final transaction = _transactions[index];
                                return TransactionCard(
                                  transaction: transaction,
                                  onEdit: () => _navigateToEditScreen(transaction),
                                  onDelete: () =>
                                      _confirmDeleteTransaction(transaction),
                                );
                              },
                              childCount: _transactions.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _navigateToAddScreen,
          tooltip: 'Tambah Transaksi',
          icon: const Icon(Icons.add),
          label: const Text('Tambah'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
      ),
    );
  }
}
