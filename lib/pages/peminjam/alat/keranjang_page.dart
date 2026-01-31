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
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _jurusanController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _jamController = TextEditingController();
  final TextEditingController _keperluanController = TextEditingController();
  final TextEditingController _lamaPinjamController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _tanggalController.text = '${now.day}/${now.month}/${now.year}';
    _jamController.text = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _lamaPinjamController.text = '1'; // Default 1 hari
  }

  int _getTotalItems() {
    return widget.jumlahPesanan.values.fold(0, (sum, jumlah) => sum + jumlah);
  }

  void _tambahJumlah(int idAlat) {
    setState(() {
      final currentJumlah = widget.jumlahPesanan[idAlat] ?? 0;
      final alat = widget.keranjangAlat.firstWhere((a) => a.idAlat == idAlat);
      // Gunakan nilai default jika null
      final stokTersedia = alat.stokTersedia ?? 0;
      if (currentJumlah < stokTersedia) {
        widget.jumlahPesanan[idAlat] = currentJumlah + 1;
        widget.onUpdate();
        _showSnackBar('${alat.namaAlat} jumlah ditambah', Colors.blue);
      } else {
        _showSnackBar('Stok ${alat.namaAlat} tidak mencukupi', Colors.orange);
      }
    });
  }

  void _kurangiJumlah(int idAlat) {
    setState(() {
      final currentJumlah = widget.jumlahPesanan[idAlat] ?? 0;
      if (currentJumlah > 1) {
        widget.jumlahPesanan[idAlat] = currentJumlah - 1;
        widget.onUpdate();
        final alat = widget.keranjangAlat.firstWhere((a) => a.idAlat == idAlat);
        _showSnackBar('${alat.namaAlat} jumlah dikurangi', Colors.blue);
      } else {
        widget.keranjangAlat.removeWhere((item) => item.idAlat == idAlat);
        widget.jumlahPesanan.remove(idAlat);
        widget.onUpdate();
        _showSnackBar('Alat dihapus dari keranjang', Colors.red);
      }
    });
  }

  void _hapusItem(int idAlat) {
    setState(() {
      widget.keranjangAlat.removeWhere((item) => item.idAlat == idAlat);
      widget.jumlahPesanan.remove(idAlat);
      widget.onUpdate();
      _showSnackBar('Alat dihapus dari keranjang', Colors.red);
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitPemesanan() {
    // Validasi input
    if (_namaController.text.isEmpty) {
      _showSnackBar('Nama harus diisi', Colors.red);
      return;
    }
    
    if (_nimController.text.isEmpty) {
      _showSnackBar('NIM harus diisi', Colors.red);
      return;
    }
    
    if (_jurusanController.text.isEmpty) {
      _showSnackBar('Jurusan harus diisi', Colors.red);
      return;
    }
    
    if (_keperluanController.text.isEmpty) {
      _showSnackBar('Keperluan harus diisi', Colors.red);
      return;
    }
    
    if (widget.keranjangAlat.isEmpty) {
      _showSnackBar('Keranjang kosong, tambahkan alat terlebih dahulu', Colors.red);
      return;
    }

    // Tampilkan konfirmasi
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pemesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin mengirim pemesanan ini?'),
            const SizedBox(height: 8),
            Text('Nama: ${_namaController.text}'),
            Text('NIM: ${_nimController.text}'),
            Text('Total Alat: ${_getTotalItems()} item'),
            const SizedBox(height: 8),
            const Text('Admin akan menghubungi Anda untuk konfirmasi.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPemesanan();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Ya, Kirim', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processPemesanan() {
   
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pemesanan Berhasil'),
        content: const Text('Pemesanan Anda berhasil dikirim! Admin akan menghubungi Anda dalam waktu 1x24 jam.'),
        actions: [
          TextButton(
            onPressed: () {
              // Kosongkan keranjang
              widget.keranjangAlat.clear();
              widget.jumlahPesanan.clear();
              widget.onUpdate();
              Navigator.pop(context);
              Navigator.pop(context); 
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.keranjangAlat.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Kosongkan Keranjang'),
                    content: const Text('Apakah Anda yakin ingin mengosongkan semua item di keranjang?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            widget.keranjangAlat.clear();
                            widget.jumlahPesanan.clear();
                            widget.onUpdate();
                          });
                          Navigator.pop(context);
                          _showSnackBar('Keranjang dikosongkan', Colors.red);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Kosongkan', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: widget.keranjangAlat.isEmpty
          ? _buildEmptyKeranjang()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFormPeminjam(),
                
                const SizedBox(height: 24),
                
                _buildDaftarAlat(),
                
                const SizedBox(height: 24),
                
                _buildRingkasanPemesanan(),
                
                const SizedBox(height: 24),
                
                _buildTombolAksi(),
                
                const SizedBox(height: 20),
              ],
            ),
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
              backgroundColor: Colors.blue,
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

  Widget _buildFormPeminjam() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Data Peminjam',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nimController,
              decoration: const InputDecoration(
                labelText: 'NIM *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _jurusanController,
              decoration: const InputDecoration(
                labelText: 'Jurusan/Fakultas *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                prefixIcon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tanggalController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Pinjam',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _jamController,
                    decoration: const InputDecoration(
                      labelText: 'Jam Pinjam',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lamaPinjamController,
              decoration: const InputDecoration(
                labelText: 'Lama Pinjam (hari)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                prefixIcon: Icon(Icons.timer),
                suffixText: 'hari',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _keperluanController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Keperluan Peminjaman *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _catatanController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan Tambahan (opsional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                prefixIcon: Icon(Icons.note),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaftarAlat() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Alat yang Dipinjam',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_getTotalItems()} item',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.keranjangAlat.map((alat) {
              final jumlah = widget.jumlahPesanan[alat.idAlat] ?? 0;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: alat.gambar != null && alat.gambar!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _alatService.getImageUrl(alat.gambar),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.construction, color: Colors.grey);
                                },
                              ),
                            )
                          : const Icon(Icons.construction, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alat.namaAlat ?? 'Tanpa Nama',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alat.kategori?.namaKategori ?? 'Tidak Ada Kategori',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getKondisiColor(alat.kondisi ?? 'Tidak Diketahui'),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  alat.kondisi ?? 'Tidak Diketahui',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Stok: ${alat.stokTersedia ?? 0}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => _kurangiJumlah(alat.idAlat),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$jumlah',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () => _tambahJumlah(alat.idAlat),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _hapusItem(alat.idAlat),
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanPemesanan() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Ringkasan Pemesanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.blue),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Alat:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '${_getTotalItems()} item',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Menunggu Konfirmasi',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tanggal Pinjam:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  _tanggalController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTombolAksi() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _submitPemesanan,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Kirim Pemesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: Colors.grey),
          ),
          child: const Text(
            'Kembali ke Alat',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Color _getKondisiColor(String kondisi) {
    switch (kondisi.toLowerCase()) {
      case 'baik':
        return Colors.green;
      case 'rusak':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}