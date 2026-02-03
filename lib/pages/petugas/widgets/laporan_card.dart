import 'package:aplikasi_peminjaman_alat/models/laporan_model.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/widgets/laporan_pdf.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanCard extends StatelessWidget {
  final LaporanModel laporan;

  const LaporanCard({super.key, required this.laporan});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                laporan.nama,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: laporan.status == 'Dikembalikan'
                      ? const Color(0xFFD4EDDA)
                      : const Color(0xFFD1ECF1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  laporan.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: laporan.status == 'Dikembalikan'
                        ? const Color(0xFF155724)
                        : const Color(0xFF0C5460),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dateText('Mulai', dateFormat.format(laporan.mulai)),
              _dateText('Kembali', dateFormat.format(laporan.kembali)),
              if (laporan.dikembalikan != null)
                _dateText('Dikembalikan', dateFormat.format(laporan.dikembalikan!)),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          const SizedBox(height: 8),

          /// ALAT HEADER
          const Text(
            'Alat',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          /// LIST ALAT
          Column(
            children: laporan.items.map((alat) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        alat.namaAlat,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${alat.jumlah} pcs',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),
Center(
  child: ElevatedButton.icon(
    onPressed: () {
      LaporanPdf.printLaporan(laporan); // panggil PDF
    },
    icon: const Icon(Icons.print, size: 16),
    label: const Text('Print Report'),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4A6FA5),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      textStyle: const TextStyle(fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
),
        ],
      ),
    );
  }

  Widget _dateText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}