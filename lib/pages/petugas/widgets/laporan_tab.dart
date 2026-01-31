import 'package:flutter/material.dart';


class LaporanTab extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const LaporanTab({
    super.key,
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF4A6FA5) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
