import 'package:aplikasi_peminjaman_alat/core/services/pemijaman_user_service.dart';
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
  final PeminjamanUserService _peminjamanUserService = PeminjamanUserService();

  String selectedFilter = 'Semua';
  TextEditingController searchController = TextEditingController();
  
  List<Map<String, dynamic>> allPeminjaman = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPeminjamanData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPeminjamanData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _peminjamanUserService.getPeminjamanByUser();
      setState(() {
        allPeminjaman = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadPeminjamanData();
  }

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
     drawer: Padding(
        padding: const EdgeInsets.only(top: 70, bottom: 60),
        child: const SideBar(currentPage: "Pengajuan"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
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
                      "Pengajuan",
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
                child: _isLoading
                    ? _buildLoadingState()
                    : _errorMessage != null
                        ? _buildErrorState()
                        : filteredData.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredData.length,
                                itemBuilder: (context, index) {
                                  return PengajuanCard(
                                    data: filteredData[index],
                                    onRefresh: _refreshData,
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Memuat data peminjaman...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: TextStyle(fontSize: 16, color: Colors.red[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Terjadi kesalahan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPeminjamanData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff36536B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada peminjaman',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
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
    final filters = ['Semua', 'Menunggu', 'Disetujui', 'Ditolak', 'Dikembalikan'];

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