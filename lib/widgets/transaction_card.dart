// lib/widgets/transaction_card.dart

import 'dart:io'; // <-- Tambahkan import ini
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ... (logic warna dan ikon tidak berubah) ...
    final bool isExpense = transaction.type == TransactionType.pengeluaran;
    final Color amountColor = isExpense ? Colors.red : Colors.green;
    final IconData iconData =
        isExpense ? Icons.arrow_downward : Icons.arrow_upward;
    final String prefix = isExpense ? '- Rp' : '+ Rp';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: amountColor.withOpacity(0.1),
          child: Icon(
            iconData,
            color: amountColor,
            size: 24,
          ),
        ),
        title: Text(
          transaction.title, // 'Makan Siang'
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          // Gunakan category jika ingin, atau tetap tanggal
          '${transaction.category} • ${DateFormat('d MMM yyyy').format(transaction.date)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          '$prefix ${transaction.amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        onTap: () {
          // --- PERUBAHAN DI SINI ---
          // Cek 'imagePath' (String), bukan 'imageFile' (File)
          if (transaction.imagePath != null && transaction.imagePath!.isNotEmpty) {
            
            // Asumsi: imagePath adalah path file di device
            final File imageFile = File(transaction.imagePath!);

            // Cek apakah file-nya ada sebelum ditampilkan
            if (imageFile.existsSync()) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: Image.file(imageFile),
                  title: Text("Bukti Transaksi"),
                  actions: [
                    TextButton(
                      child: Text('Tutup'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              );
            } else {
              print("File gambar tidak ditemukan di path: ${transaction.imagePath}");
              // (Opsional: Tampilkan snackbar error)
            }
          }
          // Jika imagePath null (seperti di JSON kamu), tidak terjadi apa-apa
        },
      ),
    );
  }
}