// Widget d'image produit avec lazy loading
// Charge l'image seulement quand elle est visible

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

class LazyProductImage extends StatefulWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableCache;
  final bool enableFadeIn;

  const LazyProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
    this.enableCache = true,
    this.enableFadeIn = true,
  });

  @override
  State<LazyProductImage> createState() => _LazyProductImageState();
}

class _LazyProductImageState extends State<LazyProductImage> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      imageWidget = widget.placeholder ?? _buildDefaultPlaceholder();
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        fit: widget.fit,
        placeholder: (context, url) =>
            widget.placeholder ?? _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) =>
            widget.errorWidget ?? _buildErrorPlaceholder(),
        fadeInDuration: widget.enableFadeIn
            ? const Duration(milliseconds: 300)
            : Duration.zero,
        fadeOutDuration: const Duration(milliseconds: 200),
        placeholderFadeInDuration: const Duration(milliseconds: 200),
        memCacheWidth: _getCacheWidth(),
        memCacheHeight: _getCacheHeight(),
      );
    }

    if (widget.borderRadius > 0) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: imageWidget,
      );
    }

    if (widget.width != null || widget.height != null) {
      imageWidget = SizedBox(
        width: widget.width,
        height: widget.height,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  // Largeur du cache mémoire (optimisation)
  int? _getCacheWidth() {
    if (widget.width != null) {
      return (widget.width! * 2).round();
    }
    return null;
  }

  // Hauteur du cache mémoire (optimisation)
  int? _getCacheHeight() {
    if (widget.height != null) {
      return (widget.height! * 2).round();
    }
    return null;
  }

  // Placeholder de chargement
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  // Placeholder par défaut
  Widget _buildDefaultPlaceholder() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 35,
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
              size: 35,
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
}