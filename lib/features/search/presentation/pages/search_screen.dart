// Écran de recherche complet
// Avec barre de recherche, historique, suggestions et résultats

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Effectuer la recherche
  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _showResults = true;
    });

    final provider = context.read<SearchProvider>();
    provider.search(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: CustomSearchBar(
            controller: _searchController,
            autoFocus: true,
            onChanged: (query) {
              if (!_showResults && query.isNotEmpty) {
                final provider = context.read<SearchProvider>();
                provider.searchSuggestions(query);
              }
            },
            onSubmitted: _performSearch,
            onClear: () {
              setState(() {
                _showResults = false;
              });
              final provider = context.read<SearchProvider>();
              provider.clearSearch();
            },
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: _showResults
          ? _buildResults()
          : _buildInitialContent(),
    );
  }

  // Contenu initial (historique + suggestions)
  Widget _buildInitialContent() {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        if (provider.isSearching || provider.hasSuggestions) {
          return SearchSuggestions(
            products: provider.suggestions,
            categories: const ['Électronique', 'Mode', 'Maison', 'Beauté'],
            isLoading: provider.isSearching,
            onSuggestionTap: (query) {
              _searchController.text = query;
              _performSearch(query);
            },
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              SearchHistory(
                onSearchSelected: (query) {
                  _searchController.text = query;
                  _performSearch(query);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Résultats de recherche
  Widget _buildResults() {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        if (provider.isSearching) {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                '${results.length} résultat(s) pour "${provider.query}"',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final product = results[index];
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
            ),
          ],
        );
      },
    );
  }

  // État d'erreur
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

  // État vide
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
                color: AppColors.background,
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
            const SizedBox(height: 20),
            const Text(
              'Vérifiez l\'orthographe ou essayez des termes plus généraux',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}