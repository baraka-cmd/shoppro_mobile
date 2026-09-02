// ============================================
// ÉCRAN DE RECHERCHE - VERSION PREMIUM
// ============================================
// Avec barre de recherche, historique, suggestions,
// correction orthographique, filtres et résultats.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/widgets/product_grid_item.dart';
import '../../../products/presentation/widgets/shimmer_product_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/search_history.dart';
import '../widgets/search_suggestions.dart';
import '../providers/search_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showResults = false;
  String _currentSort = 'created_at_desc';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SearchProvider>();
      provider.loadHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================
  // RECHERCHE
  // ============================================

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _showResults = true;
    });

    final provider = context.read<SearchProvider>();
    provider.search(query);
  }

  void _onQueryChanged(String query) {
    final provider = context.read<SearchProvider>();

    if (!_showResults && query.isNotEmpty) {
      // Debounce pour les suggestions
      provider.searchSuggestionsDebounced(query);
    } else if (query.isEmpty) {
      setState(() {
        _showResults = false;
      });
      provider.clearSearch();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _showResults = false;
    });
    final provider = context.read<SearchProvider>();
    provider.clearSearch();
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
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: CustomSearchBar(
            controller: _searchController,
            autoFocus: true,
            onChanged: _onQueryChanged,
            onSubmitted: _performSearch,
            onClear: _clearSearch,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: _showResults
          ? _buildResults()
          : _buildInitialContent(),
    );
  }

  // ============================================
  // CONTENU INITIAL (HISTORIQUE + SUGGESTIONS)
  // ============================================

  Widget _buildInitialContent() {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        // Suggestions pendant la saisie
        if (provider.hasSuggestions || provider.isSearching) {
          return SingleChildScrollView(
            child: SearchSuggestions(
              products: provider.suggestions,
              categories: const ['Électronique', 'Mode', 'Maison', 'Beauté'],
              isLoading: provider.isSearching,
              onSuggestionTap: (query) {
                _searchController.text = query;
                _performSearch(query);
              },
            ),
          );
        }

        // Historique
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              // ============================================
              // RECHERCHES RÉCENTES
              // ============================================
              if (provider.history.isNotEmpty)
                SearchHistory(
                  onSearchSelected: (query) {
                    _searchController.text = query;
                    _performSearch(query);
                  },
                  onClearAll: () {
                    provider.clearHistory();
                  },
                ),

              // ============================================
              // TENDANCES
              // ============================================
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'RECHERCHES POPULAIRES',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTrendingChip('Samsung'),
                    _buildTrendingChip('Nike'),
                    _buildTrendingChip('iPhone'),
                    _buildTrendingChip('MacBook'),
                    _buildTrendingChip('Adidas'),
                    _buildTrendingChip('L\'Oréal'),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ============================================
  // CHIP DE TENDANCE
  // ============================================

  Widget _buildTrendingChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // ============================================
  // RÉSULTATS DE RECHERCHE
  // ============================================

  Widget _buildResults() {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        if (provider.isSearching && provider.results.isEmpty) {
          return const ShimmerProductGrid(itemCount: 6);
        }

        if (provider.status == SearchStatus.error) {
          return _buildErrorState(provider.errorMessage);
        }

        if (provider.status == SearchStatus.empty || provider.results.isEmpty) {
          return _buildEmptyState(provider.query);
        }

        final results = provider.results;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // BARRE D'INFORMATION
            // ============================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '${results.length} résultat${results.length > 1 ? 's' : ''} pour "${provider.query}"',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  // Tri
                  GestureDetector(
                    onTap: () => _showSortSheet(provider),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.sort,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getSortLabel(),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ============================================
            // GRILLE DE RÉSULTATS
            // ============================================
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.50,
                ),
                itemCount: results.length + (provider.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Loader de pagination
                  if (index == results.length) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final product = results[index];
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
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // TRI
  // ============================================

  void _showSortSheet(SearchProvider provider) {
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
              _buildSortOption(sheetContext, provider, 'created_at_desc', 'Plus récents'),
              _buildSortOption(sheetContext, provider, 'price_asc', 'Prix croissant'),
              _buildSortOption(sheetContext, provider, 'price_desc', 'Prix décroissant'),
              _buildSortOption(sheetContext, provider, 'rating_desc', 'Meilleures notes'),
              _buildSortOption(sheetContext, provider, 'popularity_desc', 'Populaires'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext sheetContext,
    SearchProvider provider,
    String value,
    String label,
  ) {
    final isSelected = _currentSort == value;

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
          _currentSort = value;
        });
        final parts = value.split('_');
        provider.sortResults(parts[0], parts.length > 1 ? parts[1] : 'desc');
      },
    );
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
      default:
        return 'Récents';
    }
  }

  // ============================================
  // ÉTATS
  // ============================================

  Widget _buildErrorState(String? message) {
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
              message ?? 'Erreur de recherche',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _performSearch(_searchController.text),
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

  Widget _buildEmptyState(String query) {
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
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 40,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun résultat trouvé',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucun produit ne correspond à "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Suggestions :\n• Vérifiez l\'orthographe\n• Essayez des termes plus généraux\n• Réduisez les filtres',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textLight,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}