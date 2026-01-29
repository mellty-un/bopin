import 'dart:io';
import 'dart:typed_data';
import 'package:aplikasi_peminjaman_alat/core/services/supabase_service.dart';
import 'package:aplikasi_peminjaman_alat/models/alat_model.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatService {
  final SupabaseClient _supabase = SupabaseService.client;

Future<List<Alat>> getAllAlat() async {
  final response = await _supabase
      .from('alat')
      .select('''
        *,
        kategori!inner(id_kategori, nama_kategori)
      ''')
      .order('nama_alat', ascending: true);

  return (response as List)
      .map((e) => Alat.fromJson(e))
      .toList();
}

  Future<String> uploadImage(File file) async {
    try {
      final fileName =
          'alat_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';

      final Uint8List bytes = await file.readAsBytes();

      await _supabase.storage
          .from('alat_images') // ✅ NAMA BUCKET BENAR
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      return fileName;
    } catch (e) {
      throw Exception('Gagal upload gambar: $e');
    }
  }

  /// Ambil URL public untuk Image.network
  String getImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) return '';

    return _supabase.storage
        .from('alat_images')
        .getPublicUrl(fileName);
  }

  /// Hapus gambar dari storage
  Future<void> deleteImage(String fileName) async {
    try {
      await _supabase.storage
          .from('alat_images')
          .remove([fileName]);
    } catch (_) {}
  }

  /* ================= CRUD ALAT ================= */

  Future<Alat> createAlat({
    required String namaAlat,
    required int idKategori,
    required String kondisi,
    String? gambar,
    required int stokTotal,
    required int stokTersedia,
  }) async {
    final response = await _supabase.from('alat').insert({
      'nama_alat': namaAlat,
      'id_kategori': idKategori,
      'kondisi': kondisi,
      'gambar': gambar, // ← nama file
      'stok_total': stokTotal,
      'stok_tersedia': stokTersedia,
    }).select('''
      *,
      kategori!inner(id_kategori, nama_kategori)
    ''').single();

    return Alat.fromJson(response);
  }

  Future<Alat> updateAlat({
    required int idAlat,
    required String namaAlat,
    required int idKategori,
    required String kondisi,
    String? gambar,
    required int stokTotal,
    required int stokTersedia,
  }) async {
    final data = {
      'nama_alat': namaAlat,
      'id_kategori': idKategori,
      'kondisi': kondisi,
      'stok_total': stokTotal,
      'stok_tersedia': stokTersedia,
    };

    if (gambar != null) {
      data['gambar'] = gambar;
    }

    final response = await _supabase
        .from('alat')
        .update(data)
        .eq('id_alat', idAlat)
        .select('''
          *,
          kategori!inner(id_kategori, nama_kategori)
        ''')
        .single();

    return Alat.fromJson(response);
  }

  Future<void> deleteAlat(int idAlat) async {
    final alat = await getAlatById(idAlat);

    if (alat.gambar != null && alat.gambar!.isNotEmpty) {
      await deleteImage(alat.gambar!);
    }

    await _supabase.from('alat').delete().eq('id_alat', idAlat);
  }

  Future<Alat> getAlatById(int id) async {
    final response = await _supabase
        .from('alat')
        .select('''
          *,
          kategori!inner(id_kategori, nama_kategori)
        ''')
        .eq('id_alat', id)
        .single();

    return Alat.fromJson(response);
  }

 Future<String> uploadImageBytes(Uint8List bytes) async {
  final fileName = 'alat_${DateTime.now().millisecondsSinceEpoch}.jpg';

  await _supabase.storage
      .from('alat_images')
      .uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );

  return fileName;
}

}
