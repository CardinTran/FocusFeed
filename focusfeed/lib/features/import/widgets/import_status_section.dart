import 'package:flutter/material.dart';

class ImportStatusSection extends StatelessWidget {
  final String? selectedFileName;
  final String? statusMessage;

  const ImportStatusSection({
    super.key,
    required this.selectedFileName,
    required this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedFileName == null && statusMessage == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedFileName != null)
          Text(
            'Selected: $selectedFileName',
            style: const TextStyle(color: Colors.white70),
          ),
        if (statusMessage != null) ...[
          const SizedBox(height: 12),
          Text(statusMessage!, style: const TextStyle(color: Colors.white)),
        ],
      ],
    );
  }
}
