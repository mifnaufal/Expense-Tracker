import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/transaction_model.dart';
import '../services/local_storage_service.dart';
import '../widgets/balance_summary.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';
import 'summary_screen.dart';


final MaterialColor primaryColor = MaterialColor(0xFF2196F3, <int, Color>{
  50: Color(0xFFE3F2FD),
  100: Color(0xFFBBDEFB),
  200: Color(0xFF90CAF9),
  300: Color(0xFF64B5F6),
  400: Color(0xFF42A5F5),
  500: Color(0xFF2196F3),
  600: Color(0xFF1E88E5),
  700: Color(0xFF1976D2),
  800: Color(0xFF1565C0),
  900: Color(0xFF0D47A1),
});

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
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: primaryColor,
        // Menambahkan warna primer dan aksen
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.orange,
        ),
        // Memastikan AppBar menggunakan warna primer
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        // Memastikan FloatingActionButton menggunakan warna aksen
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Expense Tracker'),
          actions: [
            IconButton(
              icon: Icon(Icons.bar_chart),
              onPressed: _navigateToSummaryScreen,
              tooltip: 'Ringkasan',
            ),
            IconButton(
              icon: Icon(Icons.download),
              onPressed: _exportTransactions,
              tooltip: 'Ekspor JSON',
            ),
          ],
        ),
        // 5. Tampilkan loading indicator jika data sedang dimuat
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 1. Total Saldo
                  BalanceSummary(
                    totalBalance: _totalBalance,
                    totalIncome: _totalIncome,
                    totalExpense: _totalExpense,
                  ),
                  // 2. Judul Daftar Transaksi
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaksi Terakhir',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToSummaryScreen,
                          child: Text('Lihat Semua'),
                        ),
                      ],
                    ),
                  ),
                  // 3. Daftar Transaksi (Scrollable)
                  Expanded(
                    child: _transactions.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada transaksi.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _transactions.length,
                            itemBuilder: (ctx, index) {
                              final transaction = _transactions[index];
                              return TransactionCard(
                                transaction: transaction,
                                onEdit: () =>
                                    _navigateToEditScreen(transaction),
                                onDelete: () =>
                                    _confirmDeleteTransaction(transaction),
                              );
                            },
                          ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddScreen,
          tooltip: 'Tambah Transaksi',
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
