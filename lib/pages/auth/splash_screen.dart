import 'package:flutter/material.dart';
import 'package:aplikasi_peminjaman_alat/pages/auth/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor, 
       body: Center(
        child: Image.asset(
          'assets/images/logo_bopin.png',
          width: 160,
          height: 160,
        ),
      ),
    );
  }
}