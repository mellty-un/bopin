import 'package:aplikasi_peminjaman_alat/core/services/supabase_service.dart';
import 'package:aplikasi_peminjaman_alat/models/riwayat_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatService {
  final SupabaseClient _supabase = SupabaseService.client;

  // Get all riwayat pengembalian dengan join yang benar
  Future<List<Riwayat>> getAllRiwayat() async {
    try {
      // Coba query dengan multiple queries terpisah untuk menghindari error relationship
      return await _getAllRiwayatWithSeparateQueries();
    } catch (e) {
      print('Error in getAllRiwayat: $e');
      // Jika masih error, coba query alternatif yang lebih sederhana
      return await _getAllRiwayatFallback();
    }
  }

  // Method dengan query terpisah untuk menghindari error relationship
  Future<List<Riwayat>> _getAllRiwayatWithSeparateQueries() async {
    try {
      // 1. Ambil semua pengembalian
      final pengembalianResponse = await _supabase
          .from('pengembalian')
          .select()
          .order('tgl_dikembalikan', ascending: false);

      if (pengembalianResponse.isEmpty) {
        return [];
      }

      final List<Riwayat> riwayatList = [];

      for (var pengembalian in pengembalianResponse) {
        try {
          final idPeminjaman = pengembalian['id_peminjaman'] as int?;
          if (idPeminjaman == null) continue;

          // 2. Ambil data peminjaman dengan user
          final peminjamanResponse = await _supabase
              .from('peminjaman')
              .select('''
                *,
                users!peminjaman_id_user_fkey(
                  id_user,
                  nama
                )
              ''')
              .eq('id_peminjaman', idPeminjaman)
              .single();

          if (peminjamanResponse == null) continue;

          // 3. Ambil data detail peminjaman untuk nama alat
          final detailResponse = await _supabase
              .from('detail_peminjaman')
              .select('''
                alat(
                  id_alat,
                  nama_alat
                )
              ''')
              .eq('id_peminjaman', idPeminjaman)
              .limit(1);

          // 4. Parse data users
          final usersData = peminjamanResponse['users'] as Map<String, dynamic>?;
          final namaUser = usersData?['nama'] as String?;

          // 5. Parse data alat
          String? namaAlat;
          if (detailResponse.isNotEmpty) {
            final detail = detailResponse[0] as Map<String, dynamic>;
            final alatData = detail['alat'] as Map<String, dynamic>?;
            namaAlat = alatData?['nama_alat'] as String?;
          }

          // 6. Parse tanggal dengan format yang benar
          DateTime? parseDate(dynamic dateValue) {
            if (dateValue == null) return null;
            if (dateValue is DateTime) return dateValue;
            if (dateValue is String) {
              try {
                return DateTime.parse(dateValue);
              } catch (e) {
                // Coba format date saja (tanpa waktu)
                try {
                  return DateTime.parse('${dateValue}T00:00:00');
                } catch (e2) {
                  return null;
                }
              }
            }
            return null;
          }

          final riwayat = Riwayat(
            idPengembalian: pengembalian['id_pengembalian'] as int? ?? 0,
            idPeminjaman: idPeminjaman,
            tglDikembalikan: parseDate(pengembalian['tgl_dikembalikan']),
            kondisiPengembalian: pengembalian['kondisi_pengembalian'] as String?,
            keterlambatanHari: _parseInt(pengembalian['keterlambatan_hari']),
            catatan: pengembalian['catatan'] as String?,
            namaUser: namaUser,
            namaAlat: namaAlat,
            tglPinjam: parseDate(peminjamanResponse['tgl_pinjam']),
            tglKembali: parseDate(peminjamanResponse['tgl_kembali']),
            status: peminjamanResponse['status'] as String?,
            disetujuiOleh: peminjamanResponse['disetujui_oleh'] as String?,
          );

          riwayatList.add(riwayat);
        } catch (e) {
          print('Error parsing riwayat item: $e');
          continue;
        }
      }

      return riwayatList;
    } catch (e) {
      print('Error in _getAllRiwayatWithSeparateQueries: $e');
      rethrow;
    }
  }

  // Helper method untuk parse integer
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    if (value is num) return value.toInt();
    return null;
  }

  // Fallback method dengan query yang lebih sederhana
  Future<List<Riwayat>> _getAllRiwayatFallback() async {
    try {
      // Query sederhana tanpa join kompleks
      final pengembalianResponse = await _supabase
          .from('pengembalian')
          .select()
          .order('tgl_dikembalikan', ascending: false);

      if (pengembalianResponse.isEmpty) {
        return [];
      }

      final List<Riwayat> riwayatList = [];

      for (var pengembalian in pengembalianResponse) {
        final idPeminjaman = pengembalian['id_peminjaman'] as int?;
        if (idPeminjaman == null) continue;

        try {
          // Ambil data peminjaman terpisah
          final peminjamanResponse = await _supabase
              .from('peminjaman')
              .select()
              .eq('id_peminjaman', idPeminjaman)
              .single();

          // Ambil nama user dari tabel users
          final idUser = peminjamanResponse['id_user'] as String?;
          String? namaUser;
          if (idUser != null) {
            final userResponse = await _supabase
                .from('users')
                .select('nama')
                .eq('id_user', idUser)
                .single();
            namaUser = userResponse['nama'] as String?;
          }

          // Ambil data alat terpisah
          String? namaAlat;
          final detailResponse = await _supabase
              .from('detail_peminjaman')
              .select('id_alat')
              .eq('id_peminjaman', idPeminjaman)
              .limit(1);

          if (detailResponse.isNotEmpty) {
            final detail = detailResponse[0] as Map<String, dynamic>;
            final idAlat = detail['id_alat'] as int?;
            if (idAlat != null) {
              final alatResponse = await _supabase
                  .from('alat')
                  .select('nama_alat')
                  .eq('id_alat', idAlat)
                  .single();
              namaAlat = alatResponse['nama_alat'] as String?;
            }
          }

          // Parse tanggal
          DateTime? parseDate(dynamic dateValue) {
            if (dateValue == null) return null;
            if (dateValue is String) {
              try {
                // Coba format lengkap
                return DateTime.parse(dateValue);
              } catch (e) {
                // Coba format date saja
                try {
                  return DateTime.parse('${dateValue}T00:00:00');
                } catch (e2) {
                  return null;
                }
              }
            }
            return null;
          }

          final riwayat = Riwayat(
            idPengembalian: pengembalian['id_pengembalian'] as int? ?? 0,
            idPeminjaman: idPeminjaman,
            tglDikembalikan: parseDate(pengembalian['tgl_dikembalikan']),
            kondisiPengembalian: pengembalian['kondisi_pengembalian'] as String?,
            keterlambatanHari: _parseInt(pengembalian['keterlambatan_hari']),
            catatan: pengembalian['catatan'] as String?,
            namaUser: namaUser,
            namaAlat: namaAlat,
            tglPinjam: parseDate(peminjamanResponse['tgl_pinjam']),
            tglKembali: parseDate(peminjamanResponse['tgl_kembali']),
            status: peminjamanResponse['status'] as String?,
            disetujuiOleh: peminjamanResponse['disetujui_oleh'] as String?,
          );

          riwayatList.add(riwayat);
        } catch (e) {
          print('Error processing item: $e');
          continue;
        }
      }

      return riwayatList;
    } catch (e) {
      print('Error in fallback getAllRiwayat: $e');
      throw Exception('Gagal mengambil data riwayat: ${e.toString()}');
    }
  }

  // Update pengembalian - FIXED
  Future<void> updatePengembalian({
    required int idPengembalian,
    required String kondisiPengembalian,
    required String catatan,
    DateTime? tglDikembalikan,
    int? keterlambatanHari,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'kondisi_pengembalian': kondisiPengembalian,
        'catatan': catatan,
      };

      if (tglDikembalikan != null) {
        updateData['tgl_dikembalikan'] = tglDikembalikan.toIso8601String().split('T')[0];
      }

      if (keterlambatanHari != null) {
        updateData['keterlambatan_hari'] = keterlambatanHari; // TIDAK perlu as String
      }

      await _supabase
          .from('pengembalian')
          .update(updateData)
          .eq('id_pengembalian', idPengembalian);
    } catch (e) {
      throw Exception('Gagal mengupdate pengembalian: $e');
    }
  }

  // Delete pengembalian
  Future<void> deletePengembalian(int idPengembalian) async {
    try {
      await _supabase
          .from('pengembalian')
          .delete()
          .eq('id_pengembalian', idPengembalian);
    } catch (e) {
      throw Exception('Gagal menghapus pengembalian: $e');
    }
  }

  // Get pengembalian by ID
  Future<Riwayat> getPengembalianById(int id) async {
    try {
      final pengembalianResponse = await _supabase
          .from('pengembalian')
          .select()
          .eq('id_pengembalian', id)
          .single();

      final idPeminjaman = pengembalianResponse['id_peminjaman'] as int?;
      if (idPeminjaman == null) {
        throw Exception('Data peminjaman tidak ditemukan');
      }

      // Ambil data peminjaman
      final peminjamanResponse = await _supabase
          .from('peminjaman')
          .select()
          .eq('id_peminjaman', idPeminjaman)
          .single();

      // Ambil nama user
      final idUser = peminjamanResponse['id_user'] as String?;
      String? namaUser;
      if (idUser != null) {
        final userResponse = await _supabase
            .from('users')
            .select('nama')
            .eq('id_user', idUser)
            .single();
        namaUser = userResponse['nama'] as String?;
      }

      // Ambil nama alat
      String? namaAlat;
      final detailResponse = await _supabase
          .from('detail_peminjaman')
          .select('id_alat')
          .eq('id_peminjaman', idPeminjaman)
          .limit(1);

      if (detailResponse.isNotEmpty) {
        final detail = detailResponse[0] as Map<String, dynamic>;
        final idAlat = detail['id_alat'] as int?;
        if (idAlat != null) {
          final alatResponse = await _supabase
              .from('alat')
              .select('nama_alat')
              .eq('id_alat', idAlat)
              .single();
          namaAlat = alatResponse['nama_alat'] as String?;
        }
      }

      // Parse tanggal
      DateTime? parseDate(dynamic dateValue) {
        if (dateValue == null) return null;
        if (dateValue is String) {
          try {
            return DateTime.parse(dateValue);
          } catch (e) {
            try {
              return DateTime.parse('${dateValue}T00:00:00');
            } catch (e2) {
              return null;
            }
          }
        }
        return null;
      }

      return Riwayat(
        idPengembalian: pengembalianResponse['id_pengembalian'] as int? ?? 0,
        idPeminjaman: idPeminjaman,
        tglDikembalikan: parseDate(pengembalianResponse['tgl_dikembalikan']),
        kondisiPengembalian: pengembalianResponse['kondisi_pengembalian'] as String?,
        keterlambatanHari: _parseInt(pengembalianResponse['keterlambatan_hari']),
        catatan: pengembalianResponse['catatan'] as String?,
        namaUser: namaUser,
        namaAlat: namaAlat,
        tglPinjam: parseDate(peminjamanResponse['tgl_pinjam']),
        tglKembali: parseDate(peminjamanResponse['tgl_kembali']),
        status: peminjamanResponse['status'] as String?,
        disetujuiOleh: peminjamanResponse['disetujui_oleh'] as String?,
      );
    } catch (e) {
      throw Exception('Gagal mengambil pengembalian: $e');
    }
  }

  // Get kondisi pengembalian options
  List<String> getKondisiOptions() {
    return ['Baik', 'Rusak', 'Hilang'];
  }
}