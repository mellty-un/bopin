import 'package:aplikasi_peminjaman_alat/core/services/pemijaman_user_service.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_peminjaman_alat/models/alat_model.dart';
import 'package:aplikasi_peminjaman_alat/core/services/alat_service.dart';

class KeranjangPage extends StatefulWidget {
  final List<Alat> keranjangAlat;
  final Map<int, int> jumlahPesanan;
  final VoidCallback onUpdate;

  const KeranjangPage({
    super.key,
    required this.keranjangAlat,
    required this.jumlahPesanan,
    required this.onUpdate,
  });

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  final AlatService _alatService = AlatService();
  final PeminjamanUserService _peminjamanUserService = PeminjamanUserService();
  DateTime? _tanggalPinjam;
  DateTime? _tanggalKembali;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tanggalPinjam = DateTime.now();
    _tanggalKembali = DateTime.now().add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Keranjang Peminjaman',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: widget.keranjangAlat.isEmpty
          ? _buildEmptyKeranjang()
          : _buildKeranjangContent(),
    );
  }

  Widget _buildEmptyKeranjang() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Keranjang Kosong',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan alat dari halaman alat',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF36536B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Kembali ke Alat',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeranjangContent() {
    return Column(
      children: [
        // Header "Alat"
        Container(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 12),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Alat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),

        // List alat dengan gambar dan jumlah
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: widget.keranjangAlat.length,
            itemBuilder: (context, index) {
              final alat = widget.keranjangAlat[index];
              final jumlah = widget.jumlahPesanan[alat.idAlat] ?? 1;
              return _buildAlatItem(alat, jumlah);
            },
          ),
        ),

        // Tanggal Pinjam & Kembali
        _buildTanggalSection(),

        // Button Ajukan Peminjaman
        _buildButtonSection(),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAlatItem(Alat alat, int jumlah) {
    final imageUrl = (alat.gambar != null && alat.gambar!.isNotEmpty)
        ? _alatService.getImageUrl(alat.gambar)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Gambar Alat
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 30);
                      },
                    )
                  : const Icon(Icons.image_not_supported,
                      color: Colors.grey, size: 30),
            ),
          ),

          const SizedBox(width: 12),

          // Nama Alat dan Jumlah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alat.namaAlat ?? 'Tanpa Nama',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$jumlah',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Tombol hapus
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 22),
            onPressed: () {
              widget.keranjangAlat.remove(alat);
              widget.jumlahPesanan.remove(alat.idAlat);
              widget.onUpdate();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTanggalSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Row(
        children: [
          // Label "Tanggal Pinjam"
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tanggal Pinjam',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                // Input Tanggal Pinjam
                GestureDetector(
                  onTap: () => _selectTanggalPinjam(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                    ),
                    child: Text(
                      _tanggalPinjam != null
                          ? _formatTanggal(_tanggalPinjam!)
                          : 'dd/mm/yyyy',
                      style: TextStyle(
                        fontSize: 13,
                        color: _tanggalPinjam != null
                            ? Colors.black87
                            : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Label "Tanggal Kembali"
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tanggal Kembali',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                // Input Tanggal Kembali
                GestureDetector(
                  onTap: () => _selectTanggalKembali(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                    ),
                    child: Text(
                      _tanggalKembali != null
                          ? _formatTanggal(_tanggalKembali!)
                          : 'dd/mm/yyyy',
                      style: TextStyle(
                        fontSize: 13,
                        color: _tanggalKembali != null
                            ? Colors.black87
                            : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleAjukanPeminjaman,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF36536B),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Ajukan Peminjaman',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _handleAjukanPeminjaman() async {
    // Validasi tanggal
    if (_tanggalPinjam == null || _tanggalKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal pinjam dan kembali terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tanggalKembali!.isBefore(_tanggalPinjam!) ||
        _tanggalKembali!.isAtSameMomentAs(_tanggalPinjam!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal kembali harus setelah tanggal pinjam'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Panggil service untuk ajukan peminjaman
      final success = await _peminjamanUserService.ajukanPeminjaman(
        tanggalPinjam: _tanggalPinjam!,
        tanggalKembali: _tanggalKembali!,
        alatDanJumlah: widget.jumlahPesanan,
      );

      if (success) {
        // Kosongkan keranjang
        widget.keranjangAlat.clear();
        widget.jumlahPesanan.clear();
        widget.onUpdate();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Peminjaman berhasil diajukan'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengajukan peminjaman'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _selectTanggalPinjam(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPinjam ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF36536B),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _tanggalPinjam) {
      setState(() {
        _tanggalPinjam = picked;
        // Reset tanggal kembali jika lebih awal dari tanggal pinjam
        if (_tanggalKembali != null && _tanggalKembali!.isBefore(picked)) {
          _tanggalKembali = picked.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectTanggalKembali(BuildContext context) async {
    final DateTime firstDate = _tanggalPinjam != null
        ? _tanggalPinjam!.add(const Duration(days: 1))
        : DateTime.now().add(const Duration(days: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalKembali ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF36536B),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _tanggalKembali) {
      setState(() {
        _tanggalKembali = picked;
      });
    }
  }

  String _formatTanggal(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}