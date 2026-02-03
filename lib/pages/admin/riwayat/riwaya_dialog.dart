import 'package:aplikasi_peminjaman_alat/core/services/riwayat_service.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:flutter/material.dart';

class RiwayatDialog extends StatefulWidget {
  final Map<String, dynamic>? riwayat;
  final bool isEdit;
  final VoidCallback? onSuccess;

  const RiwayatDialog({
    super.key,
    this.riwayat,
    this.isEdit = false,
    this.onSuccess,
  });

  @override
  State<RiwayatDialog> createState() => _RiwayatDialogState();
}

class _RiwayatDialogState extends State<RiwayatDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _catatanController = TextEditingController();
  final RiwayatService _riwayatService = RiwayatService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedKondisi;

  final List<String> _kondisiOptions = ['Baik', 'Rusak', 'Hilang'];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.riwayat != null) {
      // Set nama user
      _namaController.text = widget.riwayat!['nama_user'] ?? '';
      
      // Debug: Print data yang diterima
      print('🔍 Data riwayat yang diterima:');
      print('  id_peminjaman: ${widget.riwayat!['id_peminjaman']}');
      print('  id_pengembalian: ${widget.riwayat!['id_pengembalian']}');
      print('  nama_user: ${widget.riwayat!['nama_user']}');
      print('  kondisi_pengembalian: ${widget.riwayat!['kondisi_pengembalian']}');
      print('  kondisi: ${widget.riwayat!['kondisi']}');
      print('  catatan: ${widget.riwayat!['catatan']}');

      // Set kondisi - coba dari beberapa field
      String? kondisi;
      
      if (widget.riwayat!['kondisi_pengembalian'] != null) {
        kondisi = widget.riwayat!['kondisi_pengembalian'] as String;
      } else if (widget.riwayat!['kondisi'] != null) {
        kondisi = widget.riwayat!['kondisi'] as String;
      }
      
      if (kondisi != null && _kondisiOptions.contains(kondisi)) {
        _selectedKondisi = kondisi;
        print('✅ Kondisi ditemukan: $kondisi');
      } else {
        print('⚠️ Kondisi tidak ditemukan atau tidak valid: $kondisi');
        _selectedKondisi = 'Baik'; // Default
      }

      // Set catatan
      final catatan = widget.riwayat!['catatan'] ?? '';
      _catatanController.text = catatan;
      print('✅ Catatan: $catatan');
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  String? _validateNama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama peminjam wajib diisi';
    }
    return null;
  }

  String? _validateKondisi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kondisi wajib dipilih';
    }
    return null;
  }

  Future<void> _saveRiwayat() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    if (_selectedKondisi == null) {
      setState(() => _errorMessage = 'Kondisi harus dipilih');
      print('❌ Kondisi belum dipilih');
      return;
    }

    setState(() => _isLoading = true);
    print('🔄 Memulai proses update...');

    try {
      if (widget.isEdit && widget.riwayat != null) {
        // PERBAIKAN: Ambil id_peminjaman dari riwayat
        final idPeminjaman = widget.riwayat!['id_peminjaman'];
        final idPengembalian = widget.riwayat!['id_pengembalian'];
        
        print('📝 Data untuk update:');
        print('  id_peminjaman: $idPeminjaman');
        print('  id_pengembalian: $idPengembalian');
        print('  kondisi terpilih: $_selectedKondisi');
        print('  catatan: ${_catatanController.text.trim()}');

        if (idPeminjaman == null) {
          throw Exception('ID peminjaman tidak ditemukan');
        }

        final peminjamanId = idPeminjaman is String ? int.parse(idPeminjaman) : idPeminjaman as int;

        // OPTION 1: Jika ada id_pengembalian, update langsung
        if (idPengembalian != null) {
          final pengembalianId = idPengembalian is String ? int.parse(idPengembalian) : idPengembalian as int;
          print('🔄 Menggunakan updatePengembalian dengan ID: $pengembalianId');
          
          await _riwayatService.updatePengembalian(
            idPengembalian: pengembalianId,
            kondisiPengembalian: _selectedKondisi!,
            catatan: _catatanController.text.trim(),
          );
        } 
        // OPTION 2: Jika tidak ada id_pengembalian, coba update latest
        else {
          print('🔄 Menggunakan updateLatestPengembalian untuk peminjaman ID: $peminjamanId');
          
          await _riwayatService.updateLatestPengembalian(
            idPeminjaman: peminjamanId,
            kondisiPengembalian: _selectedKondisi!,
            catatan: _catatanController.text.trim(),
          );
        }

        if (!mounted) {
          print('⚠️ Widget tidak mounted, tidak bisa navigasi');
          return;
        }

        print('✅ Update berhasil, menutup dialog...');
        Navigator.of(context).pop(true);
        
        if (widget.onSuccess != null) {
          print('✅ Memanggil onSuccess callback');
          widget.onSuccess!();
        } else {
          print('⚠️ onSuccess callback null');
        }

        // Delay sedikit sebelum show popup untuk memastikan dialog tertutup
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (mounted) {
          SuccessPopup.show(context, 'Pengembalian berhasil diperbarui');
          print('✅ Success popup ditampilkan');
        }
      } else {
        throw Exception('Data riwayat tidak valid untuk edit');
      }
    } catch (e) {
      print('❌ Error saat save riwayat: $e');
      
      if (!mounted) {
        print('⚠️ Widget tidak mounted, tidak bisa update UI');
        return;
      }

      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });

      print('❌ Error message: $errorMsg');

      // Auto clear error after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _errorMessage == errorMsg) {
          setState(() => _errorMessage = null);
          print('ℹ️ Error message cleared');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Center(
                  child: Text(
                    widget.isEdit ? 'Edit Pengembalian' : 'Tambah Pengembalian',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Error message
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Info alat (read-only)
                if (widget.isEdit && widget.riwayat != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alat: ${widget.riwayat!['nama_alat'] ?? '-'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.riwayat!['id_peminjaman'] != null)
                          Text(
                            'ID Peminjaman: ${widget.riwayat!['id_peminjaman']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        if (widget.riwayat!['id_pengembalian'] != null)
                          Text(
                            'ID Pengembalian: ${widget.riwayat!['id_pengembalian']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                // Nama Peminjam (EDITABLE tapi disable untuk edit)
                const Text(
                  'Nama Peminjam',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _namaController,
                  enabled: !widget.isEdit, // Disable untuk edit mode
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama peminjam',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    prefixIcon: const Icon(Icons.person, size: 20),
                  ),
                  validator: _validateNama,
                ),
                const SizedBox(height: 16),

                // Kondisi Barang (Dropdown)
                const Text(
                  'Kondisi Barang',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedKondisi,
                  items: _kondisiOptions
                      .map((kondisi) => DropdownMenuItem<String>(
                            value: kondisi,
                            child: Text(kondisi),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKondisi = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Pilih kondisi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: _validateKondisi,
                ),
                const SizedBox(height: 16),

                // Catatan
                const Text(
                  'Catatan',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _catatanController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Catatan (opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Tombol Batal
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFF3A587A)),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Color(0xFF3A587A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tombol Simpan
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveRiwayat,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF3A587A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan',
                                style: TextStyle(
                                  color: Colors.white,
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
        ),
      ),
    );
  }
}