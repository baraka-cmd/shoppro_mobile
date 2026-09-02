// ============================================
// ÉCRAN DE DÉTAIL D'UNE CATÉGORIE - PREMIUM
// ============================================
// Hero + sous-catégories + filtres + tri
// + produits en grille avec pagination infinie.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../products/domain/entities/category.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/presentation/providers/category_provider.dart';
import '../../../products/presentation/widgets/product_grid_item.dart';
import '../../../products/presentation/widgets/shimmer_product_card.dart';
import '../widgets/category_header.dart';
import '../widgets/subcategory_chip.dart';
import '../widgets/filter_bar.dart';
import '../widgets/sort_sheet.dart';
import '../widgets/filter_sheet.dart';

class CategoryDetailScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  Category? _category;
  List<Product> _products = [];
  List<dynamic> _subcategories = [];
  int _selectedSubcategoryId = 0;
  bool _isLoading = true;
  String? _errorMessage;
  String _currentSort = 'created_at_desc';
  FilterData _currentFilters = const FilterData();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
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

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoryProvider = context.read<CategoryProvider>();
      final productProvider = context.read<ProductProvider>();

      if (categoryProvider.categories.isEmpty) {
        await categoryProvider.loadCategories();
      }

      Category? category;
      try {
        category = categoryProvider.categories.firstWhere(
          (c) => (c as Category).id == widget.categoryId,
        );
      } catch (e) {
        category = null;
      }

      await productProvider.filterProducts(
        categoryId: widget.categoryId,
        sortBy: _sortFromString(),
        sortDirection: _directionFromString(),
      );

      setState(() {
        _category = category;
        _products = productProvider.products;
        _subcategories = category?.subcategories ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final provider = context.read<ProductProvider>();
    if (_isLoadingMore || !provider.hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await provider.loadMoreProducts();

    if (mounted) {
      setState(() {
        _products = provider.products;
        _isLoadingMore = false;
      });
    }
  }

  // ============================================
  // PARSING TRI
  // ============================================

  String _sortFromString() {
    switch (_currentSort) {
      case 'price_asc':
      case 'price_desc':
        return 'price';
      case 'rating_desc':
        return 'rating';
      case 'popularity_desc':
        return 'sales_count';
      default:
        return 'created_at';
    }
  }

  String _directionFromString() {
    return _currentSort.endsWith('_asc') ? 'asc' : 'desc';
  }

  // ============================================
  // FILTRAGE ET TRI LOCAL
  // ============================================

  List<Product> _getFilteredProducts() {
    var filtered = _products;

    if (_selectedSubcategoryId != 0) {
      filtered = filtered
          .where((p) => p.subcategoryId == _selectedSubcategoryId)
          .toList();
    }

    if (_currentFilters.minPrice > 0) {
      filtered = filtered
          .where((p) => p.currentPrice >= _currentFilters.minPrice)
          .toList();
    }
    if (_currentFilters.maxPrice > 0) {
      filtered = filtered
          .where((p) => p.currentPrice <= _currentFilters.maxPrice)
          .toList();
    }

    if (_currentFilters.inStockOnly) {
      filtered = filtered.where((p) => p.isInStock).toList();
    }

    if (_currentFilters.minRating > 0) {
      filtered = filtered
          .where((p) => p.averageRating >= _currentFilters.minRating)
          .toList();
    }

    return filtered;
  }

  List<Product> _getSortedProducts(List<Product> products) {
    final sorted = [...products];

    switch (_currentSort) {
      case 'price_asc':
        sorted.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
      case 'price_desc':
        sorted.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case 'rating_desc':
        sorted.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case 'popularity_desc':
        sorted.sort((a, b) => b.salesCount.compareTo(a.salesCount));
        break;
      case 'discount_desc':
        sorted.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
        break;
      default:
        break;
    }

    return sorted;
  }

  String _getSortLabel() {
    switch (_currentSort) {
      case 'price_asc':
        return 'Prix ↑';
      case 'price_desc':
        return 'Prix ↓';
      case 'rating_desc':
        return 'Notes';
      case 'popularity_desc':
        return 'Populaires';
      case 'discount_desc':
        return 'Réductions';
      default:
        return 'Récents';
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
          widget.categoryName,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const ShimmerProductGrid(itemCount: 6)
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent() {
    if (_category == null) {
      return const SizedBox.shrink();
    }

    final filteredProducts = _getFilteredProducts();
    final sortedProducts = _getSortedProducts(filteredProducts);

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),

                // ============================================
                // HERO DE CATÉGORIE
                // ============================================
                if (_category != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CategoryHeader(
                      category: _category!,
                      productsCount: _products.length,
                    ),
                  ),

                const SizedBox(height: 15),

                // ============================================
                // SOUS-CATÉGORIES
                // ============================================
                if (_subcategories.isNotEmpty) ...[
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        SubcategoryChip(
                          label: 'Tous',
                          isSelected: _selectedSubcategoryId == 0,
                          productCount: _products.length,
                          onTap: () {
                            setState(() {
                              _selectedSubcategoryId = 0;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ..._subcategories.map((subcategory) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SubcategoryChip(
                              label: subcategory.name,
                              isSelected:
                                  _selectedSubcategoryId == subcategory.id,
                              onTap: () {
                                setState(() {
                                  _selectedSubcategoryId = subcategory.id;
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // ============================================
                // BARRE DE FILTRES ET TRI
                // ============================================
                FilterBar(
                  totalProducts: sortedProducts.length,
                  currentSort: _getSortLabel(),
                  hasActiveFilters: _currentFilters.hasActiveFilters,
                  onFilterTap: _showFilters,
                  onSortTap: _showSort,
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),

          // ============================================
          // GRILLE DE PRODUITS
          // ============================================
          if (sortedProducts.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.all(15),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.55,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == sortedProducts.length) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    final product = sortedProducts[index];
                    return ProductGridItem(
                      product: product,
                      onTap: (p) {
                        Navigator.of(context).pushNamed(
                          AppRoutes.productDetail,
                          arguments: {'product_id': p.id},
                        );
                      },
                    );
                  },
                  childCount: sortedProducts.length + (_isLoadingMore ? 1 : 0),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ============================================
  // SHEETS
  // ============================================

  void _showSort() {
    showSortSheet(
      context: context,
      currentSort: _currentSort,
      onSortSelected: (value) {
        setState(() {
          _currentSort = value;
        });
        _loadData();
      },
    );
  }

  void _showFilters() {
    showFilterSheet(
      context: context,
      currentFilters: _currentFilters,
    ).then((filters) {
      if (filters != null) {
        setState(() {
          _currentFilters = filters;
        });
      }
    });
  }

  // ============================================
  // ÉTATS
  // ============================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? 'Erreur de chargement',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 250,
      margin: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.surface,
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
              'Modifiez vos filtres ou réessayez',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (_currentFilters.hasActiveFilters)
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentFilters = const FilterData();
                    _selectedSubcategoryId = 0;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: const Text(
                  'EFFACER LES FILTRES',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}