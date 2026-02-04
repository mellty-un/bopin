import 'package:aplikasi_peminjaman_alat/widgets/side_bar.dart';
import 'package:flutter/material.dart';
import 'log_aktivitas_card.dart';
import 'package:aplikasi_peminjaman_alat/core/services/log_aktivitas_service.dart'; // Import service baru

class LogAktivitas extends StatefulWidget {
  const LogAktivitas({super.key});

  @override
  State<LogAktivitas> createState() => _LogAktivitasState();
}

class _LogAktivitasState extends State<LogAktivitas> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String selectedFilter = "Semua";
  bool isLoading = true; 

  List<Map<String, dynamic>> aktivitasList = [];
  List<Map<String, dynamic>> filteredAktivitasList = [];

  @override
  void initState() {
    super.initState();
    _loadAktivitas(); 
    _searchController.addListener(_filterAktivitas);
  }

  // Fungsi untuk load data dari Supabase
  Future<void> _loadAktivitas() async {
    try {
      // Gunakan salah satu method sesuai kebutuhan
      final data = await LogAktivitasService.fetchLogAktivitasLengkap();
      
      setState(() {
        aktivitasList = data;
        filteredAktivitasList = List.from(aktivitasList);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading aktivitas: $e');
      setState(() {
        isLoading = false;
      });
      
      // Fallback ke data dummy jika error (opsional)
      aktivitasList = [
        {
          "id": "1",
          "name": "Chelia",
          "role": "samisama",
          "status": "Peminjaman",
          "alat": "Panci",
          "jumlah": 1,
          "alat_tambahan": true,
          "tanggal_pinjam": "2026-01-20",
          "tanggal_kembali": "2026-01-24",
          "disetujui_oleh": "Melati",
        },
        // ... data dummy lainnya
      ];
      filteredAktivitasList = List.from(aktivitasList);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

 void _filterAktivitas() {
  final query = _searchController.text.toLowerCase();

  setState(() {
    filteredAktivitasList = aktivitasList.where((aktivitas) {
      final name = (aktivitas['name'] ?? '').toString().toLowerCase();
      final alat = (aktivitas['alat'] ?? '').toString().toLowerCase();
      final role = (aktivitas['role'] ?? '').toString().toLowerCase();
      final status = (aktivitas['status'] ?? '').toString().toLowerCase();

      // SEARCH
      final matchesSearch =
          name.contains(query) ||
          alat.contains(query) ||
          role.contains(query) ||
          status.contains(query);

      // FILTER STATUS
      bool matchesFilter;
      if (selectedFilter == "Semua") {
        matchesFilter = true;
      } else {
        matchesFilter = status == selectedFilter.toLowerCase();
      }

      return matchesSearch && matchesFilter;
    }).toList();
  });
}

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      _filterAktivitas();
    });
  }

  // Refresh data
  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await _loadAktivitas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Padding(
        padding: const EdgeInsets.only(top: 70, bottom: 60),
        child: const SideBar(currentPage: "Log Aktivitas"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
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
                      "Log Aktivitas",
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

              // Search Bar
              Container(
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

              const SizedBox(height: 20),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("Semua"),
                    const SizedBox(width: 8),
                    _buildFilterChip("Peminjaman"),
                    const SizedBox(width: 8),
                    _buildFilterChip("Pengembalian"),
                    const SizedBox(width: 8),
                    _buildFilterChip("Menunggu"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Loading indicator
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              // List Aktivitas atau empty state
              if (!isLoading && filteredAktivitasList.isEmpty)
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
                              ? 'Belum ada aktivitas'
                              : 'Aktivitas tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (!isLoading && filteredAktivitasList.isNotEmpty)
                Column(
                  children: filteredAktivitasList.map((aktivitas) {
                    return LogAktivitasCard(
                      aktivitas: aktivitas,
                      showActionButton: false, // Nonaktifkan tombol untuk data real
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => _applyFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3A587A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF3A587A) : Colors.black26,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}