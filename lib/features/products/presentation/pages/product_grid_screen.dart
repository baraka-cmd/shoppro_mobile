// Écran de grille des produits
// Écran de liste des produits
// Avec pagination infinie, filtres et tri

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product.dart';           // ✅ AJOUTER
import '../providers/product_provider.dart';
import '../widgets/product_list_item.dart';
import '../widgets/product_grid_item.dart';            // ✅ AJOUTER
import '../widgets/shimmer_product_card.dart';

class ProductGridScreen extends StatefulWidget {
  final String title;
  final List<Product> products;
  final bool isLoading;
  final bool hasMore;
  final bool isError;
  final String? errorMessage;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRefresh;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSortTap;
  final int crossAxisCount;

  const ProductGridScreen({
    super.key,
    required this.title,
    required this.products,
    this.isLoading = false,
    this.hasMore = false,
    this.isError = false,
    this.errorMessage,
    this.onLoadMore,
    this.onRefresh,
    this.onFilterTap,
    this.onSortTap,
    this.crossAxisCount = 2,
  });

  @override
  State<ProductGridScreen> createState() => _ProductGridScreenState();
}

class _ProductGridScreenState extends State<ProductGridScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Détecter le scroll
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Filtres
          if (widget.onFilterTap != null)
            IconButton(
              onPressed: widget.onFilterTap,
              icon: const Icon(
                Icons.filter_list,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          // Tri
          if (widget.onSortTap != null)
            IconButton(
              onPressed: widget.onSortTap,
              icon: const Icon(
                Icons.sort,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // Construire le corps
  Widget _buildBody() {
    // Chargement initial
    if (widget.isLoading && widget.products.isEmpty) {
      return const ShimmerProductGrid(itemCount: 8);
    }

    // Erreur
    if (widget.isError && widget.products.isEmpty) {
      return _buildErrorState();
    }

    // Vide
    if (widget.products.isEmpty) {
      return _buildEmptyState();
    }

    // Grille de produits
    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh?.call(),
      color: AppColors.primary,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(15),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: widget.crossAxisCount == 1 ? 1.8 : 0.65,
        ),
        itemCount: widget.products.length + (widget.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loader de pagination
          if (index == widget.products.length) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          final product = widget.products[index];
          return ProductGridItem(
            product: product,
            onTap: (tappedProduct) {
              Navigator.of(context).pushNamed(
                '/product/detail',
                arguments: {'product_id': tappedProduct.id},
              );
            },
          );
        },
      ),
    );
  }

  // État d'erreur
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 35,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.errorMessage ?? 'Une erreur est survenue',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'RÉESSAYER',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // État vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 35,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Aucun produit',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          if (widget.onRefresh != null)
            TextButton(
              onPressed: widget.onRefresh,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
              child: const Text(
                'Rafraîchir',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}