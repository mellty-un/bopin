import 'package:aplikasi_peminjaman_alat/core/services/denda_service.dart';
import 'package:aplikasi_peminjaman_alat/models/denda_model.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/denda/denda_card.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/denda/denda_dialog.dart';
import 'package:aplikasi_peminjaman_alat/widgets/side_bar.dart';
import 'package:flutter/material.dart';

class KelolaDendaPage extends StatefulWidget {
  const KelolaDendaPage({super.key});

  @override
  State<KelolaDendaPage> createState() => _KelolaDendaPageState();
}

class _KelolaDendaPageState extends State<KelolaDendaPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final DendaService _dendaService = DendaService();

  List<Denda> dendaList = [];
  List<Denda> filteredDendaList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDenda();
    _searchController.addListener(_filterDenda);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDenda() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dendaData = await _dendaService.getAllDenda();
      setState(() {
        dendaList = dendaData;
        filteredDendaList = List.from(dendaData);
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

  void _filterDenda() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredDendaList = dendaList.where((denda) {
        final name = denda.jenisDenda.toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _showAddEditDialog({Denda? denda}) async {
    Map<String, dynamic>? dendaMap;
    if (denda != null) {
      dendaMap = denda.toMap();
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DendaDialog(
        denda: dendaMap,
        isEdit: denda != null,
      ),
    );

    if (result == true && mounted) {
      await _loadDenda();
      SuccessPopup.show(
        context,
        denda == null ? 'Denda berhasil ditambahkan' : 'Denda berhasil diperbarui',
      );
    }
  }

  Future<void> _deleteDenda(Denda denda) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteConfirmationDialogDenda(
        dendaName: denda.jenisDenda,
        dendaId: denda.idDenda.toString(),
      ),
    );

    if (result == true && mounted) {
      try {
        await _dendaService.deleteDenda(denda.idDenda);
        await _loadDenda();
        SuccessPopup.show(context, 'Denda berhasil dihapus');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus denda: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
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

            // Loading State
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Memuat data denda...'),
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
                        onPressed: _loadDenda,
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
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterDenda();
                                },
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
                        denda: denda.toMap(),
                        onEdit: () => _showAddEditDialog(denda: denda),
                        onDelete: () => _deleteDenda(denda),
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