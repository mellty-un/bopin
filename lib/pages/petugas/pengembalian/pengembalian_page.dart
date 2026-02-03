// file: pengembalian_page.dart
import 'package:aplikasi_peminjaman_alat/core/services/pengembalian_service.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';
import 'package:aplikasi_peminjaman_alat/models/pengembalian_model.dart';
import 'package:aplikasi_peminjaman_alat/widgets/side_bar.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/pengembalian/pengembalian_dialog.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/pengembalian/pengembalian_card.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengembalianPage extends StatefulWidget {
  const PengembalianPage({super.key});

  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<PengembalianModel> _data = [];
  bool loading = true;
  String selectedFilter = "Semua";

  @override
  void initState() {
    super.initState();
    _loadPengembalian();
  }

  Future<void> _loadPengembalian() async {
    setState(() => loading = true);
    try {
      _data = await PengembalianService.fetchPengembalian();
    } catch (e) {
      debugPrint('❌ Error loading pengembalian: $e');
      _data = [];
    } finally {
      setState(() => loading = false);
    }
  }

  void _updateStatusTerima(PengembalianModel model) async {
    try {
      // Ambil nilai denda dari database
      final dendaValues = await PengembalianService.getDendaValues();
      final dendaKeterlambatanPerHari = dendaValues['Keterlambatan'] ?? 5000;

      // Hitung keterlambatan
      final peminjaman = await Supabase.instance.client
          .from('peminjaman')
          .select('tgl_kembali')
          .eq('id_peminjaman', int.parse(model.id))
          .single();

      final tglKembali = DateTime.parse(peminjaman['tgl_kembali']);
      
      // Handle nullable tanggalDikembalikan dengan null check
      final tglDikembalikan = (model.tanggalDikembalikan != null && 
                               model.tanggalDikembalikan!.isNotEmpty)
          ? _parseTanggal(model.tanggalDikembalikan!)
          : DateTime.now();

      final keterlambatan = tglDikembalikan.difference(tglKembali).inDays;
      final keterlambatanHari = keterlambatan > 0 ? keterlambatan : 0;
      final dendaKeterlambatan = keterlambatanHari * dendaKeterlambatanPerHari;

      // Hitung denda kerusakan dan kehilangan berdasarkan kondisi alat
      int dendaKerusakan = 0;
      int dendaKehilangan = 0;

      final dendaKerusakanPerItem = dendaValues['Kerusakan'] ?? 10000;
      final dendaKehilanganPerItem = dendaValues['Kehilangan'] ?? 20000;

      for (var alat in model.alatList) {
        if (alat.kondisi == "Rusak") {
          dendaKerusakan += dendaKerusakanPerItem * alat.jumlah;
        }
        if (alat.kondisi == "Hilang") {
          dendaKehilangan += dendaKehilanganPerItem * alat.jumlah;
        }
      }

      // Proses pengembalian
      await PengembalianService.prosesPengembalian(
        idPeminjaman: model.id,
        kondisiPengembalian: 'Baik',
        keterlambatanHari: keterlambatanHari,
        dendaKerusakan: dendaKerusakan,
        dendaKeterlambatan: dendaKeterlambatan,
        dendaKehilangan: dendaKehilangan,
        catatan: 'Diterima oleh petugas',
        alatList: model.alatList,
      );

      // Reload data
      await _loadPengembalian();
      
      // PERBAIKAN: Tampilkan success popup
      if (mounted) {
        SuccessPopup.show(context, "Pengembalian berhasil diproses");
      }
    } catch (e) {
      debugPrint('❌ Error updating status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses pengembalian: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateStatusTolak(PengembalianModel model) async {
    try {
      // Tolak pengembalian
      await PengembalianService.tolakPengembalian(
        idPeminjaman: model.id,
        catatan: 'Ditolak oleh petugas',
      );

      // Reload data
      await _loadPengembalian();
      
      // PERBAIKAN: Tampilkan success popup
      if (mounted) {
        SuccessPopup.show(context, "Pengembalian ditolak");
      }
    } catch (e) {
      debugPrint('❌ Error tolak pengembalian: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menolak pengembalian: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  DateTime _parseTanggal(String tanggal) {
    try {
      // Format: DD/MM/YYYY
      final parts = tanggal.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  List<PengembalianModel> getFilteredData() {
    List<PengembalianModel> filtered = _data;

    if (selectedFilter != "Semua") {
      filtered =
          filtered.where((item) => item.status == selectedFilter).toList();
    }

    final searchText = _searchController.text.toLowerCase();
    if (searchText.isNotEmpty) {
      filtered = filtered
          .where((item) => item.nama.toLowerCase().contains(searchText))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = getFilteredData();

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideBar(currentPage: "PengembalianPetugas"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, size: 32),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Pengembalian",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Search
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

              // Filter Row
              Row(
                children: [
                  filterButton("Semua"),
                  const SizedBox(width: 8),
                  filterButton("Pengembalian"),
                  const SizedBox(width: 8),
                  filterButton("Selesai"),
                ],
              ),

              const SizedBox(height: 15),

              // List Card
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredData.isEmpty
                        ? const Center(child: Text("Tidak ada data"))
                        : ListView.builder(
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              final data = filteredData[index];
                              return PengembalianCard(
                                nama: data.nama,
                                tanggal: data.tanggalPeminjaman,
                                status: data.status,
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (_) => PengembalianDetailDialog(
                                    id: data.id,
                                    nama: data.nama,
                                    tanggalDiajukan: data.tanggalPeminjaman,
                                    status: data.status,
                                    alatList: data.alatList,
                                    tanggalPeminjaman: data.tanggalPeminjaman,
                                    tanggalPengembalian:
                                        data.tanggalPengembalian,
                                    tanggalDikembalikan:
                                        data.tanggalDikembalikan ?? '',
                                    dendaKerusakan: data.dendaKerusakan,
                                    totalDenda: data.totalDenda,
                                    onProsesSuccess: (status) {
                                      // PERBAIKAN: Proses berdasarkan status
                                      if (status == "Selesai") {
                                        _updateStatusTerima(data);
                                      } else {
                                        _updateStatusTolak(data);
                                      }
                                    },
                                  ),
                                ),
                                alatList: data.alatList,
                                tanggalPeminjaman: data.tanggalPeminjaman,
                                tanggalPengembalian: data.tanggalPengembalian,
                                tanggalDikembalikan: data.tanggalDikembalikan ?? '',
                                dendaKerusakan: data.dendaKerusakan,
                                totalDenda: data.totalDenda,
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

  Widget filterButton(String label) {
    bool active = selectedFilter == label;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: active ? const Color(0xFF3A587A) : Colors.white,
            border: Border.all(color: const Color(0xFF3A587A)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF3A587A),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}