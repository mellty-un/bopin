class Alat {
  final int idAlat;
  final String? namaAlat;
  final int? idKategori;
  final String? kondisi;
  final String? gambar;
  final int? stokTotal;
  final int? stokTersedia;
  final Kategori? kategori; 

  Alat({
    required this.idAlat,
    this.namaAlat,
    this.idKategori,
    this.kondisi,
    this.gambar,
    this.stokTotal,
    this.stokTersedia,
    this.kategori,
  });

  factory Alat.fromJson(Map<String, dynamic> json) {
    return Alat(
      idAlat: json['id_alat'] as int,
      namaAlat: json['nama_alat'] as String?,
      idKategori: json['id_kategori'] as int?,
      kondisi: json['kondisi'] as String?,
      gambar: json['gambar'] as String?,
      stokTotal: json['stok_total'] as int?,
      stokTersedia: json['stok_tersedia'] as int?,
      kategori: json['kategori'] != null 
          ? Kategori.fromJson(json['kategori'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': idAlat,
      'nama': namaAlat,
      'kategori': kategori?.namaKategori ?? '', 
      'kondisi': kondisi,
      'imageUrl': gambar, 
      'stok_total': stokTotal,
      'stok_tersedia': stokTersedia,
    };
  }
}

class Kategori {
  final int? idKategori;
  final String? namaKategori;

  Kategori({
    this.idKategori,
    this.namaKategori,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      idKategori: json['id_kategori'] as int?,
      namaKategori: json['nama_kategori'] as String?,
    );
  }
}