import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';

class PengembalianModel {
  final String id;
  final String nama;
  final String tanggalPeminjaman;
  final String tanggalPengembalian;
  final String? tanggalDikembalikan; // ✅ dengan 'kan'
  final String status;
  final List<DetailPeminjaman> alatList;
  final int dendaKerusakan;
  final int totalDenda;

  PengembalianModel({
    required this.id,
    required this.nama,
    required this.tanggalPeminjaman,
    required this.tanggalPengembalian,
    this.tanggalDikembalikan,
    required this.status,
    required this.alatList,
    this.dendaKerusakan = 0,
    this.totalDenda = 0,
  });

  PengembalianModel copyWith({
    String? id,
    String? nama,
    String? tanggalPeminjaman,
    String? tanggalPengembalian,
    String? tanggalDikembalikan,
    String? status,
    List<DetailPeminjaman>? alatList,
    int? dendaKerusakan,
    int? totalDenda,
  }) {
    return PengembalianModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tanggalPeminjaman: tanggalPeminjaman ?? this.tanggalPeminjaman,
      tanggalPengembalian: tanggalPengembalian ?? this.tanggalPengembalian,
      tanggalDikembalikan: tanggalDikembalikan ?? this.tanggalDikembalikan, // ✅ Perbaikan: tambahkan 'kan'
      status: status ?? this.status,
      alatList: alatList ?? this.alatList,
      dendaKerusakan: dendaKerusakan ?? this.dendaKerusakan,
      totalDenda: totalDenda ?? this.totalDenda,
    );
  }

  // Optional: tambahkan fromJson jika diperlukan
  factory PengembalianModel.fromJson(Map<String, dynamic> json) {
    return PengembalianModel(
      id: json['id']?.toString() ?? '0',
      nama: json['nama'] ?? 'Tidak Diketahui',
      tanggalPeminjaman: json['tanggalPeminjaman'] ?? '',
      tanggalPengembalian: json['tanggalPengembalian'] ?? '',
      tanggalDikembalikan: json['tanggalDikembalikan'],
      status: json['status'] ?? 'Menunggu',
      alatList: (json['alatList'] as List<dynamic>?)
              ?.map((e) => DetailPeminjaman.fromJson(e))
              .toList() ??
          [],
      dendaKerusakan: json['dendaKerusakan'] ?? 0,
      totalDenda: json['totalDenda'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'tanggalPeminjaman': tanggalPeminjaman,
      'tanggalPengembalian': tanggalPengembalian,
      'tanggalDikembalikan': tanggalDikembalikan,
      'status': status,
      'alatList': alatList.map((e) => e.toJson()).toList(),
      'dendaKerusakan': dendaKerusakan,
      'totalDenda': totalDenda,
    };
  }
}