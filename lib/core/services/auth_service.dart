import 'package:aplikasi_peminjaman_alat/core/services/supabase_service.dart';
import 'package:aplikasi_peminjaman_alat/models/user_model.dart';

class AuthService {
  final _supabase = SupabaseService.client;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = res.user;
    if (user == null) {
      throw Exception('Login gagal');
    }

    final data = await _supabase
        .from('users')
        .select('id_user, role')
        .eq('id_user', user.id)
        .single();

    return UserModel.fromJson(data);
  }
}
