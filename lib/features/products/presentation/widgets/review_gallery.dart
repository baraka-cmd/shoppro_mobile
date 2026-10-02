// ============================================
// REVIEW GALLERY - SHOPPRO
// ============================================
// Galerie de photos attachées à un avis.
// - Affichage en miniatures horizontales
// - Aperçu plein écran avec swipe entre images
// - Compteur "3/5" en superposition
// - Support URL réseau et fichiers locaux
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

class ReviewGallery extends StatelessWidget {
  /// Liste des URLs (réseau) ou chemins locaux
  final List<String> images;

  /// Taille des miniatures (par défaut 80)
  final double thumbnailSize;

  /// Nom d'utilisateur (pour l'en-tête du viewer)
  final String? userName;

  /// Titre de l'avis (pour l'en-tête du viewer)
  final String? reviewTitle;

  const ReviewGallery({
    super.key,
    required this.images,
    this.thumbnailSize = 80,
    this.userName,
    this.reviewTitle,
  });

  // ============================================
  // DÉTECTION URL vs FICHIER LOCAL
  // ============================================

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: thumbnailSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _buildThumbnail(context, index);
        },
      ),
    );
  }

  // ============================================
  // MINIATURE
  // ============================================

  Widget _buildThumbnail(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _openFullScreen(context, index),
      child: Stack(
        children: [
          Container(
            width: thumbnailSize,
            height: thumbnailSize,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: _buildImage(index),
            ),
          ),

          // Compteur en overlay (seulement sur la dernière si > 3 images)
          if (index == images.length - 1 && images.length > 3)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    '+${images.length - 3}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================
  // IMAGE UNIVERSELLE (réseau ou local)
  // ============================================

  Widget _buildImage(int index) {
    final path = images[index];

    if (_isNetworkImage(path)) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: AppColors.surface,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: AppColors.surface,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textLight,
            size: 24,
          ),
        ),
      );
    }

    // Fichier local
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.surface,
        child: const Icon(
          Icons.broken_image_outlined,
          color: AppColors.textLight,
          size: 24,
        ),
      ),
    );
  }

  // ============================================
  // APERÇU PLEIN ÉCRAN (swipe entre images)
  // ============================================

  void _openFullScreen(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenViewer(
            images: images,
            initialIndex: initialIndex,
            isNetworkImage: _isNetworkImage,
            userName: userName,
            reviewTitle: reviewTitle,
          );
        },
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

// ============================================
// VIEWER PLEIN ÉCRAN INTERNE
// ============================================

class _FullScreenViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final bool Function(String) isNetworkImage;
  final String? userName;
  final String? reviewTitle;

  const _FullScreenViewer({
    required this.images,
    required this.initialIndex,
    required this.isNetworkImage,
    this.userName,
    this.reviewTitle,
  });

  @override
  State<_FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<_FullScreenViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // PageView des images
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: _buildFullImage(index),
                  ),
                );
              },
            ),

            // Bouton fermer
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

            // Compteur en haut au centre
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // En-tête utilisateur (bas de l'écran)
            if (widget.userName != null)
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userName!,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            if (widget.reviewTitle != null)
                              Text(
                                widget.reviewTitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // IMAGE PLEIN ÉCRAN
  // ============================================

  Widget _buildFullImage(int index) {
    final path = widget.images[index];

    if (widget.isNetworkImage(path)) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.contain,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        errorWidget: (_, __, ___) => const Icon(
          Icons.broken_image_outlined,
          color: Colors.white54,
          size: 60,
        ),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.broken_image_outlined,
        color: Colors.white54,
        size: 60,
      ),
    );
  }
}