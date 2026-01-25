import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
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

  String _activeFilter = 'Semua';

  List<Map<String, dynamic>> riwayatList = [
    {"nama": "Chella", "tipe": "Peminjaman"},
    {"nama": "Asel", "tipe": "Peminjaman"},
    {"nama": "Egi", "tipe": "Pengembalian"},
    {"nama": "Viona", "tipe": "Peminjaman"},
  ];

  List<Map<String, dynamic>> filteredList = [];

  @override
  void initState() {
    super.initState();
    filteredList = List.from(riwayatList);
    _searchController.addListener(_applyFilter);
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredList = riwayatList.where((item) {
        final nama = item['nama'].toString().toLowerCase();
        final tipe = item['tipe'];

        final matchSearch = nama.contains(query);
        final matchFilter =
            _activeFilter == 'Semua' || tipe == _activeFilter;

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

  Future<void> _showEditDialog(Map<String, dynamic> riwayat) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RiwayatDialog(
        riwayat: riwayat,
        isEdit: true,
      ),
    );

    if (result == true && mounted) {
      SuccessPopup.show(context, 'Pengembalian berhasil disimpan');
    }
  }

  Future<void> _deleteRiwayat(Map<String, dynamic> riwayat) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          DeleteConfirmationDialogRiwayat(riwayatId: '1'),
    );

    if (result == true && mounted) {
      setState(() {
        riwayatList.remove(riwayat);
        _applyFilter();
      });
      SuccessPopup.show(context, 'Pengembalian berhasil dihapus');
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
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                    ),
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
            Column(
              children: filteredList.map((riwayat) {
                return RiwayatCard(
                  riwayat: riwayat,
                  onEdit: () => _showEditDialog(riwayat),
                  onDelete: () => _deleteRiwayat(riwayat),
                );
              }).toList(),
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
