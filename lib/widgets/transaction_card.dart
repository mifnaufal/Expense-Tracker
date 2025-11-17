// lib/widgets/transaction_card.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../utils/file_utils.dart';

enum _TransactionMenuAction { edit, delete, share }

class TransactionCard extends StatefulWidget {
  final TransactionModel transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isExpense = widget.transaction.type == TransactionType.pengeluaran;
    final Color amountColor =
        isExpense ? colorScheme.error : colorScheme.tertiary;
    final IconData iconData =
        isExpense ? Icons.arrow_downward : Icons.arrow_upward;
    final String prefix = isExpense ? '- Rp' : '+ Rp';
    final bool hasActions = widget.onEdit != null || widget.onDelete != null || widget.onShare != null;
    final bool hasImage = widget.transaction.imageBytes != null || 
                         (widget.transaction.imagePath != null && widget.transaction.imagePath!.isNotEmpty);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() {
                _isPressed = true;
              });
              _animationController.forward();
            },
            onTapUp: (_) {
              setState(() {
                _isPressed = false;
              });
              _animationController.reverse();
              _showAttachment(context);
            },
            onTapCancel: () {
              setState(() {
                _isPressed = false;
              });
              _animationController.reverse();
            },
            onLongPress: widget.onEdit,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isPressed ? 0.15 : 0.05),
                    blurRadius: _isPressed ? 8 : 4,
                    offset: Offset(0, _isPressed ? 2 : 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: amountColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            iconData,
                            color: amountColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.transaction.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.transaction.category,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$prefix ${widget.transaction.amount.toStringAsFixed(0)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: amountColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('d MMM yyyy').format(widget.transaction.date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                        if (hasActions) ...[
                          const SizedBox(width: 8),
                          _buildMenuButton(context),
                        ],
                      ],
                    ),
                    if (hasImage) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Bukti tersedia',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.touch_app,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ketuk untuk lihat',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<_TransactionMenuAction>(
      icon: Icon(
        Icons.more_vert,
        size: 20,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      onSelected: (action) {
        switch (action) {
          case _TransactionMenuAction.edit:
            widget.onEdit?.call();
            break;
          case _TransactionMenuAction.delete:
            widget.onDelete?.call();
            break;
          case _TransactionMenuAction.share:
            widget.onShare?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (widget.onEdit != null)
          PopupMenuItem<_TransactionMenuAction>(
            value: _TransactionMenuAction.edit,
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18),
                const SizedBox(width: 12),
                const Text('Edit'),
              ],
            ),
          ),
        if (widget.onShare != null)
          PopupMenuItem<_TransactionMenuAction>(
            value: _TransactionMenuAction.share,
            child: Row(
              children: [
                Icon(Icons.share_outlined, size: 18),
                const SizedBox(width: 12),
                const Text('Bagikan'),
              ],
            ),
          ),
        if (widget.onDelete != null)
          PopupMenuItem<_TransactionMenuAction>(
            value: _TransactionMenuAction.delete,
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                const SizedBox(width: 12),
                Text('Hapus', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _showAttachment(BuildContext context) async {
    final Uint8List? bytes = widget.transaction.imageBytes;
    if (bytes != null) {
      await _showImageDialog(context, bytes);
      return;
    }

    final imagePath = widget.transaction.imagePath;
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    if (!fileExists(imagePath)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('File gambar tidak ditemukan di $imagePath'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
          SnackBar(
            content: const Text('Gagal memuat bukti transaksi dari file lokal.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      return;
    }

    await _showImageDialog(context, fallbackBytes);
  }

  Future<void> _showImageDialog(BuildContext context, Uint8List imageBytes) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bukti Transaksi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Flexible(
              child: InteractiveViewer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}