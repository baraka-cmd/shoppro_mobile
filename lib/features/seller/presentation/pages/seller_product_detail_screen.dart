// ============================================
// PAGE : SellerProductDetailScreen
// ============================================
// Écran de détail produit en mode vendeur (wrapper).
//
// Rôle :
//   - Orchestrer l'aperçu vendeur du produit
//   - Afficher un bandeau "Vous êtes le vendeur"
//   - Fournir les actions vendeur (Modifier, Publier, Dupliquer, etc.)
//   - Intégrer le ProductDetailScreen client (mode preview)
//   - Afficher les statistiques détaillées du produit
//
// Architecture :
//   ┌──────────────────────────────────────┐
//   │  AppBar vendeur (retour + actions)   │
//   ├──────────────────────────────────────┤
//   │  Bandeau "Vous êtes le vendeur"      │
//   ├──────────────────────────────────────┤
//   │  ProductDetailScreen (client preview)│
//   │  - Galerie, variations, description  │
//   │  - Avis (sans bouton "ajouter")      │
//   │  - Sans panier, sans favoris         │
//   ├──────────────────────────────────────┤
//   │  Stats vendeur (vues, ventes, note)  │
//   └──────────────────────────────────────┘
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Domain
import '../../domain/entities/seller_product.dart';

// Products (client)
import '../../../products/presentation/pages/product_detail_screen.dart';

// Presentation
import '../providers/seller_product_provider.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

class SellerProductDetailScreen extends StatefulWidget {
  /// ID du produit à afficher.
  final int productId;

  const SellerProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<SellerProductDetailScreen> createState() =>
      _SellerProductDetailScreenState();
}

class _SellerProductDetailScreenState extends State<SellerProductDetailScreen> {
  // ============================================
  // ÉTAT
  // ============================================

  SellerProduct? _product;
  bool _isLoading = true;
  bool _isPerformingAction = false;
  String? _errorMessage;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<SellerProductProvider>();
      final product = await provider.loadProductById(widget.productId);

      if (!mounted) return;

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
    } catch (e) {
      debugPrint('❌ Erreur _loadProduct: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ============================================
  // APPBAR
  // ============================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Retour',
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Aperçu produit',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (_product != null)
            Text(
              _product!.statusLabel,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(_product!),
              ),
            ),
        ],
      ),
      actions: [
        if (_product != null && !_isLoading) ...[
          // Bouton "Modifier"
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              size: 22,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Modifier le produit',
            onPressed: _isPerformingAction ? null : _handleEdit,
          ),

          // Menu d'actions
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 22,
              color: AppColors.textPrimary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColors.background,
            elevation: 4,
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => _buildMenuItems(),
          ),
        ],
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    final product = _product;
    if (product == null) return [];

    final items = <PopupMenuEntry<String>>[];

    // Éditer
    items.add(
      _buildMenuItem(
        value: 'edit',
        icon: Icons.edit_outlined,
        label: 'Modifier',
      ),
    );

    // Publier / Dépublier
    if (product.isDraft) {
      items.add(
        _buildMenuItem(
          value: 'publish',
          icon: Icons.publish_rounded,
          label: 'Publier',
          color: AppColors.success,
        ),
      );
    } else if (product.isPublished) {
      items.add(
        _buildMenuItem(
          value: 'unpublish',
          icon: Icons.unpublished_rounded,
          label: 'Dépublier',
          color: AppColors.warning,
        ),
      );
    }

    // Dupliquer
    items.add(
      _buildMenuItem(
        value: 'duplicate',
        icon: Icons.copy_all_rounded,
        label: 'Dupliquer',
      ),
    );

    // Archiver (si pas encore vendu)
    if (product.canBeDeleted) {
      items.add(
        _buildMenuItem(
          value: 'delete',
          icon: Icons.delete_outline_rounded,
          label: 'Archiver',
          color: AppColors.error,
        ),
      );
    }

    return items;
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color ?? AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // BODY
  // ============================================

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null || _product == null) {
      return _buildErrorState();
    }

    return Stack(
      children: [
        // Contenu principal
        Column(
          children: [
            _buildSellerBanner(),
            Expanded(
              child: ProductDetailScreen(
                productId: widget.productId,
                isSellerPreview: true,
              ),
            ),
          ],
        ),

        // Loader overlay pendant une action
        if (_isPerformingAction)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.warning,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================
  // BANDEAU VENDEUR
  // ============================================

  Widget _buildSellerBanner() {
    final product = _product!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.15),
            AppColors.warning.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne 1 : Titre + badge
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode aperçu vendeur',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Voici ce que les clients voient',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(product),
            ],
          ),

          const SizedBox(height: 12),

          // Ligne 2 : Stats rapides
          Row(
            children: [
              _buildQuickStat(
                icon: Icons.visibility_outlined,
                value: product.formattedViewsCount,
                label: 'vues',
              ),
              const SizedBox(width: 16),
              _buildQuickStat(
                icon: Icons.shopping_bag_outlined,
                value: product.formattedSalesCount,
                label: 'ventes',
              ),
              const SizedBox(width: 16),
              _buildQuickStat(
                icon: Icons.star_rounded,
                value: product.averageRatingFormatted,
                label: 'note',
                iconColor: AppColors.ratingColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String value,
    required String label,
    Color? iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: iconColor ?? AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(SellerProduct product) {
    Color bgColor;
    Color textColor;
    String label;

    if (product.isArchived) {
      bgColor = AppColors.statusInactiveBg;
      textColor = AppColors.statusInactiveText;
      label = 'Archivé';
    } else if (product.isPublished) {
      bgColor = AppColors.statusDeliveredBg;
      textColor = AppColors.statusDeliveredText;
      label = 'Publié';
    } else {
      bgColor = AppColors.statusPendingBg;
      textColor = AppColors.statusPendingText;
      label = 'Brouillon';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ============================================
  // ÉTATS : LOADING & ERROR
  // ============================================

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.warning,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Chargement du produit...',
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? 'Une erreur est survenue',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProduct,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Réessayer',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ACTIONS
  // ============================================

  void _handleEdit() {
    Navigator.of(context).pushNamed(
      AppRoutes.sellerProductForm,
      arguments: {'product': _product},
    ).then((result) {
      if (result != null && mounted) {
        _loadProduct();
      }
    });
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'edit':
        _handleEdit();
        break;
      case 'publish':
        await _handlePublish();
        break;
      case 'unpublish':
        await _handleUnpublish();
        break;
      case 'duplicate':
        await _handleDuplicate();
        break;
      case 'delete':
        await _handleDelete();
        break;
    }
  }

  Future<void> _handlePublish() async {
    final product = _product!;

    // Vérifications préalables
    if (!product.canBePublished) {
      final reason = product.price <= 0
          ? 'Le prix doit être supérieur à 0.'
          : product.categoryId == null
              ? 'La catégorie est obligatoire.'
              : product.imagesCount == 0
                  ? 'Ajoutez au moins une image avant de publier.'
                  : 'Le produit ne peut pas être publié.';
      _showError(reason);
      return;
    }

    final confirmed = await _showConfirmation(
      title: 'Publier le produit ?',
      message: 'Le produit sera visible par les clients après publication.',
      confirmLabel: 'Publier',
      confirmColor: AppColors.success,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isPerformingAction = true);

    final provider = context.read<SellerProductProvider>();
    final result = await provider.publishProduct(product.id);

    if (!mounted) return;

    setState(() => _isPerformingAction = false);

    if (result != null) {
      _showSuccess('Produit publié avec succès');
      _loadProduct();
    } else {
      _showError(provider.actionError ?? 'Erreur lors de la publication');
    }
  }

  Future<void> _handleUnpublish() async {
    final confirmed = await _showConfirmation(
      title: 'Dépublier le produit ?',
      message:
          'Le produit ne sera plus visible par les clients mais restera dans vos données.',
      confirmLabel: 'Dépublier',
      confirmColor: AppColors.warning,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isPerformingAction = true);

    final provider = context.read<SellerProductProvider>();
    final result = await provider.unpublishProduct(_product!.id);

    if (!mounted) return;

    setState(() => _isPerformingAction = false);

    if (result != null) {
      _showSuccess('Produit dépublié');
      _loadProduct();
    } else {
      _showError(provider.actionError ?? 'Erreur lors de la dépublication');
    }
  }

  Future<void> _handleDuplicate() async {
    final confirmed = await _showConfirmation(
      title: 'Dupliquer le produit ?',
      message:
          'Une copie sera créée en brouillon. Vous pourrez la modifier avant de la publier.',
      confirmLabel: 'Dupliquer',
      confirmColor: AppColors.warning,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isPerformingAction = true);

    final provider = context.read<SellerProductProvider>();
    final result = await provider.duplicateProduct(_product!.id);

    if (!mounted) return;

    setState(() => _isPerformingAction = false);

    if (result != null) {
      _showSuccess('Produit dupliqué');
      Navigator.of(context).pop();
    } else {
      _showError(provider.actionError ?? 'Erreur lors de la duplication');
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await _showConfirmation(
      title: 'Archiver le produit ?',
      message:
          'Le produit sera archivé et ne sera plus visible. Cette action est réversible.',
      confirmLabel: 'Archiver',
      confirmColor: AppColors.error,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isPerformingAction = true);

    final provider = context.read<SellerProductProvider>();
    final success = await provider.deleteProduct(_product!.id);

    if (!mounted) return;

    setState(() => _isPerformingAction = false);

    if (success) {
      _showSuccess('Produit archivé');
      Navigator.of(context).pop();
    } else {
      _showError(provider.actionError ?? 'Erreur lors de l\'archivage');
    }
  }

  // ============================================
  // HELPERS UI
  // ============================================

  Future<bool?> _showConfirmation({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: confirmColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getStatusColor(SellerProduct product) {
    if (product.isArchived) return AppColors.statusInactiveText;
    if (product.isPublished) return AppColors.statusDeliveredText;
    return AppColors.statusPendingText;
  }
}