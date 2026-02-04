import 'package:flutter/material.dart';
import 'package:aplikasi_peminjaman_alat/core/services/alat_service.dart';

class AlatCard extends StatefulWidget {
  final String namaAlat;
  final String kategori;
  final String kondisi;
  final String? imageUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AlatCard({
    super.key,
    required this.namaAlat,
    required this.kategori,
    required this.kondisi,
    this.imageUrl,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<AlatCard> createState() => _AlatCardState();
}

class _AlatCardState extends State<AlatCard> {
  final AlatService _alatService = AlatService();
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = _processImageUrl();
  }

  @override
  void didUpdateWidget(covariant AlatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _imageUrl = _processImageUrl();
    }
  }

  String _processImageUrl() {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return '';
    }
    return _alatService.getImageUrl(widget.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 220 / 190, // ⬅️ ukuran visual TETAP SAMA
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF36536B), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// NAMA + KONDISI
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.namaAlat,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getKondisiColor(widget.kondisi),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.kondisi,
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

            /// KATEGORI
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Text(
                widget.kategori,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            /// GAMBAR
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImage(),
                ),
              ),
            ),

            /// BUTTON
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  _buildActionButton(
                    icon: Icons.edit,
                    label: 'Edit',
                    onTap: widget.onEdit,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.delete,
                    label: 'Delete',
                    onTap: widget.onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= IMAGE ================= */

  Widget _buildImage() {
    if (_imageUrl.isEmpty) {
      return _buildNoImagePlaceholder();
    }

    return Center(
      child: Image.network(
        _imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo, size: 36, color: Colors.grey),
          SizedBox(height: 6),
          Text('No Image', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 36, color: Colors.grey),
          SizedBox(height: 6),
          Text('Failed to load',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  /* ================= BUTTON ================= */

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF36536B), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: Colors.black),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
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
