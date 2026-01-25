import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:flutter/material.dart';

class RiwayatDialog extends StatefulWidget {
  final Map<String, dynamic>? riwayat;
  final bool isEdit;

  const RiwayatDialog({super.key, this.riwayat, this.isEdit = false});

  @override
  State<RiwayatDialog> createState() => _RiwayatDialogState();
}

class _RiwayatDialogState extends State<RiwayatDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tanggalController = TextEditingController();
  final _kondisiController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.riwayat != null) {
      _tanggalController.text =
          widget.riwayat!['tanggal_pengembalian'] ?? '';
      _kondisiController.text = widget.riwayat!['kondisi'] ?? '';
    }
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _kondisiController.dispose();
    super.dispose();
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
    if (value.trim().length < 3) {
      return 'Kondisi minimal 3 karakter';
    }
    return null;
  }

  Future<void> _saveRiwayat() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.of(context).pop(true);

    SuccessPopup.show(context, 'Pengembalian berhasil disimpan');
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
              TextFormField(
                controller: _tanggalController,
                decoration: InputDecoration(
                  hintText: 'Tanggal pengembalian',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                validator: _validateTanggal,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kondisiController,
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
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

class DeleteConfirmationDialogRiwayat extends StatefulWidget {
  final String riwayatId;

  const DeleteConfirmationDialogRiwayat({
    super.key,
    required this.riwayatId,
  });

  @override
  State<DeleteConfirmationDialogRiwayat> createState() =>
      _DeleteConfirmationDialogRiwayatState();
}

class _DeleteConfirmationDialogRiwayatState
    extends State<DeleteConfirmationDialogRiwayat> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.of(context).pop(true);

    SuccessPopup.show(context, 'Pengembalian berhasil dihapus');
  }

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
            const Text(
              'Apakah Anda yakin ingin menghapus data pengembalian ini?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _isDeleting ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isDeleting ? null : _handleDelete,
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
