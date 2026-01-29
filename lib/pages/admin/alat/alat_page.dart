import 'package:aplikasi_peminjaman_alat/core/services/alat_service.dart';
import 'package:aplikasi_peminjaman_alat/core/services/kategori_service.dart';
import 'package:aplikasi_peminjaman_alat/models/alat_model.dart';
import 'package:flutter/material.dart';
import 'alat_card.dart';
import 'alat_dialog.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/widgets/side_bar.dart';

class AlatPage extends StatefulWidget {
  const AlatPage({super.key});

  @override
  State<AlatPage> createState() => _AlatPageState();
}

class _AlatPageState extends State<AlatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final AlatService _alatService = AlatService();
  final KategoriService _kategoriService = KategoriService();

  List<Alat> alatList = []; // Gunakan model Alat langsung
  List<Alat> filteredAlatList = [];
  List<String> kategoriFilterOptions = ['Semua'];
  String _selectedFilter = 'Semua';
  bool _isLoading = true;
  String? _errorMessage;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterAlat);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!_isRefreshing) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Load alat dan kategori secara parallel
      final results = await Future.wait([
        _alatService.getAllAlat(),
        _kategoriService.getAllKategoriNames(),
      ]);

      final alatData = results[0] as List<Alat>;
      final kategoriData = results[1] as List<String>;

      setState(() {
        alatList = alatData;
        filteredAlatList = List.from(alatData);
        kategoriFilterOptions = ['Semua'] + kategoriData;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

void _filterAlat() {
  final query = _searchController.text.toLowerCase();
  setState(() {
    filteredAlatList = alatList.where((alat) {
      final namaMatch = alat.namaAlat?.toLowerCase().contains(query) ?? false;
      final kategoriAlat = alat.kategori?.namaKategori ?? '';
      final kategoriMatch = kategoriAlat.toLowerCase().contains(query);
      final filterMatch = _selectedFilter == 'Semua' || kategoriAlat == _selectedFilter;
      
      return (namaMatch || kategoriMatch) && filterMatch;
    }).toList();
  });
}

  void _filterByKategori(String kategori) {
    setState(() {
      _selectedFilter = kategori;
      _filterAlat();
    });
  }

  Future<void> _showAddEditDialog({Alat? alat}) async {
  Map<String, dynamic>? alatMap;
  if (alat != null) {
    alatMap = {
      'id': alat.idAlat,
      'nama_alat': alat.namaAlat,
      'id_kategori': alat.idKategori,
      'kondisi': alat.kondisi,
      'gambar': alat.gambar,
      'stok_total': alat.stokTotal,
      'stok_tersedia': alat.stokTersedia,
      'kategori_nama': alat.kategori?.namaKategori,
    };
  }

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlatDialog(
      alat: alatMap, 
      isEdit: alat != null,
      onSuccess: () => _loadData(),
    ),
  );

  if (result == true && mounted) {
    _showSuccessSnackBar(alat == null ? 'Alat berhasil ditambahkan' : 'Alat berhasil diperbarui');
    await _loadData();
  }
}

  Future<void> _deleteAlat(Alat alat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Alat'),
        content: Text('Apakah Anda yakin ingin menghapus alat "${alat.namaAlat}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _alatService.deleteAlat(alat.idAlat);
        _showSuccessSnackBar('Alat berhasil dihapus');
        await _loadData();
      } catch (e) {
        _showErrorSnackBar('Gagal menghapus alat: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Padding(
        padding: const EdgeInsets.only(top: 70, bottom: 60),
        child: const SideBar(currentPage: "Alat"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header dengan menu dan title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 32),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Alat",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_isRefreshing)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 25),

              // Loading State
              if (_isLoading && !_isRefreshing)
                _buildLoadingState()

              // Error State
              else if (_errorMessage != null)
                _buildErrorState()

              else
                Column(
                  children: [
                    // Search bar dan tombol tambah
                    _buildSearchAndAddButton(),

                    const SizedBox(height: 30),

                    // Header "Daftar Alat" dengan filter
                    _buildHeaderAndFilter(),

                    const SizedBox(height: 16),

                    // GridView untuk menampilkan alat cards
                    _buildAlatGrid(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Memuat data alat...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Column(
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
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndAddButton() {
    return Row(
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
                const Icon(Icons.search),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Cari alat atau kategori...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _filterAlat();
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderAndFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Daftar Alat",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            if (_selectedFilter != 'Semua')
              Chip(
                label: Text(_selectedFilter),
                onDeleted: () => _filterByKategori('Semua'),
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list, size: 26),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: _filterByKategori,
              itemBuilder: (context) => kategoriFilterOptions.map((kategori) {
                return PopupMenuItem(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

Widget _buildAlatGrid() {
  if (filteredAlatList.isEmpty) {
    return _buildEmptyState();
  }

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: filteredAlatList.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
    ),
    itemBuilder: (context, index) {
      final alat = filteredAlatList[index];
      return AlatCard(
        namaAlat: alat.namaAlat ?? 'Tanpa Nama',
        kategori: alat.kategori?.namaKategori ?? 'Tidak Ada Kategori',
        kondisi: alat.kondisi ?? 'Tidak Diketahui',
        imageUrl: alat.gambar,
        onEdit: () => _showAddEditDialog(alat: alat),
        onDelete: () => _deleteAlat(alat),
      );
    },
  );
}

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty || _selectedFilter != 'Semua'
                  ? 'Belum ada alat'
                  : 'Alat tidak ditemukan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (_searchController.text.isNotEmpty || _selectedFilter != 'Semua')
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _filterByKategori('Semua');
                },
                child: const Text('Reset pencarian'),
              ),
          ],
        ),
      ),
    );
  }
}