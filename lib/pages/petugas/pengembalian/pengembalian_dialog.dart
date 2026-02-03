import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';

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
  bool get isProcessed => selectedStatus == "Selesai";

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.status;
  }

  // Hitung denda keterlambatan dalam integer
  int getDendaTerlambat() {
    try {
      final tglKembali = DateTime.parse(widget.tanggalPengembalian);
      final tglDikembalikan = DateTime.parse(widget.tanggalDikembalikan);
      final keterlambatan = tglDikembalikan.difference(tglKembali).inDays;
      return keterlambatan > 0 ? keterlambatan * 5000 : 0;
    } catch (e) {
      return 0;
    }
  }

  // Hitung total denda
  int getTotalDenda() {
    int total = widget.dendaKerusakan + getDendaTerlambat();
    for (var alat in widget.alatList) {
      if (alat.kondisi == "Rusak") total += 10000;
      if (alat.kondisi == "Hilang") total += 20000;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    int dendaTerlambat = getDendaTerlambat();
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
              // ==== Nama & Status Tetap Sama ====
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
                      color: isProcessed
                          ? Colors.green
                          : const Color(0xFF3A587A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isProcessed ? "Selesai" : "Belum diproses",
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
              const Text("Alat:", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
             Column(
  children: List.generate(widget.alatList.length, (i) {
    final alat = widget.alatList[i];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(alat.namaAlat),
            DropdownButton<String>(
              value: alat.kondisi,
              items: const [
                DropdownMenuItem(value: "Baik", child: Text("Baik")),
                DropdownMenuItem(value: "Rusak", child: Text("Rusak")),
                DropdownMenuItem(value: "Hilang", child: Text("Hilang")),
              ],
              onChanged: widget.status == "Selesai"
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          widget.alatList[i].kondisi = value; // pake i
                        });
                      }
                    },
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
                              Text(widget.tanggalDikembalikan,
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
                  const Text("Denda Terlambat", style: TextStyle(fontSize: 14)),
                  Text(dendaTerlambat.toString(), style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Denda Kerusakan", style: TextStyle(fontSize: 14)),
                  Text(widget.dendaKerusakan.toString(), style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Denda", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(totalDenda.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // ==== Tombol Terima / Tolak ====
          // ==== Tombol Terima / Tolak ====
if (!isProcessed) ...[
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () {
            SuccessPopup.show(context, "Pengembalian ditolak");
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.pop(context);
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
              widget.onProsesSuccess?.call(selectedStatus);
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
  Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Center(
      child: Text("Pengembalian telah diterima",
          style: TextStyle(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
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
