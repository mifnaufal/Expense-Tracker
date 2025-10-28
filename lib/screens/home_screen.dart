// lib/screens/home_screen.dart

import 'package:flutter/material.dart';

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
      final updatedTransactions = await _storageService.addTransaction(newTx);
      if (!mounted) return;
      _setTransactions(updatedTransactions);
      _showSnackBar('Transaksi berhasil ditambahkan');
    } catch (e) {
      if (!mounted) return;
      debugPrint('Gagal menambahkan transaksi: $e');
      _showSnackBar('Gagal menambahkan transaksi: $e');
    }
  }

  void _navigateToAddScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddTransactionScreen(
          onSubmit: _addTransaction,
        ),
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
      final updatedTransactions = await _storageService.updateTransaction(updatedTransaction);
      if (!mounted) return;
      _setTransactions(updatedTransactions);
      _showSnackBar('Transaksi berhasil diperbarui');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal memperbarui transaksi');
    }
  }

  Future<void> _deleteTransaction(String transactionId) async {
    try {
      final updatedTransactions = await _storageService.deleteTransaction(transactionId);
      if (!mounted) return;
      _setTransactions(updatedTransactions);
      _showSnackBar('Transaksi berhasil dihapus');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal menghapus transaksi');
    }
  }

  void _confirmDeleteTransaction(TransactionModel transaction) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text('Apakah kamu yakin ingin menghapus "${transaction.title}"?'),
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
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: _navigateToSummaryScreen,
            tooltip: 'Ringkasan',
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      )
                    ],
                  ),
                ),
                // 3. Daftar Transaksi (Scrollable)
                Expanded(
                  child: _transactions.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada transaksi.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _transactions.length,
                          itemBuilder: (ctx, index) {
                            final transaction = _transactions[index];
                            return TransactionCard(
                              transaction: transaction,
                              onEdit: () => _navigateToEditScreen(transaction),
                              onDelete: () => _confirmDeleteTransaction(transaction),
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
    );
  }
}