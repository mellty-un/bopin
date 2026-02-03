class DetailPeminjaman {
  final int? id;
  final String namaAlat;
  final int jumlah;
 String kondisi;

  DetailPeminjaman({
    this.id,
    required this.namaAlat,
    required this.jumlah,
    required this.kondisi,
  });

  DetailPeminjaman copyWith({String? kondisi}) {
    return DetailPeminjaman(
      id: id,
      namaAlat: namaAlat,
      jumlah: jumlah,
      kondisi: kondisi ?? this.kondisi,
    );
  }

  factory DetailPeminjaman.fromJson(Map<String, dynamic> json) {
    return DetailPeminjaman(
      id: json['id_alat'],
      namaAlat: json['nama_alat'],
      jumlah: json['jumlah_pinjam'],
      kondisi: json['kondisi_alat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_alat': id,
      'nama_alat': namaAlat,
      'jumlah_pinjam': jumlah,
      'kondisi_alat': kondisi,
    };
  }
}
