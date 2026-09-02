// ============================================
// ÉCRAN DE LISTE DES PRODUITS - VERSION PREMIUM
// ============================================
// Liste avec pagination infinie, filtres avancés,
// tri intelligent et bascule grille/liste.
// Design moderne conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_list_item.dart';
import '../widgets/product_grid_item.dart';
import '../widgets/shimmer_product_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/pagination_loader.dart';
import '../widgets/filter_sheet.dart';

class ProductListScreen extends StatefulWidget {
  final String title;
  final int? categoryId;
  final int? brandId;
  final String? searchQuery;

  const ProductListScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.brandId,
    this.searchQuery,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = false;
  String _sortBy = 'created_at';
  String _sortDirection = 'desc';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================
  // PAGINATION
  // ============================================

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadProducts() async {
    final provider = context.read<ProductProvider>();

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      await provider.searchProducts(widget.searchQuery!);
    } else if (widget.categoryId != null || widget.brandId != null) {
      await provider.filterProducts(
        categoryId: widget.categoryId,
        brandId: widget.brandId,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );
    } else {
      await provider.loadProducts();
    }
  }

  Future<void> _loadMore() async {
    final provider = context.read<ProductProvider>();
    if (provider.hasMore && !provider.isLoadingMore) {
      await provider.loadMoreProducts();
    }
  }

  Future<void> _refresh() async {
    await _loadProducts();
  }

  // ============================================
  // TRI
  // ============================================

  void _changeSort(String sortBy, String sortDirection) {
    setState(() {
      _sortBy = sortBy;
      _sortDirection = sortDirection;
    });

    final provider = context.read<ProductProvider>();
    provider.setSort(sortBy, sortDirection);
    _loadProducts();
  }

  // ============================================
  // FILTRES
  // ============================================

  void _showFilters() {
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
            final provider = context.read<ProductProvider>();
            provider.filterProducts(
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
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          // Chargement initial
          if (provider.isLoading && provider.products.isEmpty) {
            return _buildLoadingState();
          }

          // Erreur
          if (provider.hasError && provider.products.isEmpty) {
            return ErrorState(
              message: provider.errorMessage,
              onRetry: _refresh,
            );
          }

          // Vide
          if (provider.products.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Aucun produit trouvé',
              message: 'Essayez de modifier vos filtres ou votre recherche',
              onAction: _refresh,
              actionLabel: 'Rafraîchir',
            );
          }

          // Produits
          return Column(
            children: [
              // Barre d'information
              _buildInfoBar(provider),

              // Liste ou grille
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  color: AppColors.primary,
                  child: _isGridView
                      ? _buildGridView(provider)
                      : _buildListView(provider),
                ),
              ),
            ],
          );
        },
      ),
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
        // Filtres
        IconButton(
          onPressed: _showFilters,
          icon: const Icon(
            Icons.filter_list,
            color: AppColors.textPrimary,
            size: 22,
          ),
          tooltip: 'Filtrer',
        ),
        // Toggle vue grille/liste
        IconButton(
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
          icon: Icon(
            _isGridView ? Icons.view_list : Icons.grid_view,
            color: AppColors.textPrimary,
            size: 22,
          ),
          tooltip: _isGridView ? 'Vue liste' : 'Vue grille',
        ),
        // Tri
        IconButton(
          onPressed: _showSortSheet,
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
  // BARRE D'INFORMATION
  // ============================================

  Widget _buildInfoBar(ProductProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          Text(
            '${provider.productsCount} produit${provider.productsCount > 1 ? 's' : ''}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (provider.hasActiveFilters)
            GestureDetector(
              onTap: () => provider.clearFilters(),
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
    );
  }

  // ============================================
  // ÉTATS
  // ============================================

  Widget _buildLoadingState() {
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.50,
        ),
        itemCount: 8,
        itemBuilder: (context, index) => const ShimmerProductCard(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: 6,
      itemBuilder: (context, index) => const ShimmerProductCard(),
    );
  }

  // ============================================
  // GRILLE DE PRODUITS
  // ============================================

  Widget _buildGridView(ProductProvider provider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.products.length) {
          return const PaginationLoader();
        }

        final product = provider.products[index];
        return ProductGridItem(
          product: product,
          onTap: (tappedProduct) => _navigateToProduct(tappedProduct),
        );
      },
    );
  }

  // ============================================
  // LISTE DE PRODUITS
  // ============================================

  Widget _buildListView(ProductProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(15),
      itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.products.length) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: PaginationLoader(),
          );
        }

        final product = provider.products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductListItem(
            product: product,
            onTap: (tappedProduct) => _navigateToProduct(tappedProduct),
          ),
        );
      },
    );
  }

  // ============================================
  // BOTTOM SHEET DE TRI
  // ============================================

  void _showSortSheet() {
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
              _buildSortOption(
                sheetContext,
                icon: Icons.access_time,
                label: 'Plus récents',
                sortBy: 'created_at',
                sortDirection: 'desc',
              ),
              _buildSortOption(
                sheetContext,
                icon: Icons.trending_up,
                label: 'Prix croissant',
                sortBy: 'price',
                sortDirection: 'asc',
              ),
              _buildSortOption(
                sheetContext,
                icon: Icons.trending_down,
                label: 'Prix décroissant',
                sortBy: 'price',
                sortDirection: 'desc',
              ),
              _buildSortOption(
                sheetContext,
                icon: Icons.star,
                label: 'Meilleures notes',
                sortBy: 'rating',
                sortDirection: 'desc',
              ),
              _buildSortOption(
                sheetContext,
                icon: Icons.local_fire_department,
                label: 'Populaires',
                sortBy: 'popularity',
                sortDirection: 'desc',
              ),
              _buildSortOption(
                sheetContext,
                icon: Icons.percent,
                label: 'Meilleures réductions',
                sortBy: 'discount',
                sortDirection: 'desc',
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext sheetContext, {
    required IconData icon,
    required String label,
    required String sortBy,
    required String sortDirection,
  }) {
    final isSelected = _sortBy == sortBy && _sortDirection == sortDirection;

    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary, size: 20)
          : null,
      onTap: () {
        Navigator.of(sheetContext).pop();
        _changeSort(sortBy, sortDirection);
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