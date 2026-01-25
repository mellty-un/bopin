import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/denda/denda_card.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/denda/denda_dialog.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/widgets/side_bar.dart';
import 'package:flutter/material.dart';


class KelolaDendaPage extends StatefulWidget {
  const KelolaDendaPage({super.key});

  @override
  State<KelolaDendaPage> createState() => _KelolaDendaPageState();
}

class _KelolaDendaPageState extends State<KelolaDendaPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> dendaList = [
    {"name": "Terlambat", "amount": 5000, "id": "1", "denda_id": "1"},
    {"name": "Rusak", "amount": 5000, "id": "2", "denda_id": "2"},
    {"name": "Hilang", "amount": 5000, "id": "3", "denda_id": "3"},
  ];

  List<Map<String, dynamic>> filteredDendaList = [];

  @override
  void initState() {
    super.initState();
    filteredDendaList = List.from(dendaList);
    _searchController.addListener(_filterDenda);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDenda() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredDendaList = List.from(dendaList);
      } else {
        filteredDendaList = dendaList.where((denda) {
          final name = denda['name']?.toString().toLowerCase() ?? '';
          return name.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? denda}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DendaDialog(
        denda: denda,
        isEdit: denda != null,
      ),
    );

    if (result == true && mounted) {

      setState(() {});
      
      SuccessPopup.show(
        context,
        denda == null ? 'Denda berhasil ditambahkan' : 'Denda berhasil diperbarui',
      );
    }
  }

  Future<void> _deleteDenda(Map<String, dynamic> denda) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteConfirmationDialogDenda(
        dendaName: denda['name'],
        dendaId: denda['id'],
      ),
    );

    if (result == true && mounted) {
      // Hapus dari data dummy
      setState(() {
        dendaList.removeWhere((item) => item['id'] == denda['id']);
        filteredDendaList = List.from(dendaList);
      });
      
      // Tampilkan popup sukses
      SuccessPopup.show(context, 'Denda berhasil dihapus');
    }
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
key: _scaffoldKey,
     drawer: Padding(
  padding: const EdgeInsets.only(top: 70, bottom: 60),
  child: const SideBar(currentPage: "Denda"),
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
                    "Kelola Denda",
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
                              hintText: "Search denda...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Tombol tambah berupa icon saja (kotak)
                InkWell(
                  onTap: () => _showAddEditDialog(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
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
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            if (filteredDendaList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.money_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'Belum ada data denda'
                            : 'Data denda tidak ditemukan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (filteredDendaList.isNotEmpty)
              Column(
                children: filteredDendaList.map((denda) {
                  return DendaCard(
                    denda: denda,
                    onEdit: () => _showAddEditDialog(denda: denda),
                    onDelete: () => _deleteDenda(denda),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}