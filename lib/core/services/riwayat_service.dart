import 'package:aplikasi_peminjaman_alat/models/riwayat_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatService {
  final SupabaseClient _client = Supabase.instance.client;

  /* =======================
     HELPER
  ======================= */
  int? _int(dynamic v) => v is int ? v : int.tryParse('$v');
  String? _str(dynamic v) => v?.toString();
  DateTime? _date(dynamic v) =>
      v is DateTime ? v : DateTime.tryParse('$v');

  /* =======================
     GET RIWAYAT
  ======================= */
  Future<List<Riwayat>> getAllRiwayat() async {
    try {
      final res = await _client.from('peminjaman').select('''
        id_peminjaman,
        tgl_pinjam,
        tgl_kembali,
        status,
        nama_user,
        users!peminjaman_id_user_fkey(nama, role),
        detail_peminjaman(
          jumlah_pinjam,
          alat(nama_alat)
        ),
        pengembalian(
          id_pengembalian,
          tgl_dikembalikan,
          kondisi_pengembalian,
          keterlambatan_hari,
          catatan
        )
      ''').order('tgl_pinjam', ascending: false);

      List<Riwayat> list = [];

      for (final item in res) {
        final user = item['users'];
        final detail = item['detail_peminjaman'];
        final pengembalian = item['pengembalian'];

        final namaUser =
            _str(item['nama_user']) ??
            _str(user?['nama']) ??
            '-';

        final alat = (detail is List && detail.isNotEmpty)
            ? detail
                .map((d) =>
                    '${d['alat']['nama_alat']} (${d['jumlah_pinjam']}x)')
                .join(', ')
            : '-';

        if (pengembalian is List && pengembalian.isNotEmpty) {
          for (final p in pengembalian) {
            list.add(Riwayat(
              idPeminjaman: _int(item['id_peminjaman']),
              idPengembalian: _int(p['id_pengembalian']),
              namaUser: namaUser,
              namaAlat: alat,
              kondisiPengembalian: _str(p['kondisi_pengembalian']),
              keterlambatanHari: _int(p['keterlambatan_hari']) ?? 0,
              catatan: _str(p['catatan']) ?? '',
              tglPinjam: _date(item['tgl_pinjam']),
              tglKembali: _date(item['tgl_kembali']),
              tglDikembalikan: _date(p['tgl_dikembalikan']),
              status: 'Dikembalikan',
              userRole: _str(user?['role']) ?? 'peminjam',
            ));
          }
        } else {
          list.add(Riwayat(
            idPeminjaman: _int(item['id_peminjaman']),
            namaUser: namaUser,
            namaAlat: alat,
            status: _str(item['status']) ?? '',
            tglPinjam: _date(item['tgl_pinjam']),
            tglKembali: _date(item['tgl_kembali']),
            userRole: _str(user?['role']) ?? 'peminjam',
          ));
        }
      }

      return list;
    } catch (e) {
      throw Exception('Gagal memuat riwayat');
    }
  }

  /* =======================
     UPDATE PENGEMBALIAN ✅ FIX
  ======================= */
  Future<void> updatePengembalian({
    required int idPengembalian,
    required String kondisiPengembalian,
    required String catatan,
    required DateTime tglDikembalikan,
  }) async {
    await _client
        .from('pengembalian')
        .update({
          'kondisi_pengembalian': kondisiPengembalian,
          'catatan': catatan,
          'tgl_dikembalikan': tglDikembalikan.toIso8601String(),
        })
        .eq('id_pengembalian', idPengembalian);

    print('✅ Pengembalian berhasil diupdate');
  }

  /* =======================
     DELETE PENGEMBALIAN
  ======================= */
  Future<void> deletePengembalian(int idPengembalian) async {
    await _client
        .from('denda')
        .delete()
        .eq('id_pengembalian', idPengembalian);

    await _client
        .from('pengembalian')
        .delete()
        .eq('id_pengembalian', idPengembalian);

    print('🗑️ Pengembalian dihapus');
  }

  /* =======================
     DELETE PEMINJAMAN
  ======================= */
  Future<void> deletePeminjaman(int idPeminjaman) async {
    await _client
        .from('detail_peminjaman')
        .delete()
        .eq('id_peminjaman', idPeminjaman);

    await _client
        .from('pengembalian')
        .delete()
        .eq('id_peminjaman', idPeminjaman);

    await _client
        .from('peminjaman')
        .delete()
        .eq('id_peminjaman', idPeminjaman);

    print('🗑️ Peminjaman dihapus');
  }
}
