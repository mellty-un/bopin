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
  bool expand = false;

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
        return Color(0xFFD1FAE5);
      case 'rusak':
        return Color(0xFFFEE2E2);
      case 'hilang':
        return Color(0xFFFEF3C7);
      default:
        return Color(0xFFE5E7EB);
    }
  }

  Color _getKondisiTextColor(String kondisi) {
    switch (kondisi.toLowerCase()) {
      case 'baik':
        return Color(0xFF047857);
      case 'rusak':
        return Color(0xFFDC2626);
      case 'hilang':
        return Color(0xFFD97706);
      default:
        return Color(0xFF6B7280);
    }
  }

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
    final kondisi = widget.riwayat['kondisi_pengembalian'] ?? 
                    widget.riwayat['kondisi'] ?? 
                    'Tidak diketahui';
    
    final namaUser = widget.riwayat['nama_user'] ?? 
                     widget.riwayat['nama'] ?? 
                     'Tidak diketahui';
    
    final namaAlat = widget.riwayat['nama_alat'] ?? 'Tidak diketahui';
    final catatan = widget.riwayat['catatan'] ?? '';
    final tglDikembalikan = _formatDate(widget.riwayat['tgl_dikembalikan']);
    final tglPinjam = _formatDate(widget.riwayat['tgl_pinjam']);
    final tglKembali = _formatDate(widget.riwayat['tgl_kembali']);
    final keterlambatan = widget.riwayat['keterlambatan_hari'] ?? 0;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          expand = !expand;
        });
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaUser,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      if (namaAlat != 'Tidak diketahui')
                        Text(
                          namaAlat,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      
                      const SizedBox(height: 4),
                      
                      if (tglPinjam != '-' && tglKembali != '-')
                        Text(
                          '$tglPinjam - $tglKembali',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                
                Row(
                  children: [
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
              ],
            ),
            
            if (expand) ...[
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: const Color(0xFFEEEEEE),
              ),
              const SizedBox(height: 16),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tglDikembalikan != '-')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            'Dikembalikan: ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            tglDikembalikan,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  if (keterlambatan > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            'Keterlambatan: ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '$keterlambatan hari',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          'Kondisi: ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
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
                      ],
                    ),
                  ),
                  
                  if (catatan.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          catatan,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}