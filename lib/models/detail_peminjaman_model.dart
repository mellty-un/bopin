class DetailPeminjaman {
  final int? id; // id alat
  final String namaAlat;
  final int jumlah;
  final String kondisi;

  DetailPeminjaman({
    this.id,
    required this.namaAlat,
    required this.jumlah,
    required this.kondisi,
  });

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
 