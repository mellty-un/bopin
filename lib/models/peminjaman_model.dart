class PeminjamanModel {
  final int id;
  final String nama;
  final String tanggal;
  final String? kembali;
  String status; 
  final Map<String, int> alat;

  PeminjamanModel({
    required this.id,
    required this.nama,
    required this.tanggal,
    this.kembali,
    required this.status,
    required this.alat,
  });

  factory PeminjamanModel.fromJson(Map<String, dynamic> json) {
    return PeminjamanModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? 'Tidak Diketahui',
      tanggal: json['tanggal'] ?? '',
      kembali: json['kembali'],
      status: json['status'] ?? 'Menunggu',
      alat: Map<String, int>.from(json['alat'] ?? {}),
    );
  }
}
