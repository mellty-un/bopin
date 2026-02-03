import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';
import 'package:flutter/material.dart';

class PengembalianCard extends StatelessWidget {
  final String nama;
  final String tanggal; 
  final String status;
  final VoidCallback onTap;
  final List<DetailPeminjaman> alatList; // <-- ubah disini
  final String tanggalPeminjaman;
  final String tanggalPengembalian;
  final String tanggalDikembalikan;
  final int dendaKerusakan;
  final int totalDenda;

  const PengembalianCard({
    super.key,
    required this.nama,
    required this.tanggal,
    required this.status,
    required this.onTap,
    required this.alatList, 
    required this.tanggalPeminjaman,
    required this.tanggalPengembalian,
    required this.tanggalDikembalikan,
    required this.dendaKerusakan,
    required this.totalDenda,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              offset: Offset(0, 2),
              color: Colors.black12,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama & Tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Diajukan $tanggal",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: status == "Selesai" ? Colors.green : const Color(0xFF3A587A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 10),

            // Tampilkan list alat
            Column(
              children: alatList.map((alat) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(alat.namaAlat),
                    Text("${alat.jumlah}"),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
