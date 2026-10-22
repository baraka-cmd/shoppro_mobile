// ============================================
// PAGE : SellerPayoutsScreen
// ============================================
// Écran des versements (payouts) vendeur.
//
// Structure :
//   - Header solde (disponible + en attente)
//   - Bouton "Demander un versement"
//   - Alerte si payout en cours
//   - Filtres pills (Tous, En attente, En cours, Complétés, Échoués)
//   - Liste paginée des payouts
//   - BottomSheet demande de versement
//
// UX :
//   - Pull-to-refresh
//   - Skeleton loading
//   - Empty state
//   - Error state
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Domain
import '../../domain/entities/seller_payout.dart';

// Presentation
import '../providers/seller_payout_provider.dart';
import '../widgets/seller_scaffold.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

class SellerPayoutsScreen extends StatefulWidget {
  const SellerPayoutsScreen({super.key});

  @override
  State<SellerPayoutsScreen> createState() => _SellerPayoutsScreenState();
}

class _SellerPayoutsScreenState extends State<SellerPayoutsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SellerPayoutProvider>();
      if (provider.balanceStatus == SellerPayoutBalanceStatus.initial) {
        provider.loadAll();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      final provider = context.read<SellerPayoutProvider>();
      if (provider.hasMore && !provider.isLoadingMore && !provider.isLoading) {
        provider.loadMore();
      }
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return SellerScaffold(
      currentIndex: 3,
      title: 'Mes gains',
      subtitle: 'Gérez vos versements',
      showBackButton: false,
      child: Consumer<SellerPayoutProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            color: AppColors.warning,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ============================================
                // HEADER SOLDE
                // ============================================
                SliverToBoxAdapter(
                  child: _buildBalanceCard(provider),
                ),

                // ============================================
                // BOUTON DEMANDE
                // ============================================
                SliverToBoxAdapter(
                  child: _buildRequestButton(provider),
                ),

                // ============================================
                // ALERTE PAYOUT EN COURS
                // ============================================
                if (provider.balance.hasActivePayout)
                  SliverToBoxAdapter(
                    child: _buildActivePayoutAlert(provider),
                  ),

                // ============================================
                // FILTRES
                // ============================================
                SliverToBoxAdapter(
                  child: _buildFiltersBar(provider),
                ),

                // ============================================
                // LISTE OU EMPTY/ERROR
                // ============================================
                _buildPayoutsContent(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // CARTE SOLDE
  // ============================================

  Widget _buildBalanceCard(SellerPayoutProvider provider) {
    if (provider.isBalanceLoading &&
        provider.balanceStatus == SellerPayoutBalanceStatus.initial) {
      return _buildBalanceSkeleton();
    }

    if (provider.isBalanceUnauthorized) {
      return _buildUnauthorizedState();
    }

    if (provider.hasBalanceError &&
        provider.balanceStatus == SellerPayoutBalanceStatus.error) {
      return _buildBalanceError(provider);
    }

    final balance = provider.balance;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF59E0B),  // warning
            Color(0xFFEA580C),  // orange-600
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // HEADER
          // ============================================
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solde disponible',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Prêt à être retiré',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ============================================
          // MONTANT DISPONIBLE
          // ============================================
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              balance.availableFormatted,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ============================================
          // SÉPARATEUR
          // ============================================
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),

          const SizedBox(height: 14),

          // ============================================
          // EN ATTENTE + COMMISSION
          // ============================================
          Row(
            children: [
              Expanded(
                child: _buildBalanceInfo(
                  icon: Icons.hourglass_bottom_rounded,
                  label: 'En attente',
                  value: balance.pendingFormatted,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBalanceInfo(
                  icon: Icons.percent_rounded,
                  label: 'Commission',
                  value: '${balance.commissionRate.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceSkeleton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceError(SellerPayoutProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.balanceError ?? 'Erreur de chargement',
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
            onPressed: () => provider.loadBalance(forceRefresh: true),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ============================================
  // BOUTON DEMANDE
  // ============================================

  Widget _buildRequestButton(SellerPayoutProvider provider) {
    final balance = provider.balance;
    final canRequest = balance.isEligibleForPayout;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: canRequest ? () => _showRequestSheet(provider) : null,
          icon: provider.isRequesting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.download_rounded, size: 20),
          label: Text(
            provider.isRequesting
                ? 'En cours...'
                : balance.hasActivePayout
                    ? 'Versement en cours...'
                    : balance.hasAvailable
                        ? 'Demander un versement'
                        : 'Solde insuffisant',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.borderColor,
            disabledForegroundColor: AppColors.textTertiary,
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
  // ALERTE PAYOUT EN COURS
  // ============================================

  Widget _buildActivePayoutAlert(SellerPayoutProvider provider) {
    final active = provider.balance.activePayout;
    if (active == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Versement en cours',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.infoDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${active.amountFormatted} • ${active.requestedAtHuman ?? ''}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.info,
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
  // FILTRES
  // ============================================

  Widget _buildFiltersBar(SellerPayoutProvider provider) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: SellerPayoutFilter.values.map((filter) {
            final isActive = provider.filter == filter;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => provider.setFilter(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.warning : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    filter.label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================
  // CONTENU LISTE
  // ============================================

  Widget _buildPayoutsContent(SellerPayoutProvider provider) {
    if (provider.isLoading && provider.payouts.isEmpty) {
      return SliverToBoxAdapter(child: _buildSkeleton());
    }

    if (provider.hasError && provider.payouts.isEmpty) {
      return SliverToBoxAdapter(child: _buildErrorState(provider));
    }

    if (provider.payouts.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(provider));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == provider.payouts.length) {
            return _buildLoadMoreIndicator();
          }

          final payout = provider.payouts[index];
          final isProcessing = provider.isPerformingAction &&
              provider.lastAffectedPayout?.id == payout.id;

          return _buildPayoutTile(payout, provider, isProcessing);
        },
        childCount: provider.payouts.length + (provider.hasMore ? 1 : 0),
      ),
    );
  }

  // ============================================
  // TUILES
  // ============================================

  Widget _buildPayoutTile(
    SellerPayout payout,
    SellerPayoutProvider provider,
    bool isProcessing,
  ) {
    final statusColor = Color(payout.statusColorHex);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPayoutDetail(payout),
          borderRadius: BorderRadius.circular(14),
          child: Container(
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
              children: [
                // ============================================
                // LIGNE 1 : Référence + Statut
                // ============================================
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getMethodIcon(payout.methodIcon),
                        size: 20,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payout.reference,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            payout.methodLabel,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        payout.statusLabel,
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

                const SizedBox(height: 12),

                // ============================================
                // LIGNE 2 : Montant + Date + Actions
                // ============================================
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payout.netAmountFormatted,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (payout.hasFee)
                            Text(
                              'Frais : ${payout.feeFormatted}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          payout.requestedAtHuman ?? '',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        if (payout.isCancellable && !isProcessing)
                          GestureDetector(
                            onTap: () => _handleCancel(payout, provider),
                            child: const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Annuler',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                        if (isProcessing)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // ============================================
                // RAISON D'ÉCHEC (si applicable)
                // ============================================
                if (payout.hasFailureReason) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 12,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            payout.failureReason!,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.errorDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMethodIcon(String icon) {
    return switch (icon) {
      'phone_android' => Icons.phone_android_rounded,
      'account_balance' => Icons.account_balance_rounded,
      'paypal' => Icons.account_balance_wallet_rounded,
      'payments' => Icons.payments_rounded,
      _ => Icons.payment_rounded,
    };
  }

  // ============================================
  // ÉTATS
  // ============================================

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.warning,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(SellerPayoutProvider provider) {
    final filter = provider.filter;
    final IconData icon;
    final String title;
    final String subtitle;

    switch (filter) {
      case SellerPayoutFilter.all:
        icon = Icons.account_balance_wallet_outlined;
        title = 'Aucun versement';
        subtitle = 'Vos futurs versements apparaîtront ici.';
        break;
      case SellerPayoutFilter.pending:
        icon = Icons.hourglass_empty_rounded;
        title = 'Aucun versement en attente';
        subtitle = 'Vos demandes en attente apparaîtront ici.';
        break;
      case SellerPayoutFilter.processing:
        icon = Icons.sync_rounded;
        title = 'Aucun versement en cours';
        subtitle = 'Vos versements en traitement apparaîtront ici.';
        break;
      case SellerPayoutFilter.completed:
        icon = Icons.check_circle_outline_rounded;
        title = 'Aucun versement complété';
        subtitle = 'Vos versements effectués apparaîtront ici.';
        break;
      case SellerPayoutFilter.failed:
        icon = Icons.error_outline_rounded;
        title = 'Aucun versement échoué';
        subtitle = 'Bonne nouvelle ! Aucun échec récent.';
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: AppColors.warning),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SellerPayoutProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: AppColors.errorLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            provider.listError ?? 'Erreur de chargement',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.loadPayouts(forceRefresh: true),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text(
              'Réessayer',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthorizedState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.errorLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 36,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Session expirée',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Veuillez vous reconnecter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
            icon: const Icon(Icons.login_rounded, size: 16),
            label: const Text(
              'Se reconnecter',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // ACTIONS
  // ============================================

  Future<void> _showRequestSheet(SellerPayoutProvider provider) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RequestPayoutSheet(balance: provider.balance),
    );

    if (result == null || !mounted) return;

    final payout = await provider.requestPayout(
      amount: result['amount'] as double,
      method: result['method'] as String,
      account: result['account'] as String?,
      note: result['note'] as String?,
    );

    if (!mounted) return;

    if (payout != null) {
      _showSuccess('Demande envoyée ! Traitement sous 3-5 jours.');
    } else {
      _showError(provider.actionError ?? 'Erreur');
    }
  }

  Future<void> _handleCancel(
    SellerPayout payout,
    SellerPayoutProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Annuler le versement ?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Le versement ${payout.reference} sera annulé.',
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
              'Non',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Annuler le versement',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await provider.cancelPayout(payout.id);

    if (!mounted) return;

    if (result != null) {
      _showSuccess('Versement annulé');
    } else {
      _showError(provider.actionError ?? 'Erreur');
    }
  }

  void _showPayoutDetail(SellerPayout payout) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PayoutDetailSheet(payout: payout),
    );
  }

  // ============================================
  // HELPERS
  // ============================================

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
// BOTTOM SHEET : _RequestPayoutSheet
// ============================================

class _RequestPayoutSheet extends StatefulWidget {
  final SellerBalance balance;

  const _RequestPayoutSheet({required this.balance});

  @override
  State<_RequestPayoutSheet> createState() => _RequestPayoutSheetState();
}

class _RequestPayoutSheetState extends State<_RequestPayoutSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _accountController;
  final _noteController = TextEditingController();

  String? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.balance.available.toStringAsFixed(0),
    );
    _accountController = TextEditingController();
    _selectedMethod = widget.balance.payoutMethod ?? 'mobile_money';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final methods = [
      {
        'value': 'mobile_money',
        'label': 'Mobile Money',
        'icon': Icons.phone_android_rounded,
      },
      {
        'value': 'bank_transfer',
        'label': 'Virement bancaire',
        'icon': Icons.account_balance_rounded,
      },
      {
        'value': 'paypal',
        'label': 'PayPal',
        'icon': Icons.account_balance_wallet_rounded,
      },
    ];

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
                  'Demander un versement',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Disponible : ${widget.balance.availableFormatted}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 20),

                // Montant
                const Text(
                  'Montant à retirer',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Ex: 50000',
                    suffixText: 'FCFA',
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
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requis';
                    final amount = double.tryParse(v.trim());
                    if (amount == null) return 'Montant invalide';
                    if (amount < widget.balance.minPayoutAmount) {
                      return 'Minimum : ${widget.balance.minPayoutAmountFormatted}';
                    }
                    if (amount > widget.balance.available) {
                      return 'Solde insuffisant';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Méthode
                const Text(
                  'Méthode de versement',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Column(
                  children: methods.map((method) {
                    final isSelected = _selectedMethod == method['value'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMethod = method['value'] as String;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.warning.withValues(alpha: 0.1)
                                : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.warning
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                method['icon'] as IconData,
                                size: 20,
                                color: isSelected
                                    ? AppColors.warning
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  method['label'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: AppColors.warning,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Compte
                const Text(
                  'Compte destinataire',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _accountController,
                  decoration: InputDecoration(
                    hintText: widget.balance.payoutAccountMasked ??
                        'Numéro, IBAN ou email',
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
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      if (widget.balance.hasPayoutMethod) return null;
                      return 'Requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Note
                const Text(
                  'Note (optionnel)',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Détails...',
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
                  ),
                ),
                const SizedBox(height: 20),

                // Bouton
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).pop({
                          'amount':
                              double.parse(_amountController.text.trim()),
                          'method': _selectedMethod,
                          'account': _accountController.text.trim().isEmpty
                              ? null
                              : _accountController.text.trim(),
                          'note': _noteController.text.trim().isEmpty
                              ? null
                              : _noteController.text.trim(),
                        });
                      }
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text(
                      'Confirmer la demande',
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

// ============================================
// BOTTOM SHEET : _PayoutDetailSheet
// ============================================

class _PayoutDetailSheet extends StatelessWidget {
  final SellerPayout payout;

  const _PayoutDetailSheet({required this.payout});

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(payout.statusColorHex);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    payout.reference,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
                    payout.statusLabel,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Montant', payout.amountFormatted),
            _buildInfoRow('Frais', payout.feeFormatted),
            _buildInfoRow('Net', payout.netAmountFormatted, isBold: true),
            _buildInfoRow('Méthode', payout.methodLabel),
            if (payout.accountMasked != null)
              _buildInfoRow('Compte', payout.accountMasked!),
            _buildInfoRow('Demandé', payout.requestedAtHuman ?? '—'),
            if (payout.completedAt != null)
              _buildInfoRow('Complété', payout.completedAtHuman ?? ''),
            if (payout.hasFailureReason)
              _buildInfoRow('Échec', payout.failureReason!),
            if (payout.hasNote) _buildInfoRow('Note', payout.note!),
            if (payout.hasExternalReference)
              _buildInfoRow('Référence', payout.externalReference!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isBold ? 14 : 12.5,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: isBold ? AppColors.warning : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}