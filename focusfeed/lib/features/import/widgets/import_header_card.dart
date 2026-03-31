import 'package:flutter/material.dart';

class ImportHeaderCard extends StatelessWidget {
  const ImportHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12182F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.upload_file,
            color: Color.fromRGBO(133, 90, 251, 1),
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Upload study material',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Import a .txt',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
