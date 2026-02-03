import 'package:flutter/material.dart';

class PengembalianPeminamCard extends StatelessWidget {
  final String tanggal;
  final String status;
  final int totalAlat;
  final VoidCallback? onTap; // bisa null jika disabled

  const PengembalianPeminamCard({
    super.key,
    required this.tanggal,
    required this.status,
    required this.totalAlat,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelesai = status == "Selesai";
    final isMenunggu = status == "Menunggu";

    return InkWell(
      onTap: (isSelesai || isMenunggu) ? null : onTap, // disable jika sudah Selesai / Menunggu
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Diajukan",
                      style: TextStyle(fontSize: 11, color: Colors.orange),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12),
                        const SizedBox(width: 4),
                        Text(tanggal, style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelesai
                        ? Colors.green
                        : (isMenunggu ? Colors.orange : const Color(0xFF3A587A)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Total Alat Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Alat",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text("$totalAlat",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
