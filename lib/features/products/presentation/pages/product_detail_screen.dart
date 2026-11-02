// ============================================
// ÉCRAN DE DÉTAILS DU PRODUIT - VERSION PREMIUM
// ============================================
// Assemble galerie immersive, infos, variantes,
// quantité, specs, avis (avec photos), produits
// similaires et CTA sticky avec animations.
//
// ✅ Mode vendeur (isSellerPreview = true) :
//   - Cache le bouton Favoris, Partager
//   - Cache la bottom bar (Ajouter au panier)
//   - Cache le bouton "Ajouter un avis"
//   - Ne stocke pas le produit dans les "récemment vus"
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
  /// Produit déjà chargé par l’API vendeur. Les brouillons ne sont pas
  /// présents dans le catalogue public et ne peuvent donc pas être résolus
  /// depuis le cache client.
  final Product? initialProduct;

  /// Si `true`, l'écran est affiché en mode "aperçu vendeur".
  /// - Cache les actions client (favoris, panier, ajout d'avis)
  /// - Le vendeur voit exactement la même chose que le client
  final bool isSellerPreview;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialProduct,
    this.isSellerPreview = false,
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

  // Liste des avis convertis pour l'UI
  List<ReviewCardData> _reviews = [];

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

      Product? product = widget.initialProduct;
      if (product == null) {
        try {
          product = provider.products.firstWhere((p) => p.id == widget.productId);
        } catch (_) {
          product = null;
        }
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

      // ✅ Vérifier si le produit est déjà en favori (uniquement côté client)
      if (!widget.isSellerPreview) {
        final favoriteProvider = context.read<FavoriteProvider>();
        final isFav = await favoriteProvider.isFavorite(widget.productId);

        if (mounted) {
          setState(() {
            _isFavorite = isFav;
          });
        }
      }

      // ✅ Ajouter aux récemment consultés (uniquement côté client)
      if (!widget.isSellerPreview) {
        await provider.addToRecentlyViewed(widget.productId);
      }

      // Les brouillons vendeurs ne sont pas dans l'API publique.
      if (!widget.isSellerPreview) {
        await provider.loadSimilarProducts(widget.productId);
        await _loadReviews();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ============================================
  // CHARGEMENT DES AVIS
  // ============================================

  Future<void> _loadReviews() async {
    try {
      final provider = context.read<ProductProvider>();
      await provider.loadProductReviews(widget.productId);

      if (!mounted) return;

      setState(() {
        _reviews = _convertReviews(provider.productReviews);
      });
    } catch (e) {
      debugPrint('❌ Erreur _loadReviews: $e');
    }
  }

  /// Convertit les données brutes de l'API en ReviewCardData
  List<ReviewCardData> _convertReviews(List<dynamic> raw) {
    final result = <ReviewCardData>[];

    for (final item in raw) {
      if (item is! Map) continue;

      try {
        final map = Map<String, dynamic>.from(item);

        String userName = 'Utilisateur';
        String? userAvatar;

        if (map['user'] is Map) {
          final user = map['user'] as Map;
          userName = user['name']?.toString() ?? 'Utilisateur';
          userAvatar = user['avatar']?.toString();
        } else if (map['user_name'] != null) {
          userName = map['user_name'].toString();
        }

        final images = <String>[];
        if (map['images'] is List) {
          for (final img in map['images']) {
            if (img is String) {
              images.add(img);
            } else if (img is Map && img['url'] != null) {
              images.add(img['url'].toString());
            } else if (img is Map && img['image_path'] != null) {
              images.add(img['image_path'].toString());
            }
          }
        }

        result.add(
          ReviewCardData(
            userName: userName,
            userAvatar: userAvatar,
            rating: _parseDouble(map['rating']),
            comment: map['comment']?.toString() ?? '',
            title: map['title']?.toString(),
            date: _parseDate(map['created_at']),
            isVerifiedPurchase: map['is_verified_purchase'] == true,
            helpfulCount: _parseInt(map['helpful_count']),
            notHelpfulCount: _parseInt(map['not_helpful_count']),
            images: images.isEmpty ? null : images,
          ),
        );
      } catch (e) {
        debugPrint('⚠️ Erreur conversion avis: $e');
      }
    }

    return result;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // ============================================
  // AJOUTER UN AVIS
  // ============================================

  Future<void> _handleAddReview() async {
    final reviewData = await showAddReviewSheet(context);

    if (!mounted || reviewData == null) return;

    final provider = context.read<ProductProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    final success = await provider.submitReview(
      productId: widget.productId,
      rating: reviewData.rating,
      comment: reviewData.comment,
      title: reviewData.title,
      qualityRating: reviewData.qualityRating,
      priceRating: reviewData.priceRating,
      shippingRating: reviewData.shippingRating,
      imagePaths: reviewData.images,
    );

    if (!mounted) return;

    Navigator.of(context).pop();

    if (success) {
      await _loadReviews();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Merci ! Votre avis a été publié.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
          duration: Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );

      provider.resetReviewStatus();
    } else {
      final error = provider.reviewError ?? 'Erreur lors de l\'envoi';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );

      provider.resetReviewStatus();
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
      // ✅ Masquer la bottom bar en mode aperçu vendeur
      bottomNavigationBar:
          _product != null && !_isLoading && !widget.isSellerPreview
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
                    decoration: const BoxDecoration(
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
                    decoration: const BoxDecoration(
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
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.error,
                ),
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
          // BARRE SUPÉRIEURE
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  // ✅ Masquer les actions client (favoris + partage) en mode vendeur
                  if (!widget.isSellerPreview)
                    Row(
                      children: [
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

          // GALERIE PREMIUM
          ProductGallery(
            imageUrls: imageUrls,
            height: 400,
            showThumbnails: imageUrls.length > 1,
            showDots: true,
            showCounter: imageUrls.length > 1,
            enableZoom: true,
            enableFloatingAnimation: true,
          ),

          // CONTENU PRINCIPAL
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
                  specifications:
                      _buildSpecifications(product).cast<SpecificationItem>(),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 15),

                // SECTION AVIS
                ReviewsSection(
                  averageRating: product.averageRating,
                  totalReviews: product.reviewsCount,
                  ratingDistribution: _buildRatingDistribution(),
                  reviews: _reviews,
                  onSeeAllReviews: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.allReviews,
                      arguments: {
                        'product_id': widget.productId,
                        'product_name': product.name,
                        'average_rating': product.averageRating,
                        'total_reviews': product.reviewsCount,
                      },
                    );
                  },
                  // ✅ Masquer "Ajouter un avis" en mode aperçu vendeur
                  onAddReview:
                      widget.isSellerPreview ? null : _handleAddReview,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // PRODUITS SIMILAIRES
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
                                // ✅ En mode aperçu, rester dans la même instance
                                Navigator.of(context).pushReplacementNamed(
                                  widget.isSellerPreview
                                      ? AppRoutes.sellerProductDetail
                                      : AppRoutes.productDetail,
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

          // ✅ Récemment vus : uniquement côté client
          if (!widget.isSellerPreview)
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
  // DISTRIBUTION DES NOTES
  // ============================================

  Map<int, int> _buildRatingDistribution() {
    final distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (final review in _reviews) {
      final rounded = review.rating.round().clamp(1, 5);
      distribution[rounded] = (distribution[rounded] ?? 0) + 1;
    }

    return distribution;
  }

  // ============================================
  // BOTTOM BAR STICKY (uniquement côté client)
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
      imageUrl: product.fullImageUrl.isNotEmpty
          ? product.fullImageUrl
          : product.mainImage,
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

    if (_isFavorite) {
      final success = await favoriteProvider.removeByProductId(product.id);
      if (!mounted) return;

      if (success) {
        setState(() => _isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Retiré des favoris',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20),
            duration: Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );
      }
    } else {
      final favorite = Favorite(
        id: DateTime.now().millisecondsSinceEpoch,
        productId: product.id,
        productName: product.name,
        productImage: product.fullImageUrl.isNotEmpty
            ? product.fullImageUrl
            : product.mainImage,
        productSku: product.sku,
        productPrice: product.price,
        productDiscountPrice:
            product.hasDiscount ? product.discountPrice : null,
        isInStock: product.isInStock,
        stock: product.stock,
        averageRating: product.averageRating,
        addedAt: DateTime.now(),
      );

      final success = await favoriteProvider.addFavorite(favorite);
      if (!mounted) return;

      if (success) {
        setState(() => _isFavorite = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ajouté aux favoris !',
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
      }
    }
  }

  // ============================================
  // CONSTRUIRE LES VARIANTES
  // ============================================

  List<dynamic> _buildVariants(Product product) {
    return const [];
  }

  // ============================================
  // CONSTRUIRE LES SPÉCIFICATIONS
  // ============================================

  List<SpecificationItem> _buildSpecifications(Product product) {
    return <SpecificationItem>[
      SpecificationItem(label: 'SKU', value: product.sku, icon: Icons.qr_code),
      SpecificationItem(
        label: 'Stock',
        value: '${product.stock} unités',
        icon: Icons.inventory,
      ),
      if (product.category != null)
        SpecificationItem(
          label: 'Catégorie',
          value: product.category!.name,
          icon: Icons.category,
        ),
      if (product.brand != null)
        SpecificationItem(
          label: 'Marque',
          value: product.brand!.name,
          icon: Icons.storefront,
        ),
    ];
  }
}
