// lib/widgets/transaction_card.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../utils/file_utils.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isExpense = transaction.type == TransactionType.pengeluaran;
    final Color amountColor =
        isExpense ? colorScheme.error : colorScheme.tertiary;
    final IconData iconData =
        isExpense ? Icons.arrow_downward : Icons.arrow_upward;
    final String prefix = isExpense ? '- Rp' : '+ Rp';
    final bool hasActions = onEdit != null || onDelete != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: amountColor.withValues(alpha: 0.12),
          child: Icon(
            iconData,
            color: amountColor,
            size: 20,
          ),
        ),
        title: Text(
          transaction.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${transaction.category} • ${DateFormat('d MMM yyyy').format(transaction.date)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$prefix ${transaction.amount.toStringAsFixed(0)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w700,
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
            ],
          ],
        ),
        onTap: () => _showAttachment(context),
        onLongPress: onEdit,
      ),
    );
  }

  Future<void> _showAttachment(BuildContext context) async {
    final Uint8List? bytes = transaction.imageBytes;
    if (bytes != null) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Bukti Transaksi'),
          content: Image.memory(bytes),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
      return;
    }

    final imagePath = transaction.imagePath;
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    if (!fileExists(imagePath)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('File gambar tidak ditemukan di $imagePath'),
          ),
        );
      return;
    }

    final fallbackBytes = await readFileBytes(imagePath);
    if (!context.mounted) return;
    if (fallbackBytes == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat bukti transaksi dari file lokal.'),
          ),
        );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bukti Transaksi'),
        content: Image.memory(fallbackBytes),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}