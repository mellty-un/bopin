import 'package:flutter/material.dart';

class RiwayatCard extends StatefulWidget {
  final Map<String, dynamic> riwayat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RiwayatCard({
    super.key,
    required this.riwayat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<RiwayatCard> createState() => _RiwayatCardState();
}

class _RiwayatCardState extends State<RiwayatCard> {
  bool isEditActive = false;
  bool isDeleteActive = false;

  void _handleEdit() async {
    setState(() {
      isEditActive = true;
      isDeleteActive = false;
    });

    widget.onEdit();

    await Future.delayed(const Duration(milliseconds: 200));
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

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        isDeleteActive = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.riwayat['nama'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pengembalian',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _handleEdit,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.edit,
                size: 20,
                color: isEditActive ? Colors.black : Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: _handleDelete,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.delete,
                size: 20,
                color: isDeleteActive ? Colors.black : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
