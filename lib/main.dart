import 'package:flutter/material.dart';
import 'package:expense_tracker/services/local_storage_service.dart';
import 'package:expense_tracker/models/transaction_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Coba baca file JSON
  final transactions = await LocalStorageService.readTransactions();

  // Coba tulis ulang ke file lokal
  await LocalStorageService.writeTransactions(transactions);

  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      home: Scaffold(
        appBar: AppBar(title: const Text('Expense Tracker')),
        body: const Center(child: Text('Setup Awal Berhasil')),
      ),
    );
  }
}
