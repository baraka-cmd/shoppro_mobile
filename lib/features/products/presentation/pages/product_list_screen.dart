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
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Détecter le scroll pour la pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  // Charger les produits
  Future<void> _loadProducts() async {
    final provider = context.read<ProductProvider>();

    if (widget.categoryId != null) {
      await provider.filterProducts(categoryId: widget.categoryId);
    } else if (widget.brandId != null) {
      await provider.filterProducts(brandId: widget.brandId);
    } else if (widget.searchQuery != null) {
      await provider.searchProducts(widget.searchQuery!);
    } else {
      await provider.loadProducts();
    }
  }

  // Charger plus de produits
  Future<void> _loadMore() async {
    final provider = context.read<ProductProvider>();
    if (provider.hasMore && !provider.isLoadingMore) {
      await provider.loadMoreProducts();
    }
  }

  // Rafraîchir
  Future<void> _refresh() async {
    await _loadProducts();
  }

  // Changer le tri
  void _changeSort(String sortBy, String sortDirection) {
    setState(() {
      _sortBy = sortBy;
      _sortDirection = sortDirection;
    });

    final provider = context.read<ProductProvider>();
    provider.setSort(sortBy, sortDirection);
    _loadProducts();
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
          ),
          // Tri
          IconButton(
            onPressed: () => _showSortDialog(),
            icon: const Icon(
              Icons.sort,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          // Chargement initial
          if (provider.isLoading && provider.products.isEmpty) {
            return _isGridView
                ? const ShimmerProductGrid(itemCount: 8)
                : const ShimmerProductList(itemCount: 6);
          }

          // Erreur
          if (provider.hasError && provider.products.isEmpty) {
            return _buildErrorState(provider.errorMessage);
          }

          // Vide
          if (provider.products.isEmpty) {
            return _buildEmptyState();
          }

          // Produits
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            child: _isGridView
                ? _buildGridView(provider)
                : _buildListView(provider),
          );
        },
      ),
    );
  }

  // Grille de produits
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
        // Loader de pagination
        if (index == provider.products.length) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        final product = provider.products[index];
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
    );
  }

  // Liste de produits
  Widget _buildListView(ProductProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(15),
      itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loader de pagination
        if (index == provider.products.length) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }

        final product = provider.products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductListItem(
            product: product,
            onTap: (tappedProduct) {
              Navigator.of(context).pushNamed(
                '/product/detail',
                arguments: {'product_id': tappedProduct.id},
              );
            },
          ),
        );
      },
    );
  }

  // État d'erreur
  Widget _buildErrorState(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: AppColors.error,
          ),
          const SizedBox(height: 15),
          Text(
            message ?? 'Une erreur est survenue',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
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
          const Icon(
            Icons.inventory_2_outlined,
            size: 60,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 15),
          const Text(
            'Aucun produit trouvé',
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
        ],
      ),
    );
  }

  // Dialog de tri
  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
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

  // Option de tri
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
          ? const Icon(
              Icons.check,
              color: AppColors.primary,
              size: 20,
            )
          : null,
      onTap: () {
        Navigator.of(sheetContext).pop();
        _changeSort(sortBy, sortDirection);
      },
    );
  }
}