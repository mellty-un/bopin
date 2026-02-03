import 'dart:io';
import 'package:aplikasi_peminjaman_alat/core/services/alat_service.dart';
import 'package:aplikasi_peminjaman_alat/core/services/kategori_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class AlatDialog extends StatefulWidget {
  final Map<String, dynamic>? alat;
  final bool isEdit;
  final VoidCallback? onSuccess;

  const AlatDialog({
    super.key, 
    this.alat, 
    this.isEdit = false,
    this.onSuccess,
  });

  @override
  State<AlatDialog> createState() => _AlatDialogState();
}

class _AlatDialogState extends State<AlatDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _stokTotalController = TextEditingController();
  final _stokTersediaController = TextEditingController();
  final AlatService _alatService = AlatService();
  final KategoriService _kategoriService = KategoriService();

  final List<String> _kondisiOptions = ['Baik', 'Rusak'];
  String? _selectedKondisi;

  List<Map<String, dynamic>> _kategoriOptions = [];
  int? _selectedKategoriId;

  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  
  File? _selectedImageFile;       
  String? _existingImageName;      
  String? _newImageName;           
  
  final ImagePicker _picker = ImagePicker();
  Uint8List? _webImageBytes;      

  @override
  void initState() {
    super.initState();
    _loadKategori();
    _initializeData();
  }

  void _initializeData() {
    if (widget.isEdit && widget.alat != null) {
      _namaController.text = widget.alat!['nama_alat'] ?? widget.alat!['nama'] ?? '';
      _stokTotalController.text = widget.alat!['stok_total']?.toString() ?? '0';
      _stokTersediaController.text = widget.alat!['stok_tersedia']?.toString() ?? '0';
      
      final kondisi = widget.alat!['kondisi'] ?? 'Baik';
      _selectedKondisi = _kondisiOptions.contains(kondisi) ? kondisi : 'Baik';
      
      _selectedKategoriId = widget.alat!['id_kategori'];
      
      _existingImageName = widget.alat!['gambar'];
    } else {
      _selectedKondisi = 'Baik';
      _selectedKategoriId = null;
      _stokTotalController.text = '0';
      _stokTersediaController.text = '0';
    }
  }

  Future<void> _loadKategori() async {
    try {
      final kategori = await _kategoriService.getAllKategoriForDropdown();
      setState(() {
        _kategoriOptions = kategori;
      });
    } catch (e) {
      print('Error loading kategori: $e');
    }
  }

  List<DropdownMenuItem<int>> _buildKategoriItems() {
    return _kategoriOptions.map<DropdownMenuItem<int>>((e) {
      final kategoriId = e['id_kategori'] as int? ?? 0;
      final kategoriName = e['nama_kategori']?.toString() ?? 'Unknown';
      return DropdownMenuItem<int>(
        value: kategoriId,
        child: Text(kategoriName, overflow: TextOverflow.ellipsis),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildKondisiItems() {
    return _kondisiOptions.map<DropdownMenuItem<String>>((e) {
      return DropdownMenuItem<String>(
        value: e,
        child: Text(e, overflow: TextOverflow.ellipsis),
      );
    }).toList();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isUploading = true;
          _errorMessage = null;
        });

        if (kIsWeb) {
          // UNTUK WEB: Baca bytes gambar
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _selectedImageFile = null; 
            _isUploading = false;
          });
        } else {
          setState(() {
            _selectedImageFile = File(image.path);
            _webImageBytes = null; 
            _isUploading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'Gagal memilih gambar: ${e.toString().replaceAll("Exception: ", "")}';
      });
    }
  }

  // ================= SAVE ALAT =================
Future<void> _saveAlat() async {
  setState(() => _errorMessage = null);

  // ================= VALIDASI WAJIB =================
  if (!_formKey.currentState!.validate()) return;

  // Cek gambar wajib
  if (_selectedImageFile == null && _webImageBytes == null && (_existingImageName == null || _existingImageName!.isEmpty)) {
    setState(() => _errorMessage = 'Gambar wajib dipilih');
    return;
  }

  // Cek stok
  final stokTotal = int.tryParse(_stokTotalController.text) ?? 0;
  final stokTersedia = int.tryParse(_stokTersediaController.text) ?? 0;
  if (stokTersedia > stokTotal) {
    setState(() => _errorMessage = 'Stok tersedia tidak boleh lebih dari stok total');
    return;
  }

  setState(() => _isLoading = true);

  try {
    String? finalImageName = _existingImageName;

    // ================= UPLOAD IMAGE =================
    if (_selectedImageFile != null || _webImageBytes != null) {
      setState(() => _isUploading = true);

      if (kIsWeb && _webImageBytes != null) {
        finalImageName = await _alatService.uploadImageBytes(_webImageBytes!);
      } else if (!kIsWeb && _selectedImageFile != null) {
        finalImageName = await _alatService.uploadImage(_selectedImageFile!);
      }

      setState(() => _isUploading = false);
    }

    // ================= SAVE DATA =================
    if (widget.isEdit && widget.alat != null) {
      final id = widget.alat!['id_alat'] ?? widget.alat!['id'];
      await _alatService.updateAlat(
        idAlat: id is String ? int.parse(id) : id,
        namaAlat: _namaController.text.trim(),
        idKategori: _selectedKategoriId!,
        kondisi: _selectedKondisi!,
        gambar: finalImageName,
        stokTotal: stokTotal,
        stokTersedia: stokTersedia,
      );
    } else {
      await _alatService.createAlat(
        namaAlat: _namaController.text.trim(),
        idKategori: _selectedKategoriId!,
        kondisi: _selectedKondisi!,
        gambar: finalImageName,
        stokTotal: stokTotal,
        stokTersedia: stokTersedia,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
    widget.onSuccess?.call();
    SuccessPopup.show(context, widget.isEdit ? 'Alat berhasil diupdate!' : 'Alat berhasil ditambahkan!');
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isUploading = false;
      _errorMessage = 'Gagal menyimpan: ${e.toString().replaceAll('Exception: ', '')}';
    });
  }
}

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wajib diisi';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Harus berupa angka';
    }
    if (number < 0) {
      return 'Tidak boleh negatif';
    }
    return null;
  }

  Widget _buildImagePreview() {
    if (_isUploading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedImageFile != null) {
      return Image.file(
        _selectedImageFile!,
        fit: BoxFit.cover,
      );
    } else if (_webImageBytes != null) {
      return Image.memory(
        _webImageBytes!,
        fit: BoxFit.cover,
      );
    }
    
    else if (_existingImageName != null && _existingImageName!.isNotEmpty) {
      final imageUrl = _alatService.getImageUrl(_existingImageName);
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading existing image: $error');
          return _buildImagePlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
      );
    }
    
    else {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 45,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          Text(
            'Pilih gambar',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFEBEFF2),
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.98,
        constraints: const BoxConstraints(maxWidth: 650),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dialog
                Center(
                  child: Text(
                    widget.isEdit ? 'Edit Alat' : 'Tambah Alat',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Error message
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Form Nama
                const Text(
                  'Nama',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _namaController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFEBEFF2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFEBEFF2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF3A587A),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    errorStyle: const TextStyle(fontSize: 11),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kategori dan Kondisi dropdown
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kategori',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            value: _selectedKategoriId,
                            items: _buildKategoriItems(),
                            onChanged: (value) {
                              setState(() {
                                _selectedKategoriId = value;
                              });
                            },
                            decoration: _inputDecoration(),
                            dropdownColor: Colors.white,
                            validator: (value) =>
                                value == null || value == 0 ? 'Kategori wajib dipilih' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kondisi',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _selectedKondisi,
                            items: _buildKondisiItems(),
                            onChanged: (value) {
                              setState(() => _selectedKondisi = value);
                            },
                            decoration: _inputDecoration(),
                            dropdownColor: Colors.white,
                            validator: (value) =>
                                value == null ? 'Kondisi wajib dipilih' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stok Total dan Stok Tersedia
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stok Total',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _stokTotalController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 14),
                            decoration: _inputDecoration().copyWith(
                              hintText: '',
                            ),
                            validator: (value) => _validateNumber(value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stok Tersedia',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _stokTersediaController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 14),
                            decoration: _inputDecoration().copyWith(
                              hintText: '',
                            ),
                            validator: (value) => _validateNumber(value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                
                const Text(
                  'Gambar',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),

                if (widget.isEdit && _existingImageName != null && _selectedImageFile == null && _webImageBytes == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Gambar saat ini: $_existingImageName',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: _isUploading ? null : _pickImage,
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 220,
                      height: 140,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFEBEFF2)),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildImagePreview(),
                        ),
                      ),
                    ),
                  ),
                ),

                // Tombol hapus gambar (jika ada gambar yang sudah ada)
                if (widget.isEdit && _existingImageName != null && (_selectedImageFile != null || _webImageBytes != null))
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedImageFile = null;
                          _webImageBytes = null;
                        });
                      },
                      child: Text(
                        'Batalkan gambar baru',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Tombol Batal dan Simpan
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_isLoading || _isUploading) ? null : _saveAlat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A587A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading || _isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Simpan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DeleteAlatConfirmationDialog extends StatefulWidget {
  final String alatName;
  final String alatId;
  final VoidCallback? onSuccess;

  const DeleteAlatConfirmationDialog({
    super.key,
    required this.alatName,
    required this.alatId,
    this.onSuccess,
  });

  @override
  State<DeleteAlatConfirmationDialog> createState() =>
      _DeleteAlatConfirmationDialogState();
}

class _DeleteAlatConfirmationDialogState
    extends State<DeleteAlatConfirmationDialog> {
  final AlatService _alatService = AlatService();
  bool _isDeleting = false;
  String? _errorMessage;

  Future<void> _handleDelete() async {
    if (_isDeleting) return;
    
    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      final id = int.tryParse(widget.alatId) ?? 0;
      await _alatService.deleteAlat(id);

      if (!mounted) return;

      Navigator.of(context).pop(true);
      widget.onSuccess?.call();

      SuccessPopup.show(context, 'Alat berhasil dihapus!');
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isDeleting = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Hapus",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            Text(
              'Apakah kamu yakin ingin menghapus alat ini?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isDeleting
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFEBEFF2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Batal",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEBEFF2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _isDeleting ? null : _handleDelete,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFF3A587A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Hapus",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF3A587A)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF3A587A)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF3A587A), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    errorStyle: const TextStyle(fontSize: 11),
  );
}