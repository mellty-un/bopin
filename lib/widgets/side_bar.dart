import 'package:aplikasi_peminjaman_alat/pages/peminjam/alat/alat_peminjam.dart';
import 'package:aplikasi_peminjaman_alat/pages/peminjam/dashboard/peminjam_dashboard.dart';
import 'package:aplikasi_peminjaman_alat/pages/peminjam/pengajuan/pengajuan_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/peminjam/pengembalian/pengembalian_peminjam_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/laporan/laporan_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/peminjaman/peminjaman_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/pengembalian/pengembalian_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/petugas_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aplikasi_peminjaman_alat/pages/admin/dashboard/admin_dashboard.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/alat/alat_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/kategori/kelola_kategori_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/kelola pengguna/kelola_pengguna_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/riwayat/riwayat_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/log_aktivitas/log_aktivitas.dart';

import 'package:aplikasi_peminjaman_alat/pages/auth/login_page.dart';

enum UserRole { admin, petugas, peminjam }

class SideBar extends StatefulWidget {
  final String currentPage;

  const SideBar({
    super.key,
    this.currentPage = "Dashboard",
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late String activePage;

  final supabase = Supabase.instance.client;

  String role = 'peminjam';
  String userId = '-';
  String email = '-';


  @override
  void initState() {
    super.initState();
    activePage = widget.currentPage;
    _loadUser();
  }

  /// ================= LOAD USER =================
 Future<void> _loadUser() async {
  final user = supabase.auth.currentUser;
  if (user == null) return;

  setState(() {
    userId = user.id;
    email = user.email ?? '-'; 
  });

  final data = await supabase
      .from('users')
      .select('role')
      .eq('id_user', user.id)
      .single();

  setState(() {
    role = data['role'] ?? 'peminjam';
  });
}


  UserRole get userRole {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'petugas':
        return UserRole.petugas;
      default:
        return UserRole.peminjam;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _buildMenuByRole(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _menuItem(
                title: "Keluar",
                isLogout: true,
                onTap: _showLogoutDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF36536B),
            child: Text(
              userId.isNotEmpty ? userId[0].toUpperCase() : "?",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                email,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
              Text(
                role.toUpperCase(),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= MENU BY ROLE =================
  List<Widget> _buildMenuByRole() {
    switch (userRole) {
      case UserRole.admin:
        return _adminMenu();
      case UserRole.petugas:
        return _petugasMenu();
      case UserRole.peminjam:
        return _peminjamMenu();
    }
  }

  // ================= ADMIN =================
  List<Widget> _adminMenu() => [
        _menuItem(title: "Dashboard", page: "Dashboard", onTap: () => _go(const AdminDashboard())),
        _menuItem(title: "Alat", page: "Alat", onTap: () => _go(const AlatPage())),
        _menuItem(title: "Kelola Pengguna", page: "Kelola Pengguna", onTap: () => _go(const KelolaPenggunaPage())),
        _menuItem(title: "Kategori", page: "Kategori", onTap: () => _go(const KelolaKategoriPage())),
        _menuItem(title: "Riwayat", page: "Riwayat", onTap: () => _go(const RiwayatPage())),
        _menuItem(title: "Log Aktivitas", page: "Log Aktivitas", onTap: () => _go(const LogAktivitas())),
      ];

  // ================= PETUGAS =================
  List<Widget> _petugasMenu() => [
        _menuItem(title: "Dashboars", page: "Dashboars", onTap: () => _go(const PetugasDashboard())),
                _menuItem(title: "Peminjaman", page: "Peminjaman", onTap: () => _go(const PeminjamanPage())),
        _menuItem(title: "Pengembalian", page: "Pengembalian", onTap: () => _go(const PengembalianPage())),
        _menuItem(title: "Laporan", page: "Laporan", onTap: () => _go(const LaporanPage())),
      ];

  // ================= PEMINJAM =================
  List<Widget> _peminjamMenu() => [
        _menuItem(title: "Dashboard", page: "Dashboard", onTap: () => _go(const PeminjamDashboard())),
        _menuItem(title: "Alat ", page: "Alat", onTap: () => _go(const AlatPeminjamPage())),
        _menuItem(title: "Pengajuan ", page: "Pengajuan ", onTap: () => _go(const PengajuanPage())),
        _menuItem(title: "Pengembalian ", page: "Pengembalian ", onTap: () => _go(const PengembaliaPeminjamnPage())),
      ];

  // ================= MENU ITEM =================
  Widget _menuItem({
    required String title,
    String? page,
    VoidCallback? onTap,
    bool isLogout = false,
  }) {
    final active = page == activePage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isLogout
                ? const Color(0xFFE85C5C)
                : active
                    ? const Color(0xFF36536B)
                    : const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF36536B)),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isLogout || active ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _go(Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Keluar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: _performLogout,
            child: const Text(
              "Ya",
              style: TextStyle(color: Color(0xFFE85C5C), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      if (context.mounted) Navigator.pop(context);
      
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      await supabase.auth.signOut();

      if (context.mounted) {
        Navigator.pop(context); 
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()), 
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); 
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }
}