import 'package:supabase_flutter/supabase_flutter.dart';

/// Service untuk handle peminjaman dari sisi USER/PEMINJAM
class PeminjamanUserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Mendapatkan user ID yang sedang login
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  // Mendapatkan nama user yang sedang login
  Future<String?> getCurrentUserName() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return null;

      final response = await _supabase
          .from('users')
          .select('nama')
          .eq('id_user', userId)
          .single();

      return response['nama'] as String?;
    } catch (e) {
      print('Error getting user name: $e');
      return null;
    }
  }

  // Ajukan peminjaman baru
  Future<bool> ajukanPeminjaman({
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required Map<int, int> alatDanJumlah, // Map<idAlat, jumlah>
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }

      final userName = await getCurrentUserName();

      // 1. Insert ke tabel peminjaman
      final peminjamanResponse = await _supabase
          .from('peminjaman')
          .insert({
            'id_user': userId,
            'tgl_pinjam': tanggalPinjam.toIso8601String().split('T')[0],
            'tgl_kembali': tanggalKembali.toIso8601String().split('T')[0],
            'status': 'Menunggu',
            'nama_user': userName,
          })
          .select('id_peminjaman')
          .single();

      final idPeminjaman = peminjamanResponse['id_peminjaman'] as int;

      // 2. Insert detail peminjaman untuk setiap alat
      final detailList = alatDanJumlah.entries.map((entry) {
        return {
          'id_peminjaman': idPeminjaman,
          'id_alat': entry.key,
          'jumlah_pinjam': entry.value,
        };
      }).toList();

      await _supabase.from('detail_peminjaman').insert(detailList);

      // 3. Update stok_tersedia untuk setiap alat (kurangi stok) - PERBAIKAN DI SINI
      for (var entry in alatDanJumlah.entries) {
        final idAlat = entry.key;
        final jumlahPinjam = entry.value;

        // Ambil stok tersedia saat ini
        final alatResponse = await _supabase
            .from('alat')
            .select('stok_tersedia')
            .eq('id_alat', idAlat)
            .single();

        final stokTersedia = alatResponse['stok_tersedia'] as int;
        final stokBaru = stokTersedia - jumlahPinjam;

        if (stokBaru < 0) {
          throw Exception('Stok tidak mencukupi untuk alat ID: $idAlat');
        }

        // Update stok
        await _supabase
            .from('alat')
            .update({'stok_tersedia': stokBaru})
            .eq('id_alat', idAlat);
      }

      // 4. Log aktivitas
      await _supabase.from('log_aktivitas').insert({
        'id_user': userId,
        'aktivitas': 'Mengajukan peminjaman dengan ID: $idPeminjaman',
        'waktu': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error ajukan peminjaman: $e');
      return false;
    }
  }

  // SOLUSI SIMPLE: Ambil peminjaman tanpa join ke pengembalian
  Future<List<Map<String, dynamic>>> getPeminjamanByUser() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }

      // 1. Ambil data peminjaman saja tanpa pengembalian
      final response = await _supabase
          .from('peminjaman')
          .select('''
            id_peminjaman,
            tgl_pinjam,
            tgl_kembali,
            status,
            detail_peminjaman(
              id_alat,
              jumlah_pinjam,
              alat!inner(nama_alat)
            )
          ''')
          .eq('id_user', userId)
          .order('id_peminjaman', ascending: false);

      // 2. Ambil semua ID peminjaman untuk query pengembalian terpisah
      final List<int> idsPeminjaman = [];
      for (var peminjaman in response) {
        idsPeminjaman.add(peminjaman['id_peminjaman'] as int);
      }

      // 3. Ambil semua pengembalian dengan OR filter
      Map<int, Map<String, dynamic>> pengembalianMap = {};
      if (idsPeminjaman.isNotEmpty) {
        // Buat filter OR string
        String orFilter = '';
        for (int i = 0; i < idsPeminjaman.length; i++) {
          if (i > 0) orFilter += ',';
          orFilter += 'id_peminjaman.eq.${idsPeminjaman[i]}';
        }

        final pengembalianResponse = await _supabase
            .from('pengembalian')
            .select('id_pengembalian, id_peminjaman, tgl_dikembalikan, kondisi_pengembalian, keterlambatan_hari, catatan')
            .or(orFilter);

        // Masukkan ke map untuk pencarian cepat
        for (var p in pengembalianResponse) {
          pengembalianMap[p['id_peminjaman'] as int] = {
            'id_pengembalian': p['id_pengembalian'],
            'tgl_dikembalikan': p['tgl_dikembalikan'],
            'kondisi_pengembalian': p['kondisi_pengembalian'],
            'keterlambatan_hari': p['keterlambatan_hari'],
            'catatan': p['catatan'],
          };
        }
      }

      // 4. Format data untuk UI
      List<Map<String, dynamic>> result = [];
      
      for (var peminjaman in response) {
        Map<String, dynamic> alatMap = {};
        
        // Agregasi alat dari detail_peminjaman
        final details = peminjaman['detail_peminjaman'] as List;
        for (var detail in details) {
          final namaAlat = detail['alat']['nama_alat'] as String;
          final jumlah = detail['jumlah_pinjam'] as int;
          
          alatMap[namaAlat] = (alatMap[namaAlat] ?? 0) + jumlah;
        }

        // Tentukan status pengembalian
        final int idPeminjaman = peminjaman['id_peminjaman'] as int;
        final bool adaPengembalian = pengembalianMap.containsKey(idPeminjaman);
        final String statusPeminjaman = peminjaman['status'] as String;
        
        String statusPengembalian = "Belum";
        
        if (statusPeminjaman == 'Menunggu Pengembalian') {
          statusPengembalian = "Menunggu";
        } else if (statusPeminjaman == 'Dikembalikan') {
          statusPengembalian = "Selesai";
        } else if (statusPeminjaman == 'Disetujui' && adaPengembalian) {
          statusPengembalian = "Menunggu";
        }

        result.add({
          'id_peminjaman': idPeminjaman,
          'tanggal': _formatTanggal(peminjaman['tgl_pinjam'] as String),
          'status_pengembalian': statusPengembalian,
          'status_peminjaman': statusPeminjaman,
          'alat': alatMap,
          'tanggal_pengembalian': peminjaman['tgl_kembali'] != null 
              ? _formatTanggal(peminjaman['tgl_kembali'] as String) 
              : null,
          'data_pengembalian': adaPengembalian ? pengembalianMap[idPeminjaman] : null,
        });
      }

      return result;
    } catch (e) {
      print('Error getting peminjaman: $e');
      throw Exception('Gagal memuat data peminjaman: $e');
    }
  }

  // Format tanggal dari YYYY-MM-DD ke DD/MM/YYYY
  String _formatTanggal(String tanggal) {
    try {
      final date = DateTime.parse(tanggal);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return tanggal;
    }
  }

  // PERBAIKAN: Ajukan pengembalian dengan validasi stok
  Future<bool> ajukanPengembalian(
    int idPeminjaman, {
    DateTime? tanggalDikembalikan,
  }) async {
    try {
      if (idPeminjaman <= 0) {
        throw Exception("ID peminjaman tidak valid");
      }

      final tanggal = tanggalDikembalikan ?? DateTime.now();

      // 1️⃣ Update status di tabel peminjaman
      await _supabase
          .from('peminjaman')
          .update({'status': 'Menunggu Pengembalian'})
          .eq('id_peminjaman', idPeminjaman);

      // 2️⃣ Cek apakah sudah ada record pengembalian
      final existingPengembalian = await _supabase
          .from('pengembalian')
          .select('id_pengembalian')
          .eq('id_peminjaman', idPeminjaman)
          .maybeSingle();

      if (existingPengembalian == null) {
        // Insert record pengembalian baru
        await _supabase.from('pengembalian').insert({
          'id_peminjaman': idPeminjaman,
          'tgl_dikembalikan': tanggal.toIso8601String().split('T')[0],
          'kondisi_pengembalian': 'Baik', // Default
          'keterlambatan_hari': 0, // Akan dihitung oleh petugas
          'catatan': 'Diajukan oleh peminjam',
        });
      } else {
        // Update record pengembalian yang sudah ada
        await _supabase
            .from('pengembalian')
            .update({
              'tgl_dikembalikan': tanggal.toIso8601String().split('T')[0],
              'catatan': 'Diajukan ulang oleh peminjam',
            })
            .eq('id_peminjaman', idPeminjaman);
      }

      // 3️⃣ Log aktivitas user
      final userId = getCurrentUserId();
      if (userId != null) {
        await _supabase.from('log_aktivitas').insert({
          'id_user': userId,
          'aktivitas': 'Mengajukan pengembalian ID $idPeminjaman',
          'waktu': DateTime.now().toIso8601String(),
        });
      }

      return true;
    } catch (e) {
      print('❌ Error ajukan pengembalian: $e');
      return false;
    }
  }
}