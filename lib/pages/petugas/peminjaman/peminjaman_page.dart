import 'package:aplikasi_peminjaman_alat/pages/admin/widgets/side_bar.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/peminjaman/pemijaman_card.dart';
import 'package:flutter/material.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  String filter = 'Semua';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> data = [
    {
      'nama': 'Chella',
      'tanggal': '20/01/2025',
      'kembali': '24/01/2026',
      'status': 'Pengajuan',
      'alat': {'Panci': 1, 'Pisau': 1},
    },
    {
      'nama': 'Viona',
      'tanggal': '20/01/2026',
      'status': 'Disetujui',
      'alat': {},
    },
    {
      'nama': 'Asel',
      'tanggal': '20/01/2026',
      'status': 'Disetujui',
      'alat': {},
    },
    {'nama': 'Egi', 'tanggal': '20/01/2026', 'status': 'Ditolak', 'alat': {}},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;

    final filteredData = filter == 'Semua'
        ? data
        : data.where((e) => e['status'] == filter).toList();

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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12.0 : 24.0,
            vertical: isSmallScreen ? 8.0 : 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.menu, size: isSmallScreen ? 28.0 : 32.0),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    SizedBox(width: isSmallScreen ? 12.0 : 16.0),
                    Text(
                      "Peminjaman",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20.0 : 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

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
                          hintText: "Search",
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Peminjaman',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 13.0 : 14.0,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    height: isSmallScreen ? 26.0 : 28.0,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6.0 : 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF36536B)),
                    ),
                    child: DropdownButton<String>(
                      value: filter,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        size: isSmallScreen ? 16.0 : 18.0,
                      ),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12.0 : 14.0,
                        color: Colors.black87,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                        DropdownMenuItem(
                          value: 'Pengajuan',
                          child: Text('Pengajuan'),
                        ),
                        DropdownMenuItem(
                          value: 'Disetujui',
                          child: Text('Disetujui'),
                        ),
                        DropdownMenuItem(
                          value: 'Ditolak',
                          child: Text('Ditolak'),
                        ),
                        DropdownMenuItem(
                          value: 'Dikembalikan',
                          child: Text('Dikembalikan'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          filter = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 8.0 : 12.0),

              Expanded(
                child: filteredData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: isSmallScreen ? 50.0 : 60.0,
                              color: Colors.grey,
                            ),
                            SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                            Text(
                              'Tidak ada data peminjaman',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: isSmallScreen ? 14.0 : 16.0,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: isSmallScreen ? 8.0 : 12.0,
                            ),
                            child: PeminjamanCard(
                              data: filteredData[index],
                              onUpdate: (status) {
                                setState(() {
                                  filteredData[index]['status'] = status;
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
