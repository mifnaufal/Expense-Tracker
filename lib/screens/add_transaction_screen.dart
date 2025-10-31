import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final Future<void> Function(TransactionModel) onSubmit;
  final TransactionModel? initialTransaction;

  const AddTransactionScreen({
    super.key,
    required this.onSubmit,
    this.initialTransaction,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  static const String _otherCategoryLabel = 'Lainnya';
  static const List<String> _predefinedCategories = [
    'Makanan',
    'Transport',
    'Belanja',
    'Tagihan',
    'Gaji',
    'Bonus',
    'Investasi',
    'Pendidikan',
    'Kesehatan',
    'Hiburan',
    _otherCategoryLabel,
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();

  TransactionType _selectedType = TransactionType.pengeluaran;
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  String? _existingImagePath;
  bool _isSubmitting = false;
  late String _selectedCategory;

  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.initialTransaction != null;
  bool get _isCustomCategory => _selectedCategory == _otherCategoryLabel;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _predefinedCategories.first;
    final transaction = widget.initialTransaction;
    if (transaction != null) {
      _titleController.text = transaction.title;
      _amountController.text = _formatAmount(transaction.amount);
      _selectedType = transaction.type;
      _selectedDate = transaction.date;
      _existingImagePath = transaction.imagePath;

      final match = _predefinedCategories.firstWhere(
        (category) => category.toLowerCase() == transaction.category.toLowerCase(),
        orElse: () => _otherCategoryLabel,
      );

      _selectedCategory = match;
      if (_isCustomCategory) {
        _customCategoryController.text = transaction.category;
      }
    } else {
      _selectedCategory = _predefinedCategories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount % 1 == 0) {
      return amount.toStringAsFixed(0);
    }
    return amount.toStringAsFixed(2);
  }

  Future<void> _presentDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _existingImagePath = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Gagal mengambil gambar. Coba lagi.')),
        );
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Kamera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
      );
    }
    if (_existingImagePath != null && _existingImagePath!.isNotEmpty) {
      final file = File(_existingImagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
        );
      }
    }
    return const Center(
      child: Text(
        'Foto Bukti',
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _submitData() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String title = _titleController.text.trim();
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final String category = _isCustomCategory
        ? _customCategoryController.text.trim()
        : _selectedCategory;

    if (title.isEmpty || amount <= 0 || category.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    final String transactionId =
        widget.initialTransaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final newTransaction = TransactionModel(
      id: transactionId,
      title: title,
      amount: amount,
      category: category,
      date: _selectedDate,
      type: _selectedType,
      imagePath: _selectedImage?.path ?? _existingImagePath,
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(newTransaction);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan transaksi. Coba lagi.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaksi' : 'Tambah Transaksi Baru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSubmitting ? null : _submitData,
            tooltip: 'Simpan',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Jumlah harus lebih besar dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedCategory),
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _predefinedCategories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCategory = value;
                    if (!_isCustomCategory) {
                      _customCategoryController.clear();
                    }
                  });
                },
              ),
              if (_isCustomCategory) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori Lainnya',
                    hintText: 'Contoh: Hadiah, Freelance, dll.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_isCustomCategory && (value == null || value.trim().isEmpty)) {
                      return 'Silakan isi kategori lainnya';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                key: ValueKey(_selectedType),
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Transaksi',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.pengeluaran,
                    child: Text('Pengeluaran'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.pemasukan,
                    child: Text('Pemasukan'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tanggal: ${DateFormat('d MMMM yyyy').format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text(
                      'Pilih Tanggal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
<<<<<<< HEAD
SizedBox(height: 16),
=======
              const SizedBox(height: 16),
>>>>>>> 87c6702623d3eba141274ba17434d417848531b3
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildImagePreview(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Ambil Foto'),
                      onPressed: _showImageSourceActionSheet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}