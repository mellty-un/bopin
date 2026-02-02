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
            pengembalian (
              id_pengembalian,
              tgl_dikembalikan,
              kondisi_pengembalian,
              keterlambatan_hari,
              catatan,
              denda (
                jenis_denda,
                jumlah_denda
              )
            ),
            detail_peminjaman (
              jumlah_pinjam,
              id_alat,
              alat (
                id_alat,
                nama_alat,
                kondisi
              )
            )
          ''')
          .order('tgl_pinjam', ascending: false);

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

        // Ambil data pengembalian (jika ada)
        final pengembalianData = data['pengembalian'];
        final pengembalian = pengembalianData is List && pengembalianData.isNotEmpty
            ? pengembalianData.first
            : null;

        // Hitung total denda
        int totalDenda = 0;
        int dendaKerusakan = 0;
        int dendaKeterlambatan = 0;
        
        if (pengembalian != null) {
          final dendaList = pengembalian['denda'] as List?;
          if (dendaList != null) {
            for (final denda in dendaList) {
              final jenis = denda['jenis_denda'] as String?;
              final jumlah = denda['jumlah_denda'] as int? ?? 0;
              
              totalDenda += jumlah;
              
              if (jenis == 'Kerusakan') {
                dendaKerusakan += jumlah;
              } else if (jenis == 'Keterlambatan') {
                dendaKeterlambatan += jumlah;
              }
            }
          }
        }

        return PengembalianModel(
          id: data['id_peminjaman']?.toString() ?? '0',
          nama: data['nama_user'] ?? 'Tidak Diketahui',
          tanggalPeminjaman: data['tgl_pinjam'] ?? '',
          tanggalPengembalian: data['tgl_kembali'] ?? '',
          tanggalDikembalikan: pengembalian?['tgl_dikembalikan'],
          status: data['status'] ?? 'Menunggu',
          alatList: detailList,
          dendaKerusakan: dendaKerusakan,
          totalDenda: totalDenda,
        );
      }).toList();
    } catch (e) {
      debugPrint("Gagal fetch pengembalian: $e");
      return [];
    }
  }

  // Proses pengembalian
  static Future<void> prosesPengembalian({
    required String idPeminjaman,
    required String kondisiPengembalian,
    required int keterlambatanHari,
    int? dendaKerusakan,
    int? dendaKeterlambatan,
    int? dendaKehilangan,
    String? catatan,
    List<DetailPeminjaman>? alatList,
  }) async {
    try {
      final id = int.parse(idPeminjaman);
      
      // 1. Restore stok alat yang dikembalikan
      await _restoreStok(id);

      // 2. Insert data pengembalian
      final pengembalianResponse = await _client
          .from('pengembalian')
          .insert({
            'id_peminjaman': id,
            'tgl_dikembalikan': DateTime.now().toIso8601String(),
            'kondisi_pengembalian': kondisiPengembalian,
            'keterlambatan_hari': keterlambatanHari,
            'catatan': catatan,
          })
          .select('id_pengembalian')
          .single();

      final idPengembalian = pengembalianResponse['id_pengembalian'];

      // 3. Insert denda jika ada
      List<Map<String, dynamic>> dendaList = [];
      
      if (dendaKeterlambatan != null && dendaKeterlambatan > 0) {
        dendaList.add({
          'id_pengembalian': idPengembalian,
          'jenis_denda': 'Keterlambatan',
          'jumlah_denda': dendaKeterlambatan,
        });
      }
      
      if (dendaKerusakan != null && dendaKerusakan > 0) {
        dendaList.add({
          'id_pengembalian': idPengembalian,
          'jenis_denda': 'Kerusakan',
          'jumlah_denda': dendaKerusakan,
        });
      }
      
      if (dendaKehilangan != null && dendaKehilangan > 0) {
        dendaList.add({
          'id_pengembalian': idPengembalian,
          'jenis_denda': 'Kehilangan',
          'jumlah_denda': dendaKehilangan,
        });
      }

      if (dendaList.isNotEmpty) {
        await _client.from('denda').insert(dendaList);
      }

      // 4. Update status peminjaman
      await _client.from('peminjaman').update({
        'status': 'Dikembalikan',
      }).eq('id_peminjaman', id);

    } catch (e) {
      debugPrint("Gagal proses pengembalian: $e");
      rethrow;
    }
  }

  // Fungsi untuk mengembalikan stok
  static Future<void> _restoreStok(int idPeminjaman) async {
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
    } catch (e) {
      debugPrint("Gagal restore stok: $e");
      rethrow;
    }
  }
}