// Écran d'accueil complet
// Assemble AppBar, bannières dynamiques, catégories et toutes les sections

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Providers
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/presentation/providers/category_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../providers/banner_provider.dart';

// Widgets produits
import '../../../products/presentation/widgets/featured_products_section.dart';
import '../../../products/presentation/widgets/popular_products_section.dart';
import '../../../products/presentation/widgets/recent_products_section.dart';
import '../../../products/presentation/widgets/on_sale_products_section.dart';

// Navigation
import '../../../navigation/presentation/widgets/role_based_navigation.dart';
import '../../../auth/domain/entities/user_role.dart';

// Widgets Home
import '../widgets/home_appbar.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_grid.dart';
import '../widgets/flash_sale_section.dart';
import '../widgets/best_sellers_section.dart';
import '../widgets/recommended_section.dart';
import '../widgets/ad_banner.dart';
import '../widgets/blog_section.dart';
import '../widgets/dynamic_sections.dart';

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
    final bannerProvider = context.read<BannerProvider>();

    await Future.wait([
      productProvider.loadAllSections(),
      categoryProvider.loadCategories(),
      bannerProvider.loadBanners(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeAppBar(
        notificationCount: context.watch<NotificationProvider>().unreadCount,
        cartCount: context.watch<CartProvider>().totalQuantity,
        onSearchTap: () {
          Navigator.of(context).pushNamed(AppRoutes.search);
        },
        onNotificationTap: () {
          Navigator.of(context).pushNamed(AppRoutes.notifications);
        },
        onCartTap: () {
          Navigator.of(context).pushNamed(AppRoutes.cart);
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
              _buildBanners(),
              const SizedBox(height: 25),
              _buildCategories(),
              const SizedBox(height: 25),
              _buildFlashSale(),
              const SizedBox(height: 25),
             
              _buildFeaturedProducts(),
              const SizedBox(height: 25),
              _buildBestSellers(),
              const SizedBox(height: 25),
              _buildPopularProducts(),
              const SizedBox(height: 25),
              _buildRecommended(),
              const SizedBox(height: 25),
              
              _buildRecentProducts(),
              const SizedBox(height: 25),
              _buildOnSaleProducts(),
              const SizedBox(height: 25),
              _buildBlogSection(),
              const SizedBox(height: 25),
              _buildDynamicSections(),
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

  // Bannières dynamiques depuis l'API
  Widget _buildBanners() {
  return Consumer<BannerProvider>(
    builder: (context, bannerProvider, child) {
      if (bannerProvider.isLoading && bannerProvider.banners.isEmpty) {
        return BannerCarousel(
          banners: const [
            BannerItem(backgroundColor: AppColors.primary),
            BannerItem(backgroundColor: AppColors.secondary),
          ],
          height: 170,
          autoPlay: true,
        );
      }

      // ✅ Utiliser TOUTES les bannières (pas seulement homeTop)
      return BannerCarousel(
        banners: bannerProvider.banners.map((banner) {
          return BannerItem(
            imageUrl: banner.imageUrl,
            title: banner.title,
            subtitle: banner.subtitle,
            onTap: () => _handleBannerTap(banner),
          );
        }).toList(),
        height: 170,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        showDots: bannerProvider.banners.length > 1,
        showCounter: bannerProvider.banners.length > 1,
      );
    },
  );
}
  // Gérer le tap sur une bannière
  void _handleBannerTap(dynamic banner) {
    switch (banner.targetType) {
      case 'product':
        Navigator.of(context).pushNamed(
          AppRoutes.productDetail,
          arguments: {'product_id': int.tryParse(banner.targetId ?? '') ?? 0},
        );
        break;
      case 'category':
        Navigator.of(context).pushNamed(
          AppRoutes.categoryDetail,
          arguments: {
            'category_id': int.tryParse(banner.targetId ?? '') ?? 0,
            'category_name': banner.title,
          },
        );
        break;
      case 'promotion':
        Navigator.of(context).pushNamed(
          AppRoutes.productList,
          arguments: {'title': banner.title ?? 'Promotion'},
        );
        break;
      default:
        break;
    }
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

  // Flash Sale
  Widget _buildFlashSale() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return FlashSaleSection(
          products: productProvider.onSaleProducts,
          isLoading: productProvider.isLoading,
          endTime: DateTime.now().add(const Duration(hours: 2, minutes: 15)),
          onSeeAll: () {
            Navigator.of(context).pushNamed(
              AppRoutes.productList,
              arguments: {'title': 'Flash Sale'},
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

  // Meilleures ventes
  Widget _buildBestSellers() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return BestSellersSection(
          products: productProvider.popularProducts,
          isLoading: productProvider.isLoading,
          onSeeAll: () {
            Navigator.of(context).pushNamed(
              AppRoutes.productList,
              arguments: {'title': 'Meilleures ventes'},
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

  // Recommandés
  Widget _buildRecommended() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return RecommendedSection(
          products: productProvider.recentProducts,
          isLoading: productProvider.isLoading,
          userName: 'CLIENT',
          onSeeAll: () {
            Navigator.of(context).pushNamed(
              AppRoutes.productList,
              arguments: {'title': 'Recommandés'},
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

  // Blog / Actualités
  Widget _buildBlogSection() {
    return BlogSection(
      articles: const [
        BlogArticle(
          id: 1,
          title: 'Comment choisir son smartphone en 2026 ?',
          imageUrl: null,
          category: 'Guide',
          author: 'Équipe ShopPro',
          date: null,
          readTime: 5,
        ),
        BlogArticle(
          id: 2,
          title: 'Top 10 des meilleures sneakers',
          imageUrl: null,
          category: 'Mode',
          author: 'Équipe ShopPro',
          date: null,
          readTime: 4,
        ),
        BlogArticle(
          id: 3,
          title: 'Conseils pour bien entretenir sa maison',
          imageUrl: null,
          category: 'Maison',
          author: 'Équipe ShopPro',
          date: null,
          readTime: 3,
        ),
      ],
      onSeeAll: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blog bientôt disponible'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20),
          ),
        );
      },
      onArticleTap: (article) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Article : ${article.title}'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
          ),
        );
      },
    );
  }

  // Sections dynamiques
  Widget _buildDynamicSections() {
    return DynamicSections(
      sections: const [
        DynamicSectionData(
          id: 1,
          title: 'Nouveautés de la semaine',
          subtitle: 'Les derniers produits ajoutés',
          icon: Icons.new_releases,
          color: AppColors.success,
          productsCount: 12,
          badgeText: 'NOUVEAU',
          route: '/product/list',
        ),
        DynamicSectionData(
          id: 2,
          title: 'Meilleures offres',
          subtitle: 'Promotions exclusives',
          icon: Icons.local_offer,
          color: AppColors.error,
          productsCount: 8,
          badgeText: '-50%',
          route: '/product/list',
        ),
        DynamicSectionData(
          id: 3,
          title: 'Tendances actuelles',
          subtitle: 'Ce que tout le monde achète',
          icon: Icons.trending_up,
          color: AppColors.warning,
          productsCount: 15,
          badgeText: 'TOP',
          route: '/product/list',
        ),
      ],
      onSectionTap: (section) {
        Navigator.of(context).pushNamed(
          AppRoutes.productList,
          arguments: {'title': section.title},
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
        Navigator.of(context).pushNamed(AppRoutes.favorites);
        break;
      case 4: // Profil
        Navigator.of(context).pushNamed(AppRoutes.profile);
        break;
    }
  }
}