// Section des produits récemment consultés
// Affiche l'historique des produits vus par l'utilisateur

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product.dart';
import 'product_card.dart';

class RecentlyViewedSection extends StatefulWidget {
  final ValueChanged<Product>? onProductTap;
  final VoidCallback? onClearAll;

  // ✅ Clé de stockage statique
  static const String _storageKey = 'recently_viewed_products';

  const RecentlyViewedSection({
    super.key,
    this.onProductTap,
    this.onClearAll,
  });

  // ✅ Méthode statique pour ajouter un produit
  static Future<void> addToRecentlyViewed(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_storageKey) ?? [];

    final productJson = jsonEncode({
      'id': product.id,
      'name': product.name,
      'slug': product.slug,
      'price': product.price,
      'current_price': product.currentPrice,
      'stock': product.stock,
      'is_in_stock': product.isInStock,
      'stock_status': product.stockStatus,
      'sku': product.sku,
      'main_image': product.mainImage,
    });

    // Supprimer si déjà présent
    data.removeWhere((item) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return map['id'] == product.id;
      } catch (e) {
        return false;
      }
    });

    // Ajouter au début
    data.insert(0, productJson);

    // Limiter à 10
    if (data.length > 10) {
      data.removeRange(10, data.length);
    }

    await prefs.setStringList(_storageKey, data);
  }

  @override
  State<RecentlyViewedSection> createState() => _RecentlyViewedSectionState();
}

class _RecentlyViewedSectionState extends State<RecentlyViewedSection> {
  List<Product> _recentProducts = [];

  @override
  void initState() {
    super.initState();
    _loadRecentProducts();
  }

  // Charger les produits récents
  Future<void> _loadRecentProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(RecentlyViewedSection._storageKey) ?? [];

    setState(() {
      _recentProducts = data
          .map((json) {
            try {
              final map = jsonDecode(json) as Map<String, dynamic>;
              return Product(
                id: map['id'] as int? ?? 0,
                name: map['name'] as String? ?? '',
                slug: map['slug'] as String? ?? '',
                price: (map['price'] as num?)?.toDouble() ?? 0,
                currentPrice: (map['current_price'] as num?)?.toDouble() ?? 0,
                stock: map['stock'] as int? ?? 0,
                isInStock: map['is_in_stock'] as bool? ?? false,
                stockStatus: map['stock_status'] as String? ?? 'out_of_stock',
                sku: map['sku'] as String? ?? '',
                mainImage: map['main_image'] as String?,
              );
            } catch (e) {
              return null;
            }
          })
          .whereType<Product>()
          .take(10)
          .toList();
    });
  }

  // Effacer tous les récents
  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(RecentlyViewedSection._storageKey);

    setState(() {
      _recentProducts = [];
    });

    widget.onClearAll?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_recentProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre + Effacer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'RÉCEMMENT CONSULTÉS',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _clearAll,
                child: const Text(
                  'Effacer',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Liste horizontale
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _recentProducts.length,
            itemBuilder: (context, index) {
              final product = _recentProducts[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 150,
                  child: ProductCard(
                    product: product,
                    onTap: widget.onProductTap,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}