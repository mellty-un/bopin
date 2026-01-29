import 'package:aplikasi_peminjaman_alat/core/services/riwayat_service.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:flutter/material.dart';

class RiwayatDialog extends StatefulWidget {
  final Map<String, dynamic>? riwayat;
  final bool isEdit;
  final VoidCallback? onSuccess;
  final bool showDeleteOption;

  const RiwayatDialog({
    super.key, 
    this.riwayat, 
    this.isEdit = false,
    this.onSuccess,
    this.showDeleteOption = true,
  });

  @override
  State<RiwayatDialog> createState() => _RiwayatDialogState();
}

class _RiwayatDialogState extends State<RiwayatDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tanggalController = TextEditingController();
  final _kondisiController = TextEditingController();
  final _catatanController = TextEditingController();
  final RiwayatService _riwayatService = RiwayatService();

  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _selectedDate;

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
      
      _kondisiController.text = widget.riwayat!['kondisi'] ?? widget.riwayat!['kondisi_pengembalian'] ?? '';
      _catatanController.text = widget.riwayat!['catatan'] ?? '';
    }
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _kondisiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String? _validateTanggal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tanggal pengembalian wajib diisi';
    }
    return null;
  }

  String? _validateKondisi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kondisi wajib diisi';
    }
    
    final validKondisi = ['Baik', 'Rusak', 'Hilang'];
    if (!validKondisi.contains(value.trim())) {
      return 'Pilih: Baik, Rusak, atau Hilang';
    }
    
    return null;
  }

  Future<void> _saveRiwayat() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final kondisi = _kondisiController.text.trim();
      final catatan = _catatanController.text.trim();
      
      if (widget.isEdit && widget.riwayat != null) {
        final id = widget.riwayat!['id_pengembalian'] ?? widget.riwayat!['id'] ?? 0;
        final idPengembalian = id is String ? int.parse(id) : id as int;
        
        await _riwayatService.updatePengembalian(
          idPengembalian: idPengembalian,
          kondisiPengembalian: kondisi,
          catatan: catatan,
          tglDikembalikan: _selectedDate,
          keterlambatanHari: 0,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
      widget.onSuccess?.call();

      SuccessPopup.show(context, 'Pengembalian berhasil diperbarui');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal menyimpan: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  Future<void> _deleteRiwayat() async {
    if (!widget.isEdit || widget.riwayat == null) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteConfirmationDialog(
        riwayatId: (widget.riwayat!['id_pengembalian'] ?? widget.riwayat!['id'] ?? 0).toString(),
        riwayatName: widget.riwayat!['nama_user'] ?? 'Pengembalian',
      ),
    );

    if (result == true && mounted) {
      try {
        final id = widget.riwayat!['id_pengembalian'] ?? widget.riwayat!['id'] ?? 0;
        final idPengembalian = id is String ? int.parse(id) : id as int;
        
        await _riwayatService.deletePengembalian(idPengembalian);
        
        Navigator.of(context).pop(true);
        widget.onSuccess?.call();
        
        SuccessPopup.show(context, 'Pengembalian berhasil dihapus');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Pengembalian',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
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
              
              // Tanggal Pengembalian
              TextFormField(
                controller: _tanggalController,
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(
                  hintText: 'Tanggal pengembalian',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  suffixIcon: Icon(Icons.calendar_today, size: 20),
                ),
                validator: _validateTanggal,
              ),
              
              const SizedBox(height: 12),
              
              // Kondisi Barang (Dropdown)
              DropdownButtonFormField<String>(
                value: _kondisiController.text.isEmpty ? null : _kondisiController.text,
                items: ['Baik', 'Rusak', 'Hilang']
                    .map((kondisi) => DropdownMenuItem<String>(
                          value: kondisi,
                          child: Text(kondisi),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _kondisiController.text = value!;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Kondisi barang',
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
              
              const SizedBox(height: 12),
              
              // Catatan
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
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  // Tombol Hapus (hanya untuk edit mode)
                  if (widget.isEdit && widget.showDeleteOption)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _deleteRiwayat,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.red),
                        ),
                        child: Text(
                          'Hapus',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  
                  if (widget.isEdit && widget.showDeleteOption)
                    const SizedBox(width: 10),
                  
                  // Tombol Batal
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  
                  const SizedBox(width: 10),
                  
                  // Tombol Simpan
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveRiwayat,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF3A587A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Delete Confirmation Dialog (digunakan dari dalam RiwayatDialog)
class DeleteConfirmationDialog extends StatefulWidget {
  final String riwayatId;
  final String riwayatName;

  const DeleteConfirmationDialog({
    super.key,
    required this.riwayatId,
    required this.riwayatName,
  });

  @override
  State<DeleteConfirmationDialog> createState() => _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hapus Pengembalian',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Apakah Anda yakin ingin menghapus data pengembalian "${widget.riwayatName}"?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isDeleting ? null : () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                  ),
                  child: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Hapus',
                          style: TextStyle(color: Colors.white),
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