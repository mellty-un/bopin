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
                  widget.denda["name"] ?? "Unknown",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAmount(widget.denda["amount"]),
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
                      color: isEditActive ?Colors.white : Colors.white,
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
                      color: isDeleteActive ? Colors.white: Colors.white,
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

  String _formatAmount(dynamic amount) {
    if (amount == null) return "Rp 0";
    
    try {
      final num value = amount is String ? double.tryParse(amount) ?? 0 : amount;
      return "Rp ${value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}";
    } catch (e) {
      return "Rp 0";
    }
  }
}