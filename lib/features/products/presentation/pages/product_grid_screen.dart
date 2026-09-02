// ============================================
// ÉCRAN DE GRILLE DES PRODUITS
// ============================================
// Version refondue : utilise ProductProvider
// au lieu de recevoir tout en paramètres.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/product_provider.dart';
import '../widgets/product_grid_item.dart';
import '../widgets/shimmer_product_card.dart';

class ProductGridScreen extends StatefulWidget {
  final String title;
  final int? categoryId;
  final int? brandId;
  final String? searchQuery;

  const ProductGridScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.brandId,
    this.searchQuery,
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
    // Charger les produits après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Charger les données initiales selon les paramètres
  void _loadInitialData() {
    final productProvider = context.read<ProductProvider>();

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      productProvider.searchProducts(widget.searchQuery!);
    } else if (widget.categoryId != null || widget.brandId != null) {
      productProvider.filterProducts(
        categoryId: widget.categoryId,
        brandId: widget.brandId,
      );
    } else {
      productProvider.loadProducts();
    }
  }

  // Détecter le scroll pour la pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final productProvider = context.read<ProductProvider>();
      if (productProvider.hasMore && !productProvider.isLoadingMore) {
        productProvider.loadMoreProducts();
      }
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
          IconButton(
            onPressed: () => _showFilterSheet(context),
            icon: const Icon(
              Icons.filter_list,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () => _showSortSheet(context),
            icon: const Icon(
              Icons.sort,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  // Construire le corps selon l'état du provider
  Widget _buildBody(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    // Chargement initial
    if (productProvider.isLoading && productProvider.products.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const ShimmerProductCard();
        },
      );
    }

    // Erreur
    if (productProvider.hasError && productProvider.products.isEmpty) {
      return _buildErrorState(context);
    }

    // Vide
    if (productProvider.products.isEmpty) {
      return _buildEmptyState(context);
    }

    // Grille de produits
    return RefreshIndicator(
      onRefresh: () async {
        await productProvider.refreshProducts();
      },
      color: AppColors.primary,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: productProvider.products.length + (productProvider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loader de pagination
          if (index == productProvider.products.length) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          final product = productProvider.products[index];
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
  Widget _buildErrorState(BuildContext context) {
    final productProvider = context.read<ProductProvider>();
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
            productProvider.errorMessage ?? 'Une erreur est survenue',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => productProvider.loadProducts(),
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
  Widget _buildEmptyState(BuildContext context) {
    final productProvider = context.read<ProductProvider>();
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
          TextButton(
            onPressed: () => productProvider.loadProducts(),
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

  // Bottom sheet de tri
  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Trier par',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildSortOption(context, sheetContext, 'created_at', 'desc', 'Plus récents'),
              _buildSortOption(context, sheetContext, 'price', 'asc', 'Prix croissant'),
              _buildSortOption(context, sheetContext, 'price', 'desc', 'Prix décroissant'),
              _buildSortOption(context, sheetContext, 'rating', 'desc', 'Meilleures notes'),
              _buildSortOption(context, sheetContext, 'sales_count', 'desc', 'Plus populaires'),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    BuildContext sheetContext,
    String sortBy,
    String sortDirection,
    String label,
  ) {
    final productProvider = context.read<ProductProvider>();
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.of(sheetContext).pop();
        productProvider.setSort(sortBy, sortDirection);
        productProvider.filterProducts(
          categoryId: widget.categoryId,
          brandId: widget.brandId,
          sortBy: sortBy,
          sortDirection: sortDirection,
        );
      },
    );
  }

  // Bottom sheet de filtres
  void _showFilterSheet(BuildContext context) {
    final minPriceController = TextEditingController();
    final maxPriceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtres',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                // Prix minimum
                TextField(
                  controller: minPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix minimum (FCFA)',
                    labelStyle: TextStyle(fontFamily: 'Poppins'),
                    prefixIcon: Icon(Icons.arrow_upward, size: 18),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                // Prix maximum
                TextField(
                  controller: maxPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix maximum (FCFA)',
                    labelStyle: TextStyle(fontFamily: 'Poppins'),
                    prefixIcon: Icon(Icons.arrow_downward, size: 18),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                // Bouton appliquer
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      final productProvider = context.read<ProductProvider>();
                      productProvider.filterProducts(
                        categoryId: widget.categoryId,
                        brandId: widget.brandId,
                        minPrice: double.tryParse(minPriceController.text),
                        maxPrice: double.tryParse(maxPriceController.text),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'APPLIQUER',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}