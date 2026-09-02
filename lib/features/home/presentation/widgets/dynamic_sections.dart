// ============================================
// WIDGET : DynamicSections
// ============================================
// Gestion des sections dynamiques de l'accueil.
// Assemble les différentes sections selon la configuration.
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/category.dart';
import 'flash_sale_section.dart';
import 'best_sellers_section.dart';
import 'recommended_section.dart';
import 'blog_section.dart';
import 'ad_banner.dart';
import 'dynamic_section_item.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class DynamicSections extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  final List<Product> flashSaleProducts;
  final DateTime? flashSaleEndTime;
  final List<Product> bestSellers;
  final List<Product> recommendedProducts;
  final List<Map<String, dynamic>> blogArticles;
  final List<Category> categories;

  // Callbacks
  final VoidCallback? onFlashSaleSeeAll;
  final VoidCallback? onBestSellersSeeAll;
  final VoidCallback? onRecommendedSeeAll;
  final VoidCallback? onBlogSeeAll;
  final ValueChanged<Product>? onProductTap;
  final ValueChanged<Product>? onToggleFavorite;
  final ValueChanged<Category>? onCategoryTap;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const DynamicSections({
    super.key,
    this.flashSaleProducts = const [],
    this.flashSaleEndTime,
    this.bestSellers = const [],
    this.recommendedProducts = const [],
    this.blogArticles = const [],
    this.categories = const [],
    this.onFlashSaleSeeAll,
    this.onBestSellersSeeAll,
    this.onRecommendedSeeAll,
    this.onBlogSeeAll,
    this.onProductTap,
    this.onToggleFavorite,
    this.onCategoryTap,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================
        // SECTION : BANNIÈRE PUBLICITAIRE
        // ============================================
        const AdBanner(
          title: 'Offres spéciales',
          subtitle: 'Jusqu\'à -40% sur une sélection',
          icon: Icons.local_offer,
          backgroundColor: AppColors.primary,
          buttonText: 'Découvrir',
        ),

        const SizedBox(height: 5),

        // ============================================
        // SECTION : FLASH SALE (si produits disponibles)
        // ============================================
        if (flashSaleProducts.isNotEmpty) ...[
          FlashSaleSection(
            products: flashSaleProducts.take(6).toList(),
            endTime: flashSaleEndTime ?? DateTime.now().add(const Duration(hours: 5)),
            onSeeAllTap: onFlashSaleSeeAll,
            onProductTap: onProductTap,
          ),
          const SizedBox(height: 5),
        ],

        // ============================================
        // SECTION : MEILLEURES VENTES
        // ============================================
        if (bestSellers.isNotEmpty) ...[
          BestSellersSection(
            products: bestSellers.take(6).toList(),
            onSeeAllTap: onBestSellersSeeAll,
            onProductTap: onProductTap,
            onToggleFavorite: onToggleFavorite,
          ),
          const SizedBox(height: 5),
        ],

        // ============================================
        // SECTION : RECOMMANDÉS
        // ============================================
        if (recommendedProducts.isNotEmpty) ...[
          RecommendedSection(
            products: recommendedProducts.take(4).toList(),
            contextMessage: 'Parce que vous avez consulté des produits similaires',
            onSeeAllTap: onRecommendedSeeAll,
            onProductTap: onProductTap,
            onToggleFavorite: onToggleFavorite,
          ),
          const SizedBox(height: 5),
        ],

        // ============================================
        // SECTION : BANNIÈRE SECONDAIRE
        // ============================================
        const AdBanner(
          title: 'Livraison gratuite',
          subtitle: 'Dès 50 000 FCFA d\'achat',
          icon: Icons.local_shipping,
          backgroundColor: AppColors.success,
          buttonText: 'En savoir plus',
        ),

        const SizedBox(height: 5),

        // ============================================
        // SECTION : BLOG
        // ============================================
        if (blogArticles.isNotEmpty) ...[
          BlogSection(
            articles: blogArticles.take(5).toList(),
            onSeeAllTap: onBlogSeeAll,
            onArticleTap: (article) {
              // Navigation vers l'article
            },
          ),
        ],
      ],
    );
  }
}