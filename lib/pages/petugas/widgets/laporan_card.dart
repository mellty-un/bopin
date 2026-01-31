import 'package:aplikasi_peminjaman_alat/pages/petugas/laporan/laporan_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class LaporanCard extends StatelessWidget {
  final Laporan laporan;

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
          Text(
            laporan.nama,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dateText('Mulai', dateFormat.format(laporan.mulai)),
              _dateText('Kembali', dateFormat.format(laporan.kembali)),
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
                        alat.nama,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      alat.jumlah.toString(),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          /// BUTTON PRINT
          Center(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print, size: 16),
              label: const Text('Print Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6FA5),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
