class Kategori {
  final int idKategori;
  final String namaKategori;
  final DateTime? createdAt;

  Kategori({
    required this.idKategori,
    required this.namaKategori,
    this.createdAt,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      idKategori: json['id_kategori'] ?? json['id'] ?? 0,
      namaKategori: json['nama_kategori'] ?? json['name'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kategori': idKategori,
      'nama_kategori': namaKategori,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Kategori copyWith({
    int? idKategori,
    String? namaKategori,
    DateTime? createdAt,
  }) {
    return Kategori(
      idKategori: idKategori ?? this.idKategori,
      namaKategori: namaKategori ?? this.namaKategori,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}