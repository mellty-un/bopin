class Riwayat {
  final int? idPengembalian;
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
  final int? jumlahPinjam;
  final String? userRole;

  Riwayat({
    this.idPengembalian,
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
    this.jumlahPinjam,
    this.userRole,
  });

  // Factory method untuk membuat dari JSON
  factory Riwayat.fromJson(Map<String, dynamic> json) {
    return Riwayat(
      idPengembalian: json['id_pengembalian'] != null 
          ? (json['id_pengembalian'] is int 
              ? json['id_pengembalian'] 
              : int.tryParse(json['id_pengembalian'].toString()))
          : null,
      idPeminjaman: json['id_peminjaman'] != null
          ? (json['id_peminjaman'] is int 
              ? json['id_peminjaman'] 
              : int.tryParse(json['id_peminjaman'].toString()))
          : null,
      tglDikembalikan: json['tgl_dikembalikan'] != null
          ? DateTime.tryParse(json['tgl_dikembalikan'].toString())
          : null,
      kondisiPengembalian: json['kondisi_pengembalian']?.toString(),
      keterlambatanHari: json['keterlambatan_hari'] != null
          ? (json['keterlambatan_hari'] is int 
              ? json['keterlambatan_hari'] 
              : int.tryParse(json['keterlambatan_hari'].toString()) ?? 0)
          : 0,
      catatan: json['catatan']?.toString(),
      namaUser: json['nama_user']?.toString(),
      namaAlat: json['nama_alat']?.toString(),
      tglPinjam: json['tgl_pinjam'] != null
          ? DateTime.tryParse(json['tgl_pinjam'].toString())
          : null,
      tglKembali: json['tgl_kembali'] != null
          ? DateTime.tryParse(json['tgl_kembali'].toString())
          : null,
      status: json['status']?.toString(),
      disetujuiOleh: json['disetujui_oleh']?.toString(),
      jumlahPinjam: json['jumlah_pinjam'] != null
          ? (json['jumlah_pinjam'] is int 
              ? json['jumlah_pinjam'] 
              : int.tryParse(json['jumlah_pinjam'].toString()) ?? 1)
          : 1,
      userRole: json['user_role']?.toString() ?? 'peminjam',
    );
  }

  // Method toMap untuk dialog dan keperluan lainnya
  Map<String, dynamic> toMap() {
    return {
      'id_pengembalian': idPengembalian,
      'id_peminjaman': idPeminjaman,
      'tgl_dikembalikan': tglDikembalikan?.toIso8601String(),
      'kondisi_pengembalian': kondisiPengembalian,
      'kondisi': kondisiPengembalian, // Backup key untuk kompatibilitas
      'keterlambatan_hari': keterlambatanHari ?? 0,
      'catatan': catatan ?? '',
      'nama_user': namaUser,
      'nama_alat': namaAlat,
      'tgl_pinjam': tglPinjam?.toIso8601String(),
      'tgl_kembali': tglKembali?.toIso8601String(),
      'status': status,
      'disetujui_oleh': disetujuiOleh,
      'jumlah_pinjam': jumlahPinjam ?? 1,
      'user_role': userRole ?? 'peminjam',
    };
  }

  // CopyWith method untuk membuat instance baru dengan beberapa field berubah
  Riwayat copyWith({
    int? idPengembalian,
    int? idPeminjaman,
    DateTime? tglDikembalikan,
    String? kondisiPengembalian,
    int? keterlambatanHari,
    String? catatan,
    String? namaUser,
    String? namaAlat,
    DateTime? tglPinjam,
    DateTime? tglKembali,
    String? status,
    String? disetujuiOleh,
    int? jumlahPinjam,
    String? userRole,
  }) {
    return Riwayat(
      idPengembalian: idPengembalian ?? this.idPengembalian,
      idPeminjaman: idPeminjaman ?? this.idPeminjaman,
      tglDikembalikan: tglDikembalikan ?? this.tglDikembalikan,
      kondisiPengembalian: kondisiPengembalian ?? this.kondisiPengembalian,
      keterlambatanHari: keterlambatanHari ?? this.keterlambatanHari,
      catatan: catatan ?? this.catatan,
      namaUser: namaUser ?? this.namaUser,
      namaAlat: namaAlat ?? this.namaAlat,
      tglPinjam: tglPinjam ?? this.tglPinjam,
      tglKembali: tglKembali ?? this.tglKembali,
      status: status ?? this.status,
      disetujuiOleh: disetujuiOleh ?? this.disetujuiOleh,
      jumlahPinjam: jumlahPinjam ?? this.jumlahPinjam,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  String toString() {
    return 'Riwayat(idPengembalian: $idPengembalian, idPeminjaman: $idPeminjaman, namaUser: $namaUser, status: $status)';
  }
}