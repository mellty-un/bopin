import 'package:aplikasi_peminjaman_alat/core/services/supabase_service.dart';
import 'package:aplikasi_peminjaman_alat/core/utils/success_popup.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_peminjaman_alat/models/detail_peminjaman_model.dart';

class PengembalianDetailDialog extends StatefulWidget {
  final String id; // id_pengembalian
  final String nama;
  final String tanggalDiajukan;
  final String status;
  final List<DetailPeminjaman> alatList;
  final String tanggalPeminjaman;
  final String tanggalPengembalian;
  final String tanggalDikembalikan;
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
    this.onProsesSuccess,
  });

  @override
  State<PengembalianDetailDialog> createState() =>
      _PengembalianDetailDialogState();
}

class _PengembalianDetailDialogState extends State<PengembalianDetailDialog> {
  late String selectedStatus;
  bool loading = false;

  // Nilai default denda
  int dendaKerusakanPerItem = 10000;
  int dendaKehilanganPerItem = 20000;
  int dendaKeterlambatanPerHari = 5000;

  // Opsi kondisi / jenis denda
  List<String> jenisDendaOptions = ["Baik", "Kerusakan", "Kehilangan"];

  bool get isProcessed => selectedStatus == "Selesai" || selectedStatus == "Ditolak";

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.status;
    _loadDendaFromSupabase();
  }

  Future<void> _loadDendaFromSupabase() async {
    try {
      final response = await SupabaseService.client
          .from('denda')
          .select('jenis_denda, jumlah_denda')
          .order('jenis_denda', ascending: true);

      for (var item in response) {
        final jenis = item['jenis_denda'] as String;
        final jumlah = item['jumlah_denda'] as int;

        if (!jenisDendaOptions.contains(jenis)) jenisDendaOptions.add(jenis);

        if (jenis == 'Kerusakan') dendaKerusakanPerItem = jumlah;
        if (jenis == 'Kehilangan') dendaKehilanganPerItem = jumlah;
        if (jenis == 'Keterlambatan') dendaKeterlambatanPerHari = jumlah;
      }

      setState(() {});
    } catch (e) {
      debugPrint('❌ Error loading denda: $e');
    }
  }

  DateTime _parseTanggal(String tanggal) {
    try {
      if (tanggal.contains('/')) {
        final parts = tanggal.split('/');
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
      return DateTime.parse(tanggal);
    } catch (e) {
      debugPrint('Error parsing tanggal: $e');
      return DateTime.now();
    }
  }

  int getDendaTerlambat() {
    try {
      final tglKembali = _parseTanggal(widget.tanggalPengembalian);
      final tglDikembalikan = _parseTanggal(widget.tanggalDikembalikan);
      final keterlambatan = tglDikembalikan.difference(tglKembali).inDays;
      return keterlambatan > 0 ? keterlambatan * dendaKeterlambatanPerHari : 0;
    } catch (e) {
      return 0;
    }
  }

  int getDendaDariKondisiAlat() {
    int total = 0;
    for (var alat in widget.alatList) {
      final kondisi = alat.kondisi.isEmpty ? "Baik" : alat.kondisi;
      if (kondisi == "Kerusakan") total += alat.jumlah * dendaKerusakanPerItem;
      if (kondisi == "Kehilangan") total += alat.jumlah * dendaKehilanganPerItem;
    }
    return total;
  }

  int getTotalDenda() => getDendaTerlambat() + getDendaDariKondisiAlat();

  Color getStatusColor() {
    switch (selectedStatus) {
      case "Selesai":
        return Colors.green;
      case "Ditolak":
        return Colors.red;
      default:
        return const Color(0xFF3A587A);
    }
  }

  Color getKondisiColor(String kondisi) {
    switch (kondisi) {
      case "Baik":
        return const Color(0xFF4CAF50);
      case "Kerusakan":
        return const Color(0xFFDC2626);
      case "Kehilangan":
        return const Color(0xFFFFA500);
      default:
        return Colors.grey;
    }
  }

 Future<void> _prosesPengembalian(String status) async {
  setState(() => loading = true);

  try {
    // 1️⃣ Ambil id_pengembalian dari tabel pengembalian berdasarkan id_peminjaman
    final response = await SupabaseService.client
        .from('pengembalian')
        .select('id_pengembalian')
        .eq('id_peminjaman', widget.id) // pastikan widget.id = id_peminjaman
        .maybeSingle(); // ambil single record

    if (response == null) {
      debugPrint('❌ ID pengembalian untuk peminjaman ${widget.id} tidak ditemukan!');
      setState(() => loading = false);
      return;
    }

    final int pengembalianId = response['id_pengembalian'] as int;

    // 2️⃣ Update tanggal dikembalikan & status pengembalian
    await SupabaseService.client
        .from('pengembalian')
        .update({
          'tgl_dikembalikan': DateTime.now().toIso8601String(),
          'kondisi_pengembalian': widget.alatList.every((a) => a.kondisi.isEmpty || a.kondisi == "Baik")
              ? "Baik"
              : "Rusak"
        })
        .eq('id_pengembalian', pengembalianId);

    // 3️⃣ Buat list denda
    final List<Map<String, dynamic>> dendaList = [];

    for (var alat in widget.alatList) {
      final kondisi = alat.kondisi.isEmpty ? "Baik" : alat.kondisi;
      if (kondisi != "Baik") {
        dendaList.add({
          'id_pengembalian': pengembalianId, // pakai integer dari DB
          'jenis_denda': kondisi,
          'jumlah_denda': kondisi == "Kerusakan"
              ? alat.jumlah * dendaKerusakanPerItem
              : alat.jumlah * dendaKehilanganPerItem,
        });
      }
    }

    // Tambahkan denda keterlambatan
    final keterlambatan = getDendaTerlambat();
    if (keterlambatan > 0) {
      dendaList.add({
        'id_pengembalian': pengembalianId,
        'jenis_denda': 'Keterlambatan',
        'jumlah_denda': keterlambatan,
      });
    }

    // 4️⃣ Insert denda ke database
    if (dendaList.isNotEmpty) {
      await SupabaseService.client.from('denda').insert(dendaList);
    }

    // 5️⃣ Popup sukses & callback
    SuccessPopup.show(context, "Pengembalian diproses");
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
      widget.onProsesSuccess?.call(status);
    });
  } catch (e) {
    debugPrint('❌ Error proses pengembalian: $e');
    setState(() => loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final totalDenda = getTotalDenda();
    final dendaTerlambat = getDendaTerlambat();
    final dendaKondisi = getDendaDariKondisiAlat();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: loading
          ? Container(
              padding: const EdgeInsets.all(40),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Memproses pengembalian..."),
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.all(18),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.nama,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

                    // Alat List
                    const Text("Alat:", style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Column(
                      children: List.generate(widget.alatList.length, (i) {
                        final alat = widget.alatList[i];
                        final kondisiValue =
                            alat.kondisi.isEmpty ? "Baik" : alat.kondisi;

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(alat.namaAlat,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500)),
                                      Text("Jumlah: ${alat.jumlah}",
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: DropdownButton<String>(
                                    value: kondisiValue,
                                    items: jenisDendaOptions
                                        .map((value) => DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: getKondisiColor(value),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: isProcessed
                                        ? null
                                        : (value) {
                                            if (value != null) {
                                              setState(() {
                                                widget.alatList[i].kondisi =
                                                    value;
                                              });
                                            }
                                          },
                                    underline: Container(),
                                    isExpanded: true,
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

                    // Denda
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Denda Keterlambatan"),
                          Text("Rp $dendaTerlambat"),
                        ]),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Denda Kerusakan/Kehilangan"),
                          Text("Rp $dendaKondisi"),
                        ]),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Denda",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("Rp $totalDenda",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ]),
                    const SizedBox(height: 20),

                    // Tombol Terima / Tolak
                    if (!isProcessed)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _prosesPengembalian("Ditolak"),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Center(
                                    child: Text("Tolak",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500))),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _prosesPengembalian("Selesai"),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Center(
                                    child: Text("Terima",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500))),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Center(
                            child: Text("Pengembalian telah diproses",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500))),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
