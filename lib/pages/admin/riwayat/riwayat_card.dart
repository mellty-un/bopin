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

  void _toggleExpanded() {
    setState(() => isExpanded = !isExpanded);
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    final d = DateTime.parse(date);
    return '${d.day}/${d.month}/${d.year}';
  }

  // ===== WARNA BACKGROUND STATUS =====
  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'dipinjam':
        return const Color(0xFFFFF3C4); // kuning muda
      case 'dikembalikan':
        return const Color(0xFFD1FAE5); // hijau muda
      case 'ditolak':
        return const Color(0xFFFEE2E2); // merah muda
      default:
        return const Color(0xFFE5E7EB); // abu
    }
  }

  // ===== WARNA TEXT STATUS =====
  Color _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'dipinjam':
        return const Color(0xFFD97706); // kuning tua
      case 'dikembalikan':
        return const Color(0xFF047857); // hijau tua
      case 'ditolak':
        return const Color(0xFFB91C1C); // merah tua
      default:
        return const Color(0xFF6B7280); // abu
    }
  }

  @override
  Widget build(BuildContext context) {
    final namaUser = widget.riwayat['nama_user'] ?? '-';
    final status = widget.riwayat['status'] ?? '-';
    final tglPinjam = _formatDate(widget.riwayat['tgl_pinjam']);
    final tglDikembalikan =
        _formatDate(widget.riwayat['tgl_dikembalikan']);
    final namaAlat = widget.riwayat['nama_alat'] ?? '-';

    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? const Color(0xFF3A587A)
                : const Color(0xFFE5E7EB),
            width: isExpanded ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== HEADER =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  namaUser,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusText(status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ===== TANGGAL PINJAM =====
            Text(
              'Pinjam : $tglPinjam',
              style: const TextStyle(fontSize: 13),
            ),

            // ===== DETAIL =====
            if (isExpanded) ...[
              const SizedBox(height: 12),
              const Divider(),

              const Text(
                'Alat :',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(namaAlat),

              const SizedBox(height: 6),
              Text('Dikembalikan : $tglDikembalikan'),
            ],

            const SizedBox(height: 14),

            // ===== BUTTON =====
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Hapus'),
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
