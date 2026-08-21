// Écran d'accueil complet
// Assemble AppBar, bannières, catégories et sections produits

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/presentation/providers/category_provider.dart';
import '../../../products/presentation/widgets/featured_products_section.dart';
import '../../../products/presentation/widgets/popular_products_section.dart';
import '../../../products/presentation/widgets/recent_products_section.dart';
import '../../../products/presentation/widgets/on_sale_products_section.dart';
import '../../../navigation/presentation/widgets/role_based_navigation.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../widgets/home_appbar.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Charger toutes les données
  Future<void> _loadData() async {
    final productProvider = context.read<ProductProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    await Future.wait([
      productProvider.loadAllSections(),
      categoryProvider.loadCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeAppBar(
        notificationCount: 3,
        cartCount: 0,
        
        onSearchTap: () {
          Navigator.of(context).pushNamed(AppRoutes.search);  // ✅ AJOUTER
        },
        onNotificationTap: () {
          // Navigation vers notifications
        },
        onCartTap: () {
          Navigator.of(context).pushNamed(AppRoutes.cart);  // ✅ CORRIGÉ
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              // Bannières
              _buildBanners(),

              const SizedBox(height: 25),

              // Catégories
              _buildCategories(),

              const SizedBox(height: 25),

              // Produits en vedette
              _buildFeaturedProducts(),

              const SizedBox(height: 25),

              // Produits populaires
              _buildPopularProducts(),

              const SizedBox(height: 25),

              // Produits récents
              _buildRecentProducts(),

              const SizedBox(height: 25),

              // Produits en promotion
              _buildOnSaleProducts(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: RoleBasedNavigation(
        roleItems: {
          UserRole.client: RoleNavigationItems.clientItems,
          UserRole.seller: RoleNavigationItems.sellerItems,
          UserRole.admin: RoleNavigationItems.adminItems,
          UserRole.guest: RoleNavigationItems.guestItems,
        },
        onItemSelected: (index) {
          setState(() {
            _currentTab = index;
          });
          _handleTabChange(index);
        },
      ),
    );
  }

  // Bannières
  Widget _buildBanners() {
    return BannerCarousel(
      banners: [
        BannerItem(
          backgroundColor: AppColors.primary,
          title: 'SOLDE D\'ÉTÉ',
          subtitle: 'Jusqu\'à -50% sur tout',
          onTap: () {},
        ),
        BannerItem(
          backgroundColor: AppColors.secondary,
          title: 'NOUVEAUX PRODUITS',
          subtitle: 'Découvrez les dernières tendances',
          onTap: () {},
        ),
        BannerItem(
          backgroundColor: AppColors.success,
          title: 'LIVRAISON GRATUITE',
          subtitle: 'Dès 50 000 FCFA d\'achat',
          onTap: () {},
        ),
      ],
      height: 170,
      autoPlay: true,
      autoPlayInterval: const Duration(seconds: 4),
      showDots: true,
      showCounter: true,
    );
  }

  // Catégories
  Widget _buildCategories() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        return CategoryGrid(
          categories: categoryProvider.categories.take(8).toList(),
          isLoading: categoryProvider.isLoading,
          crossAxisCount: 4,
          onCategoryTap: (category) {
            Navigator.of(context).pushNamed(
              AppRoutes.categoryDetail,
              arguments: {
                'category_id': category.id,
                'category_name': category.name,
              },
            );
          },
          onSeeAll: () {
            Navigator.of(context).pushNamed(AppRoutes.categoryList);
          },
        );
      },
    );
  }

  // Produits en vedette
  Widget _buildFeaturedProducts() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return FeaturedProductsSection(
          products: productProvider.featuredProducts,
          isLoading: productProvider.isLoading && productProvider.featuredProducts.isEmpty,
          onSeeAll: () {
            Navigator.of(context).pushNamed(
              AppRoutes.productList,
              arguments: {'title': 'Produits en vedette'},
            );
          },
          onProductTap: (product) {
            Navigator.of(context).pushNamed(
              AppRoutes.productDetail,
              arguments: {'product_id': product.id},
            );
          },
        );
      },
    );
  }

  // Produits populaires
  Widget _buildPopularProducts() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return PopularProductsSection(
          products: productProvider.popularProducts,
          isLoading: productProvider.isLoading && productProvider.popularProducts.isEmpty,
          onSeeAll: () {
            Navigator.of(context).pushNamed(
              AppRoutes.productList,
              arguments: {'title': 'Produits populaires'},
            );
          },
          onProductTap: (product) {
            Navigator.of(context).pushNamed(
              AppRoutes.productDetail,
              arguments: {'product_id': product.id},
            );
          },
        );
      },
    );
  }

  // Produits récents
  Widget _buildRecentProducts() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return RecentProductsSection(
          products: productProvider.recentProducts,
          isLoading: productProvider.isLoading && productProvider.recentProducts.isEmpty,
          onSeeAll: () {
            Navigator.of(context).pushNamed(
              AppRoutes.productList,
              arguments: {'title': 'Produits récents'},
            );
          },
          onProductTap: (product) {
            Navigator.of(context).pushNamed(
              AppRoutes.productDetail,
              arguments: {'product_id': product.id},
            );
          },
        );
      },
    );
  }

  // Produits en promotion
  Widget _buildOnSaleProducts() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return OnSaleProductsSection(
          products: productProvider.onSaleProducts,
          isLoading: productProvider.isLoading && productProvider.onSaleProducts.isEmpty,
          onSeeAll: () {
            Navigator.of(context).pushNamed(
              AppRoutes.productList,
              arguments: {'title': 'Promotions'},
            );
          },
          onProductTap: (product) {
            Navigator.of(context).pushNamed(
              AppRoutes.productDetail,
              arguments: {'product_id': product.id},
            );
          },
        );
      },
    );
  }

  // Gérer le changement d'onglet
 void _handleTabChange(int index) {
  switch (index) {
    case 0: // Accueil
      break;
    case 1: // Catégories
      Navigator.of(context).pushNamed(AppRoutes.categoryList);
      break;
    case 2: // Panier
      Navigator.of(context).pushNamed(AppRoutes.cart);
      break;
    case 3: // Favoris
      Navigator.of(context).pushNamed(AppRoutes.favorites);  // ✅ CORRIGÉ
      break;
    case 4: // Profil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profil bientôt disponible',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
        ),
      );
      break;
  }
}
}