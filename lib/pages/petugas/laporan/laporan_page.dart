import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final List<String> tabs = ['Semua', 'Peminjaman', 'Pengembalian'];
  int selectedTab = 0;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Dummy data untuk laporan
  final List<Laporan> listLaporan = [
    Laporan(
      nama: 'Chella',
      mulai: DateTime(2026, 1, 20),
      kembali: DateTime(2026, 1, 24),
      items: [
        Alat(nama: 'Panci', jumlah: 1),
        Alat(nama: 'Pisau', jumlah: 1),
      ],
    ),
    Laporan(
      nama: 'Viona',
      mulai: DateTime(2026, 1, 20),
      kembali: DateTime(2026, 1, 24),
      items: [
        Alat(nama: 'Panci', jumlah: 1),
        Alat(nama: 'Pisau', jumlah: 1),
      ],
    ),
    Laporan(
      nama: 'Rizky',
      mulai: DateTime(2026, 1, 22),
      kembali: DateTime(2026, 1, 25),
      items: [
        Alat(nama: 'Kompor', jumlah: 1),
        Alat(nama: 'Wajan', jumlah: 2),
      ],
    ),
  ];

  List<Laporan> get filteredLaporan {
    if (searchQuery.isEmpty) {
      return listLaporan;
    }
    
    return listLaporan.where((laporan) {
      final namaLower = laporan.nama.toLowerCase();
      final queryLower = searchQuery.toLowerCase();
      
      // Cek apakah nama mengandung query
      if (namaLower.contains(queryLower)) {
        return true;
      }
      
      // Cek apakah alat mengandung query
      for (var alat in laporan.items) {
        if (alat.nama.toLowerCase().contains(queryLower)) {
          return true;
        }
      }
      
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'search',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.search, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: List.generate(tabs.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedTab == index 
                            ? const Color(0xFF4A6FA5) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: selectedTab == index 
                                ? Colors.white 
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // List Laporan
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredLaporan.length,
              itemBuilder: (context, index) {
                return LaporanCard(laporan: filteredLaporan[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LaporanCard extends StatelessWidget {
  final Laporan laporan;
  
  const LaporanCard({
    super.key,
    required this.laporan,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama
          Text(
            laporan.nama,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 15),
          
          // Info Tanggal
          Row(
            children: [
              DateInfo(
                label: 'Mulai:',
                date: dateFormat.format(laporan.mulai),
              ),
              const SizedBox(width: 30),
              DateInfo(
                label: 'Kembali:',
                date: dateFormat.format(laporan.kembali),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Tabel Alat
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: const Color(0xFFE0E0E0).withOpacity(0.5),
                ),
                bottom: BorderSide(
                  color: const Color(0xFFE0E0E0).withOpacity(0.5),
                ),
              ),
              children: [
                // Header
                const TableRow(
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F5F9),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                      child: Text(
                        'Alat',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                      child: Text(
                        '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Data
                ...laporan.items.map((alat) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                      child: Text(alat.nama),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                      child: Text(alat.jumlah.toString()),
                    ),
                  ],
                )).toList(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Tombol Print
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => _printReport(context, laporan),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6FA5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                'Print Report',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _printReport(BuildContext context, Laporan laporan) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    // Tampilkan dialog/snackbar sebagai simulasi print
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mencetak laporan untuk ${laporan.nama}'),
        backgroundColor: const Color(0xFF4A6FA5),
      ),
    );

  }
}

class DateInfo extends StatelessWidget {
  final String label;
  final String date;
  
  const DateInfo({
    super.key,
    required this.label,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          date,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

// Model Data
class Laporan {
  final String nama;
  final DateTime mulai;
  final DateTime kembali;
  final List<Alat> items;
  
  Laporan({
    required this.nama,
    required this.mulai,
    required this.kembali,
    required this.items,
  });
}

class Alat {
  final String nama;
  final int jumlah;
  
  Alat({
    required this.nama,
    required this.jumlah,
  });
}