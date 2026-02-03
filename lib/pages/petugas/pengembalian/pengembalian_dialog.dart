import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengembalianDetailDialog extends StatefulWidget {
  final String id;
  final String nama;
  final String tanggalDiajukan;
  final String status;
  final List<DetailPeminjaman> alatList;
  final String tanggalPeminjaman;
  final String tanggalPengembalian;
  final String tanggalDikembalikan;
  final int dendaKerusakan;
  final int totalDenda;

  final void Function(String status)? onProsesSuccess;

  const PengembalianDetailDialog({
    super.key,
    required this.id,
    required this.nama,
    required this.tanggalDiajukan,
    required this.status,
    required this.alatList,
    required this.tanggalPeminjaman,
    required this.tanggalPengembalian,
    required this.tanggalDikembalikan,
    required this.dendaKerusakan,
    required this.totalDenda,
    this.onProsesSuccess,
  });

  @override
  State<PengembalianDetailDialog> createState() =>
      _PengembalianDetailDialogState();
}

class _PengembalianDetailDialogState extends State<PengembalianDetailDialog> {
  late String selectedStatus;
  
  // PERBAIKAN: Status sudah diproses jika Selesai
  bool get isProcessed => selectedStatus == "Selesai";

  // Nilai denda dari Supabase
  int dendaKerusakanPerItem = 0;
  int dendaKehilanganPerItem = 0;
  int dendaKeterlambatanPerHari = 0;
  bool loadingDenda = true;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.status;
    _loadDendaFromSupabase();
  }

  // Ambil nilai denda dari tabel denda di Supabase
  Future<void> _loadDendaFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('denda')
          .select('jenis_denda, jumlah_denda')
          .limit(10);

      // Parse denda berdasarkan jenis
      for (var item in response) {
        final jenisDenda = item['jenis_denda'] as String;
        final jumlahDenda = item['jumlah_denda'] as int;

        if (jenisDenda == 'Kerusakan') {
          dendaKerusakanPerItem = jumlahDenda;
        } else if (jenisDenda == 'Kehilangan') {
          dendaKehilanganPerItem = jumlahDenda;
        } else if (jenisDenda == 'Keterlambatan') {
          dendaKeterlambatanPerHari = jumlahDenda;
        }
      }

      setState(() {
        loadingDenda = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading denda: $e');
      // Set default values jika gagal
      setState(() {
        dendaKerusakanPerItem = 10000;
        dendaKehilanganPerItem = 20000;
        dendaKeterlambatanPerHari = 5000;
        loadingDenda = false;
      });
    }
  }

  // Hitung denda keterlambatan
  int getDendaTerlambat() {
    try {
      if (widget.tanggalDikembalikan.isEmpty ||
          widget.tanggalPengembalian.isEmpty) {
        return 0;
      }

      final tglKembali = _parseTanggal(widget.tanggalPengembalian);
      final tglDikembalikan = _parseTanggal(widget.tanggalDikembalikan);
      final keterlambatan = tglDikembalikan.difference(tglKembali).inDays;
      return keterlambatan > 0
          ? keterlambatan * dendaKeterlambatanPerHari
          : 0;
    } catch (e) {
      return 0;
    }
  }

  DateTime _parseTanggal(String tanggal) {
    try {
      // Format: DD/MM/YYYY
      final parts = tanggal.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      // Format: YYYY-MM-DD
      return DateTime.parse(tanggal);
    } catch (e) {
      return DateTime.now();
    }
  }

  // Hitung denda kerusakan dan kehilangan dari kondisi alat
  int getDendaKerusakanDanKehilangan() {
    int total = 0;
    for (var alat in widget.alatList) {
      if (alat.kondisi == "Rusak") {
        total += dendaKerusakanPerItem * alat.jumlah;
      }
      if (alat.kondisi == "Hilang") {
        total += dendaKehilanganPerItem * alat.jumlah;
      }
    }
    return total;
  }

  // Hitung total denda
  int getTotalDenda() {
    int dendaTerlambat = getDendaTerlambat();
    int dendaKerusakanKehilangan = getDendaKerusakanDanKehilangan();
    return dendaTerlambat + dendaKerusakanKehilangan;
  }

  Color getStatusColor() {
    switch (selectedStatus) {
      case "Selesai":
        return Colors.green;
      case "Ditolak":
        return Colors.red;
      case "Pengembalian":
        return Colors.orange;
      default:
        return const Color(0xFF3A587A);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loadingDenda) {
      return Dialog(
        child: Container(
          padding: const EdgeInsets.all(40),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Memuat data denda..."),
            ],
          ),
        ),
      );
    }

    int dendaTerlambat = getDendaTerlambat();
    int dendaKerusakanKehilangan = getDendaKerusakanDanKehilangan();
    int totalDenda = getTotalDenda();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==== Nama & Status ====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.nama,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      selectedStatus,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Diajukan ${widget.tanggalDiajukan}",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              // ==== Alat List dengan Dropdown Kondisi ====
              const Text("Alat:",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Column(
                children: List.generate(widget.alatList.length, (i) {
                  final alat = widget.alatList[i];
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${alat.namaAlat} (${alat.jumlah})",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownButton<String>(
                            value: alat.kondisi.isEmpty ? "Baik" : alat.kondisi,
                            items: const [
                              DropdownMenuItem(
                                  value: "Baik", child: Text("Baik")),
                              DropdownMenuItem(
                                  value: "Rusak", child: Text("Rusak")),
                              DropdownMenuItem(
                                  value: "Hilang", child: Text("Hilang")),
                            ],
                            onChanged: isProcessed
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() {
                                        widget.alatList[i].kondisi = value;
                                      });
                                    }
                                  },
                            underline: Container(),
                            style: TextStyle(
                              fontSize: 12,
                              color: alat.kondisi == "Rusak"
                                  ? const Color(0xFFDC2626)
                                  : alat.kondisi == "Hilang"
                                      ? const Color(0xFFFFA500)
                                      : const Color(0xFF4CAF50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (i < widget.alatList.length - 1)
                        const SizedBox(height: 12),
                    ],
                  );
                }),
              ),

              const SizedBox(height: 20),
              Container(height: 1, color: Colors.grey[300]),
              const SizedBox(height: 20),

              // ==== Tanggal Peminjaman / Pengembalian / Dikembalikan ====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(
                          child: Text(
                            "Tanggal Peminjaman",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Tanggal Pengembalian",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Tanggal Dikembalikan",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(widget.tanggalPeminjaman,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(widget.tanggalPengembalian,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                  widget.tanggalDikembalikan.isEmpty
                                      ? "-"
                                      : widget.tanggalDikembalikan,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Container(height: 1, color: Colors.grey[300]),
              const SizedBox(height: 8),

              // ==== Denda ====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Denda Keterlambatan",
                      style: TextStyle(fontSize: 14)),
                  Text("Rp ${dendaTerlambat.toString()}",
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Denda Kerusakan/Kehilangan",
                      style: TextStyle(fontSize: 14)),
                  Text("Rp ${dendaKerusakanKehilangan.toString()}",
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Denda",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Rp ${totalDenda.toString()}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // PERBAIKAN: Tombol Terima/Tolak hanya muncul jika belum selesai
              if (!isProcessed) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedStatus = "Ditolak");
                          SuccessPopup.show(context, "Pengembalian ditolak");
                          Future.delayed(const Duration(milliseconds: 500), () {
                            Navigator.pop(context);
                            widget.onProsesSuccess?.call("Ditolak");
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text("Tolak",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedStatus = "Selesai");
                          SuccessPopup.show(context, "Pengembalian diterima");
                          Future.delayed(const Duration(milliseconds: 500), () {
                            Navigator.pop(context);
                            widget.onProsesSuccess?.call("Selesai");
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text("Terima",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ] else ...[
                // PERBAIKAN: Info status hanya muncul jika sudah selesai
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Center(
                    child: Text(
                      "Pengembalian telah diterima",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}