import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/kelola%20pengguna/pengguna_dialog.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/widgets/side_bar.dart';
import 'package:flutter/material.dart';
import 'pengguna_card.dart';


class KelolaPenggunaPage extends StatefulWidget {
  const KelolaPenggunaPage({super.key});

  @override
  State<KelolaPenggunaPage> createState() => _KelolaPenggunaPageState();
}

class _KelolaPenggunaPageState extends State<KelolaPenggunaPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  // Dummy data dengan email dan password untuk pengujian
  List<Map<String, dynamic>> penggunaList = [
    {"name": "Nadya", "role": "Admin", "id": "1", "email": "nadya@gmail.com"},
    {"name": "Rotul", "role": "Petugas", "id": "2", "email": "rotul@gmail.com"},
    {"name": "Chella", "role": "Peminjam", "id": "3", "email": "chella@gmail.com"},
    {"name": "Viona", "role": "Peminjam", "id": "4", "email": "viona@gmail.com"},
    {"name": "Asel", "role": "Peminjam", "id": "5", "email": "asel@gmail.com"},
    {"name": "Egi", "role": "Peminjam", "id": "6", "email": "egi@gmail.com"},
  ];

  List<Map<String, dynamic>> filteredPenggunaList = [];

  @override
  void initState() {
    super.initState();
    filteredPenggunaList = List.from(penggunaList);
    _searchController.addListener(_filterPengguna);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPengguna() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredPenggunaList = List.from(penggunaList);
      } else {
        filteredPenggunaList = penggunaList.where((pengguna) {
          final name = pengguna['name']?.toString().toLowerCase() ?? '';
          final role = pengguna['role']?.toString().toLowerCase() ?? '';
          final email = pengguna['email']?.toString().toLowerCase() ?? '';
          return name.contains(query) || role.contains(query) || email.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? pengguna}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PenggunaDialog(
        pengguna: pengguna,
        isEdit: pengguna != null,
      ),
    );

    if (result == true && mounted) {
     
      setState(() {});
      
      SuccessPopup.show(
        context,
        pengguna == null ? 'Pengguna berhasil ditambahkan' : 'Pengguna berhasil diperbarui',
      );
    }
  }

  Future<void> _deletePengguna(Map<String, dynamic> pengguna) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteConfirmationDialog(
        penggunaName: pengguna['name'],
        penggunaId: pengguna['id'],
      ),
    );

    if (result == true && mounted) {
      setState(() {
        penggunaList.removeWhere((item) => item['id'] == pengguna['id']);
        filteredPenggunaList = List.from(penggunaList);
      });
      
      SuccessPopup.show(context, 'Pengguna berhasil dihapus');
    }
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
key: _scaffoldKey,
     drawer: Padding(
  padding: const EdgeInsets.only(top: 70, bottom: 60),
  child: const SideBar(currentPage: "pengguna"),
),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                    "Kelola Pengguna",
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A587A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "Tambah Pengguna",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.add, size: 22, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // List pengguna atau pesan kosong
            if (filteredPenggunaList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Belum ada pengguna'
                              : 'Pengguna tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                ),
              ),

            if (filteredPenggunaList.isNotEmpty)
              Column(
                children: filteredPenggunaList.map((pengguna) {
                  return PenggunaCard(
                    pengguna: pengguna,
                    onEdit: () => _showAddEditDialog(pengguna: pengguna),
                    onDelete: () => _deletePengguna(pengguna),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}