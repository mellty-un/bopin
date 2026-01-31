class PengembalianModel {
  final int idPengembalian;
  final String namaUser;
  final String namaAlat;
  final int jumlahPinjam;
  final String kondisiPengembalian;
  final DateTime? tglPinjam;
  final DateTime? tglDikembalikan;

  PengembalianModel({
    required this.idPengembalian,
    required this.namaUser,
    required this.namaAlat,
    required this.jumlahPinjam,
    required this.kondisiPengembalian,
    required this.tglPinjam,
    required this.tglDikembalikan,
  });

  factory PengembalianModel.fromJson(Map<String, dynamic> json) {
    final peminjaman = json['peminjaman'];
    final detail = peminjaman['detail_peminjaman'][0];
    final alat = detail['alat'];

    return PengembalianModel(
      idPengembalian: json['id_pengembalian'],
      namaUser: peminjaman['nama_user'] ?? '-',
      namaAlat: alat['nama_alat'] ?? '-',
      jumlahPinjam: detail['jumlah_pinjam'] ?? 0,
      kondisiPengembalian: json['kondisi_pengembalian'] ?? '-',
      tglPinjam: peminjaman['tgl_pinjam'] != null
          ? DateTime.parse(peminjaman['tgl_pinjam'])
          : null,
      tglDikembalikan: json['tgl_dikembalikan'] != null
          ? DateTime.parse(json['tgl_dikembalikan'])
          : null,
    );
  }
}
