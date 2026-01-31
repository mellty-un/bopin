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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Nama
          Text(
            laporan.nama,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          /// Tanggal
          Row(
            children: [
              _dateText('Mulai', dateFormat.format(laporan.mulai)),
              const SizedBox(width: 20),
              _dateText('Kembali', dateFormat.format(laporan.kembali)),
            ],
          ),
          const SizedBox(height: 12),

          /// Tabel alat
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: laporan.items.map((alat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(alat.nama)),
                      Text(alat.jumlah.toString()),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          /// Button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print, size: 16),
              label: const Text('Print laporan'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4A6FA5),
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
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
