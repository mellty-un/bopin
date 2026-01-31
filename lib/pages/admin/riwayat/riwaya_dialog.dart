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
  final _tanggalController = TextEditingController();
  final _catatanController = TextEditingController();
  final RiwayatService _riwayatService = RiwayatService();

  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _selectedDate;
  String? _selectedKondisi;

  final List<String> _kondisiOptions = ['Baik', 'Rusak', 'Hilang'];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.riwayat != null) {
      // Format tanggal jika ada
      if (widget.riwayat!['tgl_dikembalikan'] != null) {
        final dateStr = widget.riwayat!['tgl_dikembalikan'];
        if (dateStr is String && dateStr.isNotEmpty) {
          try {
            _selectedDate = DateTime.parse(dateStr);
            _tanggalController.text = _formatDate(_selectedDate!);
          } catch (e) {
            print('Error parsing date: $e');
          }
        }
      }

      // Set kondisi
      final kondisi = widget.riwayat!['kondisi'] ??
          widget.riwayat!['kondisi_pengembalian'];
      if (kondisi != null && _kondisiOptions.contains(kondisi)) {
        _selectedKondisi = kondisi;
      }

      // Set catatan
      _catatanController.text = widget.riwayat!['catatan'] ?? '';
    }
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3A587A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String? _validateTanggal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tanggal pengembalian wajib diisi';
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

    if (!_formKey.currentState!.validate()) return;

    if (_selectedKondisi == null) {
      setState(() => _errorMessage = 'Kondisi harus dipilih');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isEdit && widget.riwayat != null) {
        final id = widget.riwayat!['id_pengembalian'] ??
            widget.riwayat!['id'] ??
            0;
        final idPengembalian = id is String ? int.parse(id) : id as int;

        await _riwayatService.updatePengembalian(
          idPengembalian: idPengembalian,
          kondisiPengembalian: _selectedKondisi!,
          catatan: _catatanController.text.trim(),
          tglDikembalikan: _selectedDate,
          keterlambatanHari: 0,
        );

        if (!mounted) return;

        Navigator.of(context).pop(true);
        widget.onSuccess?.call();

        SuccessPopup.show(context, 'Pengembalian berhasil diperbarui');
      }
    } catch (e) {
      if (!mounted) return;

      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });

      // Auto clear error after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _errorMessage == errorMsg) {
          setState(() => _errorMessage = null);
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

                // Info nama user & alat (read-only)
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
                          'Peminjam: ${widget.riwayat!['nama_user'] ?? '-'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Alat: ${widget.riwayat!['nama_alat'] ?? '-'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Tanggal Pengembalian
                const Text(
                  'Tanggal Pengembalian',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tanggalController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    hintText: 'Pilih tanggal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    suffixIcon:
                        const Icon(Icons.calendar_today, size: 20),
                  ),
                  validator: _validateTanggal,
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