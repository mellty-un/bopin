import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aplikasi_peminjaman_alat/models/laporan_model.dart';
import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';

class LaporanService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Fetch semua laporan (peminjaman yang sudah disetujui atau dikembalikan)
static Future<List<LaporanModel>> fetchLaporan({String? filter}) async {
  try {
    // Build base query
    var query = _client.from('peminjaman').select('''
      id_peminjaman,
      nama_user,
      tgl_pinjam,
      tgl_kembali,
      status,
      detail_peminjaman (
        jumlah_pinjam,
        id_alat,
        alat (
          id_alat,
          nama_alat,
          kondisi
        )
      ),
      pengembalian (
        tgl_dikembalikan,
        kondisi_pengembalian
      )
    ''');

    // Apply filters with proper chaining
    PostgrestTransformBuilder finalQuery;
    
    if (filter != null && filter != 'Semua') {
      if (filter == 'Peminjaman') {
        finalQuery = query.match({'status': 'Disetujui'});
      } else if (filter == 'Pengembalian') {
        finalQuery = query.match({'status': 'Dikembalikan'});
      } else {
        // Default to Disetujui if filter is something else
        finalQuery = query.match({'status': 'Disetujui'});
      }
    } else {
      // For "Semua" status, use OR condition
      finalQuery = query.or('status.eq.Disetujui,status.eq.Dikembalikan');
    }
    
    // Add ordering
    finalQuery = finalQuery.order('tgl_pinjam', ascending: false);

    final List<dynamic> response = await finalQuery;

    // Map response to LaporanModel
    return response.map((e) {
      final data = Map<String, dynamic>.from(e);

      // Ambil detail peminjaman
      final detailList = (data['detail_peminjaman'] as List?)
          ?.map((detail) {
            final alat = detail['alat'];
            return DetailPeminjaman(
              id: alat?['id_alat'],
              namaAlat: alat?['nama_alat'] ?? 'Tidak Diketahui',
              jumlah: detail['jumlah_pinjam'] ?? 0,
              kondisi: alat?['kondisi'] ?? 'Baik',
            );
          })
          .toList() ?? [];

      // Ambil tanggal dikembalikan jika ada
      final pengembalianData = data['pengembalian'];
      String? tanggalDikembalikan;
      if (pengembalianData is List && pengembalianData.isNotEmpty) {
        tanggalDikembalikan = pengembalianData.first['tgl_dikembalikan'];
      }

      return LaporanModel(
        id: data['id_peminjaman']?.toString() ?? '0',
        nama: data['nama_user'] ?? 'Tidak Diketahui',
        tanggalMulai: data['tgl_pinjam'] ?? '',
        tanggalKembali: data['tgl_kembali'] ?? '',
        tanggalDikembalikan: tanggalDikembalikan,
        status: data['status'] ?? '',
        items: detailList,
      );
    }).toList();
  } catch (e) {
    debugPrint("Gagal fetch laporan: $e");
    return []; // Always return an empty list instead of null
  }
}
}