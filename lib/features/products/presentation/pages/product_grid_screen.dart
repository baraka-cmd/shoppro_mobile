// ============================================
// ÉCRAN DE GRILLE DES PRODUITS - VERSION PREMIUM
// ============================================
// Grille 2 colonnes avec pagination infinie,
// filtres avancés et tri intelligent.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_grid_item.dart';
import '../widgets/shimmer_product_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/pagination_loader.dart';
import '../widgets/filter_sheet.dart';

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
  String _sortBy = 'created_at';
  String _sortDirection = 'desc';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  void _loadInitialData() {
    final productProvider = context.read<ProductProvider>();

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      productProvider.searchProducts(widget.searchQuery!);
    } else if (widget.categoryId != null || widget.brandId != null) {
      productProvider.filterProducts(
        categoryId: widget.categoryId,
        brandId: widget.brandId,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );
    } else {
      productProvider.loadProducts();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final productProvider = context.read<ProductProvider>();
      if (productProvider.hasMore && !productProvider.isLoadingMore) {
        productProvider.loadMoreProducts();
      }
    }
  }

  Future<void> _refresh() async {
    final productProvider = context.read<ProductProvider>();
    await productProvider.refreshProducts();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  // ============================================
  // APP BAR
  // ============================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
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
          tooltip: 'Filtrer',
        ),
        IconButton(
          onPressed: () => _showSortSheet(context),
          icon: const Icon(
            Icons.sort,
            color: AppColors.textPrimary,
            size: 22,
          ),
          tooltip: 'Trier',
        ),
      ],
    );
  }

  // ============================================
  // CORPS
  // ============================================

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
          childAspectRatio: 0.60,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ShimmerProductCard(),
      );
    }

    // Erreur
    if (productProvider.hasError && productProvider.products.isEmpty) {
      return ErrorState(
        message: productProvider.errorMessage,
        onRetry: _refresh,
      );
    }

    // Vide
    if (productProvider.products.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Aucun produit',
        message: 'Essayez de modifier vos filtres',
        onAction: _refresh,
        actionLabel: 'Rafraîchir',
      );
    }

    // Grille de produits
    return Column(
      children: [
        // Barre d'information
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.surface,
          child: Row(
            children: [
              Text(
                '${productProvider.productsCount} produit${productProvider.productsCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (productProvider.hasActiveFilters)
                GestureDetector(
                  onTap: () => productProvider.clearFilters(),
                  child: const Text(
                    'Effacer filtres',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Grille
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.60,
              ),
              itemCount: productProvider.products.length + (productProvider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == productProvider.products.length) {
                  return const PaginationLoader();
                }

                final product = productProvider.products[index];
                return ProductGridItem(
                  product: product,
                  onTap: (tappedProduct) => _navigateToProduct(tappedProduct),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // BOTTOM SHEET DE TRI
  // ============================================

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Trier par',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 15),
              _buildSortOption(context, sheetContext, 'created_at', 'desc', 'Plus récents'),
              _buildSortOption(context, sheetContext, 'price', 'asc', 'Prix croissant'),
              _buildSortOption(context, sheetContext, 'price', 'desc', 'Prix décroissant'),
              _buildSortOption(context, sheetContext, 'rating', 'desc', 'Meilleures notes'),
              _buildSortOption(context, sheetContext, 'sales_count', 'desc', 'Plus populaires'),
              const SizedBox(height: 20),
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
    final isSelected = _sortBy == sortBy && _sortDirection == sortDirection;

    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        size: 20,
        color: isSelected ? AppColors.primary : AppColors.textTertiary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.of(sheetContext).pop();
        setState(() {
          _sortBy = sortBy;
          _sortDirection = sortDirection;
        });
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

  // ============================================
  // BOTTOM SHEET DE FILTRES
  // ============================================

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return FilterSheet(
          categoryId: widget.categoryId,
          brandId: widget.brandId,
          onApply: (filters) {
            Navigator.of(sheetContext).pop();
            final productProvider = context.read<ProductProvider>();
            productProvider.filterProducts(
              categoryId: filters['category_id'] as int?,
              brandId: filters['brand_id'] as int?,
              minPrice: filters['min_price'] as double?,
              maxPrice: filters['max_price'] as double?,
              inStock: filters['in_stock'] as bool?,
              minRating: filters['min_rating'] as double?,
              onSale: filters['on_sale'] as bool?,
              sortBy: _sortBy,
              sortDirection: _sortDirection,
            );
          },
        );
      },
    );
  }

  // ============================================
  // NAVIGATION
  // ============================================

  void _navigateToProduct(Product product) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetail,
      arguments: {'product_id': product.id},
    );
  }
}