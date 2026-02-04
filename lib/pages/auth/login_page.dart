import 'package:aplikasi_peminjaman_alat/core/theme/app_color.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/validator.dart';
import 'package:aplikasi_peminjaman_alat/pages/admin/dashboard/admin_dashboard.dart';
import 'package:aplikasi_peminjaman_alat/pages/peminjam/dashboard/peminjam_dashboard.dart';
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
  bool isPasswordVisible = false;

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
    if (!_validate()) return;

    final authProvider = context.read<AuthProvider>();
    setState(() => isLoading = true);

    try {
      await authProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      final role = authProvider.user!.role.toLowerCase().trim();

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Role tidak dikenali')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.primary,
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            SizedBox(
              height: size.height * 0.3,
              child: Center(
                child: Image.asset(
                  'assets/images/bopin.png',
                  width: size.width * 0.45,
                ),
              ),
            ),

            // ===== FORM =====
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),

                      const Text('Email'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: emailController,
                        hint: 'Masukkan email',
                        icon: Icons.email_outlined,
                        error: emailError,
                      ),

                      const SizedBox(height: 30),
                      const Text('Kata Sandi'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: passwordController,
                        hint: 'Masukkan kata sandi',
                        icon: Icons.lock_outline,
                        error: passwordError,
                        isPassword: true,
                        isPasswordVisible: isPasswordVisible,
                        onTogglePassword: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),

                      const SizedBox(height: 130),

                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Masuk',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= INPUT FIELD =================
Widget _inputField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  String? error,
  bool isPassword = false,
  bool isPasswordVisible = false,
  VoidCallback? onTogglePassword,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          errorText: error,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
          ),
        ),
      ),
    ],
  );
}
