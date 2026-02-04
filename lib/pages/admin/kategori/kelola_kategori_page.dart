import 'package:aplikasi_peminjaman_alat/core/services/kategori_service.dart';
import 'package:aplikasi_peminjaman_alat/core/services/supabase_service.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:aplikasi_peminjaman_alat/models/kategori_model.dart';
import 'package:aplikasi_peminjaman_alat/widgets/side_bar.dart';
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
  final KategoriService _kategoriService = KategoriService();

  List<Map<String, dynamic>> kategoriList = [];
  List<Map<String, dynamic>> filteredKategoriList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadKategori();
    _searchController.addListener(_filterKategori);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadKategori() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Kategori> kategori = await _kategoriService.getAllKategori();
      
      // Convert ke List<Map> untuk kompatibilitas dengan KategoriCard yang lama
      final List<Map<String, dynamic>> kategoriMapList = kategori.map((k) {
        return {
          'id': k.idKategori.toString(),
          'id_kategori': k.idKategori,
          'nama_kategori': k.namaKategori,
          'name': k.namaKategori, // backup key
        };
      }).toList();
      
      setState(() {
        kategoriList = kategoriMapList;
        filteredKategoriList = List<Map<String, dynamic>>.from(kategoriMapList);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterKategori() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredKategoriList = List<Map<String, dynamic>>.from(kategoriList);
      } else {
        filteredKategoriList = kategoriList.where((kategori) {
          final name = kategori['nama_kategori']?.toString().toLowerCase() ?? 
                      kategori['name']?.toString().toLowerCase() ?? '';
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
      await _loadKategori(); // Refresh data dari Supabase
      
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
        kategoriName: kategori['nama_kategori'] ?? kategori['name'] ?? '',
        kategoriId: kategori['id_kategori']?.toString() ?? 
                   kategori['id']?.toString() ?? '0',
      ),
    );

    if (result == true && mounted) {
      try {
        final id = int.tryParse(kategori['id_kategori']?.toString() ?? 
                               kategori['id']?.toString() ?? '0') ?? 0;
        await _kategoriService.deleteKategori(id);
        
        // Remove dari list lokal
        setState(() {
          kategoriList.removeWhere((item) => 
            item['id_kategori'] == kategori['id_kategori'] ||
            item['id'] == kategori['id']
          );
          filteredKategoriList = List<Map<String, dynamic>>.from(kategoriList);
        });
        
        SuccessPopup.show(context, 'Kategori berhasil dihapus');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menghapus: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
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

            // Loading State
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Memuat data kategori...',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )

            // Error State
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat data',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadKategori,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Coba Lagi',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )

            else Column(
              children: [
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
                          height: 100,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}