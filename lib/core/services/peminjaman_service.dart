import 'package:aplikasi_peminjaman_alat/models/peminjaman_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class PeminjamanService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ambil list peminjaman
  static Future<List<PeminjamanModel>> fetchPeminjaman() async {
    try {
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
    } catch (e) {
      debugPrint("Error fetch peminjaman: $e");
      rethrow;
    }
  }

  // update status peminjaman
  static Future<void> updateStatus({
    required int idPeminjaman,
    required String status,
  }) async {
    try {
      // Ambil status sebelumnya
      final peminjamanData = await _client
          .from('peminjaman')
          .select('status')
          .eq('id_peminjaman', idPeminjaman)
          .single();

      final statusSebelumnya = peminjamanData['status'] as String;

      // LOGIKA PERUBAHAN STATUS
      
      // 1. Dari Menunggu ke Disetujui: kurangi stok
      if (statusSebelumnya == 'Menunggu' && status == 'Disetujui') {
        await _validateAndKurangiStok(idPeminjaman);
      } 
      
      // 2. Dari Menunggu ke Ditolak: tidak ada perubahan stok
      else if (statusSebelumnya == 'Menunggu' && status == 'Ditolak') {
        // Tidak perlu apa-apa karena stok belum dikurangi
      }
      
      // 3. Dari Disetujui ke Ditolak: kembalikan stok (batal pinjam)
      else if (statusSebelumnya == 'Disetujui' && status == 'Ditolak') {
        await _kembalikanStok(idPeminjaman);
      }
      
      // 4. Dari Menunggu Pengembalian ke Dikembalikan: kembalikan stok
      else if (statusSebelumnya == 'Menunggu Pengembalian' && status == 'Dikembalikan') {
        await _kembalikanStok(idPeminjaman);
      }
      
      // 5. Dari Disetujui ke Menunggu Pengembalian: tidak ada perubahan stok
      //    (stok akan dikembalikan saat status berubah ke Dikembalikan)
      
      // Update status peminjaman
      await _client
          .from('peminjaman')
          .update({'status': status})
          .eq('id_peminjaman', idPeminjaman);

      // Tambahkan disetujui_oleh jika disetujui
      if (status == 'Disetujui') {
        final userId = _client.auth.currentUser?.id;
        if (userId != null) {
          await _client
              .from('peminjaman')
              .update({'disetujui_oleh': userId})
              .eq('id_peminjaman', idPeminjaman);
        }
      }

      debugPrint("Berhasil update status peminjaman $idPeminjaman dari $statusSebelumnya menjadi $status");
    } catch (e) {
      debugPrint("Gagal update status: $e");
      rethrow;
    }
  }

  // Validasi dan kurangi stok
  static Future<void> _validateAndKurangiStok(int idPeminjaman) async {
    try {
      // Ambil detail peminjaman
      final details = await _client
          .from('detail_peminjaman')
          .select('id_alat, jumlah_pinjam')
          .eq('id_peminjaman', idPeminjaman);

      // Cek stok untuk semua alat
      final List<String> insufficientStocks = [];
      
      for (final detail in details) {
        final idAlat = detail['id_alat'] as int;
        final jumlah = detail['jumlah_pinjam'] as int;

        // Ambil stok saat ini
        final alatData = await _client
            .from('alat')
            .select('stok_tersedia, nama_alat')
            .eq('id_alat', idAlat)
            .single();

        final stokSekarang = alatData['stok_tersedia'] as int;
        final namaAlat = alatData['nama_alat'] as String;

        // Validasi stok cukup
        if (stokSekarang < jumlah) {
          insufficientStocks.add('$namaAlat: butuh $jumlah, tersedia $stokSekarang');
        }
      }

      // Jika ada stok yang tidak cukup, throw exception
      if (insufficientStocks.isNotEmpty) {
        throw Exception(
          'Stok tidak mencukupi:\n${insufficientStocks.join('\n')}'
        );
      }

      // Jika stok cukup, kurangi stok
      for (final detail in details) {
        final idAlat = detail['id_alat'] as int;
        final jumlah = detail['jumlah_pinjam'] as int;

        // Ambil stok saat ini
        final alatData = await _client
            .from('alat')
            .select('stok_tersedia')
            .eq('id_alat', idAlat)
            .single();

        final stokSekarang = alatData['stok_tersedia'] as int;
        final stokBaru = stokSekarang - jumlah;

        // Update stok
        await _client
            .from('alat')
            .update({'stok_tersedia': stokBaru})
            .eq('id_alat', idAlat);

        debugPrint("Mengurangi stok alat ID $idAlat: $stokSekarang -> $stokBaru");
      }

      debugPrint("Berhasil mengurangi stok untuk peminjaman $idPeminjaman");
    } catch (e) {
      debugPrint("Gagal validasi/kurangi stok: $e");
      rethrow;
    }
  }

  // Kembalikan stok (tambah stok)
  static Future<void> _kembalikanStok(int idPeminjaman) async {
    try {
      final details = await _client
          .from('detail_peminjaman')
          .select('id_alat, jumlah_pinjam')
          .eq('id_peminjaman', idPeminjaman);

      for (final detail in details) {
        final idAlat = detail['id_alat'] as int;
        final jumlah = detail['jumlah_pinjam'] as int;

        // Ambil stok saat ini
        final alatData = await _client
            .from('alat')
            .select('stok_tersedia')
            .eq('id_alat', idAlat)
            .single();

        final stokSekarang = alatData['stok_tersedia'] as int;
        final stokBaru = stokSekarang + jumlah;

        // Update stok
        await _client
            .from('alat')
            .update({'stok_tersedia': stokBaru})
            .eq('id_alat', idAlat);

        debugPrint("Mengembalikan stok alat ID $idAlat: $stokSekarang -> $stokBaru");
      }
      
      debugPrint("Berhasil mengembalikan stok untuk peminjaman $idPeminjaman");
    } catch (e) {
      debugPrint("Gagal kembalikan stok: $e");
      rethrow;
    }
  }

  // Kembalikan stok saat pengembalian (untuk service lain)
  static Future<void> restoreStok(int idPeminjaman) async {
    try {
      await _kembalikanStok(idPeminjaman);
    } catch (e) {
      debugPrint("Gagal restore stok: $e");
      rethrow;
    }
  }
}