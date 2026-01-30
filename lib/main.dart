import 'package:aplikasi_peminjaman_alat/core/services/supabase_service.dart';
import 'package:aplikasi_peminjaman_alat/core/theme/app_theme.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/alat/alat_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/dashboard/admin_dashboard.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/kelola%20pengguna/kelola_pengguna_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/auth/splash_screen.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/laporan/laporan_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/peminjaman/peminjaman_page.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/pengembalian/pengembalian_page.dart';
import 'package:aplikasi_peminjaman_alat/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'boPin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LaporanPage(),
      ),
    );
  }
}
