import 'package:flutter/material.dart';
import 'package:focusfeed/features/import/import_controller.dart';
import 'package:focusfeed/features/import/ocr_import_service.dart';
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
  OcrImageInput? _activeOcrInput;
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

  Future<void> _showOcrSourceSheet() async {
    final input = await showModalBottomSheet<OcrImageInput>(
      context: context,
      backgroundColor: const Color(0xFF12182F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Import image with OCR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _OcrSourceTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Take Photo',
                  subtitle: 'Use your camera, then crop the text area.',
                  onTap: () => Navigator.pop(context, OcrImageInput.camera),
                ),
                const SizedBox(height: 8),
                _OcrSourceTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from Library',
                  subtitle: 'Pick an existing screenshot or photo.',
                  onTap: () => Navigator.pop(context, OcrImageInput.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (input == null) return;

    await _pickImageForOcr(input);
  }

  Future<void> _pickImageForOcr(OcrImageInput input) async {
    try {
      setState(() {
        _isScanningImage = true;
        _activeOcrInput = input;
        _statusMessage = null;
      });

      // This call includes both native image cropping and ML Kit OCR. It returns
      // draft cards only; saving is blocked until the preview screen approves.
      final preview = await _controller.pickImageForPreview(input: input);

      if (!mounted) return;

      setState(() {
        _isScanningImage = false;
        _activeOcrInput = null;
      });

      if (preview == null) {
        setState(() => _statusMessage = 'No image selected for OCR.');
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
        _activeOcrInput = null;
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
                  : _showOcrSourceSheet,
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
                _isScanningImage ? _ocrLoadingLabel : 'Image OCR',
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

  String get _ocrLoadingLabel {
    if (_activeOcrInput == OcrImageInput.camera) return 'Opening camera...';
    if (_activeOcrInput == OcrImageInput.gallery) return 'Opening library...';
    return 'Scanning image...';
  }
}

class _OcrSourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OcrSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1433),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color.fromRGBO(133, 90, 251, 1), size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
