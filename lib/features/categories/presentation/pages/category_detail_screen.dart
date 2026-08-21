// Écran de détail d'une catégorie
// Affiche le header, les sous-catégories, les filtres et les produits

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
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
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Charger toutes les données
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoryProvider = context.read<CategoryProvider>();
      final productProvider = context.read<ProductProvider>();

      // Charger les catégories si pas encore
      if (categoryProvider.categories.isEmpty) {
        await categoryProvider.loadCategories();
      }

      // Trouver la catégorie
      Category? category;
      try {
        category = categoryProvider.categories.firstWhere(
          (c) => c.id == widget.categoryId,
        );
      } catch (e) {
        category = null;
      }

      // Charger les produits
      await productProvider.loadProducts();
      await productProvider.filterProducts(categoryId: widget.categoryId);

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

  // Charger plus de produits (pagination)
  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final provider = context.read<ProductProvider>();
      await provider.loadMoreProducts();

      setState(() {
        _products = provider.products;
        _isLoadingMore = false;
        _hasMore = provider.hasMore;
        _currentPage = provider.currentPage;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // Filtrer par sous-catégorie
  List<Product> _getFilteredProducts() {
    var filtered = _products;

    // Filtre par sous-catégorie
    if (_selectedSubcategoryId != 0) {
      filtered = filtered
          .where((p) => p.subcategoryId == _selectedSubcategoryId)
          .toList();
    }

    // Filtre par prix
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

    // Filtre par stock
    if (_currentFilters.inStockOnly) {
      filtered = filtered.where((p) => p.isInStock).toList();
    }

    // Filtre par note
    if (_currentFilters.minRating > 0) {
      filtered = filtered
          .where((p) => p.averageRating >= _currentFilters.minRating)
          .toList();
    }

    return filtered;
  }

  // Appliquer le tri
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
        sorted.sort((a, b) => (b.discountPercentage ?? 0).compareTo(a.discountPercentage ?? 0));
        break;
      default: // created_at_desc
        break;
    }

    return sorted;
  }

  // Obtenir le label du tri
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
          widget.categoryName,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const ShimmerProductGrid(itemCount: 6)
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  // Contenu principal
  Widget _buildContent() {
    final filteredProducts = _getFilteredProducts();
    final sortedProducts = _getSortedProducts(filteredProducts);

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Header de la catégorie
            if (_category != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CategoryHeader(
                  category: _category!,
                  productsCount: _products.length,
                ),
              ),

            const SizedBox(height: 15),

            // Sous-catégories en chips
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

            // Barre de filtres et tri
            FilterBar(
              totalProducts: sortedProducts.length,
              currentSort: _getSortLabel(),
              hasActiveFilters: _currentFilters.hasActiveFilters,
              onFilterTap: () => _showFilters(),
              onSortTap: () => _showSort(),
            ),

            const SizedBox(height: 10),

            // Grille de produits
            if (sortedProducts.isEmpty)
              _buildEmptyState()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: sortedProducts.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Loader de pagination
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
                      Navigator.of(context).pushReplacementNamed(
                        '/product/detail',
                        arguments: {'product_id': p.id},
                      );
                    },
                  );
                },
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Afficher le sort sheet
  void _showSort() {
    showSortSheet(
      context: context,
      currentSort: _currentSort,
      onSortSelected: (value) {
        setState(() {
          _currentSort = value;
        });
      },
    );
  }

  // Afficher le filter sheet
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

  // État d'erreur
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

  // État vide
  Widget _buildEmptyState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(20),
      child: Center(
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
          ],
        ),
      ),
    );
  }
}