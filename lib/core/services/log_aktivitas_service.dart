import 'package:supabase_flutter/supabase_flutter.dart';

class LogAktivitasService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Ambil semua log aktivitas dengan data user dan peminjaman
  static Future<List<Map<String, dynamic>>> fetchLogAktivitas() async {
    try {
      final response = await _client
          .from('log_aktivitas')
          .select('''
            id_log,
            aktivitas,
            waktu,
            users!log_aktivitas_id_user_fkey(
              nama,
              role
            )
          ''')
          .order('waktu', ascending: false);

      final List<Map<String, dynamic>> result = [];

      for (var log in response) {
        final userData = log['users!log_aktivitas_id_user_fkey'] as Map<String, dynamic>?;
        final namaUser = userData?['nama'] as String? ?? 'User';
        final roleUser = userData?['role'] as String? ?? 'peminjam';
        final aktivitas = log['aktivitas'] as String? ?? '';
        final waktu = log['waktu'] as String? ?? '';

        final parsedInfo = _parseAktivitas(aktivitas);

        result.add({
          'id': log['id_log'],
          'name': namaUser,
          'role': roleUser,
          'status': parsedInfo['status'] ?? 'Aktivitas',
          'aktivitas': aktivitas,
          'alat': parsedInfo['alat'] ?? 'Alat',
          'jumlah': parsedInfo['jumlah'] ?? 1,
          'tanggal_pinjam': parsedInfo['tanggal_pinjam'] ?? _formatDate(waktu),
          'tanggal_kembali': parsedInfo['tanggal_kembali'] ?? _formatDate(waktu),
          'disetujui_oleh': parsedInfo['disetujui_oleh'] ?? 'Admin',
          'waktu': waktu,
        });
      }

      return result;
    } catch (e) {
      print('Error fetching log aktivitas: $e');
      return [];
    }
  }

  static Map<String, dynamic> _parseAktivitas(String aktivitas) {
    final result = <String, dynamic>{};

    if (aktivitas.toLowerCase().contains('peminjaman')) {
      result['status'] = 'Peminjaman';
    } else if (aktivitas.toLowerCase().contains('pengembalian')) {
      result['status'] = 'Pengembalian';
    } else if (aktivitas.toLowerCase().contains('menunggu')) {
      result['status'] = 'Menunggu';
    } else {
      result['status'] = 'Aktivitas';
    }

    // Coba ekstrak ID dari aktivitas
    final idMatch = RegExp(r'ID[:\s]*(\d+)').firstMatch(aktivitas);
    if (idMatch != null) {
      result['id_peminjaman'] = int.parse(idMatch.group(1)!);
    }

    return result;
  }

  static String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return '-';
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  // Alternatif: Ambil log dengan data peminjaman lengkap
  static Future<List<Map<String, dynamic>>> fetchLogAktivitasLengkap() async {
    try {
      // Pertama, ambil semua log
      final logResponse = await _client
          .from('log_aktivitas')
          .select('id_log, aktivitas, waktu, id_user')
          .order('waktu', ascending: false);

      final List<Map<String, dynamic>> result = [];

      for (var log in logResponse) {
        final userId = log['id_user'] as String?;
        final aktivitas = log['aktivitas'] as String? ?? '';
        final waktu = log['waktu'] as String? ?? '';

        // Ambil data user
        Map<String, dynamic>? userData;
        if (userId != null) {
          try {
            userData = await _client
                .from('users')
                .select('nama, role')
                .eq('id_user', userId)
                .single();
          } catch (e) {
            print('Error fetching user data: $e');
          }
        }

        final namaUser = userData?['nama'] as String? ?? 'User';
        final roleUser = userData?['role'] as String? ?? 'peminjam';

        // Coba ekstrak ID peminjaman dari aktivitas
        final idPeminjaman = _extractPeminjamanId(aktivitas);

        // Ambil data peminjaman jika ada ID
        Map<String, dynamic>? peminjamanData;
        String? tglPinjam;
        String? tglKembali;
        String? peminjamanStatus;
        
        if (idPeminjaman != null) {
          try {
            peminjamanData = await _client
                .from('peminjaman')
                .select('''
                  tgl_pinjam,
                  tgl_kembali,
                  nama_user,
                  status
                ''')
                .eq('id_peminjaman', idPeminjaman)
                .maybeSingle();

            // PERBAIKAN: Gunakan null check sebelum akses
            if (peminjamanData != null) {
              tglPinjam = peminjamanData['tgl_pinjam'] as String?;
              tglKembali = peminjamanData['tgl_kembali'] as String?;
              peminjamanStatus = peminjamanData['status'] as String?;
            }
          } catch (e) {
            print('Error fetching peminjaman data: $e');
          }
        }

        // Ambil detail alat jika ada peminjaman
        Map<String, int> alatMap = {};
        if (idPeminjaman != null) {
          try {
            final detailResponse = await _client
                .from('detail_peminjaman')
                .select('''
                  jumlah_pinjam,
                  alat(nama_alat)
                ''')
                .eq('id_peminjaman', idPeminjaman);

            for (var detail in detailResponse) {
              final alat = detail['alat'] as Map<String, dynamic>?;
              final namaAlat = alat?['nama_alat'] as String?;
              final jumlah = detail['jumlah_pinjam'] as int?;
              if (namaAlat != null && jumlah != null) {
                alatMap[namaAlat] = (alatMap[namaAlat] ?? 0) + jumlah;
              }
            }
          } catch (e) {
            print('Error fetching detail alat: $e');
          }
        }

        // Tentukan alat pertama untuk UI
        final alatPertama = alatMap.isNotEmpty ? alatMap.keys.first : 'Alat';
        final jumlahPertama = alatMap.isNotEmpty ? alatMap.values.first : 1;

        // Tentukan tanggal pinjam dan kembali
        final tanggalPinjam = tglPinjam != null 
            ? _formatDate(tglPinjam)
            : _formatDate(waktu);
        final tanggalKembali = tglKembali != null 
            ? _formatDate(tglKembali)
            : _formatDate(waktu);

        // Tentukan status
        final status = peminjamanStatus ?? _detectStatus(aktivitas);

        result.add({
          'id': log['id_log'],
          'name': namaUser,
          'role': roleUser,
          'status': status,
          'aktivitas': aktivitas,
          'alat': alatPertama,
          'jumlah': jumlahPertama,
          'alat_map': alatMap,
          'tanggal_pinjam': tanggalPinjam,
          'tanggal_kembali': tanggalKembali,
          'disetujui_oleh': 'Admin', 
          'waktu': waktu,
          'has_more_alat': alatMap.length > 1,
        });
      }

      return result;
    } catch (e) {
      print('Error fetching log aktivitas lengkap: $e');
      return [];
    }
  }

  static int? _extractPeminjamanId(String aktivitas) {
    try {
      final regex = RegExp(r'ID[:\s]*(\d+)');
      final match = regex.firstMatch(aktivitas);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String _detectStatus(String aktivitas) {
    final aktivitasLower = aktivitas.toLowerCase();
    
    if (aktivitasLower.contains('peminjaman')) return 'Peminjaman';
    if (aktivitasLower.contains('pengembalian')) return 'Pengembalian';
    if (aktivitasLower.contains('menunggu')) return 'Menunggu';
    if (aktivitasLower.contains('disetujui')) return 'Disetujui';
    if (aktivitasLower.contains('ditolak')) return 'Ditolak';
    if (aktivitasLower.contains('dikembalikan')) return 'Dikembalikan';
    
    return 'Aktivitas';
  }

  // Versi lebih sederhana tanpa parsing kompleks
  static Future<List<Map<String, dynamic>>> fetchLogAktivitasSimple() async {
    try {
      final response = await _client
          .from('log_aktivitas')
          .select('''
            id_log,
            aktivitas,
            waktu,
            users!log_aktivitas_id_user_fkey(
              nama,
              role
            )
          ''')
          .order('waktu', ascending: false);

      final List<Map<String, dynamic>> result = [];

      for (var log in response) {
        final userData = log['users!log_aktivitas_id_user_fkey'] as Map<String, dynamic>?;
        final namaUser = userData?['nama'] as String? ?? 'User';
        final roleUser = userData?['role'] as String? ?? 'peminjam';
        final aktivitas = log['aktivitas'] as String? ?? '';
        final waktu = log['waktu'] as String? ?? '';

        // Tentukan status dari aktivitas
        final status = _detectStatus(aktivitas);

        result.add({
          'id': log['id_log'],
          'name': namaUser,
          'role': roleUser,
          'status': status,
          'aktivitas': aktivitas,
          'alat': 'Alat', // Default
          'jumlah': 1, // Default
          'tanggal_pinjam': _formatDate(waktu),
          'tanggal_kembali': _formatDate(waktu),
          'disetujui_oleh': 'Admin',
          'waktu': waktu,
        });
      }

      return result;
    } catch (e) {
      print('Error fetching log aktivitas simple: $e');
      return [];
    }
  }
}