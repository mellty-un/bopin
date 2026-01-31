import 'package:aplikasi_peminjaman_alat/widgets/side_bar.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/pengembalian/pengembalian_dialog.dart';
import 'package:flutter/material.dart';
import 'pengembalian_card.dart';

class PengembalianPage extends StatefulWidget {
  const PengembalianPage({super.key});

  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = "Semua";
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  List<Map<String, dynamic>> vionaAlatList = [
    {'nama': 'Panci', 'jumlah': 1, 'kondisi': 'Rusak'},
    {'nama': 'Pisau', 'jumlah': 1, 'kondisi': 'Baik'},
  ];

  // Data untuk card lainnya
  List<Map<String, dynamic>> aselAlatList = [
    {'nama': 'Palu', 'jumlah': 2, 'kondisi': 'Baik'},
    {'nama': 'Obeng', 'jumlah': 1, 'kondisi': 'Rusak'},
    {'nama': 'Tang', 'jumlah': 1, 'kondisi': 'Baik'},
  ];

  // Gunakan state untuk data yang bisa berubah
  List<Map<String, dynamic>> _dummyData = [
    {
      "id": "1",
      "nama": "Viona",
      "tanggal": "30/01/2026",
      "status": "Pengembalian", // Awalnya Pengembalian
      "alatList": [],
      "tanggalPeminjaman": "20/01/2026",
      "tanggalPengembalian": "24/01/2026",
      "tanggalDikembalikan": "24/01/2026",
      "dendaKerusakan": 12000,
      "totalDenda": 12000,
    },
    {
      "id": "2",
      "nama": "Asel",
      "tanggal": "30/01/2026",
      "status": "Selesai",
      "alatList": [],
      "tanggalPeminjaman": "18/01/2026",
      "tanggalPengembalian": "22/01/2026",
      "tanggalDikembalikan": "22/01/2026",
      "dendaKerusakan": 5000,
      "totalDenda": 5000,
    }
  ];

  @override
  void initState() {
    super.initState();
    _dummyData[0]["alatList"] = vionaAlatList;
    _dummyData[1]["alatList"] = aselAlatList;
  }

  void _updateStatusToSelesai(String id) {
    setState(() {
      final index = _dummyData.indexWhere((item) => item["id"] == id);
      if (index != -1) {
        _dummyData[index]["status"] = "Selesai";
      }
    });
  }

  List<Map<String, dynamic>> getFilteredData() {
    if (selectedFilter == "Semua") {
      return _dummyData;
    } else if (selectedFilter == "Pengembalian") {
      return _dummyData.where((item) => item["status"] == "Pengembalian").toList();
    } else if (selectedFilter == "Selesai") {
      return _dummyData.where((item) => item["status"] == "Selesai").toList();
    }
    return _dummyData;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredData = getFilteredData();

    return Scaffold(
     key: _scaffoldKey,
      drawer: Padding(
        padding: const EdgeInsets.only(top: 70, bottom: 60),
        child: const SideBar(currentPage: "PengembalianPetugas"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      onChanged: (value) {
                        setState(() {});
                      },
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
            Column(
              children: filteredData.where((data) {
                // Filter berdasarkan pencarian
                final searchText = _searchController.text.toLowerCase();
                if (searchText.isEmpty) return true;
                return data["nama"].toLowerCase().contains(searchText);
              }).map((data) {
                return PengembalianCard(
                  nama: data["nama"],
                  tanggal: data["tanggal"],
                  status: data["status"],
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => PengembalianDetailDialog(
                        id: data["id"],
                        nama: data["nama"],
                        tanggalDiajukan: data["tanggal"],
                        status: data["status"],
                        alatList: List<Map<String, dynamic>>.from(data["alatList"]),
                        tanggalPeminjaman: data["tanggalPeminjaman"],
                        tanggalPengembalian: data["tanggalPengembalian"],
                        tanggalDikembalikan: data["tanggalDikembalikan"],
                        dendaKerusakan: data["dendaKerusakan"],
                        totalDenda: data["totalDenda"],
                        onProsesSuccess: () {
                          // Panggil fungsi untuk mengubah status
                          _updateStatusToSelesai(data["id"]);
                        },
                      ),
                    );
                  },
                  alatList: List<Map<String, dynamic>>.from(data["alatList"]),
                  tanggalPeminjaman: data["tanggalPeminjaman"],
                  tanggalPengembalian: data["tanggalPengembalian"],
                  tanggalDikembalikan: data["tanggalDikembalikan"],
                  dendaKerusakan: data["dendaKerusakan"],
                  totalDenda: data["totalDenda"],
                );
              }).toList(),
            )
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