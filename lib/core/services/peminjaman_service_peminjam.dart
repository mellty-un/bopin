import 'package:supabase_flutter/supabase_flutter.dart';

class PeminjamanServicePeminjam {
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

      // 1. Validasi stok tersedia sebelum ajukan peminjaman
      for (var entry in alatDanJumlah.entries) {
        final idAlat = entry.key;
        final jumlahPinjam = entry.value;

        // Ambil stok tersedia saat ini
        final alatResponse = await _supabase
            .from('alat')
            .select('stok_tersedia, nama_alat')
            .eq('id_alat', idAlat)
            .single();

        final stokTersedia = alatResponse['stok_tersedia'] as int;
        final namaAlat = alatResponse['nama_alat'] as String;

        // Validasi stok cukup
        if (stokTersedia < jumlahPinjam) {
          throw Exception(
            'Stok $namaAlat tidak mencukupi. Tersedia: $stokTersedia, Diminta: $jumlahPinjam'
          );
        }
      }

      // 2. Insert ke tabel peminjaman dengan status Menunggu
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

      // 3. Insert detail peminjaman untuk setiap alat
      final detailList = alatDanJumlah.entries.map((entry) {
        return {
          'id_peminjaman': idPeminjaman,
          'id_alat': entry.key,
          'jumlah_pinjam': entry.value,
        };
      }).toList();

      await _supabase.from('detail_peminjaman').insert(detailList);

      // PENTING: TIDAK MENGURANGI STOK DI SINI
      // Stok akan dikurangi saat peminjaman disetujui oleh petugas
      // di PeminjamanService.updateStatus()

      // 4. Log aktivitas
      await _supabase.from('log_aktivitas').insert({
        'id_user': userId,
        'aktivitas': 'Mengajukan peminjaman dengan ID: $idPeminjaman',
        'waktu': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error ajukan peminjaman: $e');
      rethrow; // throw ulang error agar bisa ditangkap di UI
    }
  }

  // Mendapatkan semua peminjaman user yang sedang login
  Future<List<Map<String, dynamic>>> getPeminjamanByUser() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Ambil data peminjaman dengan detail alat
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
              alat(
                nama_alat
              )
            )
          ''')
          .eq('id_user', userId)
          .order('id_peminjaman', ascending: false);

      // Format data untuk UI
      List<Map<String, dynamic>> result = [];
      
      for (var peminjaman in response) {
        Map<String, dynamic> alatMap = {};
        
        // Agregasi alat dari detail_peminjaman
        final details = peminjaman['detail_peminjaman'] as List;
        for (var detail in details) {
          final namaAlat = detail['alat']['nama_alat'] as String;
          final jumlah = detail['jumlah_pinjam'] as int;
          
          if (alatMap.containsKey(namaAlat)) {
            alatMap[namaAlat] += jumlah;
          } else {
            alatMap[namaAlat] = jumlah;
          }
        }

        result.add({
          'id_peminjaman': peminjaman['id_peminjaman'],
          'tanggal': _formatTanggal(peminjaman['tgl_pinjam']),
          'status_peminjaman': peminjaman['status'], // ubah key jadi status_peminjaman
          'alat': alatMap,
          'tanggal_pengembalian': peminjaman['tgl_kembali'] != null 
              ? _formatTanggal(peminjaman['tgl_kembali']) 
              : null,
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

  // Ajukan pengembalian
  Future<bool> ajukanPengembalian(int idPeminjaman) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Cek status peminjaman saat ini
      final peminjamanData = await _supabase
          .from('peminjaman')
          .select('status')
          .eq('id_peminjaman', idPeminjaman)
          .single();

      final statusSekarang = peminjamanData['status'] as String;

      // Hanya bisa ajukan pengembalian jika status Disetujui
      if (statusSekarang != 'Disetujui') {
        throw Exception('Hanya peminjaman yang sudah disetujui yang bisa dikembalikan');
      }

      // Update status peminjaman menjadi 'Menunggu Pengembalian'
      await _supabase
          .from('peminjaman')
          .update({'status': 'Menunggu Pengembalian'})
          .eq('id_peminjaman', idPeminjaman);

      // Insert ke tabel pengembalian dengan status menunggu
      await _supabase.from('pengembalian').insert({
        'id_peminjaman': idPeminjaman,
        'tgl_dikembalikan': DateTime.now().toIso8601String().split('T')[0],
        'kondisi_pengembalian': 'Baik',
        'keterlambatan_hari': 0,
        'catatan': 'Pengembalian diajukan oleh peminjam, menunggu konfirmasi petugas',
      });

    
      // Log aktivitas
      await _supabase.from('log_aktivitas').insert({
        'id_user': userId,
        'aktivitas': 'Mengajukan pengembalian untuk peminjaman ID: $idPeminjaman',
        'waktu': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error ajukan pengembalian: $e');
      rethrow; // throw ulang error agar bisa ditangkap di UI
    }
  }
}