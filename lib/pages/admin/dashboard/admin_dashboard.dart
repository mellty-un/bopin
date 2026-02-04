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
      errorMessage = 'Gagal memuat data dashboard';
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final res = await _supabase
            .from('users')
            .select('nama')
            .eq('id_user', user.id)
            .single();

        userName = res['nama'];
      }
    } catch (_) {
      userName = 'User';
    }
    setState(() {});
  }

  Future<void> _loadTotalUsers() async {
    final res = await _supabase
        .from('users')
        .select('id_user')
        .count(CountOption.exact);
    totalUsers = res.count ?? 0;
  }

  Future<void> _loadTotalAlat() async {
    final res = await _supabase
        .from('alat')
        .select('id_alat')
        .count(CountOption.exact);
    totalAlat = res.count ?? 0;
  }

  Future<void> _loadTotalKategori() async {
    final res = await _supabase
        .from('kategori')
        .select('id_kategori')
        .count(CountOption.exact);
    totalKategori = res.count ?? 0;
  }

  Future<void> _loadTotalPeminjam() async {
    final res = await _supabase
        .from('peminjaman')
        .select('id_peminjaman')
        .neq('status', 'Ditolak')
        .count(CountOption.exact);
    totalPeminjam = res.count ?? 0;
  }

Future<void> _loadRecentHistory() async {
  final response = await _supabase
      .from('pengembalian')
      .select('''
        tgl_dikembalikan,
        kondisi_pengembalian,
        peminjaman (
          detail_peminjaman (
            alat ( nama_alat )
          )
        )
      ''')
      .order('tgl_dikembalikan', ascending: false)
      .limit(3);

  recentHistory = [];

  for (final item in response) {
    final peminjaman = item['peminjaman'];
    final detailList = peminjaman?['detail_peminjaman'] as List? ?? [];

    String namaAlat = 'Alat';
    if (detailList.isNotEmpty) {
      final alat = detailList.first['alat'];
      if (alat != null && alat['nama_alat'] != null) {
        namaAlat = alat['nama_alat'];
      }
    }

    final date = DateTime.parse(item['tgl_dikembalikan']);

    recentHistory.add({
      'title': namaAlat,
      'subtitle': item['kondisi_pengembalian'] ?? '-',
      'qty': '${detailList.length} Alat',
      'date': '${date.day}/${date.month}/${date.year}',
    });
  }

  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideBar(currentPage: "Dashboard"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 32),
                    onPressed: () =>
                        _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                // ===== WELCOME CARD =====
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
                        userName ?? 'User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

                // ===== STAT CARDS (RESPONSIF TANPA UBah UI) =====
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio:
                          constraints.maxWidth < 360 ? 1.1 : 1.3,
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
                    );
                  },
                ),

                const SizedBox(height: 30),

                // ===== RIWAYAT =====
                Container(//tntangan menambah container
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                            border: Border.all(color:  Color(0xFF36536B)),

                  ),
                  child: const Center(
                    child: Text(
                      'Riwayat Terbaru',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ...recentHistory.map((h) => _historyItem(
                      title: h['title'],
                      subtitle: h['subtitle'],
                      qty: h['qty'],
                      date: h['date'],
                    )),
              ],
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
            child: Icon(icon, size: 20),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF16A34A),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
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
