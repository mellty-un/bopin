import 'package:aplikasi_peminjaman_alat/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? user;
  bool isLoading = false;

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    user = await _authService.login(
      email: email,
      password: password,
    );

    isLoading = false;
    notifyListeners();
  }

  void logout() {
    user = null;
    notifyListeners();
  }
}
