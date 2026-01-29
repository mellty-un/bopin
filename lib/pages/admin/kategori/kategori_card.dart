import 'package:aplikasi_peminjaman_alat/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class KategoriCard extends StatefulWidget {
  final Map<String, dynamic> kategori;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const KategoriCard({
    super.key,
    required this.kategori,
    required this.onEdit,
    required this.onDelete,
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
    if (mounted) {
      setState(() {
        isEditActive = false;
      });
    }
  }

  void _handleDelete() async {
    setState(() {
      isDeleteActive = true;
      isEditActive = false;
    });
    
    widget.onDelete();
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        isDeleteActive = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.kategori['kategori_id']?.toString() ??
        widget.kategori['id']?.toString() ??
        widget.kategori['id_kategori']?.toString() ??
        UniqueKey().toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColor.primary,
          width: 1,
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.kategori["nama_kategori"] ?? 
                  widget.kategori["name"] ?? 
                  "Unknown",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          Container(
            
            decoration: BoxDecoration(
              
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              children: [
                // Tombol Edit
                InkWell(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  onTap: _handleEdit,
                  child: Container(
                    width: 46,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isEditActive ? Colors.white: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 22,
                      color: isEditActive ? Colors.white : Colors.black54,
                    ),
                  ),
                ),


                InkWell(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  onTap: _handleDelete,
                  child: Container(
                    width: 46,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isDeleteActive ?Colors.white : Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                    child: Icon(
                      Icons.delete,
                      size: 22,
                      color: isDeleteActive ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}