import 'package:aplikasi_peminjaman_alat/pages/petugas/peminjaman/pemijaman_card.dart';
import 'package:flutter/material.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  String filter = 'Semua';

  final List<Map<String, dynamic>> data = [
    {
      'nama': 'Chella',
      'tanggal': '20/01/2025',
      'kembali': '24/01/2026',
      'status': 'Pengajuan',
      'alat': {'Panci': 1, 'Pisau': 1},
    },
    {
      'nama': 'Viona',
      'tanggal': '20/01/2026',
      'status': 'Disetujui',
      'alat': {},
    },
    {
      'nama': 'Asel',
      'tanggal': '20/01/2026',
      'status': 'Disetujui',
      'alat': {},
    },
    {'nama': 'Egi', 'tanggal': '20/01/2026', 'status': 'Ditolak', 'alat': {}},
  ];

  @override
  Widget build(BuildContext context) {
    final list = filter == 'Semua'
        ? data
        : data.where((e) => e['status'] == filter).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Peminjaman',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              child: Text('MT', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Peminjaman',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<String>(
                    value: filter,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    items: const [
                      DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                      DropdownMenuItem(
                        value: 'Pengajuan',
                        child: Text('Pengajuan'),
                      ),
                      DropdownMenuItem(
                        value: 'Disetujui',
                        child: Text('Disetujui'),
                      ),
                      DropdownMenuItem(
                        value: 'Ditolak',
                        child: Text('Ditolak'),
                      ),
                    ],
                    onChanged: (v) => setState(() => filter = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: MediaQuery.of(context).size.height - 200, // Atur height sesuai kebutuhan
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return PeminjamanCard(
                    data: list[index],
                    onUpdate: (status) {
                      setState(() => list[index]['status'] = status);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}