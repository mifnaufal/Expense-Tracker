import 'dart:convert';
<<<<<<< HEAD
import 'dart:typed_data';
=======
import 'dart:io';

>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
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

<<<<<<< HEAD
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
=======
class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  static const String _otherCategoryLabel = 'Lainnya';
  static const List<String> _predefinedCategories = [
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
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

<<<<<<< HEAD
  bool get _isEditing => widget.initialTransaction != null;
  bool get _isOther => _selectedCategory == 'Lainnya';
=======
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
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
=======
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

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
    _animationController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount % 1 == 0) {
      return amount.toStringAsFixed(0);
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

<<<<<<< HEAD
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
=======
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
            SnackBar(
              content: const Text('Kamera tidak tersedia di perangkat ini.'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
          SnackBar(
            content: const Text('Gagal mengambil gambar. Coba lagi.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Pilih Sumber Gambar',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_supportsCamera)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.photo_camera_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('Ambil Foto'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.camera);
                  },
                )
              else
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.no_photography_outlined,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  title: const Text('Kamera tidak tersedia'),
                  subtitle: const Text('Gunakan galeri untuk mengunggah bukti.'),
                  enabled: false,
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final Uint8List? bytes =
        _selectedImageBytes ?? widget.initialTransaction?.imageBytes;
    if (bytes != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(bytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImageBytes = null;
                  _selectedImagePath = null;
                  _existingImageBase64 = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 40,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 8),
        Text(
          'Foto Bukti',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
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
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
    );

    try {
      await widget.onSubmit(newTx);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
<<<<<<< HEAD
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
=======
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Gagal menyimpan transaksi. Coba lagi.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _type == TransactionType.pemasukan
        ? Colors.greenAccent.shade700
        : Colors.redAccent.shade700;

    return Scaffold(
<<<<<<< HEAD
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
=======
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          _isEditing ? 'Edit Transaksi' : 'Tambah Transaksi Baru',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _isSubmitting ? null : _submitData,
              tooltip: 'Simpan',
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Type Toggle
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = TransactionType.pemasukan;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.pemasukan
                                  ? Colors.green
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Pemasukan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedType == TransactionType.pemasukan
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = TransactionType.pengeluaran;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.pengeluaran
                                  ? Colors.red
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Pengeluaran',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedType == TransactionType.pengeluaran
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Amount Field
                Text(
                  'Jumlah',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Rp 0',
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.attach_money,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                ),
                const SizedBox(height: 24),
                
                // Description Field
                Text(
                  'Deskripsi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Tambahkan deskripsi',
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                
                // Category Field
                Text(
                  'Kategori',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
<<<<<<< HEAD
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
=======
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(_selectedCategory),
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Pilih kategori',
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.category_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                ),
                if (_isCustomCategory) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _customCategoryController,
                      decoration: InputDecoration(
                        labelText: 'Kategori Lainnya',
                        hintText: 'Contoh: Hadiah, Freelance, dll.',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: (value) {
                        if (_isCustomCategory &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Silakan isi kategori lainnya';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                
                // Date Field
                Text(
                  'Tanggal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      DateFormat('d MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    onTap: _presentDatePicker,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Image Field
                Text(
                  'Bukti Transaksi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImagePreview(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Pilih Gambar'),
                    onPressed: _showImageSourceActionSheet,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submitData,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _selectedType == TransactionType.pemasukan
                          ? Colors.green
                          : Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isEditing ? 'Perbarui Transaksi' : 'Simpan Transaksi',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
>>>>>>> de57ef109e9ea1ae1020527f4ef82d98b8efe4f8
            ),
          ),
        ],
      ),
    );
  }
}
