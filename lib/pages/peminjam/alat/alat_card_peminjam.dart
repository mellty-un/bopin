import 'package:flutter/material.dart';
import 'package:aplikasi_peminjaman_alat/core/services/alat_service.dart';
import 'package:aplikasi_peminjaman_alat/models/alat_model.dart';

class AlatCardPeminjam extends StatefulWidget {
  final Alat alat;
  final VoidCallback onTap;
  final int jumlahDiKeranjang;

  const AlatCardPeminjam({
    super.key,
    required this.alat,
    required this.onTap,
    required this.jumlahDiKeranjang,
  });

  @override
  State<AlatCardPeminjam> createState() => _AlatCardPeminjamState();
}

class _AlatCardPeminjamState extends State<AlatCardPeminjam> {
  final AlatService _alatService = AlatService();
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = _processImageUrl();
  }

  @override
  void didUpdateWidget(covariant AlatCardPeminjam oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alat.gambar != widget.alat.gambar) {
      _imageUrl = _processImageUrl();
    }
  }

  String _processImageUrl() {
    if (widget.alat.gambar == null || widget.alat.gambar!.isEmpty) {
      return '';
    }
    return _alatService.getImageUrl(widget.alat.gambar);
  }

  @override
  Widget build(BuildContext context) {
    final alat = widget.alat;
    final stokTersedia = alat.stokTersedia ?? 0;
    final isStokHabis = stokTersedia == 0;

    return GestureDetector(
      onTap: isStokHabis ? null : widget.onTap,
      child: Container(
        width: 220,
        height: 190,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isStokHabis ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isStokHabis
                ? Colors.grey[300]!
                : const Color(0xFF36536B),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(
                alat.namaAlat ?? 'Tanpa Nama',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isStokHabis ? Colors.grey : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                alat.kategori?.namaKategori ?? 'Tidak Ada Kategori',
                style: TextStyle(
                  fontSize: 12,
                  color: isStokHabis
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      _buildImage(),
                      if (isStokHabis)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.block,
                                    color: Colors.white, size: 24),
                                SizedBox(height: 4),
                                Text(
                                  'STOK HABIS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            /// STOK + KONDISI (DI BAWAH GAMBAR)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// STOK
                  Text(
                    'Stok: $stokTersedia',
                    style: TextStyle(
                      fontSize: 11,
                      color: isStokHabis
                          ? Colors.red
                          : Colors.grey[700],
                      fontWeight: isStokHabis
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                  
                  /// KONDISI BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getKondisiColor(
                          alat.kondisi ?? 'Tidak Diketahui'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      alat.kondisi ?? 'Tidak Diketahui',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_imageUrl.isEmpty) {
      return _buildNoImagePlaceholder();
    }

    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 160,
            maxHeight: 100,
          ),
          child: Image.network(
            _imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorPlaceholder();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo, size: 36, color: Colors.grey),
            SizedBox(height: 6),
            Text('No Image',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 36, color: Colors.grey),
            SizedBox(height: 6),
            Text('Failed to load',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Color _getKondisiColor(String kondisi) {
    switch (kondisi.toLowerCase()) {
      case 'baik':
        return Colors.green;
      case 'rusak':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}