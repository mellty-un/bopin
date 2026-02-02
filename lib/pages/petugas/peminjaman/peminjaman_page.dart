import 'package:aplikasi_peminjaman_alat/core/services/peminjaman_service.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_peminjaman_alat/widgets/side_bar.dart';
import 'package:aplikasi_peminjaman_alat/models/peminjaman_model.dart';
import 'pemijaman_card.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String filter = 'Semua';
  bool isLoading = true;

  List<PeminjamanModel> peminjamanList = [];

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
  }

  Future<void> _loadPeminjaman() async {
    try {
      final result = await PeminjamanService.fetchPeminjaman();
      setState(() {
        peminjamanList = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal load peminjaman: $e');
      setState(() => isLoading = false);
    }
  }

  List<PeminjamanModel> get filteredData {
    final keyword = _searchController.text.toLowerCase();

    return peminjamanList.where((item) {
      final cocokStatus = filter == 'Semua' || item.status == filter;

      final cocokSearch = item.nama.toLowerCase().contains(keyword);

      return cocokStatus && cocokSearch;
    }).toList();
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      // update ke Supabase
      await PeminjamanService.updateStatus(idPeminjaman: id, status: status);

      // tampilkan popup sukses
      if (mounted) {
        SuccessPopup.show(
          context,
          status == 'Disetujui'
              ? 'Peminjaman berhasil disetujui'
              : 'Peminjaman berhasil ditolak',
        );
      }

      // reload data
      await _loadPeminjaman();
    } catch (e) {
      debugPrint('Gagal update status: $e');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal mengubah status')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.1,
            bottom: screenHeight * 0.05,
          ),
          child: SideBar(currentPage: "PeminjamanPetugas"),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 24,
            vertical: isSmallScreen ? 8 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.menu, size: isSmallScreen ? 28 : 32),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    Text(
                      "Peminjaman",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// SEARCH
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black26),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black54),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: "Search",
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// FILTER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Peminjaman',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 13 : 14,
                    ),
                  ),
                  Container(
                    height: isSmallScreen ? 26 : 28,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF36536B)),
                    ),
                    child: DropdownButton<String>(
                      value: filter,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        size: isSmallScreen ? 16 : 18,
                      ),
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
                        DropdownMenuItem(
                          value: 'Dikembalikan',
                          child: Text('Dikembalikan'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => filter = value!);
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: isSmallScreen ? 8 : 12),

              /// LIST
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredData.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada data peminjaman',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPeminjaman,
                        child: ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: isSmallScreen ? 8 : 12,
                              ),
                              child: PeminjamanCard(
                                model: filteredData[index],
                                onUpdate: (newStatus) async {
                                  // update status di list lokal agar UI langsung berubah
                                  setState(() {
                                    filteredData[index].status = newStatus;
                                  });

                                  // reload list dari Supabase agar sinkron
                                  await _loadPeminjaman();
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
