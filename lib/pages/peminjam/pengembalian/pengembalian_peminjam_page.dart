import 'package:aplikasi_peminjaman_alat/core/services/pemijaman_user_service.dart';
import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';
import 'package:aplikasi_peminjaman_alat/pages/peminjam/pengembalian/pengembalaian_peminjaman_card.dart';
import 'package:aplikasi_peminjaman_alat/pages/peminjam/pengembalian/pengembalian_peminjaman_dialog.dart';
import 'package:aplikasi_peminjaman_alat/widgets/side_bar.dart';
import 'package:flutter/material.dart';

class PengembaliaPeminjamnPage extends StatefulWidget {
  const PengembaliaPeminjamnPage({super.key});

  @override
  State<PengembaliaPeminjamnPage> createState() =>
      _PengembaliaPeminjamnPageState();
}

class _PengembaliaPeminjamnPageState extends State<PengembaliaPeminjamnPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  final PeminjamanUserService _service = PeminjamanUserService();

  String selectedFilter = "Semua";
  bool loading = true;

  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    try {
      final result = await _service.getPeminjamanByUser();
      
      // PERBAIKAN: Filter hanya yang statusnya Disetujui atau sudah ada pengembalian
      final filteredResult = result.where((e) {
        final statusPeminjaman = e['status_peminjaman'] as String;
        return statusPeminjaman == 'Disetujui' || 
               statusPeminjaman == 'Menunggu Pengembalian' ||
               statusPeminjaman == 'Dikembalikan';
      }).toList();

      setState(() {
        data = filteredResult;
        loading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => loading = false);
    }
  }

  List<Map<String, dynamic>> get filtered {
    if (selectedFilter == "Semua") return data;
    
    // PERBAIKAN: Filter berdasarkan status_pengembalian
    return data.where((e) => e["status_pengembalian"] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Padding(
        padding: const EdgeInsets.only(top: 70, bottom: 60),
        child: const SideBar(currentPage: "Pengembalian"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu,
                          size: 32, color: Colors.black87),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Pengembalian",
                      style: TextStyle(
                        fontSize: 24,
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
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              /// FILTER
              Row(
                children: [
                  filter("Semua"),
                  const SizedBox(width: 8),
                  filter("Belum"),
                  const SizedBox(width: 8),
                  filter("Menunggu"),
                  const SizedBox(width: 8),
                  filter("Selesai"),
                ],
              ),

              const SizedBox(height: 20),

              /// LIST
              if (loading)
                const Center(child: CircularProgressIndicator())
              else if (filtered.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Tidak ada data pengembalian",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: filtered.map((e) {
                    /// alat → jumlah
                    List<DetailPeminjaman> alatList = [];
                    if (e["alat"] != null) {
                      (e["alat"] as Map<String, dynamic>)
                          .forEach((nama, jumlah) {
                        alatList.add(
                          DetailPeminjaman(
                            namaAlat: nama,
                            jumlah: jumlah,
                            kondisi: '',
                          ),
                        );
                      });
                    }

                    return PengembalianPeminamCard(
                      tanggal: e["tanggal"],
                      status: e["status_pengembalian"], // PERBAIKAN: Gunakan status_pengembalian
                      totalAlat: alatList.length,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => PengembalianPeminjamDetailDialog(
                            id: e["id_peminjaman"].toString(),
                            nama: "Peminjaman",
                            tanggalDiajukan: e["tanggal"],
                            status: e["status_pengembalian"], // PERBAIKAN: Gunakan status_pengembalian
                            alatList: alatList,
                            tanggalPeminjaman: e["tanggal"],
                            tanggalPengembalian:
                                e["tanggal_pengembalian"] ?? "-",
                            onAjukanSuccess: (pickedTanggal) async {
                              // Panggil service untuk ajukan pengembalian
                              final success = await PeminjamanUserService()
                                  .ajukanPengembalian(
                                e["id_peminjaman"],
                                tanggalDikembalikan: pickedTanggal,
                              );

                              if (success) {
                                // Update status lokal agar card berubah jadi "Menunggu"
                                setState(() {
                                  e["status_pengembalian"] = "Menunggu";
                                });

                                // Reload data dari server
                                loadData();

                                // Tampilkan snackbar sukses
                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Pengembalian berhasil diajukan'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                // Tampilkan snackbar error
                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Gagal mengajukan pengembalian'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// FILTER BUTTON
  Widget filter(String label) {
    final active = selectedFilter == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF3A587A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF3A587A)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF3A587A),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}