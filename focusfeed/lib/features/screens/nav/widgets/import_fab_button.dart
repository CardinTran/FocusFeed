import 'package:flutter/material.dart';

class ImportFabButton extends StatelessWidget {
  final VoidCallback onTap;

  const ImportFabButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color.fromRGBO(133, 90, 251, 1), Color(0xFFA78BFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFF12182F), width: 6),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 34),
      ),
    );
  }
}
