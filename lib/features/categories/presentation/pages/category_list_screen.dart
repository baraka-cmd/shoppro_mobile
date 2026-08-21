// Écran de liste des catégories
// Affiche toutes les catégories avec filtres et navigation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/category.dart';
import '../../../products/presentation/providers/category_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/category_list_item.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  String _selectedFilter = 'all';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Charger les catégories
  Future<void> _loadCategories() async {
    final provider = context.read<CategoryProvider>();
    await provider.loadCategories();
  }

  // Filtrer les catégories
  List<Category> _getFilteredCategories(CategoryProvider provider) {
    switch (_selectedFilter) {
      case 'featured':
        return provider.featuredCategories;
      case 'active':
        return provider.activeCategories;
      case 'root':
        return provider.rootCategories;
      default:
        return provider.categories;
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
        title: const Text(
          'Catégories',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigation vers recherche
            },
            icon: const Icon(
              Icons.search,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          // Chargement
          if (provider.isLoading && provider.categories.isEmpty) {
            return _buildLoadingState();
          }

          // Erreur
          if (provider.hasError && provider.categories.isEmpty) {
            return _buildErrorState(provider.errorMessage);
          }

          // Vide
          if (provider.categories.isEmpty) {
            return _buildEmptyState();
          }

          final filteredCategories = _getFilteredCategories(provider);

          return Column(
            children: [
              // Chips de filtres
              _buildFilterChips(),

              const SizedBox(height: 10),

              // Liste des catégories
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadCategories,
                  color: AppColors.primary,
                  child: filteredCategories.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = filteredCategories[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CategoryListItem(
                                category: category,
                                productsCount: category.productsCount ?? 0,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/category/detail',
                                    arguments: {
                                      'category_id': category.id,
                                      'category_name': category.name,
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Chips de filtres
  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          CategoryChip(
            label: 'Toutes',
            icon: Icons.apps,
            isSelected: _selectedFilter == 'all',
            onTap: () {
              setState(() {
                _selectedFilter = 'all';
              });
            },
          ),
          const SizedBox(width: 8),
          CategoryChip(
            label: 'Vedette',
            icon: Icons.star,
            isSelected: _selectedFilter == 'featured',
            selectedColor: AppColors.warning,
            onTap: () {
              setState(() {
                _selectedFilter = 'featured';
              });
            },
          ),
          const SizedBox(width: 8),
          CategoryChip(
            label: 'Actives',
            icon: Icons.check_circle,
            isSelected: _selectedFilter == 'active',
            selectedColor: AppColors.success,
            onTap: () {
              setState(() {
                _selectedFilter = 'active';
              });
            },
          ),
          const SizedBox(width: 8),
          CategoryChip(
            label: 'Racines',
            icon: Icons.account_tree,
            isSelected: _selectedFilter == 'root',
            selectedColor: AppColors.info,
            onTap: () {
              setState(() {
                _selectedFilter = 'root';
              });
            },
          ),
        ],
      ),
    );
  }

  // État de chargement
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              message ?? 'Erreur de chargement',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadCategories,
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
              Icons.category_outlined,
              size: 35,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Aucune catégorie',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Les catégories apparaîtront ici',
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
}