// lib/widgets/transaction_card.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

enum _TransactionMenuAction { edit, delete }

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // ... (logic warna dan ikon tidak berubah) ...
    final bool isExpense = transaction.type == TransactionType.pengeluaran;
    final Color amountColor = isExpense ? Colors.red : Colors.green;
    final IconData iconData =
        isExpense ? Icons.arrow_downward : Icons.arrow_upward;
    final String prefix = isExpense ? '- Rp' : '+ Rp';
    final bool hasActions = onEdit != null || onDelete != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: amountColor.withValues(alpha: 0.1),
          child: Icon(
            iconData,
            color: amountColor,
            size: 24,
          ),
        ),
        title: Text(
          transaction.title, // 'Makan Siang'
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          // Gunakan category jika ingin, atau tetap tanggal
          '${transaction.category} • ${DateFormat('d MMM yyyy').format(transaction.date)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$prefix ${transaction.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            if (hasActions) ...[
              const SizedBox(width: 4),
              PopupMenuButton<_TransactionMenuAction>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (action) {
                  switch (action) {
                    case _TransactionMenuAction.edit:
                      onEdit?.call();
                      break;
                    case _TransactionMenuAction.delete:
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem<_TransactionMenuAction>(
                      value: _TransactionMenuAction.edit,
                      child: Text('Edit'),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem<_TransactionMenuAction>(
                      value: _TransactionMenuAction.delete,
                      child: Text('Hapus'),
                    ),
                ],
              ),
            ]
          ],
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
                  title: const Text("Bukti Transaksi"),
                  actions: [
                    TextButton(
                      child: const Text('Tutup'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              );
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      'File gambar tidak ditemukan di path: ${transaction.imagePath}',
                    ),
                  ),
                );
            }
          }
        },
        onLongPress: onEdit,
      ),
    );
  }
}