import 'package:aplikasi_peminjaman_alat/models/pengguna_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class PenggunaService {
  static SupabaseClient get _client => SupabaseService.client;

  /// =============================
  /// CEK APAKAH USER ADMIN
  /// =============================
  static Future<bool> _isAdmin() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return false;

      // Cek dari database
      final userData = await _client
          .from('users')
          .select('role')
          .eq('id_user', currentUser.id)
          .maybeSingle();

      final role = userData?['role']?.toString().toLowerCase();
      return role == 'admin';
    } catch (e) {
      print('❌ Error checking admin status: $e');
      return false;
    }
  }

  /// =============================
  /// GET ALL PENGGUNA
  /// =============================
  static Future<List<PenggunaModel>> getAllPengguna() async {
    try {
      print('📋 Fetching all users...');

      // Semua authenticated user bisa read berkat RLS policy baru
      final response = await _client
          .from('users')
          .select('id_user, nama, role, created_at, email')
          .order('created_at', ascending: false);

      if (response == null || response.isEmpty) {
        print('ℹ️ No users found');
        return [];
      }

      print('✅ Found ${response.length} users');

      return (response as List)
          .map((json) => PenggunaModel.fromJson({
                'id_user': json['id_user']?.toString() ?? '',
                'nama': json['nama']?.toString() ?? '',
                'role': json['role']?.toString() ?? 'peminjam',
                'email': json['email']?.toString() ?? '',
                'created_at': json['created_at']?.toString() ?? 
                    DateTime.now().toIso8601String(),
              }))
          .toList();
    } catch (e) {
      print('❌ Error in getAllPengguna: $e');
      throw Exception('Gagal memuat pengguna: ${e.toString()}');
    }
  }

  /// =============================
  /// CREATE PENGGUNA
  /// =============================
  static Future<String> createPengguna({
    required String email,
    required String password,
    required String nama,
    required String role,
  }) async {
    try {
      // 1. CEK ADMIN
      final isAdmin = await _isAdmin();
      if (!isAdmin) {
        throw Exception('Hanya admin yang bisa menambah pengguna');
      }

      // 2. VALIDASI
      final validRoles = ['admin', 'petugas', 'peminjam'];
      final normalizedRole = role.toLowerCase().trim();
      final normalizedEmail = email.trim().toLowerCase();
      final cleanPassword = password.trim();

      if (!validRoles.contains(normalizedRole)) {
        throw Exception('Role tidak valid');
      }

      if (nama.trim().isEmpty) {
        throw Exception('Nama tidak boleh kosong');
      }

      final emailError = _validateEmail(normalizedEmail);
      if (emailError != null) throw Exception(emailError);

      if (cleanPassword.length < 6) {
        throw Exception('Kata sandi minimal 6 karakter');
      }

      print('👑 Creating user: $normalizedEmail');

      // 3. SIGN UP (akan auto trigger insert ke tabel users)
      final authResponse = await _client.auth.signUp(
        email: normalizedEmail,
        password: cleanPassword,
        data: {
          'nama': nama.trim(),
          'role': normalizedRole,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Gagal membuat user');
      }

      final userId = authResponse.user!.id;
      print('✅ User created: $userId');

      // 4. TUNGGU TRIGGER SELESAI
      await Future.delayed(const Duration(milliseconds: 1500));

      // 5. VERIFIKASI DATA TERSIMPAN
      try {
        final check = await _client
            .from('users')
            .select('id_user')
            .eq('id_user', userId)
            .maybeSingle();

        if (check == null) {
          print('⚠️ User not in table, manual insert...');
          
          // Manual insert jika trigger gagal
          await _client.from('users').insert({
            'id_user': userId,
            'nama': nama.trim(),
            'role': normalizedRole,
            'email': normalizedEmail,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      } catch (insertError) {
        print('⚠️ Insert error (might be duplicate): $insertError');
      }

      return userId;
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      if (e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('user already')) {
        throw Exception('Email sudah terdaftar');
      }
      throw Exception('Gagal autentikasi: ${e.message}');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      if (e.code == '23505') {
        throw Exception('Email sudah terdaftar');
      }
      if (e.code == '42501') {
        throw Exception('Akses ditolak. Pastikan Anda admin');
      }
      throw Exception('Gagal menyimpan: ${e.message}');
    } catch (e) {
      print('❌ Error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// =============================
  /// UPDATE PENGGUNA
  /// =============================
  static Future<void> updatePengguna({
    required String idUser,
    required String nama,
    required String role,
    required String email,
  }) async {
    try {
      // 1. CEK ADMIN
      final isAdmin = await _isAdmin();
      if (!isAdmin) {
        throw Exception('Hanya admin yang bisa mengubah pengguna');
      }

      // 2. VALIDASI
      final validRoles = ['admin', 'petugas', 'peminjam'];
      final normalizedRole = role.toLowerCase().trim();
      final normalizedEmail = email.trim().toLowerCase();

      if (!validRoles.contains(normalizedRole)) {
        throw Exception('Role tidak valid');
      }

      if (nama.trim().isEmpty) {
        throw Exception('Nama tidak boleh kosong');
      }

      final emailError = _validateEmail(normalizedEmail);
      if (emailError != null) throw Exception(emailError);

      // 3. CEK TIDAK MENGUBAH ROLE ADMIN SENDIRI
      final currentUser = _client.auth.currentUser;
      if (currentUser != null && currentUser.id == idUser) {
        final currentRole = await _getCurrentRole(currentUser.id);
        if (currentRole == 'admin' && normalizedRole != 'admin') {
          throw Exception('Tidak bisa mengubah role admin Anda sendiri');
        }
      }

      print('🔄 Updating user: $idUser');

      // 4. UPDATE
      await _client.from('users').update({
        'nama': nama.trim(),
        'role': normalizedRole,
        'email': normalizedEmail,
      }).eq('id_user', idUser);

      print('✅ Update successful');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      if (e.code == '42501') {
        throw Exception('Akses ditolak');
      }
      if (e.code == '23505') {
        throw Exception('Email sudah digunakan');
      }
      throw Exception('Gagal update: ${e.message}');
    } catch (e) {
      print('❌ Error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// =============================
  /// DELETE PENGGUNA
  /// =============================
  static Future<void> deletePengguna(String idUser) async {
    try {
      // 1. CEK ADMIN
      final isAdmin = await _isAdmin();
      if (!isAdmin) {
        throw Exception('Hanya admin yang bisa menghapus pengguna');
      }

      if (idUser.isEmpty) {
        throw Exception('ID tidak valid');
      }

      // 2. CEK TIDAK MENGHAPUS DIRI SENDIRI
      final currentUser = _client.auth.currentUser;
      if (currentUser != null && currentUser.id == idUser) {
        throw Exception('Tidak bisa menghapus akun Anda sendiri');
      }

      print('🗑️ Deleting user: $idUser');

      // 3. DELETE
      await _client.from('users').delete().eq('id_user', idUser);

      print('✅ Delete successful');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      if (e.code == '42501') {
        throw Exception('Akses ditolak');
      }
      if (e.code == '23503') {
        throw Exception('User masih memiliki data terkait');
      }
      throw Exception('Gagal menghapus: ${e.message}');
    } catch (e) {
      print('❌ Error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// =============================
  /// GET USER DETAIL
  /// =============================
  static Future<Map<String, dynamic>> getPenggunaDetail(String idUser) async {
    try {
      if (idUser.isEmpty) {
        throw Exception('ID tidak valid');
      }

      final response = await _client
          .from('users')
          .select('id_user, nama, role, email, created_at')
          .eq('id_user', idUser)
          .single();

      return {
        'id_user': response['id_user']?.toString() ?? '',
        'nama': response['nama']?.toString() ?? '',
        'role': response['role']?.toString() ?? '',
        'email': response['email']?.toString() ?? '',
        'created_at': response['created_at']?.toString() ?? '',
      };
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception('Pengguna tidak ditemukan');
      }
      throw Exception('Gagal mengambil data: ${e.message}');
    } catch (e) {
      print('❌ Error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// =============================
  /// GET CURRENT USER ROLE
  /// =============================
  static Future<String?> getCurrentUserRole() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return null;

      return await _getCurrentRole(currentUser.id);
    } catch (e) {
      print('❌ Error getting role: $e');
      return null;
    }
  }

  /// =============================
  /// HELPER: GET ROLE BY ID
  /// =============================
  static Future<String?> _getCurrentRole(String userId) async {
    try {
      final userData = await _client
          .from('users')
          .select('role')
          .eq('id_user', userId)
          .maybeSingle();

      return userData?['role']?.toString().toLowerCase();
    } catch (e) {
      return null;
    }
  }

  /// =============================
  /// VALIDASI EMAIL
  /// =============================
  static String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email tidak boleh kosong';
    if (email.contains(' ')) return 'Email tidak boleh mengandung spasi';

    final emailPattern =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      return 'Format email tidak valid';
    }

    final parts = email.split('@');
    if (parts.length != 2) return 'Format email tidak valid';

    final localPart = parts[0];
    if (localPart.length < 3) {
      return 'Email terlalu pendek';
    }

    return null;
  }
}