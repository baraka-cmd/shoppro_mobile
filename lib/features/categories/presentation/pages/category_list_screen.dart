// ============================================
// ÉCRAN EXPLORER - VERSION PREMIUM
// ============================================
// Affiche les catégories avec tendances,
// catégories populaires et groupes organisés.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../products/domain/entities/category.dart';
import '../../../products/presentation/providers/category_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/category_skeleton.dart';


class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadCategories() async {
    final provider = context.read<CategoryProvider>();
    await provider.loadCategories();
  }

  // ============================================
  // FILTRAGE
  // ============================================

  List<Category> _filterCategories(List<Category> categories) {
    if (_searchQuery.isEmpty) return categories;

    return categories.where((category) {
      return category.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          category.slug.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (category.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<CategoryProvider>(
          builder: (context, provider, child) {
            // Chargement
            if (provider.isLoading && provider.categories.isEmpty) {
              return const CategorySkeleton();
            }

            // Erreur
            if (provider.hasError && provider.categories.isEmpty) {
              return _buildErrorState(provider.errorMessage);
            }

            // Vide
            if (provider.categories.isEmpty) {
              return _buildEmptyState();
            }

            final filteredCategories = _filterCategories(provider.categories);
            final rootCategories = filteredCategories.where((c) => c.isRoot).toList();
            final featuredCategories = rootCategories.where((c) => c.isFeatured).toList();
            final popularCategories = rootCategories
                .where((c) => c.effectiveProductsCount > 0)
                .toList()
              ..sort((a, b) => b.effectiveProductsCount.compareTo(a.effectiveProductsCount));

            return RefreshIndicator(
              onRefresh: _loadCategories,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ============================================
                  // HEADER
                  // ============================================
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),

                  // ============================================
                  // BARRE DE RECHERCHE
                  // ============================================
                  SliverToBoxAdapter(
                    child: _buildSearchBar(),
                  ),

                  // ============================================
                  // TENDANCES
                  // ============================================
                  if (featuredCategories.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        icon: Icons.local_fire_department,
                        title: 'Tendances',
                        iconColor: AppColors.error,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildHorizontalList(featuredCategories),
                    ),
                  ],

                  // ============================================
                  // CATÉGORIES POPULAIRES
                  // ============================================
                  if (popularCategories.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        icon: Icons.star,
                        title: 'Catégories populaires',
                        iconColor: AppColors.warning,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.3,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = popularCategories[index];
                            return CategoryCard(
                              category: category,
                              onTap: () => _navigateToCategory(category),
                            );
                          },
                          childCount: popularCategories.length,
                        ),
                      ),
                    ),
                  ],

                  // ============================================
                  // TOUTES LES CATÉGORIES
                  // ============================================
                  if (rootCategories.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        icon: Icons.grid_view,
                        title: 'Toutes les catégories',
                        iconColor: AppColors.primary,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = rootCategories[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildListTile(category),
                            );
                          },
                          childCount: rootCategories.length,
                        ),
                      ),
                    ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================
  // HEADER
  // ============================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explorer',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Découvrez ce qui vous correspond',
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

  // ============================================
  // BARRE DE RECHERCHE
  // ============================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Rechercher une catégorie...',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textLight,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // EN-TÊTE DE SECTION
  // ============================================

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // LISTE HORIZONTALE
  // ============================================

  Widget _buildHorizontalList(List<Category> categories) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 160,
              child: CategoryCard(
                category: category,
                onTap: () => _navigateToCategory(category),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // TUILE DE CATÉGORIE EN LISTE
  // ============================================

  Widget _buildListTile(Category category) {
    return GestureDetector(
      onTap: () => _navigateToCategory(category),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(category.icon),
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (category.effectiveProductsCount > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${category.effectiveProductsCount} produits',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ICÔNE DE CATÉGORIE
  // ============================================

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'devices':
      case 'phone_android':
        return Icons.phone_android;
      case 'checkroom':
      case 'fashion':
        return Icons.checkroom;
      case 'home':
        return Icons.home;
      case 'restaurant':
        return Icons.restaurant;
      case 'sports':
        return Icons.sports;
      case 'beauty':
        return Icons.face;
      default:
        return Icons.category;
    }
  }

  // ============================================
  // NAVIGATION
  // ============================================

  void _navigateToCategory(Category category) {
    Navigator.of(context).pushNamed(
      AppRoutes.categoryDetail,
      arguments: {
        'category_id': category.id,
        'category_name': category.name,
      },
    );
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

  Widget _buildEmptyState() {
    return Center(
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