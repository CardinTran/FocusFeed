import 'package:flutter/material.dart';

class LibraryEmptyState extends StatelessWidget {
  const LibraryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No files imported yet.',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }
}
