class Denda {
  final int idDenda;
  final int? idPengembalian;
  final String jenisDenda;
  final int jumlahDenda;
  final DateTime? createdAt;

  Denda({
    required this.idDenda,
    this.idPengembalian,
    required this.jenisDenda,
    required this.jumlahDenda,
    this.createdAt,
  });

  factory Denda.fromJson(Map<String, dynamic> json) {
    return Denda(
      idDenda: json['id_denda'] as int,
      idPengembalian: json['id_pengembalian'] as int?,
      jenisDenda: json['jenis_denda'] as String,
      jumlahDenda: json['jumlah_denda'] as int,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_denda': idDenda,
      'id_pengembalian': idPengembalian,
      'jenis_denda': jenisDenda,
      'jumlah_denda': jumlahDenda,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': idDenda,
      'name': jenisDenda,
      'amount': jumlahDenda,
      'denda_id': idDenda,
    };
  }
}