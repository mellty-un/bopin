import 'package:aplikasi_peminjaman_alat/pages/admin/widgets/side_bar.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/widgets/laporan_card.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/widgets/laporan_tab.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/widgets/search_field.dart';
import 'package:flutter/material.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final List<String> tabs = ['Semua', 'Peminjaman', 'Pengembalian'];
  int selectedTab = 0;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Laporan> listLaporan = [
    Laporan(
      nama: 'Chella',
      mulai: DateTime(2026, 1, 20),
      kembali: DateTime(2026, 1, 24),
      items: [
        Alat(nama: 'Panci', jumlah: 1),
        Alat(nama: 'Pisau', jumlah: 1),
      ],
    ),
    Laporan(
      nama: 'Viona',
      mulai: DateTime(2026, 1, 20),
      kembali: DateTime(2026, 1, 24),
      items: [
        Alat(nama: 'Panci', jumlah: 1),
        Alat(nama: 'Pisau', jumlah: 1),
      ],
    ),
  ];

  List<Laporan> get filteredLaporan {
    if (searchQuery.isEmpty) return listLaporan;

    return listLaporan.where((laporan) {
      final q = searchQuery.toLowerCase();
      if (laporan.nama.toLowerCase().contains(q)) return true;
      return laporan.items.any(
        (alat) => alat.nama.toLowerCase().contains(q),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Padding(
        padding: const EdgeInsets.only(top: 70, bottom: 60),
        child: const SideBar(currentPage: "LaporanPetugas"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= HEADER (JANGAN DIUBAH) =================
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, size: 32),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Laporan",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // ==========================================================

              /// SEARCH
              SearchField(
                controller: searchController,
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
              ),

              const SizedBox(height: 12),

              /// TABS
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    return LaporanTab(
                      text: tabs[index],
                      active: selectedTab == index,
                      onTap: () {
                        setState(() => selectedTab = index);
                      },
                    );
                  }),
                ),
              ),

              const SizedBox(height: 12),

              /// LIST LAPORAN
              Expanded(
                child: ListView.builder(
                  itemCount: filteredLaporan.length,
                  itemBuilder: (context, index) {
                    return LaporanCard(
                      laporan: filteredLaporan[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Laporan {
  final String nama;
  final DateTime mulai;
  final DateTime kembali;
  final List<Alat> items;
  
  Laporan({
    required this.nama,
    required this.mulai,
    required this.kembali,
    required this.items,
  });
}

class Alat {
  final String nama;
  final int jumlah;
  
  Alat({
    required this.nama,
    required this.jumlah,
  });
}