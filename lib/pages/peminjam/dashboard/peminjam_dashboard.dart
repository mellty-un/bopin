import 'package:aplikasi_peminjaman_alat/core/theme/app_color.dart';
import 'package:aplikasi_peminjaman_alat/widgets/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aplikasi_peminjaman_alat/core/services/log_aktivitas_service.dart';

class PeminjamDashboard extends StatefulWidget {
  const PeminjamDashboard({super.key});

  @override
  State<PeminjamDashboard> createState() => _PeminjamDashboardState();
}

class _PeminjamDashboardState extends State<PeminjamDashboard> {
  final SupabaseClient supabase = Supabase.instance.client;
  String namaUser = 'Pengguna';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // STAT
  int totalAlat = 0;
  int menunggu = 0;
  int selesai = 0;
  int pengembalian = 0;

  // RIWAYAT PEMINJAMAN
  List<Map<String, dynamic>> riwayat = [];

  // LOG AKTIVITAS
  List<Map<String, dynamic>> logAktivitas = [];
  bool loadingLog = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadStat();
    _loadRiwayat();
    _loadLogAktivitas();
  }

  void _loadUser() {
    final user = supabase.auth.currentUser;
    setState(() {
      namaUser = user?.userMetadata?['nama'] ?? 'Pengguna';
    });
  }

  // ================= STAT =================
// ================= STAT =================
Future<void> _loadStat() async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return;

  try {
    // Total alat
    final alatRes = await supabase.from('alat').select('id_alat');

    // Peminjaman Disetujui
    final disetujuiRes = await supabase
        .from('peminjaman')
        .select('id_peminjaman')
        .eq('id_user', userId)
        .ilike('status', '%Disetujui%'); // case-insensitive

    // Peminjaman Dikembalikan
    final dikembalikanRes = await supabase
        .from('peminjaman')
        .select('id_peminjaman')
        .eq('id_user', userId)
        .ilike('status', '%Dikembalikan%');

    // Pengembalian (optional, bisa digabung dengan dikembalikan)
    final pengembalianAll =
        await supabase.from('pengembalian').select('id_pengembalian,id_peminjaman');

    final peminjamanUser =
        await supabase.from('peminjaman').select('id_peminjaman').eq('id_user', userId);

    final peminjamanUserIds = peminjamanUser.map((e) => e['id_peminjaman']).toList();

    final kembaliRes =
        pengembalianAll.where((e) => peminjamanUserIds.contains(e['id_peminjaman'])).toList();

    // Update state
    setState(() {
      totalAlat = alatRes.length;
      menunggu = disetujuiRes.length;   
      selesai = dikembalikanRes.length;  
      pengembalian = kembaliRes.length;
    });

    debugPrint(
        'Total Alat: $totalAlat, Disetujui: $menunggu, Dikembalikan: $selesai, Pengembalian: $pengembalian');
  } catch (e) {
    debugPrint('❌ Error loading stat: $e');
  }
}


  // ================= RIWAYAT =================
  Future<void> _loadRiwayat() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await supabase
          .from('peminjaman')
          .select('id_peminjaman, tgl_pinjam, status, detail_peminjaman(jumlah_pinjam)')
          .eq('id_user', userId)
          .order('tgl_pinjam', ascending: false)
          .limit(5);

      final riwayatProcessed = data.map((e) {
        int jumlahAlat = 0;
        if (e['detail_peminjaman'] != null) {
          jumlahAlat =
              (e['detail_peminjaman'] as List).fold(0, (sum, d) => sum + (d['jumlah_pinjam'] as int));
        }
        return {
          'tgl_pinjam': e['tgl_pinjam'],
          'status': e['status'],
          'jumlah': jumlahAlat,
        };
      }).toList();

      setState(() {
        riwayat = List<Map<String, dynamic>>.from(riwayatProcessed);
      });
    } catch (e) {
      debugPrint('❌ Error loading riwayat: $e');
    }
  }

  // ================= LOG =================
  Future<void> _loadLogAktivitas() async {
    try {
      final data = await LogAktivitasService.fetchLogAktivitas();
      setState(() {
        logAktivitas = data.take(5).toList();
        loadingLog = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading log aktivitas: $e');
      setState(() => loadingLog = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 40 - 16) / 2;
    final cardHeight = 120;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Padding(
        padding: const EdgeInsets.only(top: 70, bottom: 60),
        child: const SideBar(currentPage: "Dashboard"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ===== WELCOME BANNER =====
              Container(
                width: double.infinity,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      namaUser,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kelola sistem peminjaman dengan mudah dan efisien',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ===== STAT CARDS =====
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: cardWidth / cardHeight,
                children: [
                  _buildStatCard(Icons.groups_outlined, '$totalAlat', 'Total Alat'),
                  _buildStatCard(Icons.inventory_2_outlined, '$menunggu', 'Menunggu'),
                  _buildStatCard(Icons.category_outlined, '$selesai', 'Selesai'),
                  _buildStatCard(Icons.access_time, '$pengembalian', 'Pengembalian'),
                ],
              ),
              const SizedBox(height: 30),

              // ===== RIWAYAT LOG =====
              const Text(
                'Riwayat Terbaru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              loadingLog
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: logAktivitas.map((log) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    log['status'] == 'Pengembalian' ? Colors.orange : Colors.green,
                                child: Icon(
                                  log['status'] == 'Pengembalian' ? Icons.swap_horiz : Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log['status'] ?? 'Aktivitas',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    Text(
                                      '${log['jumlah'] ?? 1} Alat • ${log['alat'] ?? 'Alat'}',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    log['jumlah'] != null ? '${log['jumlah']} Alat' : '-',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    log['tanggal_pinjam'] ?? '-',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== STAT CARD WIDGET =====
  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color:  Color(0xFF36536B)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColor.primary),
          const Spacer(),
          Center(
            child: Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
