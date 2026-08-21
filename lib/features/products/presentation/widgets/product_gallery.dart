// Galerie d'images produit
// PageView avec zoom, swipe, thumbnails et indicateurs

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
  final bool autoPlay;
  final Duration autoPlayInterval;

  const ProductGallery({
    super.key,
    required this.imageUrls,
    this.height = 320,
    this.showThumbnails = true,
    this.showDots = true,
    this.showCounter = true,
    this.enableZoom = true,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 5),
  });

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay && widget.imageUrls.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Auto-play
  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval, () {
      if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Galerie principale
        SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              // PageView d'images
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
            ],
          ),
        ),

        // Thumbnails
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
                  child: Container(
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
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.background,
                          child: const Center(
                            child: SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.background,
                          child: const Icon(
                            Icons.image,
                            size: 20,
                            color: AppColors.textLight,
                          ),
                        ),
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

  // Construire une image avec zoom
  Widget _buildImage(String imageUrl) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.background,
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

  // Dialog de zoom
  void _showZoomDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(dialogContext).pop(),
            child: InteractiveViewer(
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

  // Bouton navigation
  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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

  // État vide
  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      color: AppColors.background,
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

  void _goToPrevious() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goToNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}