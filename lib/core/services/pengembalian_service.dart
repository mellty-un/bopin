import 'package:aplikasi_peminjaman_alat/core/services/supabase_service.dart';
import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';
import 'package:aplikasi_peminjaman_alat/models/pengembalian_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengembalianService {
  static final SupabaseClient _supabase = SupabaseService.client;

  /// Ambil nilai denda dari tabel denda berdasarkan jenis
  static Future<Map<String, int>> getDendaValues() async {
    try {
      final response = await _supabase
          .from('denda')
          .select('jenis_denda, jumlah_denda')
          .limit(10);

      Map<String, int> dendaValues = {
        'Keterlambatan': 5000,
        'Kerusakan': 10000,
        'Kehilangan': 20000,
      };

      for (var item in response) {
        final jenisDenda = item['jenis_denda'] as String;
        final jumlahDenda = item['jumlah_denda'] as int;
        dendaValues[jenisDenda] = jumlahDenda;
      }

      return dendaValues;
    } catch (e) {
      print('❌ Error fetching denda values: $e');
      // Return default values
      return {
        'Keterlambatan': 5000,
        'Kerusakan': 10000,
        'Kehilangan': 20000,
      };
    }
  }

  /// Fetch semua data pengembalian - PERBAIKAN QUERY
  static Future<List<PengembalianModel>> fetchPengembalian() async {
    try {
      // PERBAIKAN: Gunakan relationship yang spesifik untuk menghindari ambiguitas
      final response = await _supabase
          .from('pengembalian')
          .select('''
            id_pengembalian,
            tgl_dikembalikan,
            kondisi_pengembalian,
            keterlambatan_hari,
            catatan,
            peminjaman!inner(
              id_peminjaman,
              tgl_pinjam,
              tgl_kembali,
              status,
              nama_user,
              detail_peminjaman(
                jumlah_pinjam,
                alat(
                  nama_alat
                )
              )
            )
          ''')
          .order('id_pengembalian', ascending: false);

      // Ambil nilai denda dari database
      final dendaValues = await getDendaValues();
      final dendaKeterlambatanPerHari = dendaValues['Keterlambatan'] ?? 5000;

      List<PengembalianModel> result = [];

      for (var item in response) {
        final peminjaman = item['peminjaman'];
        final details = peminjaman['detail_peminjaman'] as List;

        // Ambil nama user dari field nama_user di peminjaman
        final userName = peminjaman['nama_user'] as String? ?? 'Unknown';

        // Format alat list
        List<DetailPeminjaman> alatList = [];
        for (var detail in details) {
          alatList.add(DetailPeminjaman(
            namaAlat: detail['alat']['nama_alat'],
            jumlah: detail['jumlah_pinjam'],
            kondisi: 'Baik', // Default
          ));
        }

        // Format tanggal
        String formatTanggal(String? tgl) {
          if (tgl == null || tgl.isEmpty) return '-';
          try {
            final date = DateTime.parse(tgl);
            return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          } catch (e) {
            return tgl;
          }
        }

        // Hitung denda keterlambatan
        int dendaKeterlambatan = 0;
        int keterlambatanHari = item['keterlambatan_hari'] ?? 0;
        if (keterlambatanHari > 0) {
          dendaKeterlambatan = keterlambatanHari * dendaKeterlambatanPerHari;
        }

        // Tentukan status berdasarkan status peminjaman
        String status = "Pengembalian"; // Default
        if (peminjaman['status'] == 'Dikembalikan') {
          status = "Selesai";
        } else if (peminjaman['status'] == 'Menunggu Pengembalian') {
          status = "Pengembalian";
        }

        result.add(PengembalianModel(
          id: peminjaman['id_peminjaman'].toString(),
          nama: userName,
          tanggalPeminjaman: formatTanggal(peminjaman['tgl_pinjam']),
          tanggalPengembalian: formatTanggal(peminjaman['tgl_kembali']),
          tanggalDikembalikan: formatTanggal(item['tgl_dikembalikan']),
          status: status,
          alatList: alatList,
          dendaKerusakan: 0, // Akan dihitung dari kondisi alat
          totalDenda: dendaKeterlambatan,
        ));
      }

      return result;
    } catch (e) {
      print('❌ Error fetching pengembalian: $e');
      return [];
    }
  }

  /// Proses pengembalian (terima) - PERBAIKAN LOGIKA STOK
  static Future<void> prosesPengembalian({
    required String idPeminjaman,
    required String kondisiPengembalian,
    required int keterlambatanHari,
    required int dendaKerusakan,
    required int dendaKeterlambatan,
    required int dendaKehilangan,
    String? catatan,
    required List<DetailPeminjaman> alatList,
  }) async {
    try {
      final idPeminjamanInt = int.parse(idPeminjaman);

      // Ambil nilai denda dari database
      final dendaValues = await getDendaValues();
      final dendaKerusakanPerItem = dendaValues['Kerusakan'] ?? 10000;
      final dendaKehilanganPerItem = dendaValues['Kehilangan'] ?? 20000;
      final dendaKeterlambatanPerHari = dendaValues['Keterlambatan'] ?? 5000;

      // Hitung ulang denda berdasarkan kondisi alat dan nilai dari database
      int totalDendaKerusakan = 0;
      int totalDendaKehilangan = 0;

      for (var alat in alatList) {
        if (alat.kondisi == 'Rusak') {
          totalDendaKerusakan += dendaKerusakanPerItem * alat.jumlah;
        }
        if (alat.kondisi == 'Hilang') {
          totalDendaKehilangan += dendaKehilanganPerItem * alat.jumlah;
        }
      }

      // Hitung denda keterlambatan
      final totalDendaKeterlambatan = keterlambatanHari * dendaKeterlambatanPerHari;

      // 1. Update tabel pengembalian
      await _supabase
          .from('pengembalian')
          .update({
            'kondisi_pengembalian': kondisiPengembalian,
            'keterlambatan_hari': keterlambatanHari,
            'catatan': catatan,
          })
          .eq('id_peminjaman', idPeminjamanInt);

      // 2. Update status peminjaman ke "Dikembalikan"
      await _supabase
          .from('peminjaman')
          .update({'status': 'Dikembalikan'})
          .eq('id_peminjaman', idPeminjamanInt);

      // 3. PERBAIKAN: Kembalikan stok alat dan update kondisi jika rusak/hilang
      // Ambil detail peminjaman terlebih dahulu
      final detailPeminjaman = await _supabase
          .from('detail_peminjaman')
          .select('id_alat, jumlah_pinjam')
          .eq('id_peminjaman', idPeminjamanInt);

      for (var detail in detailPeminjaman) {
        final idAlat = detail['id_alat'] as int;
        final jumlahPinjam = detail['jumlah_pinjam'] as int;

        // Ambil data alat
        final alatData = await _supabase
            .from('alat')
            .select('nama_alat, stok_tersedia, stok_total')
            .eq('id_alat', idAlat)
            .single();

        final namaAlat = alatData['nama_alat'] as String;
        final stokTersedia = alatData['stok_tersedia'] as int;
        final stokTotal = alatData['stok_total'] as int;

        // Cari kondisi alat dari alatList
        final alatInfo = alatList.firstWhere(
          (a) => a.namaAlat == namaAlat,
          orElse: () => DetailPeminjaman(namaAlat: namaAlat, jumlah: jumlahPinjam, kondisi: 'Baik'),
        );

        if (alatInfo.kondisi == 'Hilang') {
          // Jika hilang, kurangi stok total (stok tersedia tetap)
          final stokTotalBaru = stokTotal - jumlahPinjam;
          await _supabase
              .from('alat')
              .update({
                'stok_total': stokTotalBaru > 0 ? stokTotalBaru : 0,
              })
              .eq('id_alat', idAlat);
        } else if (alatInfo.kondisi == 'Rusak') {
          // Jika rusak, kembalikan ke stok tersedia dan update kondisi
          await _supabase
              .from('alat')
              .update({
                'stok_tersedia': stokTersedia + jumlahPinjam,
                'kondisi': 'Rusak',
              })
              .eq('id_alat', idAlat);
        } else {
          // Jika baik, kembalikan ke stok tersedia
          await _supabase
              .from('alat')
              .update({
                'stok_tersedia': stokTersedia + jumlahPinjam,
              })
              .eq('id_alat', idAlat);
        }
      }

      // 4. Hapus denda lama yang terkait dengan pengembalian ini
      final pengembalianData = await _supabase
          .from('pengembalian')
          .select('id_pengembalian')
          .eq('id_peminjaman', idPeminjamanInt)
          .single();

      final idPengembalian = pengembalianData['id_pengembalian'] as int;

      // Hapus denda lama
      await _supabase
          .from('denda')
          .delete()
          .eq('id_pengembalian', idPengembalian);

      // 5. Insert denda baru ke tabel denda
      // Insert denda keterlambatan
      if (totalDendaKeterlambatan > 0) {
        await _supabase.from('denda').insert({
          'id_pengembalian': idPengembalian,
          'jenis_denda': 'Keterlambatan',
          'jumlah_denda': totalDendaKeterlambatan,
        });
      }

      // Insert denda kerusakan
      if (totalDendaKerusakan > 0) {
        await _supabase.from('denda').insert({
          'id_pengembalian': idPengembalian,
          'jenis_denda': 'Kerusakan',
          'jumlah_denda': totalDendaKerusakan,
        });
      }

      // Insert denda kehilangan
      if (totalDendaKehilangan > 0) {
        await _supabase.from('denda').insert({
          'id_pengembalian': idPengembalian,
          'jenis_denda': 'Kehilangan',
          'jumlah_denda': totalDendaKehilangan,
        });
      }

      // 6. Log aktivitas
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase.from('log_aktivitas').insert({
          'id_user': userId,
          'aktivitas': 'Memproses pengembalian ID $idPeminjaman (Diterima)',
          'waktu': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('❌ Error proses pengembalian: $e');
      throw Exception('Gagal memproses pengembalian: $e');
    }
  }

  /// Tolak pengembalian
  static Future<void> tolakPengembalian({
    required String idPeminjaman,
    String? catatan,
  }) async {
    try {
      final idPeminjamanInt = int.parse(idPeminjaman);

      // 1. Hapus record pengembalian
      await _supabase
          .from('pengembalian')
          .delete()
          .eq('id_peminjaman', idPeminjamanInt);

      // 2. Update status peminjaman kembali ke "Disetujui"
      await _supabase
          .from('peminjaman')
          .update({'status': 'Disetujui'})
          .eq('id_peminjaman', idPeminjamanInt);

      // 3. Log aktivitas
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase.from('log_aktivitas').insert({
          'id_user': userId,
          'aktivitas': 'Menolak pengembalian ID $idPeminjaman',
          'waktu': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('❌ Error tolak pengembalian: $e');
      throw Exception('Gagal menolak pengembalian: $e');
    }
  }
}