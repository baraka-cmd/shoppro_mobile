// ============================================
// ÉCRAN DE DÉTAILS DU PRODUIT - VERSION PREMIUM
// ============================================
// Assemble galerie immersive, infos, variantes,
// quantité, specs, avis, produits similaires
// et CTA sticky avec animations professionnelles.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_gallery.dart';
import '../widgets/product_info_section.dart';
import '../widgets/variation_selector.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/specifications_section.dart';
import '../widgets/reviews_section.dart';
import '../widgets/share_button.dart';
import '../widgets/recently_viewed_section.dart';
import '../widgets/shimmer_product_card.dart';
import '../widgets/product_card.dart';
import '../widgets/add_review_sheet.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../favorites/presentation/providers/favorite_provider.dart';
import '../../../favorites/domain/entities/favorite.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _isAddingToCart = false;
  String? _errorMessage;
  Product? _product;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  // ============================================
  // CHARGEMENT DU PRODUIT
  // ============================================

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<ProductProvider>();

      Product? product;
      try {
        product = provider.products.firstWhere((p) => p.id == widget.productId);
      } catch (e) {
        product = null;
      }

      if (product == null) {
        setState(() {
          _errorMessage = 'Produit introuvable';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _product = product;
        _isLoading = false;
      });

      // Ajouter aux récemment consultés
      await provider.addToRecentlyViewed(widget.productId);

      // Charger les produits similaires
      await provider.loadSimilarProducts(widget.productId);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ============================================
  // BUILD PRINCIPAL
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildProductDetails(),
      bottomNavigationBar: _product != null && !_isLoading
          ? _buildBottomBar()
          : null,
    );
  }

  // ============================================
  // ÉTAT DE CHARGEMENT
  // ============================================

  Widget _buildLoadingState() {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Expanded(child: ShimmerProductGrid(itemCount: 2)),
      ],
    );
  }

  // ============================================
  // ÉTAT D'ERREUR
  // ============================================

  Widget _buildErrorState() {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: AppColors.error),
                const SizedBox(height: 15),
                Text(
                  _errorMessage ?? 'Erreur',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
        ),
      ],
    );
  }

  // ============================================
  // DÉTAILS DU PRODUIT
  // ============================================

  Widget _buildProductDetails() {
    final product = _product!;
    final imageUrls = _buildImageUrls(product);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // BARRE SUPÉRIEURE (RETOUR + FAVORI + PARTAGER)
          // ============================================
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Retour
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // Favori + Partager
                  Row(
                    children: [
                      // Favori
                      GestureDetector(
                        onTap: () => _toggleFavorite(product),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: _isFavorite
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Partager
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: ShareButton(
                            product: product,
                            showLabel: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ============================================
          // GALERIE PREMIUM (COMMENCE APRÈS LA BARRE)
          // ============================================
          ProductGallery(
            imageUrls: imageUrls,
            height: 400,
            showThumbnails: imageUrls.length > 1,
            showDots: true,
            showCounter: imageUrls.length > 1,
            enableZoom: true,
            enableFloatingAnimation: true,
          ),

          // ============================================
          // CONTENU PRINCIPAL
          // ============================================
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductInfoSection(product: product),

                const SizedBox(height: 20),
                const Divider(height: 1),

                const SizedBox(height: 15),

                VariationSelector(
                  variants: _buildVariants(product).cast<ProductVariant>(),
                  onVariantSelected: (variant) {},
                ),

                const SizedBox(height: 15),
                const Divider(height: 1),

                const SizedBox(height: 15),

                QuantitySelector(
                  initialQuantity: _quantity,
                  maxQuantity: product.stock > 0 ? product.stock : 99,
                  minQuantity: 1,
                  onQuantityChanged: (qty) {
                    setState(() {
                      _quantity = qty;
                    });
                  },
                ),

                const SizedBox(height: 20),
                const Divider(height: 1),

                const SizedBox(height: 15),

                SpecificationsSection(
                  specifications: _buildSpecifications(product).cast<SpecificationItem>(),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1),

                const SizedBox(height: 15),

                ReviewsSection(
                  averageRating: product.averageRating,
                  totalReviews: product.reviewsCount,
                  ratingDistribution: const {5: 2, 4: 3, 3: 1, 2: 0, 1: 0},
                  reviews: _buildReviews(product).cast<ReviewCardData>(),
                  onSeeAllReviews: () {},
                  onAddReview: () {
                    showAddReviewSheet(context);
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // ============================================
          // PRODUITS SIMILAIRES
          // ============================================
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.similarProducts.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PRODUITS SIMILAIRES',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.productList,
                              arguments: {'title': 'Produits similaires'},
                            );
                          },
                          child: const Text(
                            'Voir tout',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.similarProducts.length,
                      itemBuilder: (context, index) {
                        final similarProduct = provider.similarProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SizedBox(
                            width: 170,
                            child: ProductCard(
                              product: similarProduct,
                              onTap: (p) {
                                Navigator.of(context).pushReplacementNamed(
                                  AppRoutes.productDetail,
                                  arguments: {'product_id': p.id},
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 25),

          // ============================================
          // RÉCEMMENT CONSULTÉS
          // ============================================
          RecentlyViewedSection(
            onProductTap: (product) {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.productDetail,
                arguments: {'product_id': product.id},
              );
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ============================================
  // BOTTOM BAR STICKY
  // ============================================

  Widget _buildBottomBar() {
    final product = _product!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Favori
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => _toggleFavorite(product),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 50,
                  decoration: BoxDecoration(
                    color: _isFavorite
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isFavorite
                          ? AppColors.error
                          : AppColors.borderColor,
                    ),
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite
                        ? AppColors.error
                        : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Ajouter au panier
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: product.isPurchasable && !_isAddingToCart
                    ? () => _addToCart(product)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: AppColors.borderColor,
                  disabledForegroundColor: AppColors.textTertiary,
                ),
                child: _isAddingToCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        product.isPurchasable
                            ? 'AJOUTER AU PANIER'
                            : product.isOutOfStock
                                ? 'RUPTURE DE STOCK'
                                : 'INDISPONIBLE',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // CONSTRUIRE LES URLS DES IMAGES
  // ============================================

  List<String> _buildImageUrls(Product product) {
    final urls = <String>[];

    final mainUrl = product.fullImageUrl;
    if (mainUrl.isNotEmpty) {
      urls.add(mainUrl);
    }

    for (final img in product.images) {
      final url = img.fullUrl;
      if (url.isNotEmpty && !urls.contains(url)) {
        urls.add(url);
      }
    }

    return urls;
  }

  // ============================================
  // AJOUTER AU PANIER
  // ============================================

  Future<void> _addToCart(Product product) async {
    setState(() {
      _isAddingToCart = true;
    });

    final cartProvider = context.read<CartProvider>();

    final cartItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: product.id,
      name: product.name,
      imageUrl: product.fullImageUrl.isNotEmpty ? product.fullImageUrl : product.mainImage,
      sku: product.sku,
      unitPrice: product.currentPrice,
      discountPrice: product.hasDiscount ? product.discountPrice : null,
      quantity: _quantity,
      maxQuantity: product.stock > 0 ? product.stock : 99,
      stock: product.stock,
    );

    final success = await cartProvider.addItem(cartItem);

    if (!mounted) return;

    setState(() {
      _isAddingToCart = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Produit ajouté au panier !',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cartProvider.errorMessage ?? 'Erreur lors de l\'ajout au panier',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
    }
  }

  // ============================================
  // TOGGLE FAVORI
  // ============================================

  Future<void> _toggleFavorite(Product product) async {
    final favoriteProvider = context.read<FavoriteProvider>();

    final favorite = Favorite(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: product.id,
      productName: product.name,
      productImage: product.fullImageUrl.isNotEmpty
          ? product.fullImageUrl
          : product.mainImage,
      productSku: product.sku,
      productPrice: product.price,
      productDiscountPrice: product.hasDiscount ? product.discountPrice : null,
      isInStock: product.isInStock,
      stock: product.stock,
      averageRating: product.averageRating,
      addedAt: DateTime.now(),
    );

    final result = await favoriteProvider.toggleFavorite(favorite);

    if (!mounted) return;

    setState(() {
      _isFavorite = result ?? false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Ajouté aux favoris !' : 'Retiré des favoris',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: _isFavorite ? AppColors.success : AppColors.error,
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
  // CONSTRUIRE LES VARIANTES
  // ============================================

  List<dynamic> _buildVariants(Product product) {
    // Placeholder - à remplacer par les vraies variantes de l'API
    return const [];
  }

  // ============================================
  // CONSTRUIRE LES SPÉCIFICATIONS
  // ============================================

  List<SpecificationItem> _buildSpecifications(Product product) {
    return <SpecificationItem>[
      SpecificationItem(label: 'SKU', value: product.sku, icon: Icons.qr_code),
      SpecificationItem(label: 'Stock', value: '${product.stock} unités', icon: Icons.inventory),
      if (product.category != null)
        SpecificationItem(label: 'Catégorie', value: product.category!.name, icon: Icons.category),
      if (product.brand != null)
        SpecificationItem(label: 'Marque', value: product.brand!.name, icon: Icons.storefront),
    ];
  }

  // ============================================
  // CONSTRUIRE LES AVIS
  // ============================================

  List<dynamic> _buildReviews(Product product) {
    // Placeholder - à remplacer par les vrais avis de l'API
    return const [];
  }
}