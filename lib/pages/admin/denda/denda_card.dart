import 'package:flutter/material.dart';

class DendaCard extends StatefulWidget {
  final Map<String, dynamic> denda;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DendaCard({
    super.key,
    required this.denda,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<DendaCard> createState() => _DendaCardState();
}

class _DendaCardState extends State<DendaCard> {
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
    final id = widget.denda['denda_id']?.toString() ??
        widget.denda['id']?.toString() ??
        widget.denda['id_denda']?.toString() ?? // TAMBAH INI
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
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.denda["jenis_denda"] ?? widget.denda["name"] ?? "Tidak ada nama", // PERBAIKI DI SINI
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // PERBAIKI DI SINI - ambil dari key yang benar
                  _formatAmount(widget.denda["jumlah_denda"] ?? widget.denda["amount"] ?? 0),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF666666),
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
                      color: isEditActive ? Color(0xFF3A587A) : Colors.white, // PERBAIKI WARNA
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      border: Border.all(
                        color: isEditActive ? Color(0xFF3A587A) : Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 22,
                      color: isEditActive ? Colors.white : Colors.black54,
                    ),
                  ),
                ),

                Container(
                  height: 1,
                  color: Colors.black12,
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
                      color: isDeleteActive ? Color(0xFFDC2626) : Colors.white, // PERBAIKI WARNA
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      border: Border.all(
                        color: isDeleteActive ? Color(0xFFDC2626) : Colors.black12,
                        width: 1,
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

  String _formatAmount(dynamic amount) {
    print('🔍 DendaCard amount value: $amount'); // DEBUG
    
    if (amount == null) return "Rp 0";
    
    try {
      final num value = amount is String ? int.tryParse(amount) ?? 0 : amount;
      
      // Jika 0, tampilkan Rp 0
      if (value == 0) return "Rp 0";
      
      return "Rp ${value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}";
    } catch (e) {
      print('❌ Error formatting amount: $e');
      return "Rp 0";
    }
  }
}