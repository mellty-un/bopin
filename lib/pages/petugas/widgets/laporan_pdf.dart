import 'dart:typed_data';
import 'package:aplikasi_peminjaman_alat/models/laporan_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanStruk {
  static Future<void> printStruk(LaporanModel laporan) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Ukuran thermal printer 58mm, panjang fleksibel
    final pageFormat = PdfPageFormat(58 * PdfPageFormat.mm, double.infinity,
        marginAll: 2);

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('TOKO ALAT ABC',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Jl. Contoh No.123',
                        style: pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 5),
                  ],
                ),
              ),
              pw.Divider(),

              // INFO PEMINJAM
              pw.Text('Nama : ${laporan.nama}', style: pw.TextStyle(fontSize: 8)),
              pw.Text('Status : ${laporan.status}', style: pw.TextStyle(fontSize: 8)),
              pw.Text('Mulai : ${dateFormat.format(laporan.mulai)}',
                  style: pw.TextStyle(fontSize: 8)),
              pw.Text('Kembali : ${dateFormat.format(laporan.kembali)}',
                  style: pw.TextStyle(fontSize: 8)),
              if (laporan.dikembalikan != null)
                pw.Text(
                    'Dikembalikan : ${dateFormat.format(laporan.dikembalikan!)}',
                    style: pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 5),
              pw.Divider(),

              // LIST ALAT
              pw.Text('Daftar Alat:', style: pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 2),
              ...laporan.items.map((alat) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                        child: pw.Text(alat.namaAlat,
                            style: pw.TextStyle(fontSize: 8))),
                    pw.Text('${alat.jumlah} pcs',
                        style: pw.TextStyle(fontSize: 8)),
                  ],
                );
              }).toList(),
              pw.SizedBox(height: 5),
              pw.Divider(),

              // FOOTER
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('Terima Kasih',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Barang yang sudah dipinjam',
                        style: pw.TextStyle(fontSize: 7)),
                    pw.Text('tidak bisa dikembalikan sebagian',
                        style: pw.TextStyle(fontSize: 7)),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),
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
