import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';

class LaporanModel {
  final String id;
  final String nama;
  final String tanggalMulai;
  final String tanggalKembali;
  final String? tanggalDikembalikan;
  final String status;
  final List<DetailPeminjaman> items;

  LaporanModel({
    required this.id,
    required this.nama,
    required this.tanggalMulai,
    required this.tanggalKembali,
    this.tanggalDikembalikan,
    required this.status,
    required this.items,
  });

  DateTime get mulai {
    try {
      return DateTime.parse(tanggalMulai);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime get kembali {
    try {
      return DateTime.parse(tanggalKembali);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime? get dikembalikan {
    if (tanggalDikembalikan == null) return null;
    try {
      return DateTime.parse(tanggalDikembalikan!);
    } catch (e) {
      return null;
    }
  }
}