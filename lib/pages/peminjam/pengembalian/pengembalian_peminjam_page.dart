import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/pengembalian/pengembalian_card.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/pengembalian/pengembalian_dialog.dart';
import 'package:aplikasi_peminjaman_alat/widgets/side_bar.dart';
import 'package:flutter/material.dart';

class PengembalianPage extends StatefulWidget {
  const PengembalianPage({super.key});

  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  String selectedFilter = "Semua";
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> data = [
    {
      "id": "1",
      "tanggal": "20/01/2026",
      "status": "Pengembalian",
      "alat": 2,
      "alatList": [
        {"nama": "Panci", "jumlah": 1, "kondisi": "Rusak"},
        {"nama": "Pisau", "jumlah": 1, "kondisi": "Baik"},
      ],
      "tglPinjam": "20/01/2026",
      "tglKembali": "24/01/2026",
      "tglDikembalikan": "dd/mm/yyyy",
      "dendaKerusakan": 12000,
      "total": 12000,
    },
    {
      "id": "2",
      "tanggal": "20/01/2026",
      "status": "Selesai",
      "alat": 2,
      "alatList": [],
      "tglPinjam": "20/01/2026",
      "tglKembali": "24/01/2026",
      "tglDikembalikan": "24/01/2026",
      "dendaKerusakan": 0,
      "total": 0,
    },
  ];

  List<Map<String, dynamic>> get filtered {
    if (selectedFilter == "Semua") return data;
    return data.where((e) => e["status"] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Padding(
        padding: const EdgeInsets.only(top: 60, bottom: 60),
        child: const SideBar(currentPage: "Pengembalian Peminjam"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        size: 32,
                        color: Colors.black87,
                      ),
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
                        color: Colors.black,
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
                  children: const [
                    Icon(Icons.search, color: Colors.black54),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search",
                          border: InputBorder.none,
                        ),
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
                  filter("Pengembalian"),
                  const SizedBox(width: 8),
                  filter("Selesai"),
                ],
              ),

              const SizedBox(height: 20),

              /// LIST
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: filtered.map((e) {
                    List<DetailPeminjaman> alatList = [];
                    if (e["alatList"] != null) {
                      alatList = (e["alatList"] as List)
                          .map(
                            (item) => DetailPeminjaman(
                              namaAlat: item["nama"] ?? "",
                              jumlah: item["jumlah"] ?? 0,
                              kondisi: item["kondisi"] ?? "",
                            ),
                          )
                          .toList();
                    }

                    return PengembalianCard(
                      nama: "Peminjam",
                      tanggal: e["tanggal"],
                      status: e["status"],
                      alatList: alatList,
                      tanggalPeminjaman: e["tglPinjam"],
                      tanggalPengembalian: e["tglKembali"],
                      tanggalDikembalikan: e["tglDikembalikan"] ?? "",
                      dendaKerusakan: e["dendaKerusakan"] ?? 0,
                      totalDenda: e["total"] ?? 0,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => PengembalianDetailDialog(
                            id: e["id"],
                            nama: "Peminjam",
                            tanggalDiajukan: e["tanggal"],
                            status: e["status"],
                            alatList: alatList,
                            tanggalPeminjaman: e["tglPinjam"],
                            tanggalPengembalian: e["tglKembali"],
                            tanggalDikembalikan: e["tglDikembalikan"] ?? "",
                            dendaKerusakan: e["dendaKerusakan"] ?? 0,
                            totalDenda: e["total"] ?? 0,
                            onProsesSuccess: () {
                              setState(() {
                                e["status"] = "Selesai";
                              });
                            },
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

class Z {}
