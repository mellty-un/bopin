import 'package:aplikasi_peminjaman_alat/widgets/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_peminjaman_alat/core/theme/app_color.dart';
import 'package:aplikasi_peminjaman_alat/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SupabaseClient _supabase = SupabaseService.client;

  int totalUsers = 0;
  int totalAlat = 0;
  int totalKategori = 0;
  int totalPeminjam = 0;
  List<Map<String, dynamic>> recentHistory = [];
String? userName;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
     _loadCurrentUser();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await Future.wait([
        _loadTotalUsers(),
        _loadTotalAlat(),
        _loadTotalKategori(),
        _loadTotalPeminjam(),
        _loadRecentHistory(),
        
      ]);
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data dashboard';
      });
      print('Error loading dashboard: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentUser() async {
  try {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      // Ambil nama user dari tabel users
      final response = await _supabase
          .from('users')
          .select('nama')
          .eq('id_user', user.id)
          .single();

      setState(() {
        userName = response['nama'] as String?;
      });
    }
  } catch (e) {
    print('Error loading current user: $e');
    setState(() {
      userName = 'User';
    });
  }
}

  Future<void> _loadTotalUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id_user')
          .count(CountOption.exact);

      setState(() {
        totalUsers = response.count ?? 0;
      });
    } catch (e) {
      print('Error loading total users: $e');
    }
  }

  Future<void> _loadTotalAlat() async {
    try {
      final response = await _supabase
          .from('alat')
          .select('id_alat')
          .count(CountOption.exact);

      setState(() {
        totalAlat = response.count ?? 0;
      });
    } catch (e) {
      print('Error loading total alat: $e');
    }
  }

  Future<void> _loadTotalKategori() async {
    try {
      final response = await _supabase
          .from('kategori')
          .select('id_kategori')
          .count(CountOption.exact);

      setState(() {
        totalKategori = response.count ?? 0;
      });
    } catch (e) {
      print('Error loading total kategori: $e');
    }
  }

  Future<void> _loadTotalPeminjam() async {
    try {
      // Hitung peminjam aktif (status bukan Ditolak)
      final response = await _supabase
          .from('peminjaman')
          .select('id_peminjaman')
          .neq('status', 'Ditolak')
          .count(CountOption.exact);

      setState(() {
        totalPeminjam = response.count ?? 0;
      });
    } catch (e) {
      print('Error loading total peminjam: $e');
    }
  }

  Future<void> _loadRecentHistory() async {
    try {
      final response = await _supabase
          .from('pengembalian')
          .select('''
            id_pengembalian,
            tgl_dikembalikan,
            kondisi_pengembalian,
            catatan,
            peminjaman!inner(
              id_peminjaman,
              nama_user,
              detail_peminjaman(
                alat(nama_alat)
              )
            )
          ''')
          .order('tgl_dikembalikan', ascending: false)
          .limit(3);

      final List<Map<String, dynamic>> history = [];

      for (var item in response) {
        try {
          final peminjaman = item['peminjaman'] as Map<String, dynamic>?;
          if (peminjaman == null) continue;

          final detailList = peminjaman['detail_peminjaman'] as List?;
          String? namaAlat;
          int jumlahAlat = 0;

          if (detailList != null && detailList.isNotEmpty) {
            jumlahAlat = detailList.length;
            final detail = detailList[0] as Map<String, dynamic>?;
            if (detail != null) {
              final alat = detail['alat'] as Map<String, dynamic>?;
              namaAlat = alat?['nama_alat'] as String?;
            }
          }

          String title = 'Pengembalian';
          if (namaAlat != null) {
            title = namaAlat;
          }

          String formattedDate = 'Tidak diketahui';
          if (item['tgl_dikembalikan'] != null) {
            try {
              final date = DateTime.parse(item['tgl_dikembalikan'] as String);
              formattedDate =
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
            } catch (e) {
              formattedDate = item['tgl_dikembalikan'].toString();
            }
          }

          history.add({
            'title': title,
            'subtitle': item['kondisi_pengembalian'] ?? 'Berhasil',
            'qty': jumlahAlat > 0 ? '$jumlahAlat Alat' : '1 Alat',
            'date': formattedDate,
          });
        } catch (e) {
          print('Error parsing history item: $e');
        }
      }

      setState(() {
        recentHistory = history;
      });
    } catch (e) {
      print('Error loading recent history: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 40 - 16) / 2;
    final cardHeight = 133;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Padding(
        padding: const EdgeInsets.only(top: 60, bottom: 60),
        child: const SideBar(currentPage: "Dashboard"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        size: 32,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 40),

              if (isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memuat data dashboard...'),
                      ],
                    ),
                  ),
                )
              else if (errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 32),
                      SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          'Coba Lagi',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              // Content utama
              else
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 160,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text(
  'Selamat Datang!',
  style: TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  ),
),
Text(
  userName ?? 'User', // <-- disini
  style: const TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  ),
),
                          const SizedBox(height: 6),
                          Text(
                            'kelola sistem peminjaman dengan mudah\ndan efisien',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ===== STAT CARDS =====
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: cardWidth / cardHeight,
                      children: [
                        _buildStatCard(
                          icon: Icons.groups_outlined,
                          value: totalUsers.toString(),
                          label: 'Total Pengguna',
                        ),
                        _buildStatCard(
                          icon: Icons.inventory_2_outlined,
                          value: totalAlat.toString(),
                          label: 'Total Alat',
                        ),
                        _buildStatCard(
                          icon: Icons.category_outlined,
                          value: totalKategori.toString(),
                          label: 'Total Kategori',
                        ),
                        _buildStatCard(
                          icon: Icons.access_time,
                          value: totalPeminjam.toString(),
                          label: 'Total Peminjam',
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Riwayat Terbaru',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...recentHistory
                        .map(
                          (history) => _historyItem(
                            title: history['title'] ?? 'Riwayat',
                            subtitle: history['subtitle'] ?? 'Berhasil',
                            qty: history['qty'] ?? '1 Alat',
                            date: history['date'] ?? 'Tanggal',
                          ),
                        )
                        .toList(),

                    if (recentHistory.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Belum ada riwayat',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF9FB2C9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D8DE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
          const SizedBox(height: 3),
          Center(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyItem({
    required String title,
    required String subtitle,
    required String qty,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.check, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                qty,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
