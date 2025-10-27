// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../widgets/balance_summary.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';
import 'summary_screen.dart';
import '../services/local_storage_service.dart'; // 1. IMPORT SERVICE

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  // 2. Hapus data dummy, ganti dengan list kosong & state loading
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  
  // Buat instance service
  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    // 3. Panggil fungsi load data saat screen pertama kali dibuka
    _loadData();
  }

  // 4. Buat fungsi async untuk load data
  Future<void> _loadData() async {
    // Ambil data dari service
    final loadedTransactions = await _storageService.loadTransactions();
    
    // Update state dengan data baru dan matikan loading
    setState(() {
      _transactions = loadedTransactions;
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

  // Update fungsi add transaction untuk memanggil 'save'
  void _addTransaction(TransactionModel newTx) {
    setState(() {
      _transactions.insert(0, newTx);
    });
    // Panggil service untuk save (walau belum diimplementasi penuh)
    _storageService.saveTransactions(_transactions);
  }

  void _navigateToAddScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddTransactionScreen(
          onSave: _addTransaction,
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
                        onPressed: () {},
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
                            return TransactionCard(transaction: _transactions[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        child: Icon(Icons.add),
        tooltip: 'Tambah Transaksi',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}