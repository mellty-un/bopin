import 'package:flutter/material.dart';

class PengembalianDetailDialog extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onProses;

  const PengembalianDetailDialog({
    super.key,
    required this.data,
    required this.onProses,
  });

  @override
  Widget build(BuildContext context) {
    final status = data["status"];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Pengembalian",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  badge(status),
                ],
              ),

              const SizedBox(height: 6),
              Text("Diajukan ${data["tanggal"]}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),

              const SizedBox(height: 20),

              const Text("Alat:",
                  style: TextStyle(fontWeight: FontWeight.w600)),

              const SizedBox(height: 8),

              /// ALAT LIST
              Column(
                children: (data["alatList"] as List).map<Widget>((e) {
                  final rusak = e["kondisi"] == "Rusak";
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e["nama"]),
                        Row(
                          children: [
                            Text("${e["jumlah"]}"),
                            const SizedBox(width: 10),
                            Text(
                              e["kondisi"],
                              style: TextStyle(
                                fontSize: 12,
                                color: rusak
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              divider(),

              /// TANGGAL TABLE
              dateTable(
                data["tglPinjam"],
                data["tglKembali"],
                data["tglDikembalikan"],
              ),

              divider(),

              row("Denda Terlambat", "0"),
              row("Denda Kerusakan", "${data["dendaKerusakan"]}"),

              divider(),

              row("Total", "${data["total"]}", bold: true),

              const SizedBox(height: 20),

              if (status != "Selesai")
                Row(
                  children: [
                    button("Ditolak", Colors.red, () {
                      Navigator.pop(context);
                    }),
                    const SizedBox(width: 12),
                    button("Proses", Colors.green, () {
                      Navigator.pop(context);
                      onProses();
                    }),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget badge(String s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: s == "Selesai" ? Colors.green : const Color(0xFF3A587A),
          borderRadius: BorderRadius.circular(20),
        ),
        child:
            Text(s, style: const TextStyle(color: Colors.white, fontSize: 11)),
      );

  Widget divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(height: 1, color: Colors.grey[300]),
      );

  Widget row(String l, String r, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(r,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      );

  Widget button(String text, Color c, VoidCallback onTap) => Expanded(
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration:
                BoxDecoration(color: c, borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(text,
                    style: const TextStyle(color: Colors.white))),
          ),
        ),
      );

  Widget dateTable(String a, String b, String c) => Container(
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
                    child: Text("Tanggal\nPeminjaman",
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 11))),
                Expanded(
                    child: Text("Tanggal\nPengembalian",
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 11))),
                Expanded(
                    child: Text("Tanggal\nDikembalikan",
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 11))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Center(child: Text(a, style: const TextStyle(fontSize: 12)))) ,
                Expanded(child: Center(child: Text(b, style: const TextStyle(fontSize: 12)))) ,
                Expanded(child: Center(child: Text(c, style: const TextStyle(fontSize: 12)))) ,
              ],
            ),
          ],
        ),
      );
}
