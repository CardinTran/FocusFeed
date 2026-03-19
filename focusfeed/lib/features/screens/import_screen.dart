import 'package:flutter/material.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F2A),
        title: const Text(
          'Import Files',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
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
                    'Import PDFs, notes, slides, or documents that will be turned into feed content.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(133, 90, 251, 1),
                minimumSize: const Size(double.infinity, 54),
              ),
              onPressed: () {
              },
              icon: const Icon(Icons.folder_open, color: Colors.white),
              label: const Text(
                'Choose File',
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color.fromRGBO(133, 90, 251, 1)),
                minimumSize: const Size(double.infinity, 54),
              ),
              onPressed: () {
              },
              icon: const Icon(
                Icons.description_outlined,
                color: Color.fromRGBO(133, 90, 251, 1),
              ),
              label: const Text(
                'Import Notes or Slides',
                style: TextStyle(color: Color.fromRGBO(133, 90, 251, 1)),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF12182F),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What happens next?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Your file is uploaded\n'
                    '• Content is extracted\n'
                    '• Flashcards, quizzes, and learning posts are generated\n'
                    '• The results appear in your feed',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
