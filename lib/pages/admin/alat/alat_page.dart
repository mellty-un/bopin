import 'package:flutter/material.dart';
import 'alat_card.dart';
import 'alat_dialog.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/widgets/side_bar.dart';

class AlatPage extends StatefulWidget {
  const AlatPage({super.key});

  @override
  State<AlatPage> createState() => _AlatPageState();
}

class _AlatPageState extends State<AlatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> alatList = [
    {
      "id": "1",
      "nama": "Panci",
      "kategori": "Alat Masak",
      "kondisi": "Baik",
      "imageUrl": "assets/images/panci.jpg"
    },
    {
      "id": "2",
      "nama": "Pisau",
      "kategori": "Alat Potong",
      "kondisi": "Baik",
      "imageUrl": "assets/images/pisau.jpg"
    },
    {
      "id": "3",
      "nama": "Fondant Tool",
      "kategori": "Alat Pastry",
      "kondisi": "Baik",
      "imageUrl": "assets/images/fondant.png"
    },
    {
      "id": "4",
      "nama": "Blow Torch",
      "kategori": "Alat Dekorasi",
      "kondisi": "Baik",
      "imageUrl": "assets/images/blow.webp"
    },
  ];

  List<Map<String, dynamic>> filteredAlatList = [];

  @override
  void initState() {
    super.initState();
    filteredAlatList = List.from(alatList);
    _searchController.addListener(_filterAlat);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAlat() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredAlatList = alatList.where((alat) {
        final name = alat['nama']?.toString().toLowerCase() ?? '';
        final kategori = alat['kategori']?.toString().toLowerCase() ?? '';
        return name.contains(query) || kategori.contains(query);
      }).toList();
    });
  }

  void _filterByKategori(String kategori) {
    setState(() {
      if (kategori == "Semua") {
        filteredAlatList = List.from(alatList);
      } else {
        filteredAlatList =
            alatList.where((alat) => alat['kategori'] == kategori).toList();
      }
    });
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? alat}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlatDialog(
        alat: alat,
        isEdit: alat != null,
      ),
    );

    if (result == true && mounted) {
      setState(() {
        filteredAlatList = List.from(alatList);
      });
    }
  }

  Future<void> _deleteAlat(Map<String, dynamic> alat) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteAlatConfirmationDialog(
        alatName: alat['nama'] ?? '',
        alatId: alat['id'] ?? '',
      ),
    );

    if (result == true && mounted) {
      setState(() {
        alatList.removeWhere((item) => item['id'] == alat['id']);
        filteredAlatList = List.from(alatList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Padding(
        padding: const EdgeInsets.only(top: 70, bottom: 60),
        child: const SideBar(currentPage: "Alat"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, size: 32),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                const SizedBox(width: 16),
                const Text(
                  "Alat",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Search bar dan tombol tambah
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: "Search",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => _showAddEditDialog(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Header "Daftar Alat" dengan filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daftar Alat",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, size: 26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: _filterByKategori,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: "Semua", child: Text("Semua")),
                    const PopupMenuItem(
                        value: "Alat Masak", child: Text("Alat Masak")),
                    const PopupMenuItem(
                        value: "Alat Potong", child: Text("Alat Potong")),
                    const PopupMenuItem(
                        value: "Alat Dekorasi", child: Text("Alat Dekorasi")),
                    const PopupMenuItem(
                        value: "Alat Pastry", child: Text("Alat Pastry")),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // GridView untuk menampilkan alat cards
            if (filteredAlatList.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredAlatList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final Map<String, dynamic> alat = filteredAlatList[index];

                  return AlatCard(
                    namaAlat: alat['nama'],
                    kategori: alat['kategori'],
                    kondisi: alat['kondisi'],
                    imageUrl: alat['imageUrl'],
                    onEdit: () => _showAddEditDialog(alat: alat),
                    onDelete: () => _deleteAlat(alat),
                  );
                },
              ),

            // Pesan jika tidak ada data
            if (filteredAlatList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.construction,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'Belum ada alat'
                            : 'Alat tidak ditemukan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}