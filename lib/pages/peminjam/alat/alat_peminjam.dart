import 'package:aplikasi_peminjaman_alat/core/services/alat_service.dart';
import 'package:aplikasi_peminjaman_alat/models/alat_model.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/widgets/side_bar.dart';
import 'package:aplikasi_peminjaman_alat/pages/peminjam/alat/alat_card_peminjam.dart';
import 'package:flutter/material.dart';
import 'keranjang_page.dart';

class AlatPeminjamPage extends StatefulWidget {
  const AlatPeminjamPage({super.key});

  @override
  State<AlatPeminjamPage> createState() => _AlatPeminjamPageState();
}

class _AlatPeminjamPageState extends State<AlatPeminjamPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final AlatService _alatService = AlatService();

  List<Alat> alatList = [];
  List<Alat> filteredAlatList = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isRefreshing = false;

  // Keranjang untuk menyimpan alat yang dipilih
  final List<Alat> _keranjangAlat = [];
  final Map<int, int> _jumlahPesanan = {}; // key: idAlat, value: jumlah

  @override
  void initState() {
    super.initState();
    _loadAlatData();
    _searchController.addListener(_filterAlat);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAlatData() async {
    if (!_isRefreshing) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final alatData = await _alatService.getAllAlat();

      setState(() {
        alatList = alatData;
        filteredAlatList = List.from(alatData);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      print('Error loading alat data: $e');
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
        
        return namaMatch || kategoriMatch;
      }).toList();
    });
  }

  void _tambahKeKeranjang(Alat alat) {
    setState(() {
      final existingIndex = _keranjangAlat.indexWhere((item) => item.idAlat == alat.idAlat);
      
      if (existingIndex >= 0) {
        final currentJumlah = _jumlahPesanan[alat.idAlat] ?? 1;
        final stokTersedia = alat.stokTersedia ?? 0;
        if (currentJumlah < stokTersedia) {
          _jumlahPesanan[alat.idAlat] = currentJumlah + 1;
          _showSnackBar('${alat.namaAlat} jumlah ditambah', Colors.blue);
        } else {
          _showSnackBar('Stok ${alat.namaAlat} tidak mencukupi', Colors.orange);
        }
      } else {
        _keranjangAlat.add(alat);
        _jumlahPesanan[alat.idAlat] = 1;
        _showSnackBar('${alat.namaAlat} ditambahkan ke keranjang', Colors.green);
      }
    });
  }
 


  int _getTotalItems() {
    return _jumlahPesanan.values.fold(0, (sum, jumlah) => sum + jumlah);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadAlatData();
  }

  void _navigateToKeranjang() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KeranjangPage(
          keranjangAlat: _keranjangAlat,
          jumlahPesanan: _jumlahPesanan,
          onUpdate: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideBar(currentPage: "Alat Peminjam"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart, size: 28),
                        onPressed: _navigateToKeranjang,
                      ),
                      if (_getTotalItems() > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${_getTotalItems()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
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

              if (_isLoading && !_isRefreshing)
                _buildLoadingState()

              else if (_errorMessage != null)
                _buildErrorState()

              else
                Column(
                  children: [
                    _buildSearchBar(),

                    const SizedBox(height: 30),

                    _buildHeader(),

                    const SizedBox(height: 16),

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
              onPressed: _loadAlatData,
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

  Widget _buildSearchBar() {
    return Container(
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
    );
  }

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Daftar Alat",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        final jumlahDiKeranjang = _jumlahPesanan[alat.idAlat] ?? 0;
        
        return AlatCardPeminjam(
          alat: alat,
          onTap: () => _tambahKeKeranjang(alat),
          jumlahDiKeranjang: jumlahDiKeranjang,
        
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
              'Belum ada alat tersedia',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}