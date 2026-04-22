import 'package:flutter/material.dart';
import 'package:focusfeed/features/import/import_controller.dart';
import 'package:focusfeed/features/import/widgets/import_format_card.dart';
import 'package:focusfeed/features/import/widgets/import_header_card.dart';
import 'package:focusfeed/features/import/widgets/import_status_section.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final ImportController _controller = ImportController();

  bool _isImporting = false;
  String? _statusMessage;
  String? _selectedFileName;

  Future<void> _pickAndImportFile() async {
    try {
      setState(() {
        _isImporting = true;
        _statusMessage = null;
      });

      final result = await _controller.pickAndImportFile();

      if (!mounted) return;

      setState(() {
        _selectedFileName = result.fileName;
        _isImporting = false;
        _statusMessage = result.message;
      });

      Navigator.pop(context, result.items);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isImporting = false;
        _statusMessage = 'Import failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F2A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(133, 90, 251, 1),
          ),
          onPressed: () => Navigator.pop(context),
        ),
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
            const ImportHeaderCard(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(133, 90, 251, 1),
                minimumSize: const Size(double.infinity, 54),
              ),
              onPressed: _isImporting ? null : _pickAndImportFile,
              icon: const Icon(Icons.folder_open, color: Colors.white),
              label: Text(
                _isImporting ? 'Importing...' : 'Choose File',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            ImportStatusSection(
              selectedFileName: _selectedFileName,
              statusMessage: _statusMessage,
            ),
            const SizedBox(height: 24),
            const ImportFormatCard(),
          ],
        ),
      ),
    );
  }
}
