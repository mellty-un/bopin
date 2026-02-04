import 'package:aplikasi_peminjaman_alat/core/services/peminjaman_service.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:aplikasi_peminjaman_alat/models/peminjaman_model.dart';
import 'package:aplikasi_peminjaman_alat/widgets/status_badge.dart';
import 'package:flutter/material.dart';

class PeminjamanCard extends StatefulWidget {
  final PeminjamanModel model;
  final Function(String) onUpdate; // callback untuk update UI lokal

  const PeminjamanCard({
    super.key,
    required this.model,
    required this.onUpdate,
  });

  @override
  State<PeminjamanCard> createState() => _PeminjamanCardState();
}

class _PeminjamanCardState extends State<PeminjamanCard> {
  bool expand = false;
  bool loadingUpdate = false; // untuk menandai proses update

  Color colorStatus(String s) {
    if (s == 'Disetujui') return const Color(0xff22C55E);
    if (s == 'Ditolak') return const Color(0xffEF4444);
    if (s == 'Menunggu') return const Color(0xffFACC15);
    if (s == 'Dikembalikan') return const Color(0xff3B82F6);
    if (s == 'Menunggu Pengembalian') return const Color(0xffFF9800);
    return const Color(0xff9CA3AF);
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;

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
          border: Border.all(color:  Color(0xFF36536B)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Nama & tanggal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model.tanggal,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Action / Status
                if (model.status == 'Menunggu')
                  Row(
                    children: [
                      loadingUpdate
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      _showConfirmationDialog(true),
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
                                  onPressed: () =>
                                      _showConfirmationDialog(false),
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Color(0xffEF4444),
                                    size: 28,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                    ],
                  )
                else
                  StatusBadge(status: model.status),
              ],
            ),

            /// ================= DETAIL =================
            if (expand) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              const Text(
                'Alat :',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              /// List alat
              if (model.alat.isNotEmpty)
                ...model.alat.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.key,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                        Text(
                          '${e.value}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Text(
                  'Tidak ada alat',
                  style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                ),

              if (model.kembali != null && model.kembali!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Kembali : ${model.kembali}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              /// Status bawah
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status :',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  StatusBadge(status: model.status),
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(approve ? 'Setujui Peminjaman' : 'Tolak Peminjaman'),
        content: Text(
          'Apakah kamu yakin ingin ${approve ? 'menyetujui' : 'menolak'} peminjaman ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // tutup dialog dulu
              setState(() => loadingUpdate = true);

              try {
                final newStatus = approve ? 'Disetujui' : 'Ditolak';

                // update status ke Supabase
                await PeminjamanService.updateStatus(
                  idPeminjaman: widget.model.id,
                  status: newStatus,
                );

                // update UI lokal
                widget.onUpdate(newStatus);

                // tampilkan popup sukses
                if (mounted) {
                  SuccessPopup.show(
                    context,
                    approve
                        ? 'Peminjaman disetujui'
                        : 'Peminjaman ditolak',
                  );
                }
              } catch (e) {
                debugPrint('Gagal update status: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal update status: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => loadingUpdate = false);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  approve ? const Color(0xff22C55E) : const Color(0xffEF4444),
            ),
            child: const Text(
              'Ya',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}