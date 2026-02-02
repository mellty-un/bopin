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
  bool isExpanded = false;
  bool isEditActive = false;
  bool isDeleteActive = false;

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

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

    // Tampilkan konfirmasi hapus
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Riwayat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus riwayat pengembalian "${widget.riwayat['nama_user'] ?? 'ini'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      widget.onDelete();
    }

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        isDeleteActive = false;
      });
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return const Color(0xFFE5E7EB);
    
    switch (status.toLowerCase()) {
      case 'dikembalikan':
        return const Color(0xFFD1FAE5);
      case 'dipinjam':
        return const Color(0xFFFEF3C7);
      case 'menunggu':
        return const Color(0xFFF3E8FF);
      case 'disetujui':
        return const Color(0xFFDBEAFE);
      case 'ditolak':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Color _getStatusTextColor(String? status) {
    if (status == null) return const Color(0xFF6B7280);
    
    switch (status.toLowerCase()) {
      case 'dikembalikan':
        return const Color(0xFF047857);
      case 'dipinjam':
        return const Color(0xFFD97706);
      case 'menunggu':
        return const Color(0xFF7C3AED);
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildKondisiChip(String kondisi) {
    Color chipColor;
    Color textColor;
    
    switch (kondisi.toLowerCase()) {
      case 'baik':
        chipColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF047857);
        break;
      case 'rusak':
        chipColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case 'hilang':
        chipColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        break;
      default:
        chipColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        kondisi,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final namaUser = widget.riwayat['nama_user'] ?? 'Tidak diketahui';
    final status = widget.riwayat['status'] ?? 'Tidak diketahui';
    final tglPinjam = _formatDate(widget.riwayat['tgl_pinjam']);
    final tglKembali = _formatDate(widget.riwayat['tgl_kembali']);
    final tglDikembalikan = _formatDate(widget.riwayat['tgl_dikembalikan']);
    final kondisi = widget.riwayat['kondisi_pengembalian'] ?? '-';
    final catatan = widget.riwayat['catatan'] ?? '-';
    final keterlambatanHari = widget.riwayat['keterlambatan_hari'] ?? 0;
    final jumlahPinjam = widget.riwayat['jumlah_pinjam'] ?? 1;

    // Parse nama alat - bisa berupa string tunggal atau list
    String namaAlat = widget.riwayat['nama_alat'] ?? 'Tidak diketahui';
    List<String> alatList = [];
    if (namaAlat.contains(',')) {
      alatList = namaAlat.split(',').map((e) => e.trim()).toList();
    } else {
      alatList = [namaAlat];
    }

    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama user dan status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    namaUser,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusTextColor(status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Tanggal pinjam
            Row(
              children: [
                Text(
                  'Pinjam : ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  tglPinjam,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Daftar alat yang dipinjam (selalu tampil)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alat :',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                ...alatList.map((alat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B7280),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alat,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),

            // Expanded content (detail pengembalian)
            if (isExpanded && status == 'Dikembalikan') ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 12),

              // Detail Pengembalian
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tanggal dikembalikan
                  _buildDetailRow('Dikembalikan :', tglDikembalikan),
                  const SizedBox(height: 8),

                  // Kondisi
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 100,
                        child: Text(
                          'Kondisi :',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      _buildKondisiChip(kondisi),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Keterlambatan
                  if (keterlambatanHari > 0)
                    _buildDetailRow('Keterlambatan :', '$keterlambatanHari hari'),

                  // Catatan
                  if (catatan.isNotEmpty && catatan != '-')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Catatan :',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          catatan,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],

            // Tombol Edit dan Hapus (hanya untuk status Dikembalikan)
            if (status == 'Dikembalikan') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  // Tombol Edit
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handleEdit,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isEditActive 
                              ? const Color(0xFF3A587A) 
                              : const Color(0xFF9CA3AF),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: isEditActive 
                            ? const Color(0xFF3A587A).withOpacity(0.05)
                            : Colors.white,
                      ),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: isEditActive 
                            ? const Color(0xFF3A587A) 
                            : const Color(0xFF6B7280),
                      ),
                      label: Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isEditActive 
                              ? const Color(0xFF3A587A) 
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 10),
                  
                  // Tombol Hapus
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handleDelete,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isDeleteActive 
                              ? const Color(0xFFDC2626) 
                              : const Color(0xFF9CA3AF),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: isDeleteActive 
                            ? const Color(0xFFDC2626).withOpacity(0.05)
                            : Colors.white,
                      ),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: isDeleteActive 
                            ? const Color(0xFFDC2626) 
                            : const Color(0xFF6B7280),
                      ),
                      label: Text(
                        'Hapus',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDeleteActive 
                              ? const Color(0xFFDC2626) 
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Chevron untuk expand/collapse (hanya untuk Dikembalikan)
            if (status == 'Dikembalikan') ...[
              const SizedBox(height: 8),
              Center(
                child: Icon(
                  isExpanded 
                      ? Icons.expand_less 
                      : Icons.expand_more,
                  size: 24,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }
}