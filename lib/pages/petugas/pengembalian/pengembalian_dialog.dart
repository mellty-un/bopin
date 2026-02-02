import 'package:flutter/material.dart';
import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';

class PengembalianDetailDialog extends StatelessWidget {
  final String id;
  final String nama;
  final String tanggalDiajukan;
  final String status;
  final List<DetailPeminjaman> alatList; 
  final String tanggalPeminjaman;
  final String tanggalPengembalian;
  final String tanggalDikembalikan;
  final int dendaKerusakan;
  final int totalDenda;
  final VoidCallback? onProsesSuccess;

  const PengembalianDetailDialog({
    super.key,
    required this.id,
    required this.nama,
    required this.tanggalDiajukan,
    required this.status,
    required this.alatList,
    required this.tanggalPeminjaman,
    required this.tanggalPengembalian,
    required this.tanggalDikembalikan,
    required this.dendaKerusakan,
    required this.totalDenda,
    this.onProsesSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nama,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: status == "Selesai" ? Colors.green : const Color(0xFF3A587A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Diajukan $tanggalDiajukan",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Alat
            const Text("Alat:", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Column(
              children: alatList.map((alat) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(alat.namaAlat),
                        Text("${alat.jumlah}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          alat.kondisi,
                          style: TextStyle(
                            color: alat.kondisi == "Rusak"
                                ? const Color(0xFFDC2626)
                                : alat.kondisi == "Hilang"
                                    ? const Color(0xFFFFA500)
                                    : const Color(0xFF4CAF50),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (alatList.indexOf(alat) < alatList.length - 1)
                      const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Container(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 20),

            // Tanggal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                        child: Text(
                          "Tanggal Peminjaman",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Tanggal Pengembalian",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Tanggal Dikembalikan",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              tanggalPeminjaman,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              tanggalPengembalian,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              tanggalDikembalikan,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Container(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 20),

            // Denda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Denda Terlambat", style: TextStyle(fontSize: 14)),
                Text("0", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Denda Kerusakan", style: TextStyle(fontSize: 14)),
                Text(dendaKerusakan.toString(), style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Container(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(totalDenda.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol Proses / Ditolak
            if (status != "Selesai") ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text("Ditolak", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showSuccessDialog(context, nama, onProsesSuccess);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text("Proses", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text("Pengembalian telah diproses", style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String namaPeminjam, VoidCallback? callback) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 2), () {
          if (ctx.mounted) {
            Navigator.pop(ctx);
            callback?.call();
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 50),
                padding: const EdgeInsets.fromLTRB(32, 70, 32, 32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Pengembalian $namaPeminjam berhasil Diproses",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1F2937), letterSpacing: -0.5),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 8),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
