import 'package:aplikasi_peminjaman_alat/models/pengguna_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class PenggunaService {
  static SupabaseClient get _client => SupabaseService.client;

  /// =============================
  /// CEK APAKAH USER ADMIN
  /// =============================
  static Future<void> _checkIsAdmin() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Anda belum login. Silakan login terlebih dahulu.');
    }
    
    // Cek role di user metadata
    final userRole = currentUser.userMetadata?['role']?.toString().toLowerCase();
    print('🔍 Current user role from metadata: $userRole');
    print('👤 Current user email: ${currentUser.email}');
    
    if (userRole != 'admin') {
      throw Exception('Hanya admin yang bisa mengakses fitur ini. Role Anda: ${userRole ?? "tidak diketahui"}');
    }
  }

  /// =============================
  /// GET ALL PENGGUNA - HANYA ADMIN
  /// =============================
  static Future<List<PenggunaModel>> getAllPengguna() async {
    try {
      // Cek apakah user admin
      await _checkIsAdmin();
      
      print('👑 Admin mengakses daftar pengguna...');
      
      final response = await _client
          .from('users')
          .select('id_user, nama, role, created_at, email')
          .order('created_at', ascending: false);

      if (response == null || response.isEmpty) {
        print('ℹ️ Tidak ada pengguna ditemukan');
        return [];
      }

      print('✅ Ditemukan ${response.length} pengguna');
      
      return (response as List)
          .map((json) => PenggunaModel.fromJson({
                'id_user': json['id_user']?.toString() ?? '',
                'nama': json['nama']?.toString() ?? '',
                'role': json['role']?.toString() ?? 'peminjam',
                'email': json['email']?.toString() ?? '',
                'created_at': json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
              }))
          .toList();
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      if (e.code == '42501') {
        throw Exception('Akses ditolak: Pastikan Anda login sebagai admin');
      }
      throw Exception('Gagal memuat pengguna: ${e.message}');
    } catch (e) {
      print('❌ Error getAllPengguna: $e');
      throw Exception('Terjadi kesalahan saat memuat pengguna');
    }
  }

  /// =============================
  /// CREATE PENGGUNA - HANYA ADMIN
  /// =============================
  static Future<String> createPengguna({
    required String email,
    required String password,
    required String nama,
    required String role,
  }) async {
    try {
      // 1. CEK ADMIN
      await _checkIsAdmin();
      
      // 2. VALIDASI INPUT
      final validRoles = ['admin', 'petugas', 'peminjam'];
      final normalizedRole = role.toLowerCase().trim();
      final normalizedEmail = email.trim().toLowerCase();
      final cleanPassword = password.trim();

      if (!validRoles.contains(normalizedRole)) {
        throw Exception('Role tidak valid. Gunakan: admin, petugas, atau peminjam');
      }

      if (nama.trim().isEmpty) {
        throw Exception('Nama tidak boleh kosong');
      }

      final emailError = _validateEmail(normalizedEmail);
      if (emailError != null) throw Exception(emailError);

      if (cleanPassword.length < 6) {
        throw Exception('Kata sandi minimal 6 karakter');
      }

      print('👑 Admin membuat pengguna baru...');
      print('📧 Email: $normalizedEmail');
      print('👤 Nama: $nama');
      print('🎯 Role: $normalizedRole');

      // 3. SIGN UP KE AUTH
      final authResponse = await _client.auth.signUp(
        email: normalizedEmail,
        password: cleanPassword,
        data: {
          'nama': nama.trim(),
          'role': normalizedRole,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Gagal membuat user di sistem autentikasi');
      }

      final userId = authResponse.user!.id;
      print('✅ Auth berhasil. User ID: $userId');

      // 4. TUNGGU UNTUK MEMASTIKAN USER TERDAFTAR
      await Future.delayed(const Duration(milliseconds: 1500));

      // 5. INSERT KE TABEL USERS
      final userData = {
        'id_user': userId,
        'nama': nama.trim(),
        'role': normalizedRole,
        'email': normalizedEmail,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('📝 Menyimpan ke tabel users...');
      
      final insertResponse = await _client
          .from('users')
          .insert(userData);

      print('✅ Data berhasil disimpan ke tabel users');

      // 6. VERIFIKASI
      await Future.delayed(const Duration(milliseconds: 500));
      
      final checkData = await _client
          .from('users')
          .select()
          .eq('id_user', userId)
          .single();

      print('✅ Verifikasi berhasil: Data ditemukan di database');
      print('👤 User created: ${checkData['nama']} - ${checkData['email']}');

      return userId;
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      if (e.message.toLowerCase().contains('already registered') || 
          e.message.toLowerCase().contains('user already')) {
        throw Exception('Email $email sudah terdaftar');
      }
      throw Exception('Gagal autentikasi: ${e.message}');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      if (e.code == '23505') {
        throw Exception('Data sudah ada di sistem');
      }
      if (e.code == '42501') {
        throw Exception('Akses ditolak. Pastikan Anda login sebagai admin.');
      }
      throw Exception('Gagal menyimpan data: ${e.message}');
    } catch (e) {
      print('❌ Error createPengguna: $e');
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// =============================
  /// UPDATE PENGGUNA - HANYA ADMIN
  /// =============================
 static Future<void> updatePengguna({
  required String idUser,
  required String nama,
  required String role,
  required String email,
}) async {
  try {
    // 1. CEK ADMIN
    await _checkIsAdmin();
    final currentUser = _client.auth.currentUser;
    if (currentUser != null && currentUser.id == idUser) {
      final currentRole = currentUser.userMetadata?['role']?.toString().toLowerCase();
      final newRole = role.toLowerCase().trim();
      
      if (currentRole == 'admin' && newRole != 'admin') {
        throw Exception('Tidak bisa mengubah role admin Anda sendiri. Minta admin lain untuk melakukannya.');
      }
    }
    
    final validRoles = ['admin', 'petugas', 'peminjam'];
    final normalizedRole = role.toLowerCase().trim();
    final normalizedEmail = email.trim().toLowerCase();

    if (!validRoles.contains(normalizedRole)) {
      throw Exception('Role tidak valid');
    }

    if (nama.trim().isEmpty) {
      throw Exception('Nama tidak boleh kosong');
    }

    if (normalizedEmail.isEmpty) {
      throw Exception('Email tidak boleh kosong');
    }

    final emailError = _validateEmail(normalizedEmail);
    if (emailError != null) throw Exception(emailError);

    print('👑 Admin mengupdate pengguna...');
    print('🔄 ID: $idUser');
    print('📧 Email baru: $normalizedEmail');
    print('👤 Nama baru: $nama');
    print('🎯 Role baru: $normalizedRole');
    final updateData = {
      'nama': nama.trim(),
      'role': normalizedRole,
      'email': normalizedEmail,
    };

    await _client
        .from('users')
        .update(updateData)
        .eq('id_user', idUser);

    print('✅ Update berhasil di tabel users');
    

  } on PostgrestException catch (e) {
    print('❌ PostgrestException update: ${e.code} - ${e.message}');
    if (e.code == '42501') {
      throw Exception('Akses ditolak. Pastikan Anda login sebagai admin.');
    }
    if (e.code == '23505') {
      throw Exception('Email sudah digunakan oleh pengguna lain');
    }
    throw Exception('Gagal memperbarui data: ${e.message}');
  } catch (e) {
    print('❌ Error updatePengguna: $e');
    throw Exception('Terjadi kesalahan saat update');
  }
}
  /// =============================
  /// DELETE PENGGUNA - HANYA ADMIN
  /// =============================
  static Future<void> deletePengguna(String idUser) async {
    try {
      await _checkIsAdmin();
      
      if (idUser.isEmpty) {
        throw Exception('ID pengguna tidak valid');
      }

      print('👑 Admin menghapus pengguna ID: $idUser');

      await _client
          .from('users')
          .delete()
          .eq('id_user', idUser);

      print('✅ Data pengguna dihapus dari tabel users');

      try {
       
      } catch (e) {
        print('⚠️ Tidak bisa menghapus dari auth: $e');
      }

    } on PostgrestException catch (e) {
      print('❌ PostgrestException delete: ${e.code} - ${e.message}');
      if (e.code == '42501') {
        throw Exception('Akses ditolak. Pastikan Anda login sebagai admin.');
      }
      if (e.code == '23503') {
        throw Exception('Tidak bisa menghapus: Pengguna masih memiliki data terkait (peminjaman, dll)');
      }
      throw Exception('Gagal menghapus: ${e.message}');
    } catch (e) {
      print('❌ Error deletePengguna: $e');
      throw Exception('Terjadi kesalahan saat menghapus');
    }
  }

  /// =============================
  /// GET USER DETAIL BY ID - HANYA ADMIN ATAU USER SENDIRI
  /// =============================
  static Future<Map<String, dynamic>> getPenggunaDetail(String idUser) async {
    try {
      if (idUser.isEmpty) {
        throw Exception('ID pengguna tidak valid');
      }

      final userResponse = await _client
          .from('users')
          .select('id_user, nama, role, email, created_at')
          .eq('id_user', idUser)
          .single();

      return {
        'id_user': userResponse['id_user']?.toString() ?? '',
        'nama': userResponse['nama']?.toString() ?? '',
        'role': userResponse['role']?.toString() ?? '',
        'email': userResponse['email']?.toString() ?? '',
        'created_at': userResponse['created_at']?.toString() ?? '',
      };
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception('Data pengguna tidak ditemukan');
      }
      if (e.code == '42501') {
        throw Exception('Akses ditolak. Pastikan Anda memiliki izin.');
      }
      throw Exception('Gagal mengambil data: ${e.message}');
    } catch (e) {
      print('❌ Error getPenggunaDetail: $e');
      throw Exception('Terjadi kesalahan');
    }
  }

  /// =============================
  /// VALIDASI EMAIL
  /// =============================
  static String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email tidak boleh kosong';
    
    if (email.contains(' ')) return 'Email tidak boleh mengandung spasi';
    
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      return 'Format email tidak valid. Contoh: user@gmail.com';
    }
    
    final parts = email.split('@');
    if (parts.length != 2) return 'Format email tidak valid';
    
    final localPart = parts[0];
    if (localPart.length < 3) {
      return 'Email terlalu pendek. Minimal 3 karakter sebelum @';
    }
    
    return null;
  }

  /// =============================
  /// CEK ROLE USER SAAT INI
  /// =============================
  static Future<String?> getCurrentUserRole() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return null;
      
      return currentUser.userMetadata?['role']?.toString().toLowerCase();
    } catch (e) {
      print('❌ Error getCurrentUserRole: $e');
      return null;
    }
  }
}