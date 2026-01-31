import 'package:aplikasi_peminjaman_alat/widgets/side_bar.dart';
import 'package:flutter/material.dart';
import 'pengajuan_card.dart';

class PengajuanPage extends StatefulWidget {
  const PengajuanPage({super.key});

  @override
  State<PengajuanPage> createState() => _PengajuanPageState();
}

class _PengajuanPageState extends State<PengajuanPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedFilter = 'Semua';
  TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> allPeminjaman = [
    {
      'tanggal': '20/01/2026',
      'status': 'Menunggu',
      'alat': {'Alat': 2},
      'tanggal_pengembalian': '25/01/2026',
    },
    {
      'tanggal': '20/01/2026',
      'status': 'Dipinjam',
      'alat': {'Alat': 2},
      'tanggal_pengembalian': '24/01/2026',
    },
    {
      'tanggal': '20/01/2026',
      'status': 'Selesai',
      'alat': {'Alat': 2},
    },
    {
      'tanggal': '20/01/2026',
      'status': 'Ditolak',
      'alat': {'Alat': 2},
    },
  ];

  List<Map<String, dynamic>> get filteredData {
    var result = allPeminjaman;

    if (selectedFilter != 'Semua') {
      result = result.where((e) => e['status'] == selectedFilter).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.1,
            bottom: screenHeight * 0.05,
          ),
          child: SideBar(currentPage: "PeminjamanPetugas"),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 24,
                vertical: 16,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.menu, size: isSmallScreen ? 28 : 32),
                    onPressed: () =>
                        _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Peminjaman",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            _searchBar(),
            _filterChips(),

            /// LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  return PengajuanCard(data: filteredData[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _filterChips() {
    final filters = ['Semua', 'Menunggu', 'Dipinjam', 'Selesai', 'Ditolak'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final selected = selectedFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f),
                selected: selected,
                onSelected: (_) =>
                    setState(() => selectedFilter = f),
                selectedColor: const Color(0xff36536B),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
