import 'package:aplikasi_peminjaman_alat/models/pengembalian_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengembalianService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<PengembalianModel>> fetchPengembalian() async {
    final response = await _client
        .from('pengembalian')
        .select('''
          id_pengembalian,
          kondisi_pengembalian,
          tgl_dikembalikan,
          peminjaman (
            nama_user,
            tgl_pinjam,
            detail_peminjaman (
              jumlah_pinjam,
              alat (
                nama_alat
              )
            )
          )
        ''')
        .order('id_pengembalian', ascending: false);

    return (response as List)
        .map((e) => PengembalianModel.fromJson(e))
        .toList();
  }
}
