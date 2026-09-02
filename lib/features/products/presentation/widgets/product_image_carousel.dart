// ============================================
// CAROUSEL D'IMAGES PRODUIT - VERSION PREMIUM
// ============================================
// Galerie avec indicateurs animés, navigation,
// zoom plein écran et thumbnails synchronisés.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

class ProductImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final bool showIndicators;
  final bool showThumbnails;
  final bool showCounter;
  final bool enableZoom;
  final bool autoPlay;
  final Duration autoPlayInterval;

  const ProductImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 300,
    this.showIndicators = true,
    this.showThumbnails = false,
    this.showCounter = true,
    this.enableZoom = true,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 5),
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay && widget.imageUrls.length > 1) {
      _isAutoPlaying = true;
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _isAutoPlaying = false;
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
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 400),
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
        // CAROUSEL PRINCIPAL
        // ============================================
        SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              // Images
              PageView.builder(
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

              // Indicateur de page (dots)
              if (widget.showIndicators && widget.imageUrls.length > 1)
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
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

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
            ],
          ),
        ),

        // ============================================
        // THUMBNAILS
        // ============================================
        if (widget.showThumbnails && widget.imageUrls.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
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
                    width: 55,
                    height: 55,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
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
                                color: AppColors.primary.withValues(alpha: 0.1),
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
  // IMAGE
  // ============================================

  Widget _buildImage(String imageUrl) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.surface,
        child: const Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.surface,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
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
        width: 32,
        height: 32,
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
          size: 18,
          color: onTap != null ? AppColors.textPrimary : AppColors.textLight,
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

  // ============================================
  // ZOOM PLEIN ÉCRAN
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