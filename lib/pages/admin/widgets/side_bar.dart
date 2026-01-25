import 'package:aplikasi_peminjaman_alat/pages/admin/alat/alat_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/dashboard/admin_dashboard.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/denda/denda_pege.dart' show DendaPege, KelolaDendaPage;
import 'package:aplikasi_peminjaman_alat/pages/admin/kategori/kelola_kategori_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/kelola%20pengguna/kelola_pengguna_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/log_aktivitas/log_aktivitas.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/riwayat/riwayat_page.dart';
import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
  final String currentPage;
  const SideBar({super.key, this.currentPage = "Dashboard"});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late String activePage;

  @override
  void initState() {
    super.initState();
    activePage = widget.currentPage;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      backgroundColor: Colors.white,
      elevation: 0,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    Icons.dashboard,
                    "Dashboard",
                    activePage == "Dashboard",
                    () => _navigateTo(const AdminDashboard(), "Dashboard"),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.inventory,
                    "Alat",
                    activePage == "Alat",
                    () => _navigateTo(const AlatPage(), "Alat"),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.people,
                    "Kelola Pengguna",
                    activePage == "Kelola Pengguna",
                    () => _navigateTo(const KelolaPenggunaPage(), "Kelola Pengguna"),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.money,
                    "Denda",
                    activePage == "Denda",
                    () => _navigateTo(const KelolaDendaPage(), "Denda"),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.category,
                    "Kategori",
                    activePage == "Kategori",
                    () => _navigateTo(const KelolaKategoriPage(), "Kategori"),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.history,
                    "Riwayat",
                    activePage == "Riwayat",
                    () => _navigateTo(const RiwayatPage(), "Riwayat"),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.assignment,
                    "Log Aktivitas",
                    activePage == "Log Aktivitas",
                    () => _navigateTo(const LogAktivitas(), "Log Aktivitas"),
                  ),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: _buildMenuItem(
                Icons.logout,
                "Keluar",
                false,
                () => _showLogoutDialog(),
                isLogout: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildMenuItem(
  IconData icon,
  String title,
  bool active,
  VoidCallback onTap, {
  bool isLogout = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isLogout
              ? const Color(0xFFE85C5C)
              : active
                  ?Color(0xFF36536B)
                  : const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLogout
                ? const Color(0xFFE85C5C)
                : active
                    ? Color(0xFF36536B)
                    : Color(0xFF36536B),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isLogout ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  void _navigateTo(Widget page, String pageName) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Keluar",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Apakah Anda yakin ingin keluar?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        side: const BorderSide(color: Color(0xFF3A587A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Color(0xFF3A587A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A587A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      
                      },
                      child: const Text(
                        "Keluar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}