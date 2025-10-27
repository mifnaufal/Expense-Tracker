import 'package:flutter/material.dart';
import 'package:expense_tracker/services/local_storage_service.dart';
import 'package:expense_tracker/models/transaction_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ambil data transaksi
  final transactions = await LocalStorageService.readTransactions();

  runApp(ExpenseTrackerApp(transactions: transactions));
}

class ExpenseTrackerApp extends StatelessWidget {
  final List<TransactionModel> transactions;

  const ExpenseTrackerApp({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: HomeScreen(transactions: transactions),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<TransactionModel> transactions;

  const HomeScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: transactions.isEmpty
          ? const Center(
              child: Text(
                'Belum ada transaksi',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(tx.title),
                    subtitle: Text(
                        "${tx.category} • ${tx.date.toLocal().toString().split(' ')[0]}"),
                    trailing: Text(
                      'Rp ${tx.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
