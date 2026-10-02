// ============================================
// BOTTOM SHEET POUR AJOUTER UN AVIS - PREMIUM
// ============================================
// Avec étoiles interactives, commentaire,
// upload photos multiples (avec compression),
// prévisualisation plein écran et validation.
// Design conforme à la vision ShopPro.
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_colors.dart';

class AddReviewSheet extends StatefulWidget {
  final VoidCallback? onSubmit;
  final ValueChanged<ReviewData>? onReviewSubmitted;

  const AddReviewSheet({
    super.key,
    this.onSubmit,
    this.onReviewSubmitted,
  });

  @override
  State<AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<AddReviewSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  double _rating = 0;
  double _qualityRating = 0;
  double _priceRating = 0;
  double _shippingRating = 0;

  /// Liste des images sélectionnées (chemins locaux compressés)
  List<String> _selectedImages = [];

  /// Suivi de la compression en cours
  bool _isCompressing = false;

  /// Soumission en cours
  bool _isSubmitting = false;

  /// Nombre maximum de photos
  static const int _maxImages = 5;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // ============================================
  // SÉLECTION D'IMAGES (avec compression)
  // ============================================

  Future<void> _pickImages() async {
    if (_selectedImages.length >= _maxImages) return;

    try {
      final images = await _picker.pickMultiImage(
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );

      if (images.isEmpty) return;

      setState(() => _isCompressing = true);

      final compressedPaths = <String>[];

      for (final img in images) {
        if (_selectedImages.length + compressedPaths.length >= _maxImages) {
          break;
        }

        final compressed = await _compressImage(File(img.path));
        if (compressed != null) {
          compressedPaths.add(compressed.path);
        }
      }

      if (mounted) {
        setState(() {
          _selectedImages.addAll(compressedPaths);
          _isCompressing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCompressing = false);
        _showSnack('Erreur lors de la sélection: $e');
      }
    }
  }

  /// Compresse une image à ~1 Mo max
  /// Compresse une image (version SANS flutter_image_compress)
/// Retourne simplement le fichier original en attendant la vraie compression
Future<File?> _compressImage(File file) async {
  try {
    // Vérifier que le fichier existe
    if (!await file.exists()) {
      debugPrint('⚠️ Fichier introuvable: ${file.path}');
      return null;
    }

    // Pas de compression pour l'instant — on retourne le fichier tel quel
    return file;
  } catch (e) {
    debugPrint('❌ Erreur _compressImage: $e');
    return file;
  }
}

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// Aperçu plein écran d'une image
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
                    File(_selectedImages[index]),
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
            ],
          ),
        );
      },
    );
  }

  // ============================================
  // SOUMISSION
  // ============================================

  bool get _canSubmit =>
      _rating > 0 &&
      _commentController.text.trim().isNotEmpty &&
      !_isSubmitting &&
      !_isCompressing;

  void _handleSubmit() {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      Navigator.of(context).pop();
      widget.onReviewSubmitted?.call(
        ReviewData(
          rating: _rating,
          comment: _commentController.text.trim(),
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          qualityRating: _qualityRating,
          priceRating: _priceRating,
          shippingRating: _shippingRating,
          images: List.from(_selectedImages),
        ),
      );
    });
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicateur
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Titre
              const Center(
                child: Text(
                  'Écrire un avis',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ============================================
              // NOTE GÉNÉRALE
              // ============================================
              _buildRatingSection(
                label: 'Note générale',
                rating: _rating,
                onRatingChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),

              const SizedBox(height: 15),

              // ============================================
              // NOTES SPÉCIFIQUES
              // ============================================
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildRatingSection(
                      label: 'Qualité',
                      rating: _qualityRating,
                      onRatingChanged: (value) {
                        setState(() {
                          _qualityRating = value;
                        });
                      },
                      compact: true,
                    ),
                    const SizedBox(height: 8),
                    _buildRatingSection(
                      label: 'Prix',
                      rating: _priceRating,
                      onRatingChanged: (value) {
                        setState(() {
                          _priceRating = value;
                        });
                      },
                      compact: true,
                    ),
                    const SizedBox(height: 8),
                    _buildRatingSection(
                      label: 'Livraison',
                      rating: _shippingRating,
                      onRatingChanged: (value) {
                        setState(() {
                          _shippingRating = value;
                        });
                      },
                      compact: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ============================================
              // TITRE DE L'AVIS
              // ============================================
              TextField(
                controller: _titleController,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: 'Titre de votre avis (optionnel)',
                  hintStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  counterText: '',
                ),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 10),

              // ============================================
              // COMMENTAIRE
              // ============================================
              TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Partagez votre expérience avec ce produit...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 10),

              // ============================================
              // SECTION PHOTOS
              // ============================================
              Row(
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Photos (${_selectedImages.length}/$_maxImages)',
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

              // ============================================
              // GRILLE PHOTOS + BOUTON AJOUTER
              // ============================================
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Aperçus
                  ...List.generate(_selectedImages.length, (index) {
                    return GestureDetector(
                      onTap: () => _previewImage(index),
                      child: Stack(
                        children: [
                          Container(
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.borderColor,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.file(
                                File(_selectedImages[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
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
                  }),

                  // Bouton ajouter
                  if (_selectedImages.length < _maxImages)
                    GestureDetector(
                      onTap: _isCompressing ? null : _pickImages,
                      child: Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 22,
                              color: AppColors.primary,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Ajouter',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // ============================================
              // BOUTON SOUMETTRE
              // ============================================
              ElevatedButton(
                onPressed: _canSubmit ? _handleSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: AppColors.borderColor,
                  disabledForegroundColor: AppColors.textTertiary,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'SOUMETTRE L\'AVIS',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // SECTION DE NOTATION
  // ============================================

  Widget _buildRatingSection({
    required String label,
    required double rating,
    required ValueChanged<double> onRatingChanged,
    bool compact = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            final star = index + 1;
            return GestureDetector(
              onTap: () => onRatingChanged(star.toDouble()),
              child: Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Icon(
                  rating >= star ? Icons.star : Icons.star_border,
                  size: compact ? 20 : 28,
                  color: rating >= star
                      ? AppColors.ratingColor
                      : AppColors.textLight,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ============================================
// DONNÉES DE L'AVIS
// ============================================

class ReviewData {
  final double rating;
  final String comment;
  final String? title;
  final double qualityRating;
  final double priceRating;
  final double shippingRating;
  final List<String> images;

  const ReviewData({
    required this.rating,
    required this.comment,
    this.title,
    this.qualityRating = 0,
    this.priceRating = 0,
    this.shippingRating = 0,
    this.images = const [],
  });
}

// ============================================
// FONCTION POUR AFFICHER LE SHEET
// ============================================

Future<ReviewData?> showAddReviewSheet(BuildContext context) {
  return showModalBottomSheet<ReviewData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return AddReviewSheet(
        onReviewSubmitted: (reviewData) {
          Navigator.of(sheetContext).pop(reviewData);
        },
      );
    },
  );
}