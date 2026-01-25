import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogAktivitasCard extends StatefulWidget {
  final Map<String, dynamic> aktivitas;

  const LogAktivitasCard({
    super.key,
    required this.aktivitas,
  });

  @override
  State<LogAktivitasCard> createState() => _LogAktivitasCardState();
}

class _LogAktivitasCardState extends State<LogAktivitasCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  void _toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'peminjaman':
        return const Color(0xFF4CAF50); 
      case 'pengembalian':
        return const Color(0xFF2196F3);
      case 'menunggu':
        return const Color(0xFFFF9800); 
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    String initial = widget.aktivitas["name"].toString().isNotEmpty
        ? widget.aktivitas["name"][0].toUpperCase()
        : "?";

    String status = widget.aktivitas["status"] ?? "Peminjaman";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Column(
        children: [
          // Header Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
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

                // Nama dan Status
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.aktivitas["name"] ?? "Unknown",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tombol Detail
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _toggleExpansion,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A587A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Divider atas
                  Container(
                    height: 1,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.only(bottom: 16),
                  ),

                  // Alat
                  _buildDetailRow(
                    icon: Icons.build_outlined,
                    label: 'Alat',
                    value: widget.aktivitas["alat"] ?? '-',
                  ),
                  
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Row(
                      children: [
                        Text(
                          widget.aktivitas["alat"] ?? 'Panci',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.aktivitas["jumlah"]?.toString() ?? '1',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: _formatDate(widget.aktivitas["tanggal_pinjam"]),
                    value: 'Kembali: ${_formatDate(widget.aktivitas["tanggal_kembali"])}',
                    isDate: true,
                  ),

                  const SizedBox(height: 16),

                  _buildDetailRow(
                    icon: Icons.person_outline,
                    label: 'Disetujui oleh',
                    value: widget.aktivitas["disetujui_oleh"] ?? '-',
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A587A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isDate = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF3A587A),
          ),
        ),
        
        const SizedBox(width: 8),

        // Content
        Expanded(
          child: isDate
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}