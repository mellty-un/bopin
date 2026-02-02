import 'package:aplikasi_peminjaman_alat/models/kategori_model.dart';

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
      idAlat: (json['id_alat'] as num).toInt(),
      namaAlat: json['nama_alat'] as String?,
      idKategori: (json['id_kategori'] as num?)?.toInt(),
      kondisi: json['kondisi'] as String?,
      gambar: json['gambar'] as String?,
      stokTotal: (json['stok_total'] as num?)?.toInt(),
      stokTersedia: (json['stok_tersedia'] as num?)?.toInt(),
      kategori: json['kategori'] != null
          ? Kategori.fromJson(json['kategori'] as Map<String, dynamic>)
          : null,
    );
  }
}
