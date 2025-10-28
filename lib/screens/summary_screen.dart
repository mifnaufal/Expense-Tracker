import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class SummaryScreen extends StatelessWidget {
  final List<TransactionModel> transactions;

  const SummaryScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Di sini kamu bisa menambahkan logic untuk mengelompokkan
    // transaksi berdasarkan harian atau mingguan.
    // Untuk saat ini, kita tampilkan placeholder.

    // TODO: Implement grouping logic
    double totalHarian = 0; // Hitung total hari ini
    double totalMingguan = 0; // Hitung total 7 hari terakhir

    return Scaffold(
      appBar: AppBar(
        title: Text('Ringkasan Keuangan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Sederhana',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 20),
              Card(
                child: ListTile(
                  title: Text('Total Pengeluaran Hari Ini'),
                  trailing: Text(
                    'Rp $totalHarian',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('Total Pengeluaran Minggu Ini'),
                  trailing: Text(
                    'Rp $totalMingguan',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: Text(
                  '(Grafik sederhana bisa ditambahkan di sini)',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
              // (Opsional: Tambahkan package 'charts_flutter' untuk grafik)
            ],
          ),
        ),
      ),
    );
  }
}