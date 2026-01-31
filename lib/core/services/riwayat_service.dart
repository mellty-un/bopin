import 'package:aplikasi_peminjaman_alat/models/riwayat_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatService {
  final SupabaseClient _client = Supabase.instance.client;

  /// =============================
  /// HELPER FUNCTIONS
  /// =============================
  int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.tryParse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String? _safeParseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  DateTime? _safeParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.tryParse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// =============================
  /// GET ALL PEMINJAMAN & PENGEMBALIAN - FIXED
  /// =============================
  Future<List<Riwayat>> getAllRiwayat() async {
    try {
      print('📋 Fetching riwayat data...');

      final response = await _client
          .from('peminjaman')
          .select('''
            id_peminjaman,
            tgl_pinjam,
            tgl_kembali,
            status,
            disetujui_oleh,
            users!peminjaman_id_user_fkey(
              nama,
              role
            ),
            detail_peminjaman(
              jumlah_pinjam,
              alat(
                nama_alat,
                id_alat
              )
            ),
            pengembalian(
              id_pengembalian,
              tgl_dikembalikan,
              kondisi_pengembalian,
              keterlambatan_hari,
              catatan
            )
          ''')
          .order('tgl_pinjam', ascending: false);

      if (response == null || response is! List) {
        print('ℹ️ No riwayat found');
        return [];
      }

      print('✅ Found ${response.length} riwayat records');

      List<Riwayat> result = [];

      for (final item in response) {
        try {
          final dynamic userData = item['users'];
          final dynamic detailList = item['detail_peminjaman'];
          final dynamic pengembalianList = item['pengembalian'];

          // DEBUG: Print data untuk troubleshooting
          print('Processing peminjaman ID: ${item['id_peminjaman']}');
          print('Status: ${item['status']}');
          print('Pengembalian data: $pengembalianList');

          // Get user info
          String userName = 'Unknown';
          if (userData is Map<String, dynamic>) {
            userName = _safeParseString(userData['nama']) ?? 'Unknown';
          }

          // Get alat names
          List<String> namaAlatList = [];
          int totalJumlahPinjam = 0;
          
          if (detailList is List && detailList.isNotEmpty) {
            for (final detail in detailList) {
              if (detail is Map<String, dynamic>) {
                final alatData = detail['alat'];
                if (alatData is Map<String, dynamic>) {
                  final namaAlat = _safeParseString(alatData['nama_alat']) ?? 'Unknown';
                  final jumlah = _safeParseInt(detail['jumlah_pinjam']) ?? 1;
                  totalJumlahPinjam += jumlah;
                  
                  if (jumlah > 1) {
                    namaAlatList.add('$namaAlat (${jumlah}x)');
                  } else {
                    namaAlatList.add(namaAlat);
                  }
                }
              }
            }
          }

          String namaAlat = namaAlatList.isNotEmpty 
              ? namaAlatList.join(', ')
              : 'Tidak ada alat';

          // Get pengembalian data
          int? idPengembalian;
          String? kondisiPengembalian;
          int keterlambatanHari = 0;
          String catatan = '';
          DateTime? tglDikembalikan;

          if (pengembalianList is List && pengembalianList.isNotEmpty) {
            final pengembalian = pengembalianList[0];
            if (pengembalian is Map<String, dynamic>) {
              idPengembalian = _safeParseInt(pengembalian['id_pengembalian']);
              kondisiPengembalian = _safeParseString(pengembalian['kondisi_pengembalian']);
              keterlambatanHari = _safeParseInt(pengembalian['keterlambatan_hari']) ?? 0;
              catatan = _safeParseString(pengembalian['catatan']) ?? '';
              tglDikembalikan = _safeParseDate(pengembalian['tgl_dikembalikan']);
              
              print('  Found pengembalian ID: $idPengembalian');
            }
          } else {
            print('  No pengembalian data for peminjaman ID: ${item['id_peminjaman']}');
          }

          result.add(Riwayat(
            idPeminjaman: _safeParseInt(item['id_peminjaman']),
            idPengembalian: idPengembalian,
            namaUser: userName,
            namaAlat: namaAlat,
            kondisiPengembalian: kondisiPengembalian,
            keterlambatanHari: keterlambatanHari,
            catatan: catatan,
            tglPinjam: _safeParseDate(item['tgl_pinjam']),
            tglKembali: _safeParseDate(item['tgl_kembali']),
            tglDikembalikan: tglDikembalikan,
            status: _safeParseString(item['status']) ?? 'Unknown',
            disetujuiOleh: _safeParseString(item['disetujui_oleh']),
            jumlahPinjam: totalJumlahPinjam > 0 ? totalJumlahPinjam : 1,
            userRole: userData is Map<String, dynamic> 
                ? _safeParseString(userData['role']) ?? 'peminjam'
                : 'peminjam',
          ));
        } catch (e) {
          print('⚠️ Error parsing item: $e');
          print('Item data: $item');
          continue;
        }
      }

      print('✅ Loaded ${result.length} riwayat peminjaman');
      return result;
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      throw Exception('Gagal memuat riwayat: ${e.message}');
    } catch (e) {
      print('❌ Error in getAllRiwayat: $e');
      throw Exception('Gagal memuat riwayat');
    }
  }

  /// =============================
  /// GET PENGEMBALIAN BY ID - FIXED (untuk edit)
  /// =============================
  Future<Map<String, dynamic>> getPengembalianById(int idPengembalian) async {
    try {
      if (idPengembalian <= 0) {
        throw Exception('ID pengembalian tidak valid');
      }

      print('📋 Fetching pengembalian detail ID: $idPengembalian');

      final response = await _client
          .from('pengembalian')
          .select('''
            id_pengembalian,
            tgl_dikembalikan,
            kondisi_pengembalian,
            keterlambatan_hari,
            catatan,
            peminjaman!inner(
              id_peminjaman,
              users!inner(nama),
              detail_peminjaman!inner(
                alat!inner(nama_alat)
              )
            )
          ''')
          .eq('id_pengembalian', idPengembalian)
          .single();

      final dynamic peminjamanData = response['peminjaman'];
      if (peminjamanData == null) {
        throw Exception('Data peminjaman tidak ditemukan');
      }

      final dynamic userData = peminjamanData['users'];
      final dynamic detailList = peminjamanData['detail_peminjaman'];

      // Get alat name
      String namaAlat = 'Tidak ada alat';
      if (detailList is List && detailList.isNotEmpty) {
        final detail = detailList[0];
        if (detail is Map<String, dynamic>) {
          final alatData = detail['alat'];
          if (alatData is Map<String, dynamic>) {
            namaAlat = _safeParseString(alatData['nama_alat']) ?? 'Tidak ada alat';
          }
        }
      }

      return {
        'id_pengembalian': _safeParseInt(response['id_pengembalian']),
        'id_peminjaman': _safeParseInt(peminjamanData['id_peminjaman']),
        'nama_user': userData is Map<String, dynamic> 
            ? _safeParseString(userData['nama']) ?? 'Unknown'
            : 'Unknown',
        'nama_alat': namaAlat,
        'kondisi_pengembalian': _safeParseString(response['kondisi_pengembalian']) ?? 'Baik',
        'catatan': _safeParseString(response['catatan']) ?? '',
        'tgl_dikembalikan': _safeParseDate(response['tgl_dikembalikan']),
        'keterlambatan_hari': _safeParseInt(response['keterlambatan_hari']) ?? 0,
      };
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception('Data pengembalian tidak ditemukan');
      }
      throw Exception('Gagal mengambil detail: ${e.message}');
    } catch (e) {
      print('❌ Error in getPengembalianById: $e');
      throw Exception('Gagal mengambil detail pengembalian');
    }
  }

  /// =============================
  /// UPDATE PENGEMBALIAN - FIXED (menerima int?)
  /// =============================
  Future<void> updatePengembalian({
    required int? idPengembalian,
    required String kondisiPengembalian,
    String? catatan,
    DateTime? tglDikembalikan,
    int? keterlambatanHari,
  }) async {
    try {
      // VALIDASI
      if (idPengembalian == null) {
        throw Exception('ID pengembalian tidak ditemukan');
      }
      
      if (idPengembalian <= 0) {
        throw Exception('ID pengembalian tidak valid: $idPengembalian');
      }

      final validKondisi = ['Baik', 'Rusak', 'Hilang'];
      if (!validKondisi.contains(kondisiPengembalian)) {
        throw Exception('Kondisi tidak valid. Pilih: Baik, Rusak, atau Hilang');
      }

      print('🔄 Updating pengembalian ID: $idPengembalian');

      // Prepare update data
      final updateData = <String, dynamic>{
        'kondisi_pengembalian': kondisiPengembalian,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (catatan != null) {
        updateData['catatan'] = catatan;
      }

      if (tglDikembalikan != null) {
        updateData['tgl_dikembalikan'] = tglDikembalikan.toIso8601String().split('T')[0];
      }

      if (keterlambatanHari != null) {
        updateData['keterlambatan_hari'] = keterlambatanHari;
      }

      // Update data
      await _client
          .from('pengembalian')
          .update(updateData)
          .eq('id_pengembalian', idPengembalian);

      print('✅ Pengembalian updated successfully');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      
      if (e.code == '42501') {
        throw Exception('Akses ditolak. Hanya admin/petugas yang bisa mengubah data');
      }
      
      if (e.code == 'PGRST116') {
        throw Exception('Data pengembalian tidak ditemukan');
      }
      
      if (e.code == '23505') {
        throw Exception('Data sudah ada di sistem');
      }
      
      throw Exception('Gagal update: ${e.message}');
    } catch (e) {
      print('❌ Error in updatePengembalian: $e');
      throw Exception('Terjadi kesalahan saat update');
    }
  }

  /// =============================
  /// DELETE PENGEMBALIAN - FIXED (menerima int?)
  /// =============================
  Future<void> deletePengembalian(int? idPengembalian) async {
    try {
      // VALIDASI
      if (idPengembalian == null) {
        throw Exception('ID pengembalian tidak ditemukan');
      }
      
      if (idPengembalian <= 0) {
        throw Exception('ID pengembalian tidak valid: $idPengembalian');
      }

      print('🗑️ Deleting pengembalian ID: $idPengembalian');

      // Hapus pengembalian
      await _client
          .from('pengembalian')
          .delete()
          .eq('id_pengembalian', idPengembalian);

      print('✅ Pengembalian deleted successfully');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      
      if (e.code == '42501') {
        throw Exception('Akses ditolak. Hanya admin/petugas yang bisa menghapus data');
      }
      
      if (e.code == '23503') {
        throw Exception('Tidak bisa menghapus: Data masih memiliki relasi dengan tabel lain');
      }
      
      if (e.code == 'PGRST116') {
        throw Exception('Data pengembalian tidak ditemukan');
      }
      
      throw Exception('Gagal menghapus: ${e.message}');
    } catch (e) {
      print('❌ Error in deletePengembalian: $e');
      throw Exception('Terjadi kesalahan saat menghapus');
    }
  }

  /// =============================
  /// CREATE PENGEMBALIAN BARU (tambah data pengembalian)
  /// =============================
  Future<void> createPengembalian({
    required int idPeminjaman,
    required String kondisiPengembalian,
    DateTime? tglDikembalikan,
    int keterlambatanHari = 0,
    String? catatan,
  }) async {
    try {
      // Validasi
      final validKondisi = ['Baik', 'Rusak', 'Hilang'];
      if (!validKondisi.contains(kondisiPengembalian)) {
        throw Exception('Kondisi tidak valid. Pilih: Baik, Rusak, atau Hilang');
      }

      if (idPeminjaman <= 0) {
        throw Exception('ID peminjaman tidak valid');
      }

      print('➕ Creating pengembalian for peminjaman ID: $idPeminjaman');

      // Prepare data
      final pengembalianData = <String, dynamic>{
        'id_peminjaman': idPeminjaman,
        'kondisi_pengembalian': kondisiPengembalian,
        'keterlambatan_hari': keterlambatanHari,
        'tgl_dikembalikan': tglDikembalikan?.toIso8601String().split('T')[0] ?? 
            DateTime.now().toIso8601String().split('T')[0],
        'created_at': DateTime.now().toIso8601String(),
      };

      if (catatan != null && catatan.isNotEmpty) {
        pengembalianData['catatan'] = catatan;
      }

      // Insert data
      await _client
          .from('pengembalian')
          .insert(pengembalianData);

      // Update status peminjaman menjadi "Dikembalikan"
      await _client
          .from('peminjaman')
          .update({'status': 'Dikembalikan'})
          .eq('id_peminjaman', idPeminjaman);

      print('✅ Pengembalian created successfully');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      
      if (e.code == '23505') {
        throw Exception('Pengembalian untuk peminjaman ini sudah ada');
      }
      
      if (e.code == '23503') {
        throw Exception('Peminjaman tidak ditemukan');
      }
      
      throw Exception('Gagal membuat pengembalian: ${e.message}');
    } catch (e) {
      print('❌ Error in createPengembalian: $e');
      throw Exception('Terjadi kesalahan saat membuat pengembalian');
    }
  }

  /// =============================
  /// GET PEMINJAMAN BY STATUS
  /// =============================
  Future<List<Riwayat>> getPeminjamanByStatus(String status) async {
    try {
      final response = await _client
          .from('peminjaman')
          .select('''
            id_peminjaman,
            tgl_pinjam,
            tgl_kembali,
            status,
            users!peminjaman_id_user_fkey(nama),
            detail_peminjaman(
              alat(nama_alat)
            )
          ''')
          .eq('status', status)
          .order('tgl_pinjam', ascending: false);

      if (response == null || response is! List) {
        return [];
      }

      List<Riwayat> result = [];

      for (final item in response) {
        try {
          final dynamic userData = item['users'];
          final dynamic detailList = item['detail_peminjaman'];

          String namaAlat = 'Tidak ada alat';
          if (detailList is List && detailList.isNotEmpty) {
            final detail = detailList[0];
            if (detail is Map<String, dynamic>) {
              final alatData = detail['alat'];
              if (alatData is Map<String, dynamic>) {
                namaAlat = _safeParseString(alatData['nama_alat']) ?? 'Tidak ada alat';
              }
            }
          }

          result.add(Riwayat(
            idPeminjaman: _safeParseInt(item['id_peminjaman']),
            namaUser: userData is Map<String, dynamic> 
                ? _safeParseString(userData['nama']) ?? 'Unknown'
                : 'Unknown',
            namaAlat: namaAlat,
            status: _safeParseString(item['status']) ?? status,
            tglPinjam: _safeParseDate(item['tgl_pinjam']),
            tglKembali: _safeParseDate(item['tgl_kembali']),
          ));
        } catch (e) {
          print('⚠️ Error parsing status item: $e');
          continue;
        }
      }

      return result;
    } catch (e) {
      print('❌ Error in getPeminjamanByStatus: $e');
      throw Exception('Gagal memuat peminjaman berdasarkan status');
    }
  }
}