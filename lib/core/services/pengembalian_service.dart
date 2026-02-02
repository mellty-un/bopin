import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aplikasi_peminjaman_alat/models/pengembalian_model.dart';
import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';

class PengembalianService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Fetch pengembalian
  static Future<List<PengembalianModel>> fetchPengembalian() async {
    try {
    final List<dynamic> response = await _client
    .from('peminjaman')
    .select('''
      id_peminjaman,
      nama_user,
      tgl_pinjam,
      tgl_kembali,
      status,
      denda_kerusakan,
      total_denda,
      tgl_dikembalikan,
      detail_peminjaman (
        jumlah_pinjam,
        alat (
          id_alat,
          nama_alat,
          kondisi
        )
      )
    ''')
    .order('tgl_pinjam', ascending: false);

      // Mapping ke model
      return response
          .map((e) => PengembalianModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint("Gagal fetch pengembalian: $e");
      return [];
    }
  }

  // Proses pengembalian
  static Future<void> prosesPengembalian({
    required String idPeminjaman,
    required int dendaKerusakan,
    required int totalDenda,
    List<DetailPeminjaman>? alatList,
  }) async {
    try {
      final alatMaps = alatList?.map((e) => e.toJson()).toList();

      await _client.from('peminjaman').update({
        'status': 'Selesai',
        'tgl_dikembalikan': DateTime.now().toIso8601String(),
        'denda_kerusakan': dendaKerusakan,
        'total_denda': totalDenda,
      }).eq('id_peminjaman', int.parse(idPeminjaman));

   

    } catch (e) {
      debugPrint("Gagal proses pengembalian: $e");
      rethrow;
    }
  }
}
