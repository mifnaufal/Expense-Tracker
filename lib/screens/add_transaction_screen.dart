import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../utils/file_utils.dart';

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
  Uint8List? _selectedImageBytes;
  String? _selectedImagePath;
  String? _existingImageBase64;
  bool _isSubmitting = false;
  late String _selectedCategory;

  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.initialTransaction != null;
  bool get _isCustomCategory => _selectedCategory == _otherCategoryLabel;
  bool get _supportsCamera {
    if (kIsWeb) {
      return false;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      default:
        return false;
    }
  }

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
      _selectedImageBytes = transaction.imageBytes;
      _selectedImagePath = transaction.imagePath;
      _existingImageBase64 = transaction.imageBase64;

      final match = _predefinedCategories.firstWhere(
        (category) =>
            category.toLowerCase() == transaction.category.toLowerCase(),
        orElse: () => _otherCategoryLabel,
      );

      _selectedCategory = match;
      if (_isCustomCategory) {
        _customCategoryController.text = transaction.category;
      }
    } else {
      _selectedCategory = _predefinedCategories.first;
    }

    if (_selectedImageBytes == null &&
        _selectedImagePath != null &&
        _selectedImagePath!.isNotEmpty &&
        !kIsWeb) {
      _hydrateExistingImage();
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

  Future<void> _hydrateExistingImage() async {
    final path = _selectedImagePath;
    if (path == null || path.isEmpty) {
      return;
    }
    final bytes = await readFileBytes(path);
    if (!mounted) return;
    if (bytes != null) {
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera && !_supportsCamera) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Kamera tidak tersedia di perangkat ini.'),
            ),
          );
        return;
      }
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImagePath = kIsWeb ? null : pickedFile.path;
          _existingImageBase64 = null;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_supportsCamera)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.no_photography_outlined),
                title: const Text('Kamera tidak tersedia'),
                subtitle: const Text('Gunakan galeri untuk mengunggah bukti.'),
                enabled: false,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final Uint8List? bytes =
        _selectedImageBytes ?? widget.initialTransaction?.imageBytes;
    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover);
    }
    return const Center(child: Text('Foto Bukti', textAlign: TextAlign.center));
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
        widget.initialTransaction?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    String? imageBase64;
    if (_selectedImageBytes != null) {
      imageBase64 = base64Encode(_selectedImageBytes!);
    } else {
      imageBase64 = _existingImageBase64;
    }

    final newTransaction = TransactionModel(
      id: transactionId,
      title: title,
      amount: amount,
      category: category,
      date: _selectedDate,
      type: _selectedType,
      imagePath: _selectedImagePath,
      imageBase64: imageBase64,
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
          const SnackBar(
            content: Text('Gagal menyimpan transaksi. Coba lagi.'),
          ),
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
          ),
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
                    return 'Jumlah tidak boleh kosong >:( )';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid >:( )';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Jumlah harus lebih besar dari 0 >:( )';
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
                    if (_isCustomCategory &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Silakan isi kategori lainnya 😁';
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
                    value: TransactionType.pemasukan,
                    child: Text('Pemasukan'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.pengeluaran,
                    child: Text('Pengeluaran'),
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
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildImagePreview(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Lampirkan Bukti'),
                      onPressed: _showImageSourceActionSheet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSubmitting ? null : _submitData,
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
