
class Riwayat {
  final int idPengembalian;
  final int? idPeminjaman;
  final DateTime? tglDikembalikan;
  final String? kondisiPengembalian;
  final int? keterlambatanHari;
  final String? catatan;
  final String? namaUser;
  final String? namaAlat;
  final DateTime? tglPinjam;
  final DateTime? tglKembali;
  final String? status;
  final String? disetujuiOleh;

  Riwayat({
    required this.idPengembalian,
    this.idPeminjaman,
    this.tglDikembalikan,
    this.kondisiPengembalian,
    this.keterlambatanHari,
    this.catatan,
    this.namaUser,
    this.namaAlat,
    this.tglPinjam,
    this.tglKembali,
    this.status,
    this.disetujuiOleh,
  });

  // Method toMap untuk dialog
  Map<String, dynamic> toMap() {
    return {
      'id_pengembalian': idPengembalian,
      'id_peminjaman': idPeminjaman,
      'tgl_dikembalikan': tglDikembalikan?.toIso8601String(),
      'kondisi_pengembalian': kondisiPengembalian,
      'kondisi': kondisiPengembalian, // Backup key untuk kompatibilitas
      'keterlambatan_hari': keterlambatanHari,
      'catatan': catatan,
      'nama_user': namaUser,
      'nama_alat': namaAlat,
      'tgl_pinjam': tglPinjam?.toIso8601String(),
      'tgl_kembali': tglKembali?.toIso8601String(),
      'status': status,
      'disetujui_oleh': disetujuiOleh,
    };
  }
}