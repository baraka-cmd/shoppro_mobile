// ============================================
// BOTTOM SHEET POUR AJOUTER UN AVIS - PREMIUM
// ============================================
// Avec étoiles interactives, commentaire,
// upload photos multiples et validation.
// Design conforme à la vision ShopPro.
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  List<String> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // ============================================
  // SÉLECTION D'IMAGES
  // ============================================

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (images.isNotEmpty) {
      setState(() {
        // Limiter à 5 images maximum
        for (final img in images) {
          if (_selectedImages.length < 5) {
            _selectedImages.add(img.path);
          }
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // ============================================
  // SOUMISSION
  // ============================================

  bool get _canSubmit => _rating > 0 && _commentController.text.trim().isNotEmpty;

  void _handleSubmit() {
    if (!_canSubmit || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simuler un délai
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
          images: _selectedImages,
        ),
      );
    });
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
              // PHOTOS SÉLECTIONNÉES
              // ============================================
              if (_selectedImages.isNotEmpty) ...[
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            margin: const EdgeInsets.only(right: 8),
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
                            right: 10,
                            top: 0,
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
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // ============================================
              // BOUTON AJOUTER PHOTO
              // ============================================
              GestureDetector(
                onTap: _selectedImages.length < 5 ? _pickImages : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedImages.length < 5
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 14,
                        color: _selectedImages.length < 5
                            ? AppColors.primary
                            : AppColors.textLight,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _selectedImages.isEmpty
                            ? 'Ajouter des photos'
                            : 'Ajouter plus (${_selectedImages.length}/5)',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _selectedImages.length < 5
                              ? AppColors.primary
                              : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
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