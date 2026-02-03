import 'package:aplikasi_peminjaman_alat/widgets/side_bar.dart';
import 'package:flutter/material.dart';
import 'log_aktivitas_card.dart';

class LogAktivitas extends StatefulWidget {
  const LogAktivitas({super.key});

  @override
  State<LogAktivitas> createState() => _LogAktivitasState();
}

class _LogAktivitasState extends State<LogAktivitas> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String selectedFilter = "Semua";

  List<Map<String, dynamic>> aktivitasList = [
    {
      "id": "1",
      "name": "Chelia",
      "role": "samisama", // Menambahkan role
      "status": "Peminjaman",
      "alat": "Panci",
      "jumlah": 1,
      "alat_tambahan": true, // Untuk menampilkan alat kedua
      "tanggal_pinjam": "2026-01-20",
      "tanggal_kembali": "2026-01-24",
      "disetujui_oleh": "Melati",
    },
    {
      "id": "2",
      "name": "Asel",
      "role": "samisama", // Menambahkan role
      "status": "Peminjaman",
      "alat": "Panci",
      "jumlah": 1,
      "alat_tambahan": true,
      "tanggal_pinjam": "2026-01-20",
      "tanggal_kembali": "2026-01-24",
      "disetujui_oleh": "Melati",
    },
    {
      "id": "3",
      "name": "Egi",
      "role": "sangentadar", 
      "status": "Pengembalian",
      "alat": "Pisau",
      "jumlah": 1,
      "tanggal_pinjam": "2026-01-15",
      "tanggal_kembali": "2026-01-20",
      "disetujui_oleh": "Nadya",
    },
    {
      "id": "4",
      "name": "Melati",
      "role": "admin", 
      "status": "Peminjaman",
      "alat": "Blow Torch",
      "jumlah": 1,
      "tanggal_pinjam": "2026-01-18",
      "tanggal_kembali": "2026-01-22",
      "disetujui_oleh": "Rotul",
    },
  ];

  List<Map<String, dynamic>> filteredAktivitasList = [];

  @override
  void initState() {
    super.initState();
    filteredAktivitasList = List.from(aktivitasList);
    _searchController.addListener(_filterAktivitas);
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
        final name = aktivitas['name']?.toString().toLowerCase() ?? '';
        final alat = aktivitas['alat']?.toString().toLowerCase() ?? '';
        final status = aktivitas['status']?.toString().toLowerCase() ?? '';
        final role = aktivitas['role']?.toString().toLowerCase() ?? '';

        bool matchesSearch =
            name.contains(query) || alat.contains(query) || status.contains(query) || role.contains(query);
        bool matchesFilter = selectedFilter == "Semua" ||
            aktivitas['status'] == selectedFilter;

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

            // List Aktivitas
            if (filteredAktivitasList.isEmpty)
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

            if (filteredAktivitasList.isNotEmpty)
              Column(
                children: filteredAktivitasList.map((aktivitas) {
                  return LogAktivitasCard(
                    aktivitas: aktivitas,
                  );
                }).toList(),
              ),
          ],
          
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