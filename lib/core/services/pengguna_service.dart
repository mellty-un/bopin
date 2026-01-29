import 'package:aplikasi_peminjaman_alat/models/pengguna_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class PenggunaService {
  static SupabaseClient get _client => SupabaseService.client;

  /// =============================
  /// GET ALL PENGGUNA
  /// =============================
  static Future<List<PenggunaModel>> getAllPengguna() async {
    try {
      final response = await _client
          .from('users')
          .select('id_user, nama, role, created_at')
          .order('created_at', ascending: false);

      if (response == null || response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => PenggunaModel.fromJson({
                'id_user': json['id_user'] ?? '',
                'nama': json['nama'] ?? '',
                'role': json['role'] ?? 'peminjam',
                'created_at': json['created_at'] ?? DateTime.now().toString(),
                'email': null,
              }))
          .toList();
    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        throw Exception('Akses ditolak: Anda tidak memiliki izin melihat pengguna');
      }
      throw Exception('Gagal memuat pengguna: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat pengguna');
    }
  }

  /// =============================
  /// CREATE PENGGUNA - FINAL SOLUTION
  /// =============================
static Future<String> createPengguna({
  required String email,
  required String password,
  required String nama,
  required String role,
}) async {
  final validRoles = ['admin', 'petugas', 'peminjam'];
  final normalizedRole = role.toLowerCase().trim();
  final normalizedEmail = email.trim().toLowerCase();

  if (!validRoles.contains(normalizedRole)) {
    throw Exception('Role tidak valid');
  }

  final emailValidation = _validateEmailForSupabase(normalizedEmail);
  if (emailValidation != null) {
    throw Exception(emailValidation);
  }

  if (password.length < 6) {
    throw Exception('Kata sandi minimal 6 angka');
  }

  try {
    print('🔄 Membuat pengguna: $normalizedEmail');

    /// 1️⃣ SIGN UP AUTH
    final authResponse = await _client.auth.signUp(
      email: normalizedEmail,
      password: password.trim(),
      data: {
        'nama': nama.trim(),
        'role': normalizedRole,
      },
    );

    final user = authResponse.user;
    if (user == null) {
      throw Exception('Gagal membuat akun autentikasi');
    }

    print('✅ Auth berhasil, user ID: ${user.id}');

    /// 2️⃣ TUNGGU SEDIKIT (WAJIB)
    await Future.delayed(const Duration(milliseconds: 800));

    /// 3️⃣ INSERT KE TABEL USERS
    await _client.from('users').upsert({
      'id_user': user.id,
      'nama': nama.trim(),
      'role': normalizedRole,
      'email': normalizedEmail,
      'created_at': DateTime.now().toIso8601String(),
    });

    print('✅ Data berhasil disimpan di tabel users');

    return user.id;
  } on AuthException catch (e) {
    if (e.message.contains('already registered')) {
      throw Exception('Email sudah terdaftar');
    }
    throw Exception(e.message);
  } catch (e) {
    print('❌ Error: $e');
    throw Exception('Gagal menyimpan data penggid_useruna');
  }
}


  /// =============================
  /// SUGGEST VALID EMAIL
  /// =============================
  static String _suggestValidEmail(String originalEmail) {
    final parts = originalEmail.split('@');
    if (parts.length != 2) return 'user123456@gmail.com';
    
    final localPart = parts[0];
    final domain = parts[1];
    
    if (localPart.length < 6) {
      return '${localPart}123456@$domain';
    }
    
    return originalEmail;
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
    final validRoles = ['admin', 'petugas', 'peminjam'];
    final normalizedRole = role.toLowerCase().trim();

    if (!validRoles.contains(normalizedRole)) {
      throw Exception('Role tidak valid');
    }

    if (nama.trim().isEmpty) {
      throw Exception('Nama tidak boleh kosong');
    }

    if (email.trim().isEmpty) {
      throw Exception('Email tidak boleh kosong');
    }

    try {
      await _client
          .from('users')
          .update({
            'nama': nama.trim(),
            'role': normalizedRole,
            'email': email.trim(),
          })
          .eq('id_user', idUser);

    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        throw Exception('Akses ditolak');
      }
      throw Exception('Gagal memperbarui data: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat update');
    }
  }

  /// =============================
  /// DELETE PENGGUNA
  /// =============================
  static Future<void> deletePengguna(String idUser) async {
    if (idUser.isEmpty) {
      throw Exception('ID pengguna tidak valid');
    }

    try {
      await _client
          .from('users')
          .delete()
          .eq('id_user', idUser);

    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        throw Exception('Tidak memiliki izin');
      }
      throw Exception('Gagal menghapus: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menghapus');
    }
  }

  /// =============================
  /// GET USER DETAIL BY ID
  /// =============================
  static Future<Map<String, dynamic>> getPenggunaDetail(String idUser) async {
    try {
      final userResponse = await _client
          .from('users')
          .select('nama, role, email')
          .eq('id_user', idUser)
          .single();

      return {
        'nama': userResponse['nama'] ?? '',
        'role': userResponse['role'] ?? '',
        'email': userResponse['email'] ?? '',
      };
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception('Data tidak ditemukan');
      }
      throw Exception('Gagal mengambil data: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan');
    }
  }

  /// =============================
  /// VALIDASI EMAIL UNTUK SUPABASE
  /// =============================
  static String? _validateEmailForSupabase(String email) {
    if (email.isEmpty) return 'Email tidak boleh kosong';
    
    // Wajib @gmail.com
    if (!email.endsWith('@gmail.com')) {
      return 'Email harus menggunakan @gmail.com';
    }
    
    final parts = email.split('@');
    if (parts.length != 2) return 'Format email tidak valid';
    
    final localPart = parts[0];
    final domain = parts[1];
    
    if (localPart.isEmpty) return 'Bagian sebelum @ tidak boleh kosong';
    if (domain.isEmpty) return 'Bagian setelah @ tidak boleh kosong';
    
    // **SUPABASE MINIMAL 6 KARAKTER SEBELUM @**
    if (localPart.length < 6) {
      return 'Email terlalu pendek untuk sistem.\n'
             'Minimal 6 karakter sebelum @\n'
             'Saran: ${localPart}123456@gmail.com';
    }
    
    if (email.contains(' ')) return 'Email tidak boleh mengandung spasi';
    
    if (!domain.contains('.')) return 'Domain harus mengandung titik';
    
    // Format dasar
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }
}