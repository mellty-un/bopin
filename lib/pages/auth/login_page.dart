import 'package:aplikasi_peminjaman_alat/core/theme/app_color.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/validator.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/dashboard/admin_dashboard.dart';
import 'package:aplikasi_peminjaman_alat/pages/peminjam/peminjam_dashboard.dart';
import 'package:aplikasi_peminjaman_alat/pages/petugas/petugas_dashboard.dart';
import 'package:aplikasi_peminjaman_alat/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? emailError;
  String? passwordError;

  // ================= VALIDASI =================
  bool _validate() {
  setState(() {
    emailError = Validator.email(emailController.text);
    passwordError = Validator.password(passwordController.text);
  });

  return emailError == null && passwordError == null;
}


  // ================= LOGIN =================
  Future<void> _handleLogin() async {
    if (!_validate()) return; // ⬅️ INI YANG KURANG

    final authProvider = context.read<AuthProvider>();

    setState(() => isLoading = true);

    try {
      await authProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      final role = authProvider.user!.role.toLowerCase().trim();

      // ================= PINDAH SESUAI ROLE =================
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (role == 'petugas') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PetugasDashboard()),
        );
      } else if (role == 'peminjam') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PeminjamDashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role tidak dikenali')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Column(
        children: [
          // ===== HEADER =====
          Container(
            height: 260,
            width: double.infinity,
            color: AppColor.primary,
            child: Center(
              child: Image.asset(
                'assets/images/bopin.png',
                width: 160,
              ),
            ),
          ),

          // ===== FORM =====
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email'),
                    const SizedBox(height: 6),
                    _inputBox(
                      controller: emailController,
                      error: emailError,
                    ),

                    const SizedBox(height: 16),
                    const Text('Kata Sandi'),
                    const SizedBox(height: 6),
                    _inputBox(
                      controller: passwordController,
                      isPassword: true,
                      error: passwordError,
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Masuk'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= INPUT =================
Widget _inputBox({
  required TextEditingController controller,
  bool isPassword = false,
  String? error,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            error,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
    ],
  );
}
