import 'package:aplikasi_peminjaman_alat/models/peminjaman_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
            alat (
              nama_alat
            )
          )
        ''')
        .order('tgl_pinjam', ascending: false);

    // pastikan response bukan null
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
    await _client
        .from('peminjaman')
        .update({'status': status})
        .eq('id_peminjaman', idPeminjaman);
  }
}
