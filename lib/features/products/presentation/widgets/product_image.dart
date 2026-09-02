// ============================================
// WIDGET D'IMAGE PRODUIT - VERSION PREMIUM
// ============================================
// Gère le chargement, le placeholder, l'erreur
// et le zoom. Support des images locales et réseau.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool showZoomOnTap;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableFadeIn;
  final bool showLoadingIndicator;
  final bool showErrorText;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius = 0,
    this.showZoomOnTap = false,
    this.placeholder,
    this.errorWidget,
    this.enableFadeIn = true,
    this.showLoadingIndicator = true,
    this.showErrorText = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildImage();

    if (borderRadius > 0) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }

    if (width != null || height != null) {
      imageWidget = SizedBox(
        width: width,
        height: height,
        child: imageWidget,
      );
    }

    if (showZoomOnTap && imageUrl != null && imageUrl!.isNotEmpty) {
      return GestureDetector(
        onTap: () => _showZoomDialog(context),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  // ============================================
  // CONSTRUIRE L'IMAGE SELON L'URL
  // ============================================

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorWidget ?? _buildPlaceholder();
    }

    // Si l'image est locale (fichier asset)
    if (imageUrl!.startsWith('assets/')) {
      return Image.asset(
        imageUrl!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildErrorPlaceholder(),
      );
    }

    // Image réseau avec cache
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ?? _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildErrorPlaceholder(),
      fadeInDuration: enableFadeIn
          ? const Duration(milliseconds: 300)
          : Duration.zero,
      fadeOutDuration: const Duration(milliseconds: 200),
      placeholderFadeInDuration: const Duration(milliseconds: 200),
    );
  }

  // ============================================
  // PLACEHOLDERS
  // ============================================

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: showLoadingIndicator
            ? SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 40,
              color: AppColors.textLight,
            ),
            SizedBox(height: 5),
            Text(
              'Pas d\'image',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.broken_image_outlined,
              size: 40,
              color: AppColors.textLight,
            ),
            if (showErrorText) ...[
              const SizedBox(height: 5),
              const Text(
                'Image indisponible',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================
  // ZOOM PLEIN ÉCRAN
  // ============================================

  void _showZoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image_outlined,
                      size: 80,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
              // Bouton fermer
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
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
}