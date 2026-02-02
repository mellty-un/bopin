import 'package:aplikasi_peminjaman_alat/models/peminjaman_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class PeminjamanService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ambil list peminjaman
  static Future<List<PeminjamanModel>> fetchPeminjaman() async {
    final response = await _client
        .from('peminjaman')
        .select('''
          id_peminjaman,
          nama_user,
          tgl_pinjam,
          tgl_kembali,
          status,
          detail_peminjaman (
            jumlah_pinjam,
            id_alat,
            alat (
              nama_alat
            )
          )
        ''')
        .order('tgl_pinjam', ascending: false);

    final list = response as List<dynamic>? ?? [];
    return list.map<PeminjamanModel>((json) {
      final Map<String, int> alatMap = {};
      final detail = json['detail_peminjaman'] as List? ?? [];
      for (final item in detail) {
        final namaAlat = item['alat']?['nama_alat'];
        final jumlah = item['jumlah_pinjam'];
        if (namaAlat != null && jumlah != null) {
          alatMap[namaAlat] = jumlah;
        }
      }

      return PeminjamanModel.fromJson({
        'id': json['id_peminjaman'] ?? 0,
        'nama': json['nama_user'] ?? 'Tidak Diketahui',
        'tanggal': json['tgl_pinjam'] ?? '',
        'kembali': json['tgl_kembali'],
        'status': json['status'] ?? 'Menunggu',
        'alat': alatMap,
      });
    }).toList();
  }

  // update status peminjaman
  static Future<void> updateStatus({
    required int idPeminjaman,
    required String status,
  }) async {
    try {
      // Jika disetujui, kurangi stok
      if (status == 'Disetujui') {
        await _kurangiStok(idPeminjaman);
      }
      
      await _client
          .from('peminjaman')
          .update({'status': status})
          .eq('id_peminjaman', idPeminjaman);
    } catch (e) {
      debugPrint("Gagal update status: $e");
      rethrow;
    }
  }

  // Kurangi stok saat peminjaman disetujui
  static Future<void> _kurangiStok(int idPeminjaman) async {
    try {
      final details = await _client
          .from('detail_peminjaman')
          .select('id_alat, jumlah_pinjam')
          .eq('id_peminjaman', idPeminjaman);

      for (final detail in details) {
        final idAlat = detail['id_alat'];
        final jumlah = detail['jumlah_pinjam'];

        final alatData = await _client
            .from('alat')
            .select('stok_tersedia')
            .eq('id_alat', idAlat)
            .single();

        final stokSekarang = alatData['stok_tersedia'] as int;
        final stokBaru = stokSekarang - jumlah;

        await _client
            .from('alat')
            .update({'stok_tersedia': stokBaru})
            .eq('id_alat', idAlat);
      }
    } catch (e) {
      debugPrint("Gagal kurangi stok: $e");
      rethrow;
    }
  }

  // Kembalikan stok saat pengembalian
  static Future<void> restoreStok(int idPeminjaman) async {
    try {
      final details = await _client
          .from('detail_peminjaman')
          .select('id_alat, jumlah_pinjam')
          .eq('id_peminjaman', idPeminjaman);

      for (final detail in details) {
        final idAlat = detail['id_alat'];
        final jumlah = detail['jumlah_pinjam'];

        final alatData = await _client
            .from('alat')
            .select('stok_tersedia')
            .eq('id_alat', idAlat)
            .single();

        final stokSekarang = alatData['stok_tersedia'] as int;
        final stokBaru = stokSekarang + jumlah;

        await _client
            .from('alat')
            .update({'stok_tersedia': stokBaru})
            .eq('id_alat', idAlat);
      }
      
      debugPrint("Berhasil restore stok untuk peminjaman $idPeminjaman");
    } catch (e) {
      debugPrint("Gagal restore stok: $e");
      rethrow;
    }
  }
}