// ============================================
// PAGE : SellerStockDetailScreen
// ============================================
// Écran de détail complet d'un stock (vue vendeur).
//
// Structure :
//   - AppBar avec action "Ajuster"
//   - Carte produit (image, nom, SKU, prix)
//   - Jauge visuelle du stock (circulaire, %)
//   - Cartes de quantités (disponible, réservé, min, max)
//   - Carte alertes / recommandations
//   - Carte localisation (entrepôt, allée, étagère)
//   - Historique paginé des mouvements
//   - BottomSheet d'ajustement
//
// UX :
//   - Skeleton loading
//   - Error state
//   - Scroll infini pour l'historique
//   - Actions contextuelles
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Domain
import '../../domain/entities/seller_stock.dart';

// Presentation
import '../providers/seller_stock_provider.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

class SellerStockDetailScreen extends StatefulWidget {
  final int stockId;

  const SellerStockDetailScreen({
    super.key,
    required this.stockId,
  });

  @override
  State<SellerStockDetailScreen> createState() =>
      _SellerStockDetailScreenState();
}

class _SellerStockDetailScreenState extends State<SellerStockDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SellerStockProvider>();
      provider.loadStockDetail(widget.stockId);
      provider.loadStockMovements(widget.stockId, forceRefresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Nettoyer à la sortie
    Future.microtask(() {
      if (mounted) {
        context.read<SellerStockProvider>().clearCurrentStock();
      }
    });
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      final provider = context.read<SellerStockProvider>();
      if (provider.hasMoreStockMovements &&
          !provider.isLoadingStockMovements) {
        provider.loadMoreStockMovements();
      }
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerStockProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(provider),
          body: _buildBody(provider),
        );
      },
    );
  }

  // ============================================
  // APPBAR
  // ============================================

  PreferredSizeWidget _buildAppBar(SellerStockProvider provider) {
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
      ),
      title: const Text(
        'Détail du stock',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        if (provider.currentStock != null)
          IconButton(
            icon: const Icon(
              Icons.tune_rounded,
              size: 22,
              color: AppColors.textPrimary,
            ),
            onPressed: () => _showAdjustSheet(provider),
            tooltip: 'Ajuster le stock',
          ),
      ],
    );
  }

  // ============================================
  // BODY
  // ============================================

  Widget _buildBody(SellerStockProvider provider) {
    if (provider.isLoadingDetail && provider.currentStock == null) {
      return _buildSkeleton();
    }

    if (provider.detailError != null || provider.currentStock == null) {
      return _buildErrorState(provider);
    }

    final stock = provider.currentStock!;

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductCard(stock),
          const SizedBox(height: 12),
          _buildGaugeCard(stock),
          const SizedBox(height: 12),
          _buildQuantitiesCard(stock),
          if (stock.needsRestock || stock.isExpiringSoon) ...[
            const SizedBox(height: 12),
            _buildAlertsCard(stock),
          ],
          const SizedBox(height: 12),
          _buildLocationCard(stock),
          const SizedBox(height: 12),
          _buildMovementsSection(provider),
          const SizedBox(height: 24),
          _buildActionButton(provider),
        ],
      ),
    );
  }

  // ============================================
  // CARTE PRODUIT
  // ============================================

  Widget _buildProductCard(SellerStock stock) {
    final product = stock.product;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product?.hasImage == true
                  ? Image.network(
                      product!.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_outlined,
                        size: 28,
                        color: AppColors.textTertiary,
                      ),
                    )
                  : const Icon(
                      Icons.image_outlined,
                      size: 28,
                      color: AppColors.textTertiary,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.name ?? 'Produit',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product?.sku ?? '—',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (product != null)
                  Text(
                    product.priceFormatted,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CARTE JAUGE CIRCULAIRE
  // ============================================

  Widget _buildGaugeCard(SellerStock stock) {
    final statusColor = _parseHexColor(stock.statusColor);
    final max = stock.maxQuantity ?? (stock.minQuantity * 3);
    final percentage = max > 0
        ? (stock.availableQuantity / max).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Niveau de stock',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  stock.statusLabel,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Jauge visuelle
          SizedBox(
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cercle de fond
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 12,
                    backgroundColor: AppColors.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Texte au centre
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${stock.availableQuantity}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'disponibles',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Légende
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(percentage * 100).toStringAsFixed(0)}% du stock max',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              if (stock.maxQuantity != null) ...[
                const SizedBox(width: 6),
                const Text(
                  '•',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'max ${stock.maxQuantity}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // CARTE QUANTITÉS
  // ============================================

  Widget _buildQuantitiesCard(SellerStock stock) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.straighten_rounded,
                size: 16,
                color: AppColors.warning,
              ),
              SizedBox(width: 8),
              Text(
                'Quantités',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildQuantityRow(
            icon: Icons.inventory_2_outlined,
            label: 'Quantité totale',
            value: '${stock.quantity} unités',
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 10),
          _buildQuantityRow(
            icon: Icons.shopping_bag_outlined,
            label: 'Réservé (commandes)',
            value: '${stock.reservedQuantity} unités',
            color: stock.hasReserved ? AppColors.warning : AppColors.textTertiary,
          ),
          const SizedBox(height: 10),
          _buildQuantityRow(
            icon: Icons.check_circle_outline_rounded,
            label: 'Disponible à la vente',
            value: '${stock.availableQuantity} unités',
            color: _parseHexColor(stock.statusColor),
            isBold: true,
          ),
          const SizedBox(height: 10),
          _buildQuantityRow(
            icon: Icons.warning_amber_rounded,
            label: 'Seuil minimum',
            value: '${stock.minQuantity} unités',
            color: AppColors.warning,
          ),
          if (stock.maxQuantity != null) ...[
            const SizedBox(height: 10),
            _buildQuantityRow(
              icon: Icons.vertical_align_top_rounded,
              label: 'Stock maximum',
              value: '${stock.maxQuantity} unités',
              color: AppColors.info,
            ),
          ],
          if (stock.lastCountedAt != null) ...[
            const SizedBox(height: 10),
            _buildQuantityRow(
              icon: Icons.event_outlined,
              label: 'Dernier inventaire',
              value: _formatDate(stock.lastCountedAt!),
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantityRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isBold ? 12.5 : 12,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isBold ? 13 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============================================
  // CARTE ALERTES
  // ============================================

  Widget _buildAlertsCard(SellerStock stock) {
    final alerts = <Widget>[];

    if (stock.needsRestock) {
      final isOut = stock.isOutOfStock;
      alerts.add(
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isOut ? AppColors.error : AppColors.warning)
                .withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (isOut ? AppColors.error : AppColors.warning)
                  .withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isOut
                    ? Icons.error_outline_rounded
                    : Icons.warning_amber_rounded,
                size: 18,
                color: isOut ? AppColors.error : AppColors.warning,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOut ? 'Rupture de stock' : 'Stock bas',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isOut ? AppColors.error : AppColors.warningDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Réapprovisionner ${stock.recommendedRestock} unité(s) recommandé',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
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

    if (stock.isExpiringSoon) {
      if (alerts.isNotEmpty) {
        alerts.add(const SizedBox(height: 8));
      }
      alerts.add(
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.event_busy_rounded,
                size: 18,
                color: AppColors.info,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Expire bientôt : ${_formatDate(stock.expiryDate!)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                size: 16,
                color: AppColors.warning,
              ),
              SizedBox(width: 8),
              Text(
                'Alertes',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alerts,
        ],
      ),
    );
  }

  // ============================================
  // CARTE LOCALISATION
  // ============================================

  Widget _buildLocationCard(SellerStock stock) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.warning,
              ),
              SizedBox(width: 8),
              Text(
                'Localisation',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (stock.warehouse != null) ...[
            _buildLocationRow(
              icon: Icons.warehouse_outlined,
              label: 'Entrepôt',
              value: '${stock.warehouse!.name} (${stock.warehouse!.code})',
            ),
            const SizedBox(height: 10),
          ],
          if (stock.hasLocation) ...[
            _buildLocationRow(
              icon: Icons.place_outlined,
              label: 'Emplacement',
              value: stock.location!,
            ),
            const SizedBox(height: 10),
          ],
          if (stock.hasShelf) ...[
            _buildLocationRow(
              icon: Icons.grid_view_rounded,
              label: 'Étagère',
              value: stock.shelf!,
            ),
            const SizedBox(height: 10),
          ],
          if (stock.hasBin) ...[
            _buildLocationRow(
              icon: Icons.inbox_outlined,
              label: 'Bac',
              value: stock.bin!,
            ),
          ],
          if (!stock.hasLocation && !stock.hasShelf && !stock.hasBin)
            const Text(
              'Aucune localisation physique définie',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // MOUVEMENTS
  // ============================================

  Widget _buildMovementsSection(SellerStockProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(
                Icons.history_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Historique des mouvements',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (provider.stockMovements.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${provider.stockMovements.length}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (provider.isLoadingStockMovements &&
            provider.stockMovements.isEmpty)
          _buildMovementsSkeleton()
        else if (provider.stockMovementsError != null &&
            provider.stockMovements.isEmpty)
          _buildMovementsError(provider)
        else if (provider.stockMovements.isEmpty)
          _buildMovementsEmpty()
        else
          ...provider.stockMovements.map(
            (m) => _buildMovementCard(m),
          ),
        if (provider.hasMoreStockMovements)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.warning,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMovementCard(SellerStockMovement movement) {
    final color = _parseHexColor(movement.typeColor);
    final icon = _getMovementIcon(movement.type);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      movement.typeLabel,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        movement.formattedQuantity,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${movement.quantityBefore} → ${movement.quantityAfter}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (movement.hasNote) ...[
                      const SizedBox(width: 6),
                      const Text(
                        '•',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          movement.note!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            movement.createdAtHuman ?? '',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementsSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovementsEmpty() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 28,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 6),
          Text(
            'Aucun mouvement enregistré',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementsError(SellerStockProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.stockMovementsError ?? 'Erreur',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.errorDark,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            color: AppColors.error,
            onPressed: () => provider.loadStockMovements(
              widget.stockId,
              forceRefresh: true,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ============================================
  // BOUTON D'ACTION
  // ============================================

  Widget _buildActionButton(SellerStockProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: provider.isPerformingAction
              ? null
              : () => _showAdjustSheet(provider),
          icon: provider.isAdjusting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.tune_rounded, size: 20),
          label: Text(
            provider.isAdjusting ? 'En cours...' : 'Ajuster le stock',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.warning.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  // ============================================
  // BOTTOM SHEET : AJUSTEMENT
  // ============================================

  Future<void> _showAdjustSheet(SellerStockProvider provider) async {
    final stock = provider.currentStock;
    if (stock == null) return;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AdjustStockSheet(stock: stock),
    );

    if (result == null || !mounted) return;

    final adjustResult = await provider.adjustStock(
      stock.id,
      quantity: result['quantity'] as int,
      reason: result['reason'] as String,
      note: result['note'] as String?,
    );

    if (!mounted) return;

    if (adjustResult != null) {
      _showSuccess(
        'Stock ajusté : ${adjustResult.oldQuantity} → ${adjustResult.newQuantity} '
        '(${adjustResult.difference > 0 ? '+' : ''}${adjustResult.difference})',
      );
      // Recharger les mouvements
      provider.loadStockMovements(widget.stockId, forceRefresh: true);
    } else {
      _showError(provider.actionError ?? 'Erreur');
    }
  }

  // ============================================
  // SKELETON
  // ============================================

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // ERROR STATE
  // ============================================

  Widget _buildErrorState(SellerStockProvider provider) {
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
              provider.detailError ?? 'Impossible de charger le stock',
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
              onPressed: () {
                provider.loadStockDetail(widget.stockId);
                provider.loadStockMovements(
                  widget.stockId,
                  forceRefresh: true,
                );
              },
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
  // HELPERS
  // ============================================

  IconData _getMovementIcon(String type) {
    return switch (type) {
      'in' => Icons.arrow_downward_rounded,
      'out' => Icons.arrow_upward_rounded,
      'sale' => Icons.shopping_bag_outlined,
      'return' => Icons.undo_rounded,
      'adjustment' => Icons.tune_rounded,
      'transfer' => Icons.swap_horiz_rounded,
      'purchase' => Icons.local_shipping_outlined,
      _ => Icons.history_rounded,
    };
  }

  Color _parseHexColor(String hex) {
    try {
      final cleaned = hex.replaceFirst('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return AppColors.textTertiary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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
        duration: const Duration(seconds: 3),
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
}

// ============================================
// BOTTOM SHEET : _AdjustStockSheet
// ============================================

class _AdjustStockSheet extends StatefulWidget {
  final SellerStock stock;

  const _AdjustStockSheet({required this.stock});

  @override
  State<_AdjustStockSheet> createState() => _AdjustStockSheetState();
}

class _AdjustStockSheetState extends State<_AdjustStockSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  final _noteController = TextEditingController();
  String? _selectedReason;

  static const _reasons = [
    {'value': 'inventory', 'label': 'Inventaire physique'},
    {'value': 'damage', 'label': 'Produit endommagé'},
    {'value': 'return', 'label': 'Retour client'},
    {'value': 'correction', 'label': 'Correction manuelle'},
    {'value': 'other', 'label': 'Autre raison'},
  ];

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: '${widget.stock.quantity}',
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Ajuster le stock',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.stock.product?.name ?? 'Produit',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Quantité actuelle : ${widget.stock.quantity} '
                          '(dont ${widget.stock.reservedQuantity} réservées)',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nouvelle quantité totale',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Ex: 100',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    suffixText: 'unités',
                    suffixStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Quantité obligatoire';
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null) return 'Nombre invalide';
                    if (n < 0) return 'Ne peut pas être négatif';
                    if (n > 999999) return 'Maximum 999 999';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Raison de l\'ajustement',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedReason,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: 'Sélectionner une raison',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  items: _reasons
                      .map((r) => DropdownMenuItem<String>(
                            value: r['value'],
                            child: Text(
                              r['label']!,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedReason = v),
                  validator: (v) => v == null ? 'Raison obligatoire' : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Note (optionnel)',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Détails supplémentaires...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final newQty =
                            int.tryParse(_quantityController.text.trim()) ?? 0;
                        Navigator.of(context).pop({
                          'quantity': newQty,
                          'reason': _selectedReason,
                          'note': _noteController.text.trim().isEmpty
                              ? null
                              : _noteController.text.trim(),
                        });
                      }
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text(
                      'Confirmer l\'ajustement',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}