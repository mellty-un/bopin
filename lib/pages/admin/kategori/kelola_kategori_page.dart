import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/widgets/side_bar.dart';
import 'package:flutter/material.dart';
import 'kategori_card.dart';
import 'kategori_dialog.dart';

class KelolaKategoriPage extends StatefulWidget {
  const KelolaKategoriPage({super.key});

  @override
  State<KelolaKategoriPage> createState() => _KelolaKategoriPageState();
}

class _KelolaKategoriPageState extends State<KelolaKategoriPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> kategoriList = [
    {"name": "Alat Masak", "id": "1"},
    {"name": "Alat Potong", "id": "2"},
    {"name": "Alat Dekorasi", "id": "3"},
    {"name": "Alat Pastry", "id": "4"},
  ];

  List<Map<String, dynamic>> filteredKategoriList = [];

  @override
  void initState() {
    super.initState();
    filteredKategoriList = List.from(kategoriList);
    _searchController.addListener(_filterKategori);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterKategori() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredKategoriList = List.from(kategoriList);
      } else {
        filteredKategoriList = kategoriList.where((kategori) {
          final name = kategori['name']?.toString().toLowerCase() ?? '';
          return name.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? kategori}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => KategoriDialog(
        kategori: kategori,
        isEdit: kategori != null,
      ),
    );

    if (result == true && mounted) {
     
      setState(() {});
      
      SuccessPopup.show(
        context,
        kategori == null ? 'Kategori berhasil ditambahkan' : 'Kategori berhasil diperbarui',
      );
    }
  }

  Future<void> _deleteKategori(Map<String, dynamic> kategori) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteConfirmationDialog(
        kategoriName: kategori['name'],
        kategoriId: kategori['id'],
      ),
    );

    if (result == true && mounted) {
      setState(() {
        kategoriList.removeWhere((item) => item['id'] == kategori['id']);
        filteredKategoriList = List.from(kategoriList);
      });
      
      SuccessPopup.show(context, 'Kategori berhasil dihapus');
    }
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
key: _scaffoldKey,
     drawer: Padding(
  padding: const EdgeInsets.only(top: 70, bottom: 60),
  child: const SideBar(currentPage: "Kategori"),
),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header dengan menu dan judul
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 32, color: Colors.black87),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Kelola Kategori",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

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
                        const Icon(Icons.search, color: Colors.black54),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                       border: Border.all(
        color: Colors.black,
        width: 1.2,
      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            if (filteredKategoriList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'Belum ada kategori'
                            : 'Kategori tidak ditemukan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (filteredKategoriList.isNotEmpty)
              Column(
                children: filteredKategoriList.map((kategori) {
                  return KategoriCard(
                    kategori: kategori,
                    onEdit: () => _showAddEditDialog(kategori: kategori),
                    onDelete: () => _deleteKategori(kategori),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
