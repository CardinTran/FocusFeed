import 'package:flutter/material.dart';
import 'package:focusfeed/features/import/import_controller.dart';
import 'package:focusfeed/features/import/ocr_import_preview_screen.dart';
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
  bool _isScanningImage = false;
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

  Future<void> _pickImageForOcr() async {
    try {
      setState(() {
        _isScanningImage = true;
        _statusMessage = null;
      });

      // This call includes both native image cropping and ML Kit OCR. It returns
      // draft cards only; saving is blocked until the preview screen approves.
      final preview = await _controller.pickImageForPreview();

      if (!mounted) return;

      setState(() => _isScanningImage = false);

      if (preview == null) {
        setState(() => _statusMessage = 'No image selected.');
        return;
      }

      // Route users through the editor because OCR output is not trustworthy
      // enough to save directly, even for clean screenshots.
      final result = await Navigator.push<ImportResult>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OcrImportPreviewScreen(controller: _controller, preview: preview),
        ),
      );

      if (!mounted || result == null) return;

      setState(() {
        _selectedFileName = result.fileName;
        _statusMessage = result.message;
      });

      // Match the existing import contract: returning items lets the caller
      // refresh feed/library state without needing to know the import type.
      Navigator.pop(context, result.items);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isScanningImage = false;
        _statusMessage = 'OCR failed: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              onPressed: (_isImporting || _isScanningImage)
                  ? null
                  : _pickAndImportFile,
              icon: const Icon(Icons.folder_open, color: Colors.white),
              label: Text(
                _isImporting ? 'Importing...' : 'Choose File',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color.fromRGBO(133, 90, 251, 1)),
                minimumSize: const Size(double.infinity, 54),
              ),
              onPressed: (_isImporting || _isScanningImage)
                  ? null
                  : _pickImageForOcr,
              icon: _isScanningImage
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color.fromRGBO(133, 90, 251, 1),
                      ),
                    )
                  : const Icon(
                      Icons.image_search_outlined,
                      color: Color.fromRGBO(133, 90, 251, 1),
                    ),
              label: Text(
                _isScanningImage ? 'Scanning image...' : 'Crop Image for OCR',
                style: const TextStyle(color: Color.fromRGBO(133, 90, 251, 1)),
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
