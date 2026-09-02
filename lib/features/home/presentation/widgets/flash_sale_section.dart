// ============================================
// WIDGET : FlashSaleSection
// ============================================
// Section Vente Flash avec :
// - Timer compte à rebours animé
// - Cartes produits avec badges de réduction
// - Design d'urgence (couleurs chaudes)
// - Scroll horizontal fluide
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/product.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class FlashSaleSection extends StatefulWidget {
  final List<Product> products;
  final DateTime endTime;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<Product>? onProductTap;
  final ValueChanged<Product>? onAddToCart;

  const FlashSaleSection({
    super.key,
    required this.products,
    required this.endTime,
    this.onSeeAllTap,
    this.onProductTap,
    this.onAddToCart,
  });

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

// ============================================
// STATE
// ============================================

class _FlashSaleSectionState extends State<FlashSaleSection> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ============================================
  // TIMER
  // ============================================

  void _calculateRemainingTime() {
    final now = DateTime.now();
    _remainingTime = widget.endTime.isAfter(now)
        ? widget.endTime.difference(now)
        : Duration.zero;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  // ============================================
  // FORMATAGE DU TEMPS
  // ============================================

  String _formatTime(int value) {
    return value.toString().padLeft(2, '0');
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const SizedBox.shrink();
    }

    final hours = _remainingTime.inHours;
    final minutes = _remainingTime.inMinutes % 60;
    final seconds = _remainingTime.inSeconds % 60;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.promoLight,
            AppColors.warningLight,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // EN-TÊTE DE LA SECTION
          // ============================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Titre
                const Icon(
                  Icons.bolt,
                  size: 22,
                  color: AppColors.promo,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Flash Sale',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),

                const Spacer(),

                // Timer
                _buildTimer(hours, minutes, seconds),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ============================================
          // LISTE DES PRODUITS (SCROLL HORIZONTAL)
          // ============================================
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                return _buildFlashProductCard(product);
              },
            ),
          ),

          const SizedBox(height: 8),

          // ============================================
          // BOUTON VOIR TOUT
          // ============================================
          Center(
            child: TextButton(
              onPressed: widget.onSeeAllTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.promo,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Voir toutes les offres',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // TIMER UI
  // ============================================

  Widget _buildTimer(int hours, int minutes, int seconds) {
    return Row(
      children: [
        _buildTimeBox(_formatTime(hours), 'H'),
        _buildTimeSeparator(),
        _buildTimeBox(_formatTime(minutes), 'MIN'),
        _buildTimeSeparator(),
        _buildTimeBox(_formatTime(seconds), 'SEC'),
      ],
    );
  }

  Widget _buildTimeBox(String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 7,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ':',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ============================================
  // CARTE PRODUIT FLASH SALE
  // ============================================

  Widget _buildFlashProductCard(Product product) {
    final discountPercentage = product.discountPercentage ?? 0;

    return GestureDetector(
      onTap: () => widget.onProductTap?.call(product),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // IMAGE + BADGE
            // ============================================
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    color: AppColors.surface,
                    child: product.mainImage != null
                        ? CachedNetworkImage(
                            imageUrl: product.mainImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.surface,
                              child: const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surface,
                              child: const Icon(
                                Icons.image_outlined,
                                size: 28,
                                color: AppColors.textLight,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.image_outlined,
                            size: 28,
                            color: AppColors.textLight,
                          ),
                  ),
                ),

                // Badge réduction
                if (discountPercentage > 0)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.promo,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-$discountPercentage%',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Bouton favori
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      // Toggle favori
                    },
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ============================================
            // DÉTAILS
            // ============================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        // Prix actuel
                        Text(
                          '${product.currentPrice.round()} FCFA',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Ancien prix barré
                        if (product.discountPrice != null)
                          Flexible(
                            child: Text(
                              '${product.price.round()}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textLight,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    // Progression stock
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.7,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.promo,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
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
}