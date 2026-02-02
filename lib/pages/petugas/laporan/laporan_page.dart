import 'package:aplikasi_peminjaman_alat/core/services/laporan_service.dart';
import 'package:aplikasi_peminjaman_alat/widgets/side_bar.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/widgets/laporan_card.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/widgets/laporan_tab.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/widgets/search_field.dart';
import 'package:aplikasi_peminjaman_alat/models/laporan_model.dart';
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

  List<LaporanModel> listLaporan = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchLaporanData();
  }

  Future<void> fetchLaporanData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await LaporanService.fetchLaporan(
        filter: tabs[selectedTab],
      );
      setState(() {
        listLaporan = data;
      });
    } catch (e) {
      debugPrint('Error fetching laporan: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<LaporanModel> get filteredLaporan {
    if (searchQuery.isEmpty) return listLaporan;

    return listLaporan.where((laporan) {
      final q = searchQuery.toLowerCase();
      if (laporan.nama.toLowerCase().contains(q)) return true;
      return laporan.items.any(
        (alat) => alat.namaAlat.toLowerCase().contains(q),
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
                        setState(() {
                          selectedTab = index;
                        });
                        fetchLaporanData();
                      },
                    );
                  }),
                ),
              ),

              const SizedBox(height: 12),

              /// LOADING INDICATOR
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              /// LIST LAPORAN
              Expanded(
                child: listLaporan.isEmpty && !isLoading
                    ? const Center(
                        child: Text('Tidak ada data laporan'),
                      )
                    : ListView.builder(
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