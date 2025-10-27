import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final Function(TransactionModel) onSave;
  // final TransactionModel? transactionToEdit; // (Opsional untuk fitur edit)

  const AddTransactionScreen({
    Key? key,
    required this.onSave,
    // this.transactionToEdit,
  }) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  // 1. TAMBAHKAN CONTROLLER UNTUK KATEGORI
  final _categoryController = TextEditingController(); 

  TransactionType _selectedType = TransactionType.pengeluaran;
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    // 2. JANGAN LUPA DISPOSE CONTROLLER BARU
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan DatePicker
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

  // Fungsi untuk mengambil gambar (dari kamera atau galeri)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600, // Mengurangi ukuran file
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Gagal mengambil gambar: $e");
      // Tampilkan snackbar error
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galeri'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Kamera'),
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

  // Fungsi untuk menyimpan form
  void _submitData() {
    if (!_formKey.currentState!.validate()) {
      return; // Validasi gagal
    }

    final String title = _titleController.text;
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    // 3. AMBIL VALUE KATEGORI DARI CONTROLLER
    final String category = _categoryController.text;

    if (title.isEmpty || amount <= 0 || category.isEmpty) {
      return;
    }

    // 4. PERBAIKI KONSTRUKTOR TransactionModel
    final newTransaction = TransactionModel(
      id: DateTime.now().toString(), // ID unik sementara
      title: title,
      amount: amount,
      category: category,           // <-- MASUKKAN KATEGORI
      date: _selectedDate,
      type: _selectedType,
      imagePath: _selectedImage?.path, // <-- GANTI 'imageFile' JADI 'imagePath'
    );

    widget.onSave(newTransaction); // Kirim data kembali ke HomeScreen
    Navigator.of(context).pop(); // Tutup layar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Transaksi Baru'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submitData,
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
              // Input Deskripsi/Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
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
SizedBox(height: 16),
              // Input Jumlah
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
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
SizedBox(height: 16),
              // 5. TAMBAHKAN INPUT FIELD UNTUK KATEGORI
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Kategori (cth: Makanan, Gaji, Transport)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori tidak boleh kosong';
                  }
                  return null;
                },
              ),
SizedBox(height: 16),
              // 6. GANTI NAMA LABEL DROPDOWN INI
              DropdownButtonFormField<TransactionType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Tipe Transaksi', // <-- GANTI LABEL
                  border: OutlineInputBorder(),
                ),
                items: [
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
SizedBox(height: 16),
              // Input Tanggal (DatePicker)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tanggal: ${DateFormat('d MMMM yyyy').format(_selectedDate)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: Text(
                      'Pilih Tanggal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              'Foto Bukti',
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.camera_alt),
                      label: Text('Ambil Foto'),
                      onPressed: _showImageSourceActionSheet,
                    ),
                  ),
                ],
              ),
SizedBox(height: 32),
              // Tombol Simpan
              ElevatedButton(
                onPressed: _submitData,
                child: Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}