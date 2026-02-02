import 'detail_peminjaman_model.dart';

class PengembalianModel {
  final String id;
  final String nama;
  final String tanggalPeminjaman;
  final String tanggalPengembalian;
  final String? tanggalDikembalikan;
  final String status;
  final int dendaKerusakan;
  final int totalDenda;
  final List<DetailPeminjaman> alatList;

  PengembalianModel({
    required this.id,
    required this.nama,
    required this.tanggalPeminjaman,
    required this.tanggalPengembalian,
    this.tanggalDikembalikan,
    required this.status,
    required this.dendaKerusakan,
    required this.totalDenda,
    required this.alatList,
  });

  factory PengembalianModel.fromJson(Map<String, dynamic> json) {
    var detailList = json['detail_peminjaman'] as List<dynamic>? ?? [];
    List<DetailPeminjaman> alatList = detailList
        .map((e) => DetailPeminjaman.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return PengembalianModel(
      id: json['id_peminjaman'].toString(),
      nama: json['nama_user'] ?? '',
      tanggalPeminjaman: json['tgl_pinjam'] ?? '',
      tanggalPengembalian: json['tgl_kembali'] ?? '',
      tanggalDikembalikan: json['tgl_dikembalikan'],
      status: json['status'] ?? '',
      dendaKerusakan: json['denda_kerusakan'] ?? 0,
      totalDenda: json['total_denda'] ?? 0,
      alatList: alatList,
    );
  }

  PengembalianModel copyWith({String? status}) {
    return PengembalianModel(
      id: id,
      nama: nama,
      tanggalPeminjaman: tanggalPeminjaman,
      tanggalPengembalian: tanggalPengembalian,
      tanggalDikembalikan: tanggalDikembalikan,
      status: status ?? this.status,
      dendaKerusakan: dendaKerusakan,
      totalDenda: totalDenda,
      alatList: alatList,
    );
  }
}
