import 'package:flutter/material.dart';

class PengajuanCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onRefresh;

  const PengajuanCard({
    super.key,
    required this.data,
    required this.onRefresh,
  });

  @override
  State<PengajuanCard> createState() => _PengajuanCardState();
}

class _PengajuanCardState extends State<PengajuanCard> {
  bool expand = false;

  Color statusColor(String s) {
    switch (s) {
      case 'Menunggu':
        return Colors.amber;
      case 'Disetujui':
        return Colors.green;
      case 'Dikembalikan':
        return Colors.teal;
      case 'Ditolak':
        return Colors.red;
      case 'Menunggu Pengembalian':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.data['status_peminjaman'] as String? ?? 'Menunggu';
    final alat = widget.data['alat'] as Map<String, dynamic>? ?? {};
    final tgl = widget.data['tanggal'] as String? ?? '-';
    final kembali = widget.data['tanggal_pengembalian'] as String?;

    return GestureDetector(
      onTap: () => setState(() => expand = !expand),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diajukan',
                      style: TextStyle(fontSize: 11, color: Colors.orange),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          tgl,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// ALAT
            Row(
              children: [
                const Text(
                  'Alat',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    alat.keys.isEmpty ? '-' : alat.keys.join(', '),
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            if (expand && status != 'Ditolak') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (alat.isNotEmpty)
                      ...alat.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key,
                                  style: const TextStyle(fontSize: 12)),
                              Text('${e.value}',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    if (kembali != null && kembali.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Text(
                            'Tanggal Pengembalian',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            kembali,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
