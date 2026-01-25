import 'package:aplikasi_peminjaman_alat/pages/admin/widgets/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_peminjaman_alat/core/theme/app_color.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


class _AdminDashboardState extends State<AdminDashboard> {
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
                    icon: const Icon(Icons.menu, size: 32, color: Colors.black87),
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

              Container(
                width: double.infinity,
                height: 154,
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
                    const Text(
                      'Melati Tiara',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                    value: '60',
                    label: 'Total Pengguna',
                  ),
                  _buildStatCard(
                    icon: Icons.inventory_2_outlined,
                    value: '10',
                    label: 'Total Alat',
                  ),
                  _buildStatCard(
                    icon: Icons.category_outlined,
                    value: '4',
                    label: 'Total Kategori',
                  ),
                  _buildStatCard(
                    icon: Icons.access_time,
                    value: '12',
                    label: 'Total Peminjam',
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ===== RIWAYAT TERBARU =====
              const Text(
                'Riwayat Terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              _historyItem(
                title: 'Peminjam 1',
                subtitle: 'Berhasil',
                qty: '2 Alat',
                date: '12/01/2026',
              ),
              _historyItem(
                title: 'Pengembalian',
                subtitle: 'Berhasil',
                qty: '2 Alat',
                date: '12/01/2026',
              ),
              _historyItem(
                title: 'Menambah Alat',
                subtitle: 'Berhasil',
                qty: '2 Alat',
                date: '12/01/2026',
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
      border: Border.all(
        color: const Color(0xFF9FB2C9),
        width: 1.2,
      ),
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
          child: Icon(
            icon,
            size: 20,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 3),

        // VALUE
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
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // TITLE & SUBTITLE
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
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}