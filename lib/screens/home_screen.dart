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

class _HomeScreenState extends State<HomeScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
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
    } catch (e) {
      _showSnackBar('Gagal menambahkan transaksi: $e');
    }
  }

  Future<void> _editTransaction(TransactionModel updatedTransaction) async {
    try {
      final result = await _storageService.updateTransaction(updatedTransaction);
      if (!mounted) return;
      _setTransactions(result.transactions);
      _showSnackBar('Transaksi diperbarui ✅');
    } catch (e) {
      _showSnackBar('Gagal memperbarui transaksi');
    }
  }

  Future<void> _deleteTransaction(String id) async {
    try {
      final result = await _storageService.deleteTransaction(id);
      if (!mounted) return;
      _setTransactions(result.transactions);
      _showSnackBar('Transaksi dihapus 🗑️');
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
        title: const Text('Hapus Transaksi'),
        content: Text('Yakin ingin menghapus "${tx.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTransaction(tx.id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}
