import 'package:flutter/material.dart';

class PenggunaCard extends StatefulWidget {
  final Map<String, dynamic> pengguna;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PenggunaCard({
    super.key,
    required this.pengguna,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<PenggunaCard> createState() => _PenggunaCardState();
}

class _PenggunaCardState extends State<PenggunaCard> {
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
    final id = widget.pengguna['pengguna_id']?.toString() ??
        widget.pengguna['id']?.toString() ??
        UniqueKey().toString();

    String initial = widget.pengguna["name"].toString().isNotEmpty
        ? widget.pengguna["name"][0].toUpperCase()
        : "?";

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
      ),
      child: Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF3A587A),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    const SizedBox(width: 14),

    Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.pengguna["name"] ?? "Unknown",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            widget.pengguna["role"] ?? "Peminjam",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black54,
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
                      color: isEditActive ? Colors.white : Colors.white,
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


                // Tombol Delete
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