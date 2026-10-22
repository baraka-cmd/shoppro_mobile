// ============================================
// WIDGET : SellerProductStepImages
// ============================================
// Étape 2 du formulaire produit : Gestion des images.
//
// Contient :
//   - Grille d'images (existantes + nouvelles)
//   - Bouton "Ajouter des images" (galerie)
//   - Bouton "Prendre une photo" (caméra)
//   - Suppression d'image avec confirmation
//   - Compteur d'images (X / 10)
//   - Image principale marquée d'un badge
//   - Drag-and-drop pour réorganiser (si possible)
//
// Design :
//   - Grille 3 colonnes responsive
//   - Vignettes carrées avec coins arrondis
//   - Overlay sur chaque image (bouton supprimer)
//   - Badge "Principale" sur la première image
//   - Skeleton pendant le chargement
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Dart
import 'dart:io';

// Core
import '../../../../core/constants/app_colors.dart';

// Domain
import '../../domain/entities/seller_product.dart';

// Presentation
import '../pages/seller_product_form_state.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class SellerProductStepImages extends StatelessWidget {
  /// State du formulaire (source de vérité).
  final SellerProductFormState formState;

  /// Callback quand on ajoute des images.
  final VoidCallback? onPickImages;

  /// Callback quand on prend une photo.
  final VoidCallback? onPickCamera;

  /// Callback quand on supprime une image existante.
  final void Function(int index)? onRemoveExistingImage;

  /// Callback quand on supprime une nouvelle image.
  final void Function(int index)? onRemoveNewImage;

  const SellerProductStepImages({
    super.key,
    required this.formState,
    this.onPickImages,
    this.onPickCamera,
    this.onRemoveExistingImage,
    this.onRemoveNewImage,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // EN-TÊTE
          // ============================================
          _buildHeader(),

          const SizedBox(height: 20),

          // ============================================
          // BARRE D'INFORMATION
          // ============================================
          _buildInfoBanner(),

          const SizedBox(height: 20),

          // ============================================
          // GRILLE D'IMAGES
          // ============================================
          _buildImagesGrid(context),

          const SizedBox(height: 20),

          // ============================================
          // BOUTONS D'AJOUT
          // ============================================
          if (formState.canAddMoreImages) _buildAddButtons(context),

          const SizedBox(height: 20),

          // ============================================
          // CONSEILS
          // ============================================
          _buildTips(),
        ],
      ),
    );
  }

  // ============================================
  // EN-TÊTE
  // ============================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.photo_library_outlined,
            size: 20,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Photos du produit',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${formState.totalImagesCount} / ${SellerProductFormState.maxImages} image${formState.totalImagesCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // BARRE D'INFORMATION
  // ============================================

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.info,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'La première image sera utilisée comme image principale du produit. '
              'Format recommandé : carré, min 800x800px.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.info.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // GRILLE D'IMAGES
  // ============================================

  Widget _buildImagesGrid(BuildContext context) {
    final totalImages = formState.totalImagesCount;

    if (totalImages == 0) {
      return _buildEmptyState(context);
    }

    // Calcul du nombre de slots à afficher :
    // totalImages + 1 si on peut encore ajouter des images
    final itemCount = formState.canAddMoreImages
        ? totalImages + 1
        : totalImages;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Bouton "Ajouter" en dernier
        if (index == totalImages) {
          return _buildAddImageCard(context);
        }

        // Images existantes (serveur)
        if (index < formState.existingImages.length) {
          final image = formState.existingImages[index];
          return _buildImageThumbnail(
            imageUrl: image.url,
            isNetwork: true,
            isPrimary: index == 0,
            onDelete: () => _confirmDeleteExisting(context, index),
          );
        }

        // Nouvelles images (locales)
        final newIndex = index - formState.existingImages.length;
        final xFile = formState.newImages[newIndex];

        return _buildImageThumbnail(
          imageUrl: xFile.path,
          isNetwork: false,
          isPrimary: index == 0,
          onDelete: () => _confirmDeleteNew(context, newIndex),
        );
      },
    );
  }

  // ============================================
  // VIGNETTE IMAGE
  // ============================================

  Widget _buildImageThumbnail({
    required String imageUrl,
    required bool isNetwork,
    required bool isPrimary,
    required VoidCallback onDelete,
  }) {
    return Stack(
      children: [
        // Image
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary
                  ? AppColors.warning
                  : AppColors.borderColor.withValues(alpha: 0.5),
              width: isPrimary ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: isNetwork
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppColors.surfaceAlt,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => _buildImageError(),
                  )
                : Image.file(
                    File(imageUrl),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => _buildImageError(),
                  ),
          ),
        ),

        // Badge "Principale"
        if (isPrimary)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 9,
                    color: Colors.white,
                  ),
                  SizedBox(width: 2),
                  Text(
                    'Principale',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Bouton supprimer
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.surfaceAlt,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 24,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  // ============================================
  // CARTE "AJOUTER"
  // ============================================

  Widget _buildAddImageCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddOptions(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.4),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 20,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ajouter',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ÉTAT VIDE
  // ============================================

  Widget _buildEmptyState(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddOptions(context),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 32,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Ajoutez vos premières photos',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Jusqu\'à ${SellerProductFormState.maxImages} images',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // BOUTONS D'AJOUT
  // ============================================

  Widget _buildAddButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              if (onPickImages != null) {
                onPickImages!();
              }
            },
            icon: const Icon(
              Icons.photo_library_outlined,
              size: 18,
            ),
            label: const Text(
              'Galerie',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              side: BorderSide(
                color: AppColors.warning.withValues(alpha: 0.5),
                width: 1.2,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              if (onPickCamera != null) {
                onPickCamera!();
              }
            },
            icon: const Icon(
              Icons.camera_alt_outlined,
              size: 18,
            ),
            label: const Text(
              'Caméra',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              side: BorderSide(
                color: AppColors.warning.withValues(alpha: 0.5),
                width: 1.2,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // CONSEILS
  // ============================================

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: AppColors.warning,
              ),
              const SizedBox(width: 6),
              const Text(
                'Conseils pour de bonnes photos',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTip('Fond neutre et éclairé'),
          _buildTip('Image nette, sans flou'),
          _buildTip('Produit sous plusieurs angles'),
          _buildTip('Format carré, min 800x800px'),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // OPTIONS D'AJOUT (BottomSheet)
  // ============================================

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Ajouter des images',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Galerie
                _buildOptionTile(
                  icon: Icons.photo_library_outlined,
                  label: 'Choisir dans la galerie',
                  subtitle: 'Sélectionnez plusieurs photos',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onPickImages?.call();
                  },
                ),

                const SizedBox(height: 8),

                // Caméra
                _buildOptionTile(
                  icon: Icons.camera_alt_outlined,
                  label: 'Prendre une photo',
                  subtitle: 'Ouvrir la caméra',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onPickCamera?.call();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // CONFIRMATION DE SUPPRESSION
  // ============================================

  Future<void> _confirmDeleteExisting(
    BuildContext context,
    int index,
  ) async {
    final confirmed = await _showDeleteConfirmation(
      context,
      'Supprimer cette image ?',
      'L\'image sera retirée du produit lors de la prochaine sauvegarde.',
    );

    if (confirmed == true) {
      onRemoveExistingImage?.call(index);
    }
  }

  Future<void> _confirmDeleteNew(BuildContext context, int index) async {
    final confirmed = await _showDeleteConfirmation(
      context,
      'Supprimer cette image ?',
      'L\'image sera définitivement supprimée de votre sélection.',
    );

    if (confirmed == true) {
      onRemoveNewImage?.call(index);
    }
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Supprimer',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}