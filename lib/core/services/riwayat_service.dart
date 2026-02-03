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
  /// HELPER: KEMBALIKAN STOK AMAN
  /// =============================
  Future<void> _kembalikanStokAman(int idPeminjaman) async {
    try {
      print('  🛒 Mengembalikan stok untuk peminjaman ID: $idPeminjaman');
      
      // Ambil detail alat yang dipinjam
      final details = await _client
          .from('detail_peminjaman')
          .select('id_alat, jumlah_pinjam')
          .eq('id_peminjaman', idPeminjaman);

      if (details is! List || details.isEmpty) {
        print('  ℹ️ Tidak ada detail alat ditemukan');
        return;
      }

      // Untuk setiap alat, kembalikan stok dengan aman
      for (var detail in details) {
        final idAlat = detail['id_alat'] as int;
        final jumlah = detail['jumlah_pinjam'] as int;

        // Gunakan RPC function yang sudah aman
        try {
          await _client.rpc('kembalikan_stok_alat', params: {
            'p_id_alat': idAlat,
            'p_jumlah_kembali': jumlah,
          });
          print('  ✅ Stok dikembalikan untuk alat ID: $idAlat, jumlah: $jumlah');
        } catch (e) {
          print('  ⚠️ Gagal kembalikan stok untuk alat $idAlat: $e');
          // Lanjutkan ke alat berikutnya
        }
      }
    } catch (e) {
      print('  ❌ Error in _kembalikanStokAman: $e');
      // Jangan throw error, karena ini hanya proses tambahan
    }
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
            nama_user,
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

          print('Processing peminjaman ID: ${item['id_peminjaman']}');
          print('Status: ${item['status']}');
          print('Jumlah pengembalian: ${pengembalianList is List ? pengembalianList.length : 0}');

          // Get user info - gunakan nama_user dari peminjaman jika ada
          String userName = _safeParseString(item['nama_user']) ?? 'Unknown';
          if (userName == 'Unknown' && userData is Map<String, dynamic>) {
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

          // Jika ada multiple pengembalian, buat satu untuk setiap pengembalian
          if (pengembalianList is List && pengembalianList.isNotEmpty) {
            for (var pengembalian in pengembalianList) {
              if (pengembalian is Map<String, dynamic>) {
                final idPengembalian = _safeParseInt(pengembalian['id_pengembalian']);
                final kondisiPengembalian = _safeParseString(pengembalian['kondisi_pengembalian']);
                final keterlambatanHari = _safeParseInt(pengembalian['keterlambatan_hari']) ?? 0;
                final catatan = _safeParseString(pengembalian['catatan']) ?? '';
                final tglDikembalikan = _safeParseDate(pengembalian['tgl_dikembalikan']);

                print('  Creating riwayat for pengembalian ID: $idPengembalian');

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
                  status: 'Dikembalikan',
                  disetujuiOleh: _safeParseString(item['disetujui_oleh']),
                  jumlahPinjam: totalJumlahPinjam > 0 ? totalJumlahPinjam : 1,
                  userRole: userData is Map<String, dynamic> 
                      ? _safeParseString(userData['role']) ?? 'peminjam'
                      : 'peminjam',
                ));
              }
            }
          } else {
            // Untuk peminjaman tanpa pengembalian
            print('  No pengembalian data for peminjaman ID: ${item['id_peminjaman']}');

            result.add(Riwayat(
              idPeminjaman: _safeParseInt(item['id_peminjaman']),
              idPengembalian: null,
              namaUser: userName,
              namaAlat: namaAlat,
              kondisiPengembalian: null,
              keterlambatanHari: 0,
              catatan: '',
              tglPinjam: _safeParseDate(item['tgl_pinjam']),
              tglKembali: _safeParseDate(item['tgl_kembali']),
              tglDikembalikan: null,
              status: _safeParseString(item['status']) ?? 'Unknown',
              disetujuiOleh: _safeParseString(item['disetujui_oleh']),
              jumlahPinjam: totalJumlahPinjam > 0 ? totalJumlahPinjam : 1,
              userRole: userData is Map<String, dynamic> 
                  ? _safeParseString(userData['role']) ?? 'peminjam'
                  : 'peminjam',
            ));
          }
        } catch (e) {
          print('⚠️ Error parsing item: $e');
          continue;
        }
      }

      // Urutkan berdasarkan tanggal pengembalian (terbaru dulu) atau tanggal pinjam
      result.sort((a, b) {
        final dateA = a.tglDikembalikan ?? a.tglPinjam;
        final dateB = b.tglDikembalikan ?? b.tglPinjam;
        
        if (dateA != null && dateB != null) {
          return dateB.compareTo(dateA);
        } else if (dateA != null) {
          return -1;
        } else if (dateB != null) {
          return 1;
        }
        return 0;
      });

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
  /// UPDATE PENGGUNAAN TERBARU
  /// =============================
  Future<void> updateLatestPengembalian({
    required int idPeminjaman,
    required String kondisiPengembalian,
    String? catatan,
  }) async {
    try {
      // Validasi
      final validKondisi = ['Baik', 'Rusak', 'Hilang'];
      if (!validKondisi.contains(kondisiPengembalian)) {
        throw Exception('Kondisi tidak valid. Pilih: Baik, Rusak, atau Hilang');
      }

      print('🔄 Updating latest pengembalian for peminjaman ID: $idPeminjaman');

      // Cari pengembalian terbaru
      final latestResponse = await _client
          .from('pengembalian')
          .select('id_pengembalian')
          .eq('id_peminjaman', idPeminjaman)
          .order('tgl_dikembalikan', ascending: false)
          .limit(1)
          .single();

      final latestId = _safeParseInt(latestResponse['id_pengembalian']);
      
      if (latestId == null) {
        throw Exception('Tidak ditemukan pengembalian untuk update');
      }

      // Prepare update data
      final updateData = <String, dynamic>{
        'kondisi_pengembalian': kondisiPengembalian,
        'catatan': catatan ?? '',
      };

      // Update data
      await _client
          .from('pengembalian')
          .update(updateData)
          .eq('id_pengembalian', latestId);

      print('✅ Latest pengembalian updated successfully');
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
      print('❌ Error in updateLatestPengembalian: $e');
      throw Exception('Terjadi kesalahan saat update');
    }
  }

  /// =============================
  /// DELETE PENGGUNAAN TERBARU - FIXED STOK ISSUE
  /// =============================
  Future<void> deleteLatestPengembalian(int idPeminjaman) async {
    try {
      if (idPeminjaman <= 0) {
        throw Exception('ID peminjaman tidak valid');
      }

      print('🗑️ Deleting latest pengembalian for peminjaman ID: $idPeminjaman');

      // 1️⃣ Ambil pengembalian terbaru
      final latestResponse = await _client
          .from('pengembalian')
          .select('id_pengembalian, tgl_dikembalikan')
          .eq('id_peminjaman', idPeminjaman)
          .order('tgl_dikembalikan', ascending: false)
          .limit(1)
          .single();

      final latestId = _safeParseInt(latestResponse['id_pengembalian']);
      
      if (latestId == null) {
        throw Exception('Tidak ditemukan pengembalian untuk dihapus');
      }

      // 2️⃣ HAPUS DENDA DULU
      print('  Deleting related denda records...');
      try {
        await _client
            .from('denda')
            .delete()
            .eq('id_pengembalian', latestId);
      } catch (e) {
        print('  ℹ️ No denda records to delete');
      }

      // 3️⃣ Hapus pengembalian terbaru
      print('  Deleting pengembalian record...');
      await _client
          .from('pengembalian')
          .delete()
          .eq('id_pengembalian', latestId);

      // 4️⃣ Cek apakah masih ada pengembalian lain
      final remainingResponse = await _client
          .from('pengembalian')
          .select('id_pengembalian')
          .eq('id_peminjaman', idPeminjaman);

      final hasRemaining = remainingResponse != null && (remainingResponse as List).isNotEmpty;

      // 5️⃣ Update status peminjaman TANPA mengembalikan stok
      final newStatus = hasRemaining ? 'Menunggu Pengembalian' : 'Disetujui';
      
      print('  Updating peminjaman status to: $newStatus');
      await _client
          .from('peminjaman')
          .update({'status': newStatus})
          .eq('id_peminjaman', idPeminjaman);

      // 6️⃣ JANGAN KEMBALIKAN STOK - stok tetap dikurangi karena alat sudah dikembalikan
      print('  ℹ️ Stok TIDAK dikembalikan karena alat sudah benar-benar digunakan');
      
      print('✅ Latest pengembalian deleted & peminjaman status updated to $newStatus');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      throw Exception('Gagal menghapus pengembalian: ${e.message}');
    } catch (e) {
      print('❌ Error in deleteLatestPengembalian: $e');
      throw Exception('Terjadi kesalahan saat menghapus: $e');
    }
  }

  /// =============================
  /// DELETE SEMUA PENGGUNAAN - FIXED STOK ISSUE
  /// =============================
  Future<void> deleteAllPengembalianForPeminjaman(int idPeminjaman) async {
    try {
      if (idPeminjaman <= 0) {
        throw Exception('ID peminjaman tidak valid');
      }

      print('🗑️ Deleting ALL pengembalian for peminjaman ID: $idPeminjaman');

      // 1️⃣ Ambil semua id_pengembalian untuk peminjaman ini
      final pengembalianList = await _client
          .from('pengembalian')
          .select('id_pengembalian')
          .eq('id_peminjaman', idPeminjaman);

      // 2️⃣ Hapus semua denda yang terkait
      if (pengembalianList is List && pengembalianList.isNotEmpty) {
        print('  Deleting related denda records...');
        for (final pengembalian in pengembalianList) {
          final idPengembalian = pengembalian['id_pengembalian'];
          try {
            await _client
                .from('denda')
                .delete()
                .eq('id_pengembalian', idPengembalian);
          } catch (e) {
            print('  ℹ️ No denda for pengembalian $idPengembalian');
          }
        }

        // 3️⃣ Hapus semua pengembalian
        print('  Deleting pengembalian records...');
        await _client
            .from('pengembalian')
            .delete()
            .eq('id_peminjaman', idPeminjaman);
      }

      // 4️⃣ Update status peminjaman TANPA mengembalikan stok
      print('  Updating peminjaman status to Disetujui');
      await _client
          .from('peminjaman')
          .update({'status': 'Disetujui'})
          .eq('id_peminjaman', idPeminjaman);

      // 5️⃣ JANGAN KEMBALIKAN STOK - status tetap "Disetujui" tapi stok tetap terpakai
      print('  ℹ️ Stok TIDAK dikembalikan - alat sudah digunakan');

      print('✅ All pengembalian deleted successfully');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      throw Exception('Gagal menghapus semua pengembalian: ${e.message}');
    } catch (e) {
      print('❌ Error in deleteAllPengembalianForPeminjaman: $e');
      throw Exception('Terjadi kesalahan saat menghapus semua pengembalian: $e');
    }
  }

  /// =============================
  /// DELETE PEMINJAMAN - FIXED
  /// =============================
  Future<void> deletePeminjaman(int? idPeminjaman) async {
    try {
      if (idPeminjaman == null || idPeminjaman <= 0) {
        throw Exception('ID peminjaman tidak valid');
      }

      print('🗑️ Deleting peminjaman ID: $idPeminjaman');

      // 1️⃣ Cek status peminjaman
      final peminjamanData = await _client
          .from('peminjaman')
          .select('status')
          .eq('id_peminjaman', idPeminjaman)
          .single();

      final status = peminjamanData['status'] as String;
      
      // 2️⃣ Jika status Ditolak atau Menunggu, langsung hapus tanpa urusan stok
      if (status == 'Ditolak' || status == 'Menunggu') {
        print('  Status: $status - langsung hapus tanpa stok adjustment');
        
        // Hapus pengembalian jika ada
        try {
          await deleteAllPengembalianForPeminjaman(idPeminjaman);
        } catch (e) {
          print('  ℹ️ No pengembalian to delete or error: $e');
        }
        
        // Hapus detail
        print('  Deleting detail_peminjaman records...');
        await _client
            .from('detail_peminjaman')
            .delete()
            .eq('id_peminjaman', idPeminjaman);
            
        // Hapus peminjaman
        print('  Deleting peminjaman record...');
        await _client
            .from('peminjaman')
            .delete()
            .eq('id_peminjaman', idPeminjaman);
            
        print('✅ Peminjaman dengan status $status deleted successfully');
        return;
      }

      // 3️⃣ Untuk status Disetujui/Dikembalikan, perlu kembalikan stok dulu
      if (status == 'Disetujui' || status == 'Dikembalikan' || status == 'Menunggu Pengembalian') {
        print('  Status: $status - perlu kembalikan stok');
        
        // Kembalikan stok sebelum hapus
        await _kembalikanStokAman(idPeminjaman);
      }

      // 4️⃣ Hapus semua pengembalian
      try {
        await deleteAllPengembalianForPeminjaman(idPeminjaman);
      } catch (e) {
        print('  ℹ️ No pengembalian to delete or error: $e');
      }

      // 5️⃣ Hapus detail_peminjaman
      print('  Deleting detail_peminjaman records...');
      await _client
          .from('detail_peminjaman')
          .delete()
          .eq('id_peminjaman', idPeminjaman);

      // 6️⃣ Hapus peminjaman
      print('  Deleting peminjaman record...');
      await _client
          .from('peminjaman')
          .delete()
          .eq('id_peminjaman', idPeminjaman);

      print('✅ Peminjaman & all related records deleted successfully');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      throw Exception('Gagal menghapus peminjaman: ${e.message}');
    } catch (e) {
      print('❌ Error in deletePeminjaman: $e');
      throw Exception('Terjadi kesalahan saat menghapus peminjaman: $e');
    }
  }

  /// =============================
  /// METODE LAINNYA (tetap sama)
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
        'catatan': catatan ?? '',
      };

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

  Future<void> deletePengembalian(int? idPengembalian) async {
    try {
      if (idPengembalian == null || idPengembalian <= 0) {
        throw Exception('ID pengembalian tidak valid');
      }

      print('🗑️ Deleting pengembalian ID: $idPengembalian');

      // 1️⃣ Ambil id_peminjaman terlebih dahulu
      final pengembalian = await _client
          .from('pengembalian')
          .select('id_peminjaman')
          .eq('id_pengembalian', idPengembalian)
          .single();

      final int idPeminjaman = pengembalian['id_peminjaman'];

      // 2️⃣ HAPUS DENDA DULU
      print('  Deleting related denda records...');
      try {
        await _client
            .from('denda')
            .delete()
            .eq('id_pengembalian', idPengembalian);
      } catch (e) {
        print('  ℹ️ No denda records to delete');
      }

      // 3️⃣ Hapus pengembalian
      print('  Deleting pengembalian record...');
      await _client
          .from('pengembalian')
          .delete()
          .eq('id_pengembalian', idPengembalian);

      // 4️⃣ Kembalikan status peminjaman TANPA mengembalikan stok
      print('  Updating peminjaman status to Disetujui');
      await _client
          .from('peminjaman')
          .update({'status': 'Disetujui'})
          .eq('id_peminjaman', idPeminjaman);

      print('✅ Pengembalian deleted & status peminjaman restored to Disetujui');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      throw Exception('Gagal menghapus pengembalian: ${e.message}');
    } catch (e) {
      print('❌ Error in deletePengembalian: $e');
      throw Exception('Terjadi kesalahan saat menghapus: $e');
    }
  }

  // Metode lainnya tetap sama...
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