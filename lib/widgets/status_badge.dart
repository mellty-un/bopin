import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  Color _colorStatus() {
    switch (status) {
      case 'Disetujui':
        return const Color(0xff22C55E);
      case 'Ditolak':
        return const Color(0xffEF4444);
      case 'Menunggu':
        return const Color(0xffFACC15);
      case 'Dikembalikan':
        return const Color(0xff3B82F6);
      default:
        return const Color(0xff9CA3AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _colorStatus(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
