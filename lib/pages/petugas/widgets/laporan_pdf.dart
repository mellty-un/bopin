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

    // ===== CONFIGURABLE SETTINGS =====
    final double fontHeader = 10;
    final double fontSubHeader = 8;
    final double fontItem = 8;
    final double fontTotal = 9;
    final double spacingSmall = 2;
    final double spacingMedium = 4;
    final double margin = 2;
    final double pageWidth = 58 * PdfPageFormat.mm;

    // Thermal printer 58mm, panjang fleksibel
    final pageFormat = PdfPageFormat(pageWidth, double.infinity, marginAll: margin);

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('RECEIPT',
                        style: pw.TextStyle(fontSize: fontHeader, fontWeight: pw.FontWeight.bold)),
                    pw.Text('BOPIN SIDOMULYO CITY', style: pw.TextStyle(fontSize: fontSubHeader)),
                    pw.SizedBox(height: spacingMedium),
                    pw.Divider(),
                  ],
                ),
              ),

              // ===== INFO USER =====
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Nama', style: pw.TextStyle(fontSize: fontSubHeader)),
                        pw.Text('Status', style: pw.TextStyle(fontSize: fontSubHeader)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(' ${laporan.nama}', style: pw.TextStyle(fontSize: fontSubHeader)),
                        pw.Text(' ${laporan.status}', style: pw.TextStyle(fontSize: fontSubHeader)),
                      ]),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Mulai', style: pw.TextStyle(fontSize: fontSubHeader)),
                  pw.Text(' ${dateFormat.format(laporan.mulai)}', style: pw.TextStyle(fontSize: fontSubHeader)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Kembali', style: pw.TextStyle(fontSize: fontSubHeader)),
                  pw.Text(' ${dateFormat.format(laporan.kembali)}', style: pw.TextStyle(fontSize: fontSubHeader)),
                ],
              ),
              if (laporan.dikembalikan != null)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Dikembalikan', style: pw.TextStyle(fontSize: fontSubHeader)),
                    pw.Text(' ${dateFormat.format(laporan.dikembalikan!)}', style: pw.TextStyle(fontSize: fontSubHeader)),
                  ],
                ),
              pw.SizedBox(height: spacingMedium),
              pw.Divider(),

              // ===== DAFTAR ALAT =====
              pw.Text('Description', style: pw.TextStyle(fontSize: fontTotal, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: spacingSmall),
              ...laporan.items.map((alat) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text(alat.namaAlat, style: pw.TextStyle(fontSize: fontItem))),
                    pw.Text('${alat.jumlah} pcs', style: pw.TextStyle(fontSize: fontItem)),
                  ],
                );
              }).toList(),
              pw.Divider(),

              // ===== TOTAL =====
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontSize: fontTotal, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${laporan.items.fold(0, (sum, item) => sum + item.jumlah)} pcs',
                      style: pw.TextStyle(fontSize: fontTotal, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: spacingMedium),
              pw.Divider(),

              // ===== FOOTER =====
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('THANK YOU', style: pw.TextStyle(fontSize: fontTotal, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: spacingSmall),
                    pw.Text('Barang yang sudah dipinjam', style: pw.TextStyle(fontSize: fontSubHeader)),
                    pw.Text('tidak bisa dikembalikan sebagian', style: pw.TextStyle(fontSize: fontSubHeader)),
                  ],
                ),
              ),
              pw.SizedBox(height: spacingMedium),
            ],
          );
        },
      ),
    );

    // Cetak / preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
