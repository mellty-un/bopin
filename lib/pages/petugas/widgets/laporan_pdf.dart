import 'dart:typed_data';
import 'package:aplikasi_peminjaman_alat/models/laporan_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanPdf {
  static Future<void> printLaporan(LaporanModel laporan) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Peminjaman',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Nama: ${laporan.nama}',
                      style: pw.TextStyle(fontSize: 14)),
                  pw.Text('Status: ${laporan.status}',
                      style: pw.TextStyle(fontSize: 14)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Mulai: ${dateFormat.format(laporan.mulai)}',
                      style: pw.TextStyle(fontSize: 12)),
                  pw.Text('Kembali: ${dateFormat.format(laporan.kembali)}',
                      style: pw.TextStyle(fontSize: 12)),
                  if (laporan.dikembalikan != null)
                    pw.Text(
                        'Dikembalikan: ${dateFormat.format(laporan.dikembalikan!)}',
                        style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text('Alat:',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Column(
                children: laporan.items.map((alat) {
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(alat.namaAlat,
                          style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('${alat.jumlah} pcs',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    // Tampilkan print dialog / generate PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
