import 'package:aplikasi_peminjaman_alat/core/services/riwayat_service.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RiwayatDialog extends StatefulWidget {
  final Map<String, dynamic> riwayat;
  final VoidCallback? onSuccess;

  const RiwayatDialog({
    super.key,
    required this.riwayat,
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
  String _selectedKondisi = 'Baik';

  final List<String> _kondisiOptions = ['Baik', 'Rusak', 'Hilang'];

  DateTime? _tglDikembalikan;

  @override
  void initState() {
    super.initState();

    _catatanController.text = widget.riwayat['catatan'] ?? '';

    final kondisi = widget.riwayat['kondisi_pengembalian'];
    if (_kondisiOptions.contains(kondisi)) {
      _selectedKondisi = kondisi;
    }

    final tgl = widget.riwayat['tgl_dikembalikan'];
    if (tgl != null) {
      _tglDikembalikan = DateTime.parse(tgl);
      _tanggalController.text =
          DateFormat('yyyy-MM-dd').format(_tglDikembalikan!);
    }
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tglDikembalikan ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _tglDikembalikan = picked;
        _tanggalController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _updateRiwayat() async {
    if (!_formKey.currentState!.validate()) return;

    final idPengembalian = widget.riwayat['id_pengembalian'];
    if (idPengembalian == null) {
      setState(() {
        _errorMessage = 'ID pengembalian tidak ditemukan';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
   if (_tglDikembalikan == null) {
  throw Exception('Tanggal dikembalikan wajib diisi');
}

await _riwayatService.updatePengembalian(
  idPengembalian: idPengembalian,
  kondisiPengembalian: _selectedKondisi!,
  tglDikembalikan: _tglDikembalikan!,
  catatan: _catatanController.text.trim(),
);


      if (!mounted) return;
      Navigator.pop(context);
      widget.onSuccess?.call();
      SuccessPopup.show(context, 'Pengembalian berhasil diperbarui');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRiwayat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pengembalian'),
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _riwayatService.deletePengembalian(
      widget.riwayat['id_pengembalian'],
    );

    if (!mounted) return;
    Navigator.pop(context);
    widget.onSuccess?.call();
    SuccessPopup.show(context, 'Pengembalian berhasil dihapus');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Pengembalian',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null)
                Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 12),

              TextFormField(
                controller: _tanggalController,
                readOnly: true,
                onTap: _pickTanggal,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Dikembalikan',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Tanggal wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedKondisi,
                items: _kondisiOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedKondisi = v!),
                decoration:
                    const InputDecoration(labelText: 'Kondisi Barang'),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _catatanController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Catatan'),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateRiwayat,
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: _deleteRiwayat,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus Pengembalian'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
