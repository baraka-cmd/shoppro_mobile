// Écran du panier d'achat
// Assemble tous les éléments : articles, résumé, coupon et suggestions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/cart_summary.dart';
import '../widgets/coupon_field.dart';
import '../widgets/empty_cart.dart';
import '../widgets/free_shipping_progress.dart';
import '../widgets/cart_suggestions.dart';
import '../widgets/saved_for_later_section.dart';
import '../../../../routes/app_routes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // Charger le panier
  Future<void> _loadCart() async {
    final cartProvider = context.read<CartProvider>();
    await cartProvider.loadCart();

    // Charger les suggestions (produits populaires)
    final productProvider = context.read<ProductProvider>();
    await productProvider.loadPopularProducts();
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
        title: Consumer<CartProvider>(
          builder: (context, provider, child) {
            return Text(
              provider.isEmpty
                  ? 'Panier'
                  : 'Panier (${provider.totalItems})',
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
          // Vider le panier
          Consumer<CartProvider>(
            builder: (context, provider, child) {
              if (provider.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _showClearCartDialog(provider),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 22,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.isEmpty) {
            return _buildEmptyCart(provider);
          }

          return _buildCartContent(provider);
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.isEmpty) return const SizedBox.shrink();
          return _buildBottomBar(provider);
        },
      ),
    );
  }

  // Panier vide
  Widget _buildEmptyCart(CartProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          EmptyCart(
            onExplore: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 30),
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              return CartSuggestions(
                products: productProvider.popularProducts,
                isLoading: productProvider.isLoading,
                onProductTap: (product) {
                  Navigator.of(context).pushNamed(
                    '/product/detail',
                    arguments: {'product_id': product.id},
                  );
                },
                onSeeAll: () {
                  Navigator.of(context).pop();
                },
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Contenu du panier
  Widget _buildCartContent(CartProvider provider) {
    return RefreshIndicator(
      onRefresh: _loadCart,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Barre de progression livraison gratuite
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FreeShippingProgress(cart: provider.cart),
            ),

            const SizedBox(height: 15),

            // Liste des articles actifs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'ARTICLES (${provider.totalItems})',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 10),

            ...provider.cart.activeItems.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: CartItemWidget(
                  item: item,
                  onIncrement: () => provider.incrementQuantity(item.id),
                  onDecrement: () => provider.decrementQuantity(item.id),
                  onRemove: () => provider.removeItem(item.id),
                  onSaveForLater: () => provider.saveForLater(item.id),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/product/detail',
                      arguments: {'product_id': item.productId},
                    );
                  },
                ),
              );
            }),

            // Articles sauvegardés
            if (provider.cart.savedForLaterItems.isNotEmpty) ...[
              const SizedBox(height: 20),
              SavedForLaterSection(
                savedItems: provider.cart.savedForLaterItems,
                onMoveToCart: () {
                  // Déplacer chaque item
                  for (final item in provider.cart.savedForLaterItems) {
                    provider.moveToCart(item.id);
                  }
                },
                onRemove: () {
                  // Supprimer chaque item
                  for (final item in provider.cart.savedForLaterItems) {
                    provider.removeItem(item.id);
                  }
                },
                onClearAll: () {
                  for (final item in provider.cart.savedForLaterItems) {
                    provider.removeItem(item.id);
                  }
                },
              ),
            ],

            const SizedBox(height: 20),

            // Résumé
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CartSummary(cart: provider.cart),
            ),

            const SizedBox(height: 15),

            // Code promo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CouponField(
                currentCoupon: provider.cart.couponCode,
                isLoading: provider.isUpdating,
                onApply: (code) {
                  provider.applyCoupon(code).then((success) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code promo appliqué !'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(20),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.errorMessage ?? 'Code invalide',
                          ),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(20),
                        ),
                      );
                    }
                  });
                },
                onRemove: () {
                  provider.removeCoupon();
                },
              ),
            ),

            const SizedBox(height: 20),

            // Suggestions
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                return CartSuggestions(
                  products: productProvider.popularProducts,
                  isLoading: productProvider.isLoading,
                  onProductTap: (product) {
                    Navigator.of(context).pushNamed(
                      '/product/detail',
                      arguments: {'product_id': product.id},
                    );
                  },
                  onSeeAll: () {
                    Navigator.of(context).pushNamed('/product/list');
                  },
                );
              },
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // Bottom bar avec total + paiement
  Widget _buildBottomBar(CartProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Total
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    provider.cart.formattedTotal,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Bouton paiement
            ElevatedButton(
              // Le bouton PAIEMENT doit utiliser AppRoutes.checkout
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.checkout);  // ✅ PAS '/checkout' en dur
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'PAIEMENT',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog pour vider le panier
  void _showClearCartDialog(CartProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Vider le panier ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Tous les articles seront supprimés de votre panier.',
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
                await provider.clearCart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
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