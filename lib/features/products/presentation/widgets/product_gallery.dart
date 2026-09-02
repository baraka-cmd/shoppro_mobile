// ============================================
// GALERIE D'IMAGES PRODUIT - VERSION PREMIUM
// ============================================
// PageView avec zoom, swipe, thumbnails animés,
// effet de flottement prononcé et fond Cream.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

class ProductGallery extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final bool showThumbnails;
  final bool showDots;
  final bool showCounter;
  final bool enableZoom;
  final bool enableFloatingAnimation;
  final bool autoPlay;
  final Duration autoPlayInterval;

  const ProductGallery({
    super.key,
    required this.imageUrls,
    this.height = 400,
    this.showThumbnails = true,
    this.showDots = true,
    this.showCounter = true,
    this.enableZoom = true,
    this.enableFloatingAnimation = true,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 5),
  });

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isAutoPlaying = false;

  // Animation de flottement
  AnimationController? _floatController;
  Animation<double>? _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Initialiser l'animation de flottement avec grande amplitude
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _floatAnimation = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(
        parent: _floatController!,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.enableFloatingAnimation && widget.imageUrls.isNotEmpty) {
      _floatController!.repeat(reverse: true);
    }

    if (widget.autoPlay && widget.imageUrls.length > 1) {
      _isAutoPlaying = true;
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _isAutoPlaying = false;
    _floatController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ============================================
  // AUTO-PLAY
  // ============================================

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval, () {
      if (!mounted || !_isAutoPlaying) return;

      if (_currentPage < widget.imageUrls.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      _startAutoPlay();
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // ============================================
        // GALERIE PRINCIPALE AVEC FOND CREAM
        // ============================================
        Container(
          height: widget.height,
          decoration: const BoxDecoration(
            color: AppColors.cream,
          ),
          child: Stack(
            children: [
              // PageView d'images avec animation de flottement prononcée
              AnimatedBuilder(
                animation: _floatAnimation!,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation!.value),
                    child: child,
                  );
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildImage(widget.imageUrls[index]);
                  },
                ),
              ),

              // Boutons navigation
              if (widget.imageUrls.length > 1) ...[
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildNavButton(
                      icon: Icons.chevron_left,
                      onTap: _currentPage > 0 ? _goToPrevious : null,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildNavButton(
                      icon: Icons.chevron_right,
                      onTap: _currentPage < widget.imageUrls.length - 1
                          ? _goToNext
                          : null,
                    ),
                  ),
                ),
              ],

              // Compteur
              if (widget.showCounter && widget.imageUrls.length > 1)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${_currentPage + 1} / ${widget.imageUrls.length}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // Dots indicateurs
              if (widget.showDots && widget.imageUrls.length > 1)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.imageUrls.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: index == _currentPage ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ============================================
        // THUMBNAILS
        // ============================================
        if (widget.showThumbnails && widget.imageUrls.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 65,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                final isSelected = _currentPage == index;
                return GestureDetector(
                  onTap: () => _goToPage(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderColor,
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.imageUrls[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.surface,
                              child: const Center(
                                child: SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surface,
                              child: const Icon(
                                Icons.image_outlined,
                                size: 20,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // ============================================
  // IMAGE AVEC ZOOM
  // ============================================

  Widget _buildImage(String imageUrl) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => Container(
        color: AppColors.cream,
        child: const Center(
          child: SizedBox(
            width: 35,
            height: 35,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.cream,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: 45,
                color: AppColors.textLight,
              ),
              SizedBox(height: 8),
              Text(
                'Image indisponible',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.enableZoom) {
      return GestureDetector(
        onTap: () => _showZoomDialog(imageUrl),
        child: image,
      );
    }

    return image;
  }

  // ============================================
  // DIALOG DE ZOOM
  // ============================================

  void _showZoomDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
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
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
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

  // ============================================
  // BOUTON NAVIGATION
  // ============================================

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: onTap != null
              ? Colors.white
              : Colors.white.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null ? AppColors.textPrimary : AppColors.textLight,
        ),
      ),
    );
  }

  // ============================================
  // ÉTAT VIDE
  // ============================================

  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      color: AppColors.surface,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 50,
              color: AppColors.textLight,
            ),
            SizedBox(height: 10),
            Text(
              'Aucune image disponible',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // NAVIGATION
  // ============================================

  void _goToPrevious() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _goToNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}