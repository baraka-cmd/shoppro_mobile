// ============================================
// REVIEW IMAGE PICKER - SHOPPRO
// ============================================
// Widget réutilisable pour sélectionner
// jusqu'à 5 photos avec compression automatique,
// aperçu plein écran et badge "principale".
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_colors.dart';

class ReviewImagePicker extends StatefulWidget {
  /// Liste actuelle des chemins d'images
  final List<String> images;

  /// Callback quand la liste change
  final ValueChanged<List<String>> onImagesChanged;

  /// Nombre maximum d'images (par défaut 5)
  final int maxImages;

  /// Taille cible de compression en pixels (par défaut 1080)
  final int targetSize;

  /// Qualité de compression 0-100 (par défaut 75)
  final int quality;

  /// Affiche le label d'en-tête
  final bool showHeader;

  /// Label personnalisé
  final String? headerLabel;

  const ReviewImagePicker({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.maxImages = 5,
    this.targetSize = 1080,
    this.quality = 75,
    this.showHeader = true,
    this.headerLabel,
  });

  @override
  State<ReviewImagePicker> createState() => _ReviewImagePickerState();
}

class _ReviewImagePickerState extends State<ReviewImagePicker> {
  final ImagePicker _picker = ImagePicker();
  bool _isCompressing = false;

  // ============================================
  // SÉLECTION D'IMAGES
  // ============================================

  // ============================================
// SÉLECTION D'IMAGES
// ============================================

Future<void> _pickImages() async {
  if (widget.images.length >= widget.maxImages) return;

  try {
    final picked = await _picker.pickMultiImage(
      maxWidth: widget.targetSize * 1.5,
      maxHeight: widget.targetSize * 1.5,
      imageQuality: 90,
    );

    if (picked.isEmpty) return;

    setState(() => _isCompressing = true);

    final compressed = <String>[];

    for (final img in picked) {
      if (widget.images.length + compressed.length >= widget.maxImages) {
        break;
      }

      final result = await _compressImage(File(img.path));
      if (result != null) {
        compressed.add(result.path);
      }
    }

    if (!mounted) return;

    final updated = [...widget.images, ...compressed];
    widget.onImagesChanged(updated);

    setState(() => _isCompressing = false);
  } catch (e) {
    if (!mounted) return;
    setState(() => _isCompressing = false);
    _showSnack('Erreur: $e');
  }
}
  /// Compresse une image à la taille cible
  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/review_${DateTime.now().microsecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: widget.quality,
        minWidth: widget.targetSize,
        minHeight: widget.targetSize,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      debugPrint('❌ Erreur compression: $e');
      return file; // En cas d'échec, garder l'original
    }
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  void _removeImage(int index) {
    final updated = [...widget.images]..removeAt(index);
    widget.onImagesChanged(updated);
  }

  /// Définit une image comme principale (la déplace en 1ère position)
  void _setAsPrimary(int index) {
    if (index == 0) return;
    final updated = [...widget.images];
    final item = updated.removeAt(index);
    updated.insert(0, item);
    widget.onImagesChanged(updated);
  }

  // ============================================
  // APERÇU PLEIN ÉCRAN
  // ============================================

  void _previewImage(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(widget.images[index]),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              if (index != 0)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _setAsPrimary(index);
                      },
                      icon: const Icon(Icons.star, size: 16),
                      label: const Text(
                        'Définir comme principale',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        if (widget.showHeader) ...[
          Row(
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.headerLabel ??
                    'Photos (${widget.images.length}/${widget.maxImages})',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              if (_isCompressing) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Grille de photos + bouton ajouter
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...List.generate(widget.images.length, (index) {
              return _buildImageTile(index);
            }),
            if (widget.images.length < widget.maxImages)
              _buildAddButton(),
          ],
        ),
      ],
    );
  }

  // ============================================
  // TUILE IMAGE
  // ============================================

  Widget _buildImageTile(int index) {
    return GestureDetector(
      onTap: () => _previewImage(index),
      child: Stack(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.file(
                File(widget.images[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Bouton supprimer
          Positioned(
            right: 3,
            top: 3,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Badge "principale"
          if (index == 0)
            Positioned(
              left: 3,
              bottom: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Principale',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================
  // BOUTON AJOUTER
  // ============================================

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _isCompressing ? null : _pickImages,
      child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isCompressing
                  ? Icons.hourglass_top
                  : Icons.add_a_photo_outlined,
              size: 22,
              color: AppColors.primary,
            ),
            const SizedBox(height: 2),
            Text(
              _isCompressing ? 'Compression' : 'Ajouter',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}