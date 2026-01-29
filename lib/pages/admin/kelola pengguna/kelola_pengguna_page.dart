import 'package:aplikasi_peminjaman_alat/core/services/pengguna_service.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:aplikasi_peminjaman_alat/models/pengguna_model.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/kelola%20pengguna/pengguna_dialog.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/widgets/delete_confirmation_diaalog.dart';
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

  List<PenggunaModel> penggunaList = [];
  List<PenggunaModel> filteredPenggunaList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPengguna();
    _searchController.addListener(_filterPengguna);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPengguna() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await PenggunaService.getAllPengguna();

      if (mounted) {
        setState(() {
          penggunaList = data;
          filteredPenggunaList = List.from(penggunaList);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat pengguna: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterPengguna() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredPenggunaList = List.from(penggunaList);
      } else {
        filteredPenggunaList = penggunaList.where((pengguna) {
          final nama = pengguna.nama.toLowerCase();
          final role = pengguna.role.toLowerCase();
          final email = pengguna.email?.toLowerCase() ?? '';
          return nama.contains(query) || role.contains(query) || email.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _showAddEditDialog({PenggunaModel? pengguna}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PenggunaDialog(
        pengguna: pengguna,
        isEdit: pengguna != null,
      ),
    );

    if (result == true && mounted) {
      await _loadPengguna();
      
      if (mounted) {
        SuccessPopup.show(
          context,
          pengguna == null 
              ? 'Pengguna berhasil ditambahkan' 
              : 'Pengguna berhasil diperbarui',
        );
      }
    }
  }

  Future<void> _deletePengguna(PenggunaModel pengguna) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PenggunaDeleteDialog(
        penggunaName: pengguna.nama,
        penggunaId: pengguna.idUser,
      ),
    );

    if (result == true && mounted) {
      await _loadPengguna();
      
      if (mounted) {
        SuccessPopup.show(context, 'Pengguna berhasil dihapus');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const Drawer(
        child: Padding(
          padding: EdgeInsets.only(top: 70, bottom: 60),
          child: SideBar(currentPage: "pengguna"),
        ),
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

            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: Color(0xFF3A587A),
                  ),
                ),
              )
            else if (filteredPenggunaList.isEmpty)
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
              )
            else
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