import 'package:flutter/material.dart';
import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';

class PengembalianPeminjamDetailDialog extends StatefulWidget {
  final String id;
  final String nama;
  final String tanggalDiajukan;
  final String status; // bisa "Belum", "Menunggu", "Selesai"
  final List<DetailPeminjaman> alatList;
  final String tanggalPeminjaman;
  final String tanggalPengembalian;
  final void Function(DateTime tglDikembalikan) onAjukanSuccess;

  const PengembalianPeminjamDetailDialog({
    super.key,
    required this.id,
    required this.nama,
    required this.tanggalDiajukan,
    required this.status,
    required this.alatList,
    required this.tanggalPeminjaman,
    required this.tanggalPengembalian,
    required this.onAjukanSuccess,
  });

  @override
  State<PengembalianPeminjamDetailDialog> createState() =>
      _PengembalianPeminjamDetailDialogState();
}

class _PengembalianPeminjamDetailDialogState
    extends State<PengembalianPeminjamDetailDialog> {
  DateTime? tglDikembalikan;

  bool get isAlreadySubmitted =>
      widget.status == "Menunggu" || widget.status == "Selesai";

  @override
  Widget build(BuildContext context) {
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.nama,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.status == "Selesai"
                          ? Colors.green
                          : widget.status == "Menunggu"
                              ? Colors.orange
                              : const Color(0xFF3A587A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.status,
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

              // Alat list
              const Text("Alat:", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Column(
                children: widget.alatList.map((alat) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(alat.namaAlat),
                          Text("${alat.jumlah}"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            alat.kondisi,
                            style: TextStyle(
                              color: alat.kondisi == "Rusak"
                                  ? const Color(0xFFDC2626)
                                  : alat.kondisi == "Hilang"
                                      ? const Color(0xFFFFA500)
                                      : const Color(0xFF4CAF50),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (widget.alatList.indexOf(alat) <
                          widget.alatList.length - 1)
                        const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              Container(height: 1, color: Colors.grey[300]),
              const SizedBox(height: 20),

              // Tanggal Peminjaman & Pengembalian
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Tanggal Peminjaman",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 6),
                          Text(widget.tanggalPeminjaman,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Tanggal Pengembalian",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 6),
                          Text(widget.tanggalPengembalian,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Input Tanggal Dikembalikan
              InkWell(
                onTap: isAlreadySubmitted
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setState(() {
                            tglDikembalikan = picked;
                          });
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: isAlreadySubmitted
                        ? Colors.grey[200]
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tglDikembalikan == null
                            ? (isAlreadySubmitted
                                ? "Menunggu pengembalian"
                                : "Pilih Tanggal Dikembalikan")
                            : "${tglDikembalikan!.day.toString().padLeft(2,'0')}/${tglDikembalikan!.month.toString().padLeft(2,'0')}/${tglDikembalikan!.year}",
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isAlreadySubmitted ? Colors.grey : Colors.black,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tombol Ajukan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (tglDikembalikan == null || isAlreadySubmitted)
                      ? null
                      : () {
                          Navigator.pop(context);
                          widget.onAjukanSuccess(tglDikembalikan!);
                        },
                  child: Text(
                    isAlreadySubmitted
                        ? widget.status == "Selesai"
                            ? "Selesai"
                            : "Menunggu"
                        : "Ajukan Pengembalian",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
