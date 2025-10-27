import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> initAppDirectory() async {
  // Fungsi ini hanya dijalankan di platform selain web
  try {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS && !Platform.isAndroid && !Platform.isIOS) {
      // Jika di web, tidak perlu inisialisasi path provider
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    debugPrint('App directory initialized: ${directory.path}');
  } catch (e) {
    debugPrint('Skipping directory initialization (likely running on web): $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppDirectory();
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const ExpenseHomePage(),
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  double totalBalance = 0;
  final List<Map<String, dynamic>> transactions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Total Saldo',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${totalBalance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final trx = transactions[index];
                return ListTile(
                  title: Text(trx['category']),
                  subtitle: Text(trx['date']),
                  trailing: Text('Rp ${trx['amount']}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addTransaction() {
    setState(() {
      transactions.add({
        'category': 'Belanja',
        'amount': 50000,
        'date': DateTime.now().toString().split(' ')[0],
      });
      totalBalance -= 50000;
    });
  }
}
