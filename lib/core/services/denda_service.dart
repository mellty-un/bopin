import 'package:aplikasi_peminjaman_alat/core/services/supabase_service.dart';
import 'package:aplikasi_peminjaman_alat/models/denda_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DendaService {
  final SupabaseClient _supabase = SupabaseService.client;

  Future<List<Denda>> getAllDenda() async {
    try {
      final response = await _supabase
          .from('denda')
          .select('*')
          .order('jenis_denda', ascending: true);

      return (response as List)
          .map((item) => Denda.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data denda: $e');
    }
  }

  // Create new denda
  Future<Denda> createDenda({
    required String jenisDenda,
    required int jumlahDenda,
    int? idPengembalian,
  }) async {
    try {
      final response = await _supabase
          .from('denda')
          .insert({
            'jenis_denda': jenisDenda,
            'jumlah_denda': jumlahDenda,
            'id_pengembalian': idPengembalian,
          })
          .select()
          .single();

      return Denda.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat denda: $e');
    }
  }

  Future<Denda> updateDenda({
    required int idDenda,
    required String jenisDenda,
    required int jumlahDenda,
    int? idPengembalian,
  }) async {
    try {
      final response = await _supabase
          .from('denda')
          .update({
            'jenis_denda': jenisDenda,
            'jumlah_denda': jumlahDenda,
            'id_pengembalian': idPengembalian,
          })
          .eq('id_denda', idDenda)
          .select()
          .single();

      return Denda.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate denda: $e');
    }
  }

  Future<void> deleteDenda(int idDenda) async {
    try {
      await _supabase
          .from('denda')
          .delete()
          .eq('id_denda', idDenda);
    } catch (e) {
      throw Exception('Gagal menghapus denda: $e');
    }
  }

  // Get denda by ID
  Future<Denda> getDendaById(int id) async {
    try {
      final response = await _supabase
          .from('denda')
          .select('*')
          .eq('id_denda', id)
          .single();

      return Denda.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil denda: $e');
    }
  }

  // Get jenis denda options
  List<String> getJenisDendaOptions() {
    return ['Keterlambatan', 'Kerusakan', 'Kehilangan'];
  }
}