import 'package:aplikasi_peminjaman_alat/core/services/supabase_service.dart';
import 'package:aplikasi_peminjaman_alat/models/kategori_model.dart';

class KategoriService {
  final _supabase = SupabaseService.client;

  Future<List<Kategori>> getAllKategori() async {
  try {
    final response = await _supabase
        .from('kategori')
        .select('*')
        .order('nama_kategori', ascending: true);

    final List<Kategori> kategoriList = [];
    
    for (var item in response) {
      kategoriList.add(Kategori.fromJson(item));
    }
    
    return kategoriList; 
  } catch (e) {
    throw Exception('Gagal mengambil data kategori: ${SupabaseService.handleError(e)}');
  }
}

  Future<Kategori> getKategoriById(int id) async {
    try {
      final response = await _supabase
          .from('kategori')
          .select('*')
          .eq('id_kategori', id)
          .single();

      return Kategori.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil kategori: ${SupabaseService.handleError(e)}');
    }
  }

  // Create new kategori
  Future<Kategori> createKategori(String namaKategori) async {
    try {
      final response = await _supabase
          .from('kategori')
          .insert({
            'nama_kategori': namaKategori,
          })
          .select()
          .single();

      return Kategori.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat kategori: ${SupabaseService.handleError(e)}');
    }
  }

  Future<Kategori> updateKategori({
    required int idKategori,
    required String namaKategori,
  }) async {
    try {
      final response = await _supabase
          .from('kategori')
          .update({
            'nama_kategori': namaKategori,
          })
          .eq('id_kategori', idKategori)
          .select()
          .single();

      return Kategori.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate kategori: ${SupabaseService.handleError(e)}');
    }
  }

  Future<void> deleteKategori(int idKategori) async {
    try {
      final alatResponse = await _supabase
          .from('alat')
          .select('id_alat')
          .eq('id_kategori', idKategori)
          .limit(1);

      if (alatResponse.isNotEmpty) {
        throw Exception('Kategori tidak dapat dihapus karena masih digunakan oleh alat');
      }

      await _supabase
          .from('kategori')
          .delete()
          .eq('id_kategori', idKategori);
    } catch (e) {
      throw Exception('Gagal menghapus kategori: ${SupabaseService.handleError(e)}');
    }
  }

  Future<List<Map<String, dynamic>>> getAllKategoriForDropdown() async {
    try {
      final response = await _supabase
          .from('kategori')
          .select('id_kategori, nama_kategori')
          .order('nama_kategori', ascending: true);

      return response.map<Map<String, dynamic>>((item) {
        return {
          'id': item['id_kategori'],
          'name': item['nama_kategori'],
          'id_kategori': item['id_kategori'],
          'nama_kategori': item['nama_kategori'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data kategori: ${SupabaseService.handleError(e)}');
    }
  }


  Future<List<String>> getAllKategoriNames() async {
    try {
      final response = await _supabase
          .from('kategori')
          .select('nama_kategori')
          .order('nama_kategori', ascending: true);

      final List<String> kategoriNames = ['Semua'];
      kategoriNames.addAll(response.map<String>((item) => item['nama_kategori'] as String));
      
      return kategoriNames;
    } catch (e) {
      throw Exception('Gagal mengambil nama kategori: ${SupabaseService.handleError(e)}');
    }
  }
}