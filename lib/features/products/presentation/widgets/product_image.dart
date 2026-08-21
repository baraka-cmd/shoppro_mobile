// Widget d'image produit
// Gère le chargement, le placeholder, l'erreur et le zoom

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

    if (showZoomOnTap) {
      return GestureDetector(
        onTap: () => _showZoomDialog(context),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  // Construire l'image selon l'URL
  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    // Si l'image est locale (fichier)
    if (imageUrl!.startsWith('file://') || imageUrl!.startsWith('/')) {
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
      placeholder: (context, url) => placeholder ?? _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildErrorPlaceholder(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 200),
      placeholderFadeInDuration: const Duration(milliseconds: 200),
    );
  }

  // Placeholder de chargement
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  // Placeholder par défaut (pas d'image)
  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.background,
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

  // Placeholder d'erreur
  Widget _buildErrorPlaceholder() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 40,
              color: AppColors.textLight,
            ),
            SizedBox(height: 5),
            Text(
              'Image indisponible',
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

  // Afficher le zoom
  void _showZoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(dialogContext).pop(),
            child: InteractiveViewer(
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
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image,
                    size: 80,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}