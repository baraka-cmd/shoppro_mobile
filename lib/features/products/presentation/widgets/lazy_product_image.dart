// ============================================
// WIDGET D'IMAGE PRODUIT AVEC LAZY LOADING
// ============================================
// Charge l'image seulement quand elle est visible.
// Optimisé pour les connexions lentes (Goma/RDC).
// Fade in élégant, cache mémoire intelligent.
// ============================================

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
  final bool showLoadingIndicator;
  final bool showErrorText;

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
    this.showLoadingIndicator = true,
    this.showErrorText = true,
  });

  @override
  State<LazyProductImage> createState() => _LazyProductImageState();
}

class _LazyProductImageState extends State<LazyProductImage> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Délai pour le lazy loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (!_isVisible) {
      imageWidget = widget.placeholder ?? _buildLoadingPlaceholder();
    } else if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      imageWidget = widget.errorWidget ?? _buildDefaultPlaceholder();
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
        maxWidthDiskCache: _getCacheWidth(),
        maxHeightDiskCache: _getCacheHeight(),
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

  // ============================================
  // OPTIMISATION CACHE
  // ============================================

  int? _getCacheWidth() {
    if (!widget.enableCache) return null;
    if (widget.width != null) {
      return (widget.width! * 2).round();
    }
    return null;
  }

  int? _getCacheHeight() {
    if (!widget.enableCache) return null;
    if (widget.height != null) {
      return (widget.height! * 2).round();
    }
    return null;
  }

  // ============================================
  // PLACEHOLDERS
  // ============================================

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: widget.showLoadingIndicator
            ? SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      color: AppColors.surface,
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

  Widget _buildErrorPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 35,
              color: AppColors.textLight,
            ),
            if (widget.showErrorText) ...[
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
}