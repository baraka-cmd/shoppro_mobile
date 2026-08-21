// Bottom sheet pour ajouter un avis
// Avec étoiles interactives, commentaire et upload photo

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import 'dart:io';  // ✅ AJOUTER

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
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  double _rating = 0;
  double _qualityRating = 0;
  double _priceRating = 0;
  double _shippingRating = 0;
  List<String> _selectedImages = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Sélectionner des images
  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((img) => img.path).toList());
      });
    }
  }

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
        child: Padding(
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

              // Note générale
              _buildRatingSection(
                label: 'Note générale',
                rating: _rating,
                onRatingChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Note qualité
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

              // Note prix
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

              // Note livraison
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

              const SizedBox(height: 15),

              // Champ commentaire
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
                  fillColor: AppColors.background,
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

              // Photos sélectionnées
              if (_selectedImages.isNotEmpty) ...[
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
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
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                width: 18,
                                height: 18,
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

              // Bouton ajouter photo
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Ajouter des photos',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Bouton soumettre
              ElevatedButton(
                onPressed: _rating > 0 && _commentController.text.isNotEmpty
                    ? () {
                        Navigator.of(context).pop();
                        widget.onReviewSubmitted?.call(
                          ReviewData(
                            rating: _rating,
                            comment: _commentController.text,
                            images: _selectedImages,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
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

  // Section de notation
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

// Données de l'avis
class ReviewData {
  final double rating;
  final String comment;
  final List<String> images;

  const ReviewData({
    required this.rating,
    required this.comment,
    this.images = const [],
  });
}

// Fonction pour afficher le sheet
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