import 'package:aplikasi_peminjaman_alat/core/services/riwayat_service.dart';
import 'package:aplikasi_peminjaman_alat/models/riwayat_model.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/riwayat/riwaya_dialog.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/riwayat/riwayat_card.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/widgets/side_bar.dart';
import 'package:flutter/material.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final RiwayatService _riwayatService = RiwayatService();

  String _activeFilter = 'Semua';
  List<Riwayat> riwayatList = [];
  List<Riwayat> filteredList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRiwayat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _riwayatService.getAllRiwayat();
      setState(() {
        riwayatList = data;
        filteredList = List.from(data);
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

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredList = riwayatList.where((riwayat) {
        final nama = riwayat.namaUser?.toLowerCase() ?? '';
        final alat = riwayat.namaAlat?.toLowerCase() ?? '';
        final catatan = riwayat.catatan?.toLowerCase() ?? '';

        final matchSearch = nama.contains(query) || 
                           alat.contains(query) || 
                           catatan.contains(query);
        
        final matchFilter = _activeFilter == 'Semua' || 
                           (_activeFilter == 'Pengembalian');

        return matchSearch && matchFilter;
      }).toList();
    });
  }

  void _setFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _applyFilter();
    });
  }

  Future<void> _showEditDialog(Riwayat riwayat) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RiwayatDialog(
        riwayat: riwayat.toMap(),
        isEdit: true,
        onSuccess: _loadRiwayat,
      ),
    );

    if (result == true && mounted) {
      // Data berhasil diupdate atau dihapus
      await _loadRiwayat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Padding(
        padding: const EdgeInsets.only(top: 70, bottom: 60),
        child: const SideBar(currentPage: "Riwayat"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, size: 30),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'Riwayat',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Loading State
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Memuat data riwayat...'),
                    ],
                  ),
                ),
              )

            // Error State
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 50, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Gagal memuat data'),
                      SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRiwayat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              )

            else Column(
              children: [
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
                            hintText: 'Cari nama, alat, atau catatan...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilter();
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildFilter('Semua'),
                    const SizedBox(width: 8),
                    _buildFilter('Peminjaman'),
                    const SizedBox(width: 8),
                    _buildFilter('Pengembalian'),
                  ],
                ),
                const SizedBox(height: 20),

                if (filteredList.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Belum ada data riwayat'
                                : 'Data riwayat tidak ditemukan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (filteredList.isNotEmpty)
                  Column(
                    children: filteredList.map((riwayat) {
                      return RiwayatCard(
                        riwayat: riwayat.toMap(),
                        onEdit: () => _showEditDialog(riwayat), onDelete: () {  },
                        // Tidak perlu onDelete lagi karena sudah ada di dialog
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

  Widget _buildFilter(String label) {
    final isActive = _activeFilter == label;

    return Expanded(
      child: InkWell(
        onTap: () => _setFilter(label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3A587A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF3A587A)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : const Color(0xFF3A587A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}