// ============================================
// ÉCRAN DES FAVORIS - VERSION PREMIUM
// ============================================
// Affiche la liste des produits favoris avec
// filtres, tri, alertes prix et actions.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../providers/favorite_provider.dart';
import '../widgets/favorite_item_widget.dart';
import '../widgets/empty_favorites.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _selectedFilter = 'all';
  String _currentSort = 'recent';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadData() async {
    final favoriteProvider = context.read<FavoriteProvider>();
    await favoriteProvider.loadFavorites();

    final productProvider = context.read<ProductProvider>();
    await productProvider.loadPopularProducts();
  }

  // ============================================
  // FILTRAGE ET TRI
  // ============================================

  List<dynamic> _getFilteredFavorites(FavoriteProvider provider) {
    final favorites = provider.sortedFavorites;

    switch (_selectedFilter) {
      case 'in_stock':
        return favorites.where((f) => f.isInStock).toList();
      case 'on_sale':
        return favorites.where((f) => f.hasDiscount).toList();
      case 'price_dropped':
        return favorites.where((f) => f.hasPriceDropped).toList();
      case 'price_alert':
        return favorites.where((f) => f.priceAlert).toList();
      default:
        return favorites;
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
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
        title: Consumer<FavoriteProvider>(
          builder: (context, provider, child) {
            return Text(
              provider.isEmpty
                  ? 'Favoris'
                  : 'Favoris (${provider.favoritesCount})',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            );
          },
        ),
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, provider, child) {
              if (provider.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _showClearDialog(provider),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 22,
                ),
                tooltip: 'Vider les favoris',
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.isEmpty) {
            return EmptyFavorites(
              onExplore: () {
                Navigator.of(context).pop();
              },
            );
          }

          final filteredFavorites = _getFilteredFavorites(provider);

          return Column(
            children: [
              // ============================================
              // CHIPS DE FILTRES
              // ============================================
              _buildFilterChips(provider),

              // ============================================
              // BARRE DE TRI
              // ============================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${filteredFavorites.length} produit${filteredFavorites.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
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

              const SizedBox(height: 5),

              // ============================================
              // LISTE DES FAVORIS
              // ============================================
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: filteredFavorites.isEmpty
                      ? EmptyFavorites(
                          onExplore: () {
                            Navigator.of(context).pop();
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: filteredFavorites.length,
                          itemBuilder: (context, index) {
                            final favorite = filteredFavorites[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: FavoriteItemWidget(
                                favorite: favorite,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.productDetail,
                                    arguments: {
                                      'product_id': favorite.productId,
                                    },
                                  );
                                },
                                onAddToCart: () {
                                  _addToCart(favorite);
                                },
                                onRemove: () {
                                  _handleRemoveFavorite(provider, favorite.id);
                                },
                                onTogglePriceAlert: () {
                                  provider.togglePriceAlert(favorite.id);
                                  _showPriceAlertSnackBar(provider, favorite);
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

  // ============================================
  // CHIPS DE FILTRES
  // ============================================

  Widget _buildFilterChips(FavoriteProvider provider) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        children: [
          _buildChip(
            label: 'Tous',
            count: provider.favoritesCount,
            isSelected: _selectedFilter == 'all',
            onTap: () {
              setState(() {
                _selectedFilter = 'all';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: '🔥 Prix en baisse',
            count: provider.priceDroppedCount,
            isSelected: _selectedFilter == 'price_dropped',
            color: AppColors.error,
            onTap: () {
              setState(() {
                _selectedFilter = 'price_dropped';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Disponibles',
            count: provider.inStockFavorites.length,
            isSelected: _selectedFilter == 'in_stock',
            color: AppColors.success,
            onTap: () {
              setState(() {
                _selectedFilter = 'in_stock';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: '🔔 Alertes prix',
            count: provider.priceAlertCount,
            isSelected: _selectedFilter == 'price_alert',
            color: AppColors.warning,
            onTap: () {
              setState(() {
                _selectedFilter = 'price_alert';
              });
            },
          ),
        ],
      ),
    );
  }

  // ============================================
  // CHIP DE FILTRE
  // ============================================

  Widget _buildChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.borderColor,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 5,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================
  // TRI
  // ============================================

  void _showSortSheet(FavoriteProvider provider) {
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
              _buildSortOption(sheetContext, provider, 'recent', 'Plus récents'),
              _buildSortOption(sheetContext, provider, 'price_asc', 'Prix croissant'),
              _buildSortOption(sheetContext, provider, 'price_desc', 'Prix décroissant'),
              _buildSortOption(sheetContext, provider, 'rating_desc', 'Meilleures notes'),
              _buildSortOption(sheetContext, provider, 'discount_desc', 'Meilleures réductions'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext sheetContext,
    FavoriteProvider provider,
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
        provider.setSort(value);
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
      case 'discount_desc':
        return 'Réductions';
      default:
        return 'Récents';
    }
  }

  // ============================================
  // SUPPRESSION AVEC ANNULATION
  // ============================================

  Future<void> _handleRemoveFavorite(FavoriteProvider provider, int favoriteId) async {
    final success = await provider.removeFavorite(favoriteId);

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Produit retiré des favoris',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        action: SnackBarAction(
          label: 'ANNULER',
          textColor: AppColors.error,
          onPressed: () {
            provider.undoLastAction();
          },
        ),
      ),
    );
  }

  // ============================================
  // ALERTE PRIX SNACKBAR
  // ============================================

  void _showPriceAlertSnackBar(FavoriteProvider provider, dynamic favorite) {
    final isAlertActive = provider.priceAlertFavorites
        .any((f) => f.id == favorite.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAlertActive
              ? '🔔 Alerte prix activée !'
              : 'Alerte prix désactivée',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: isAlertActive ? AppColors.success : AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  // ============================================
  // AJOUTER AU PANIER
  // ============================================

  Future<void> _addToCart(dynamic favorite) async {
    final cartProvider = context.read<CartProvider>();

    final cartItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: favorite.productId,
      name: favorite.productName,
      imageUrl: favorite.productImage,
      sku: favorite.productSku,
      unitPrice: favorite.effectivePrice,
      discountPrice: favorite.hasDiscount ? favorite.productDiscountPrice : null,
      quantity: 1,
      maxQuantity: favorite.stock > 0 ? favorite.stock : 99,
      stock: favorite.stock,
    );

    final success = await cartProvider.addItem(cartItem);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Produit ajouté au panier !' : 'Erreur lors de l\'ajout',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  // ============================================
  // DIALOG VIDER LES FAVORIS
  // ============================================

  void _showClearDialog(FavoriteProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Vider les favoris ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Tous vos produits favoris seront supprimés.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await provider.clearFavorites();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Vider',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}