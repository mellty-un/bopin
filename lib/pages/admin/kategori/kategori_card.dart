import 'package:aplikasi_peminjaman_alat/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class KategoriCard extends StatefulWidget {
  final Map<String, dynamic> kategori;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double? height; 

  const KategoriCard({
    super.key,
    required this.kategori,
    required this.onEdit,
    required this.onDelete,
    this.height,
  });

  @override
  State<KategoriCard> createState() => _KategoriCardState();
}

class _KategoriCardState extends State<KategoriCard> {
  bool isEditActive = false;
  bool isDeleteActive = false;

  void _handleEdit() async {
    setState(() {
      isEditActive = true;
      isDeleteActive = false;
    });

    widget.onEdit();

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => isEditActive = false);
  }

  void _handleDelete() async {
    setState(() {
      isDeleteActive = true;
      isEditActive = false;
    });

    widget.onDelete();

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => isDeleteActive = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.primary, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              widget.kategori["nama_kategori"] ??
                  widget.kategori["name"] ??
                  "Unknown",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: _handleEdit,
                child: Container(
                  width: 30,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Icon(Icons.edit, size: 22),
                ),
              ),
              InkWell(
                onTap: _handleDelete,
                child: Container(
                  width: 30,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Icon(Icons.delete, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
