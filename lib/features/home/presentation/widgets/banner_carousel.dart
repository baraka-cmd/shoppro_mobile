// Carousel de bannières promotionnelles
// Avec auto-play, indicateurs et navigation

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerItem> banners;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool showIndicators;
  final bool showDots;
  final bool showCounter;
  final bool enableZoom;
  final BannerIndicatorStyle indicatorStyle;

  const BannerCarousel({
    super.key,
    required this.banners,
    this.height = 180,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.showIndicators = true,
    this.showDots = true,
    this.showCounter = true,
    this.enableZoom = false,
    this.indicatorStyle = BannerIndicatorStyle.dots,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay && widget.banners.length > 1) {
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

      if (_currentPage < widget.banners.length - 1) {
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
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Bannières
          PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildBanner(widget.banners[index]);
            },
          ),

          // Boutons navigation
          if (widget.banners.length > 1) ...[
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
                  onTap: _currentPage < widget.banners.length - 1
                      ? _goToNext
                      : null,
                ),
              ),
            ),
          ],

          // Indicateurs
          if (widget.showIndicators && widget.banners.length > 1)
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: _buildIndicators(),
            ),

          // Compteur
          if (widget.showCounter && widget.banners.length > 1)
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
                  '${_currentPage + 1} / ${widget.banners.length}',
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
    );
  }

  // Construire une bannière
  Widget _buildBanner(BannerItem banner) {
    Widget content = GestureDetector(
      onTap: banner.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              if (banner.imageUrl != null && banner.imageUrl!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: banner.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.background,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: banner.backgroundColor ?? AppColors.background,
                    child: const Icon(
                      Icons.image,
                      size: 40,
                      color: AppColors.textLight,
                    ),
                  ),
                )
              else
                Container(
                  color: banner.backgroundColor ?? AppColors.primary,
                ),

              // Overlay dégradé
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Texte
              if (banner.title != null || banner.subtitle != null)
                Positioned(
                  left: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (banner.title != null)
                        Text(
                          banner.title!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      if (banner.subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          banner.subtitle!,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return content;
  }

  // Construire les indicateurs
  Widget _buildIndicators() {
    switch (widget.indicatorStyle) {
      case BannerIndicatorStyle.dots:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
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
        );

      case BannerIndicatorStyle.bars:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: index == _currentPage ? 25 : 10,
              height: 4,
              decoration: BoxDecoration(
                color: index == _currentPage
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
    }
  }

  // Bouton de navigation
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
}

// Item de bannière
class BannerItem {
  final String? imageUrl;
  final String? title;
  final String? subtitle;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const BannerItem({
    this.imageUrl,
    this.title,
    this.subtitle,
    this.backgroundColor,
    this.onTap,
  });
}

// Style d'indicateur
enum BannerIndicatorStyle {
  dots,   // Points ronds
  bars,   // Barres
}