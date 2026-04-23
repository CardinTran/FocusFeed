import 'package:flutter/material.dart';
import 'package:focusfeed/core/theme/app_colors.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

enum OcrImageInput { camera, gallery }

class OcrImportDraft {
  /// Display name for the selected source image.
  final String imageName;

  /// OCR text after the crop step. This is intentionally raw because the
  /// preview screen lets users correct OCR mistakes before anything is saved.
  final String rawText;

  const OcrImportDraft({required this.imageName, required this.rawText});
}

class OcrImportService {
  final ImagePicker imagePicker;
  final ImageCropper imageCropper;
  final TextRecognizer textRecognizer;

  OcrImportService({ImagePicker? imagePicker, TextRecognizer? textRecognizer})
    : imagePicker = imagePicker ?? ImagePicker(),
      imageCropper = ImageCropper(),
      textRecognizer =
          textRecognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  Future<OcrImportDraft?> pickImageAndExtractText({
    required OcrImageInput input,
  }) async {
    // The OCR pipeline is shared for camera and library images. The only thing
    // that changes is where the original image comes from.
    final image = await imagePicker.pickImage(
      source: input == OcrImageInput.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 100,
    );

    if (image == null) return null;

    // Cropping before OCR lets the user remove headers, diagrams, margins, or
    // unrelated notes that would otherwise pollute the draft flashcards.
    final croppedImage = await imageCropper.cropImage(
      sourcePath: image.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop for OCR',
          toolbarColor: AppColors.setupBackground,
          toolbarWidgetColor: Colors.white,
          backgroundColor: AppColors.setupBackground,
          activeControlsWidgetColor: AppColors.purpleBright,
          cropFrameColor: AppColors.purpleBright,
          cropGridColor: Colors.white70,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Crop for OCR',
          doneButtonTitle: 'Use',
          cancelButtonTitle: 'Cancel',
          aspectRatioLockEnabled: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );

    if (croppedImage == null) return null;

    // ML Kit reads the cropped file only. The original image is left untouched.
    final inputImage = InputImage.fromFilePath(croppedImage.path);
    final recognizedText = await textRecognizer.processImage(inputImage);

    return OcrImportDraft(
      imageName: image.name.isEmpty ? _defaultImageName(input) : image.name,
      rawText: _readTextByVisualLine(recognizedText),
    );
  }

  Future<void> dispose() => textRecognizer.close();

  String _readTextByVisualLine(RecognizedText recognizedText) {
    // `recognizedText.text` can flatten multi-line layouts in surprising ways.
    // Sorting ML Kit's detected lines by bounding boxes gives the parser a more
    // predictable top-to-bottom, left-to-right input.
    final lines = recognizedText.blocks
        .expand((block) => block.lines)
        .where((line) => line.text.trim().isNotEmpty)
        .toList();

    lines.sort((a, b) {
      final aBox = a.boundingBox;
      final bBox = b.boundingBox;

      final verticalDelta = aBox.top.compareTo(bBox.top);
      if ((aBox.top - bBox.top).abs() > 8) return verticalDelta;

      return aBox.left.compareTo(bBox.left);
    });

    final text = lines.map((line) => line.text.trim()).join('\n').trim();

    // Fall back to ML Kit's raw text if line extraction is unexpectedly empty.
    return text.isEmpty ? recognizedText.text.trim() : text;
  }

  String _defaultImageName(OcrImageInput input) {
    return input == OcrImageInput.camera
        ? 'Camera OCR import'
        : 'Image OCR import';
  }
}
