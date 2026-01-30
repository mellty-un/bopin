import 'package:flutter/material.dart';

class PeminjamanCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(String) onUpdate;

  const PeminjamanCard({
    super.key, 
    required this.data, 
    required this.onUpdate
  });

  @override
  State<PeminjamanCard> createState() => _PeminjamanCardState();
}

class _PeminjamanCardState extends State<PeminjamanCard> {
  bool expand = false;

  Color colorStatus(String s) {
    if (s == 'Disetujui') return const Color(0xff22C55E);
    if (s == 'Ditolak') return const Color(0xffEF4444);
    if (s == 'Pengajuan') return const Color(0xffFACC15);
    return const Color(0xffFACC15);
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.data['status'];
    final alat = widget.data['alat'] ?? {};
    final kembali = widget.data['kembali'] ?? '';

    return GestureDetector(
      onTap: () {
        setState(() {
          expand = !expand;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            // Nama dan Icon Check/Cancel (SELALU TAMPIL)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data['nama'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.data['tanggal'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                // Icon Check dan Cancel di bagian atas (hanya untuk status Pengajuan)
                if (status == 'Pengajuan' || status == 'Menunggu')
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showConfirmationDialog(true),
                        icon: const Icon(
                          Icons.check_circle,
                          color: Color(0xff22C55E),
                          size: 28,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showConfirmationDialog(false),
                        icon: const Icon(
                          Icons.cancel,
                          color: Color(0xffEF4444),
                          size: 28,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  )
                else
                  // Jika sudah disetujui/ditolak, tampilkan status badge di atas
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colorStatus(status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            // DETAIL HANYA TAMPIL JIKA DIKLIK (expand = true)
            if (expand) ...[
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: const Color(0xFFEEEEEE),
              ),
              const SizedBox(height: 16),

              // Section Alat
              const Text(
                'Alat :',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // List alat
              if (alat is Map && alat.isNotEmpty)
                ...alat.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          entry.key ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()
              else
                const Text(
                  'Tidak ada alat',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              
              // Tanggal kembali
              if (kembali.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Kembali : $kembali',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],

              // Status section di bagian bawah (setelah expand)
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status :',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  
                  // Status badge di bagian bawah (setelah expand)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colorStatus(status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(bool approve) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                approve ? 'Setujui Peminjaman' : 'Tolak Peminjaman',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${approve ? 'menyetujui' : 'menolak'} peminjaman ini?',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Tidak',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onUpdate(approve ? 'Disetujui' : 'Ditolak');
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: approve ? const Color(0xff22C55E) : const Color(0xffEF4444),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Ya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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