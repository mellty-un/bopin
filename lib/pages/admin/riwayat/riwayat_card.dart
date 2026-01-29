import 'package:flutter/material.dart';

class RiwayatCard extends StatefulWidget {
  final Map<String, dynamic> riwayat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RiwayatCard({
    super.key,
    required this.riwayat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<RiwayatCard> createState() => _RiwayatCardState();
}

class _RiwayatCardState extends State<RiwayatCard> {
  bool isEditActive = false;
  bool isDeleteActive = false;

  void _handleEdit() async {
    setState(() {
      isEditActive = true;
      isDeleteActive = false;
    });

    widget.onEdit();

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        isEditActive = false;
      });
    }
  }

  void _handleDelete() async {
    setState(() {
      isDeleteActive = true;
      isEditActive = false;
    });

    widget.onDelete();

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        isDeleteActive = false;
      });
    }
  }

  Color _getKondisiColor(String kondisi) {
    switch (kondisi.toLowerCase()) {
      case 'baik':
        return Color(0xFFD1FAE5); // Green light
      case 'rusak':
        return Color(0xFFFEE2E2); // Red light
      case 'hilang':
        return Color(0xFFFEF3C7); // Yellow light
      default:
        return Color(0xFFE5E7EB); // Gray light
    }
  }

  Color _getKondisiTextColor(String kondisi) {
    switch (kondisi.toLowerCase()) {
      case 'baik':
        return Color(0xFF047857); // Green dark
      case 'rusak':
        return Color(0xFFDC2626); // Red dark
      case 'hilang':
        return Color(0xFFD97706); // Yellow dark
      default:
        return Color(0xFF6B7280); // Gray dark
    }
  }

  // Helper untuk format tanggal
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data dengan prioritas yang benar
    final kondisi = widget.riwayat['kondisi_pengembalian'] ?? 
                    widget.riwayat['kondisi'] ?? 
                    'Tidak diketahui';
    
    // Ambil nama user dengan prioritas yang benar
    final namaUser = widget.riwayat['nama_user'] ?? 
                     widget.riwayat['nama'] ?? 
                     'Tidak diketahui';
    
    // Ambil nama alat
    final namaAlat = widget.riwayat['nama_alat'] ?? 'Tidak diketahui';
    
    // Ambil catatan
    final catatan = widget.riwayat['catatan'] ?? '';
    
    // Format tanggal pengembalian
    final tglDikembalikan = _formatDate(widget.riwayat['tgl_dikembalikan']);
    
    // Format tanggal pinjam
    final tglPinjam = _formatDate(widget.riwayat['tgl_pinjam']);
    
    // Format tanggal harus kembali
    final tglKembali = _formatDate(widget.riwayat['tgl_kembali']);
    
    // Keterlambatan
    final keterlambatan = widget.riwayat['keterlambatan_hari'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama user
                Text(
                  namaUser,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Nama alat
                if (namaAlat != 'Tidak diketahui')
                  Text(
                    namaAlat,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                
                const SizedBox(height: 4),
                
                // Tanggal-tanggal
                if (tglPinjam != '-' && tglKembali != '-')
                  Row(
                    children: [
                      Text(
                        'Pinjam: $tglPinjam',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Kembali: $tglKembali',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                
                // Tanggal dikembalikan
                if (tglDikembalikan != '-')
                  Text(
                    'Dikembalikan: $tglDikembalikan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                
                // Keterlambatan jika ada
                if (keterlambatan > 0)
                  Text(
                    'Terlambat: $keterlambatan hari',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                
                const SizedBox(height: 6),
                
                // Badge kondisi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getKondisiColor(kondisi),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    kondisi,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getKondisiTextColor(kondisi),
                    ),
                  ),
                ),
                
                // Catatan jika ada
                if (catatan.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Catatan: $catatan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          
          // Tombol Edit
          InkWell(
            onTap: _handleEdit,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.edit,
                size: 20,
                color: isEditActive ? Color(0xFF3A587A) : Colors.black54,
              ),
            ),
          ),
          
          const SizedBox(width: 6),
          
          // Tombol Delete
          InkWell(
            onTap: _handleDelete,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.delete,
                size: 20,
                color: isDeleteActive ? Color(0xFFDC2626) : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}