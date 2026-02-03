import 'package:aplikasi_peminjaman_alat/core/services/denda_service.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:flutter/material.dart';

class DendaDialog extends StatefulWidget {
  final Map<String, dynamic>? denda;
  final bool isEdit;
  final VoidCallback? onSuccess;

  const DendaDialog({super.key, this.denda, this.isEdit = false, this.onSuccess});

  @override
  State<DendaDialog> createState() => _DendaDialogState();
}

class _DendaDialogState extends State<DendaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final DendaService _dendaService = DendaService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.denda != null) {
      _nameController.text = widget.denda!['jenis_denda'] ?? widget.denda!['name'] ?? '';
      final amount = widget.denda!['jumlah_denda'] ?? widget.denda!['amount'] ?? 0;
      if (amount > 0) {
        _formatAmountInput(amount.toString());
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveDenda() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final jenisDenda = _nameController.text.trim();
      final jumlahDenda = int.parse(
        _amountController.text
            .replaceAll('Rp', '')
            .replaceAll('.', '')
            .trim(),
      );

      if (widget.isEdit && widget.denda != null) {
        final id = widget.denda!['id_denda'] ?? widget.denda!['id'] ?? 0;
        final idDenda = id is String ? int.parse(id) : id as int;
        
        await _dendaService.updateDenda(
          idDenda: idDenda,
          jenisDenda: jenisDenda,
          jumlahDenda: jumlahDenda,
        );
      } else {
        await _dendaService.createDenda(
          jenisDenda: jenisDenda,
          jumlahDenda: jumlahDenda,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
      widget.onSuccess?.call();

      SuccessPopup.show(
        context,
        widget.isEdit ? 'Denda berhasil diperbarui' : 'Denda berhasil ditambahkan',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal menyimpan: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  // Validasi khusus untuk nama denda
  String? _validateDendaName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Jenis denda wajib diisi';
    }
    
    // Validasi agar sesuai dengan enum di database
    final validJenis = ['Keterlambatan', 'Kerusakan', 'Kehilangan'];
    if (!validJenis.contains(value.trim())) {
      return 'Pilih: Keterlambatan, Kerusakan, atau Kehilangan';
    }
    
    return null;
  }

  // Validasi khusus untuk biaya denda
  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Biaya denda wajib diisi';
    }
    
    // Hapus format Rupiah jika ada
    String cleanValue = value.replaceAll('Rp', '').replaceAll('.', '').trim();
    
    if (cleanValue.isEmpty) {
      return 'Biaya denda wajib diisi';
    }
    
    final amount = int.tryParse(cleanValue);
    if (amount == null) {
      return 'Masukkan angka yang valid';
    }
    
    if (amount <= 0) {
      return 'Biaya denda harus lebih dari 0';
    }
    
    if (amount > 10000000) { 
      return 'Biaya denda maksimal Rp 10.000.000';
    }
    
    return null;
  }

  // Format input biaya secara real-time
  void _formatAmountInput(String value) {
    if (value.isEmpty) return;
    
    String digits = value.replaceAll(RegExp(r'[^\d]'), '');
    
    int amount = int.tryParse(digits) ?? 0;
    
    String formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    
    if (_amountController.text != 'Rp $formatted') {
      _amountController.value = TextEditingValue(
        text: 'Rp $formatted',
        selection: TextSelection.collapsed(offset: 'Rp $formatted'.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dialog
                Center(
                  child: Text(
                    widget.isEdit ? 'Edit Denda' : 'Tambah Denda',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Pesan error
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

                // Form Jenis Denda (Dropdown)
                const Text(
                  'Jenis Denda',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _nameController.text.isEmpty ? null : _nameController.text,
                  items: ['Keterlambatan', 'Kerusakan', 'Kehilangan']
                      .map((jenis) => DropdownMenuItem<String>(
                            value: jenis,
                            child: Text(jenis),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _nameController.text = value!;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    errorMaxLines: 2,
                  ),
                  validator: _validateDendaName,
                ),
                const SizedBox(height: 20),

                // Form Biaya Denda
                const Text(
                  'Biaya Denda',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '',
                    prefixIcon: const Icon(Icons.attach_money, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    errorMaxLines: 2,
                  ),
                  validator: _validateAmount,
                  onChanged: _formatAmountInput,
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
                          side: const BorderSide(color: Color(0xFF3A587A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Color(0xFF3A587A)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveDenda,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A587A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isLoading
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

class DeleteConfirmationDialogDenda extends StatefulWidget {
  final String dendaName;
  final String dendaId;
  final VoidCallback? onSuccess;

  const DeleteConfirmationDialogDenda({
    super.key,
    required this.dendaName,
    required this.dendaId,
    this.onSuccess,
  });

  @override
  State<DeleteConfirmationDialogDenda> createState() =>
      _DeleteConfirmationDialogDendaState();
}

class _DeleteConfirmationDialogDendaState extends State<DeleteConfirmationDialogDenda> {
  final DendaService _dendaService = DendaService();
  bool _isDeleting = false;
  String? _errorMessage;

  Future<void> _handleDelete() async {
    if (_isDeleting) return;
    
    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      final id = int.tryParse(widget.dendaId) ?? 0;
      await _dendaService.deleteDenda(id);

      if (!mounted) return;

      Navigator.of(context).pop(true);
      widget.onSuccess?.call();

      SuccessPopup.show(context, 'Denda berhasil dihapus');
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
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Hapus Denda",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'Apakah Anda yakin ingin menghapus "${widget.dendaName}"?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Color(0xFF4B5563)),
            ),
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _isDeleting ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Batal",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),

                ElevatedButton(
                  onPressed: _isDeleting ? null : _handleDelete,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    backgroundColor: const Color(0xFFDC2626),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                          "Hapus",
                          style: TextStyle(color: Colors.white, fontSize: 15),
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