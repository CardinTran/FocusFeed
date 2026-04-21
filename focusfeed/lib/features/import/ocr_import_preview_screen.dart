import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';
import 'package:focusfeed/features/import/import_controller.dart';
import 'package:focusfeed/features/import/parsed_flashcard.dart';

class OcrImportPreviewScreen extends StatefulWidget {
  final ImportController controller;
  final OcrPreviewResult preview;

  const OcrImportPreviewScreen({
    super.key,
    required this.controller,
    required this.preview,
  });

  @override
  State<OcrImportPreviewScreen> createState() => _OcrImportPreviewScreenState();
}

class _OcrImportPreviewScreenState extends State<OcrImportPreviewScreen> {
  final List<_EditableCardDraft> _drafts = [];
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // If OCR returns no usable lines, still show one editable row so the user
    // can manually create cards from the image instead of hitting a dead end.
    final cards = widget.preview.cards.isEmpty
        ? [const ParsedFlashcard(term: '', answer: '')]
        : widget.preview.cards;

    _drafts.addAll(
      cards.map(
        (card) => _EditableCardDraft(
          frontController: TextEditingController(text: card.term),
          backController: TextEditingController(text: card.answer),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  void _addDraft() {
    setState(() {
      _drafts.add(
        _EditableCardDraft(
          frontController: TextEditingController(),
          backController: TextEditingController(),
        ),
      );
    });
  }

  void _removeDraft(int index) {
    if (_drafts.length == 1) {
      // Keep one editable row on screen. Removing the final card would make the
      // empty OCR state harder to recover from.
      _drafts[index].frontController.clear();
      _drafts[index].backController.clear();
      return;
    }

    setState(() {
      final removed = _drafts.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      // Read the latest controller values at save time so every user edit is
      // captured. The controller will trim and ignore fully blank drafts.
      final cards = _drafts
          .map(
            (draft) => ParsedFlashcard(
              term: draft.frontController.text,
              answer: draft.backController.text,
            ),
          )
          .toList();

      final result = await widget.controller.saveOcrCards(
        fileName: widget.preview.fileName,
        rawText: widget.preview.rawText,
        cards: cards,
      );

      if (!mounted) return;
      Navigator.pop<ImportResult>(context, result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _error = 'Save failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Empty OCR is allowed into preview because the user may still want to type
    // cards manually from the cropped image.
    final hasExtractedText = widget.preview.rawText.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.setupBackground,
      appBar: AppBar(
        backgroundColor: AppColors.setupBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.purpleBright,
          ),
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Review OCR Cards',
          style: TextStyle(color: AppColors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  _RawTextPanel(rawText: widget.preview.rawText),
                  const SizedBox(height: 16),
                  if (!hasExtractedText) const _EmptyOcrState(),
                  if (_error != null) ...[
                    _ErrorBanner(message: _error!),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Draft flashcards',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Add card',
                        onPressed: _isSaving ? null : _addDraft,
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.purpleBright,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (int index = 0; index < _drafts.length; index++) ...[
                    _DraftCardEditor(
                      draft: _drafts[index],
                      index: index,
                      onRemove: _isSaving ? null : () => _removeDraft(index),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purpleBright,
                  disabledBackgroundColor: AppColors.grayDark,
                  minimumSize: const Size(double.infinity, 54),
                ),
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.check, color: AppColors.white),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save Approved Cards',
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RawTextPanel extends StatelessWidget {
  final String rawText;

  const _RawTextPanel({required this.rawText});

  @override
  Widget build(BuildContext context) {
    // Showing raw OCR text makes it easy to spot whether bad drafts came from
    // recognition quality or from the flashcard splitter.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.setupCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.document_scanner_outlined,
                color: AppColors.purpleBright,
              ),
              SizedBox(width: 8),
              Text(
                'Extracted text',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rawText.trim().isEmpty ? 'No text was detected.' : rawText,
            style: const TextStyle(
              color: AppColors.grayLight,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOcrState extends StatelessWidget {
  const _EmptyOcrState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x26FDCB6E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: const Text(
        'OCR did not find usable text. You can still create cards manually below.',
        style: TextStyle(color: AppColors.gold, height: 1.35),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x26FF6B6B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.redCoral.withValues(alpha: 0.5)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.redCoral, height: 1.35),
      ),
    );
  }
}

class _DraftCardEditor extends StatelessWidget {
  final _EditableCardDraft draft;
  final int index;
  final VoidCallback? onRemove;

  const _DraftCardEditor({
    required this.draft,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.setupCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Card ${index + 1}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remove card',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                color: AppColors.gray,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _OcrTextField(
            controller: draft.frontController,
            label: 'Front',
            minLines: 1,
          ),
          const SizedBox(height: 12),
          _OcrTextField(
            controller: draft.backController,
            label: 'Back',
            minLines: 2,
          ),
        ],
      ),
    );
  }
}

class _OcrTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int minLines;

  const _OcrTextField({
    required this.controller,
    required this.label,
    required this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: 5,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.gray),
        filled: true,
        fillColor: AppColors.setupInput,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.purpleBright),
        ),
      ),
    );
  }
}

class _EditableCardDraft {
  // Controllers live with each draft so add/remove operations do not lose edits
  // from the other cards.
  final TextEditingController frontController;
  final TextEditingController backController;

  const _EditableCardDraft({
    required this.frontController,
    required this.backController,
  });

  void dispose() {
    frontController.dispose();
    backController.dispose();
  }
}
