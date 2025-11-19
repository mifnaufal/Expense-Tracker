import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _imagePath;
  bool _isSubmitting = false;

  TransactionType _type = TransactionType.pengeluaran;
  DateTime _date = DateTime.now();
  late String _selectedCategory;

  static const List<String> _categories = [
    'Makanan',
    'Transport',
    'Belanja',
    'Tagihan',
    'Gaji',
    'Bonus',
    'Investasi',
    'Kesehatan',
    'Hiburan',
    'Lainnya'
  ];

  bool get _isEditing => widget.initialTransaction != null;
  bool get _isOther => _selectedCategory == 'Lainnya';

  @override
  void initState() {
    super.initState();
    final tx = widget.initialTransaction;
    if (tx != null) {
      _titleController.text = tx.title;
      _amountController.text = tx.amount.toString();
      _type = tx.type;
      _date = tx.date;
      _selectedCategory = tx.category;
      if (tx.imageBytes != null) _imageBytes = tx.imageBytes;
    } else {
      _selectedCategory = _categories.first;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source, maxWidth: 800);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imagePath = kIsWeb ? null : file.path;
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final newTx = TransactionModel(
      id: widget.initialTransaction?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      category: _isOther
          ? _customCategoryController.text.trim()
          : _selectedCategory,
      date: _date,
      type: _type,
      imagePath: _imagePath,
      imageBase64: _imageBytes != null ? base64Encode(_imageBytes!) : null,
    );

    try {
      await widget.onSubmit(newTx);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _type == TransactionType.pemasukan
        ? Colors.greenAccent.shade700
        : Colors.redAccent.shade700;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Deskripsi
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Jumlah
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Jumlah (Rp)',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Masukkan jumlah';
                      final val = double.tryParse(v);
                      if (val == null || val <= 0) {
                        return 'Jumlah tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Jenis transaksi toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: _type == TransactionType.pemasukan
                                ? accentColor
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () => setState(
                                () => _type = TransactionType.pemasukan),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  'Pemasukan',
                                  style: GoogleFonts.poppins(
                                    color: _type == TransactionType.pemasukan
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: _type == TransactionType.pengeluaran
                                ? accentColor
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () => setState(
                                () => _type = TransactionType.pengeluaran),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  'Pengeluaran',
                                  style: GoogleFonts.poppins(
                                    color: _type == TransactionType.pengeluaran
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Pilih kategori
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Kategori',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: accentColor,
                        labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87),
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  if (_isOther) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customCategoryController,
                      decoration: InputDecoration(
                        labelText: 'Kategori Lainnya',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        if (_isOther && (v == null || v.isEmpty)) {
                          return 'Isi kategori lainnya';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Pilih tanggal
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tanggal: ${DateFormat('d MMM yyyy').format(_date)}',
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                      ),
                      TextButton(
                        onPressed: _pickDate,
                        child: const Text('Pilih'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Foto bukti
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _imageBytes == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_rounded,
                                    color: Colors.grey[500], size: 40),
                                const SizedBox(height: 8),
                                Text('Tambah Foto Bukti',
                                    style:
                                        TextStyle(color: Colors.grey[600])),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(_imageBytes!,
                                  fit: BoxFit.cover, width: double.infinity),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tombol simpan di bawah
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              icon: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _isSubmitting ? 'Menyimpan...' : 'Simpan Transaksi',
                style: GoogleFonts.poppins(fontSize: 17),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSubmitting ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}
