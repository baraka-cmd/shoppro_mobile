// ============================================
// PAGE : AdminPromotionsScreen
// ============================================
// Écran de gestion des promotions administrées mobile.
// Design avec cartes verticales pleine largeur.
//
// Structure :
// - AdminScaffold (AppBar + Drawer + BottomNavBar)
// - Statistiques compactes
// - Liste de cartes promotions verticales
// - Actions contextuelles
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Providers (même feature admin)
import '../providers/admin_promotion_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_confirm_dialog.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de gestion des promotions mobile.
///
/// Affiche :
/// - Les promotions en cartes verticales
/// - Le statut de chaque promotion
/// - Les actions contextuelles
class AdminPromotionsScreen extends StatefulWidget {
  const AdminPromotionsScreen({super.key});

  @override
  State<AdminPromotionsScreen> createState() => _AdminPromotionsScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminPromotionsScreenState extends State<AdminPromotionsScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPromotionProvider>().loadPromotions();
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Promotions',
      subtitle: 'Gérez vos promotions',
      currentRoute: AppRoutes.adminPromotions,
      onNavigate: (route) {
        if (route.isNotEmpty) {
          Navigator.of(context).pushNamed(route);
        }
      },
      onNotificationsTap: () {
        Navigator.of(context).pushNamed(AppRoutes.adminNotifications);
      },
      onLogout: () {},
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: _buildContent(),
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent() {
    return Consumer<AdminPromotionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: AdminLoadingState(
              type: AdminLoadingType.list,
              itemCount: 5,
            ),
          );
        }

        if (provider.hasError) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AdminErrorState(
              message: provider.errorMessage ?? 'Erreur inconnue',
              onRetry: provider.loadPromotions,
            ),
          );
        }

        return Column(
          children: [
            // ============================================
            // STATISTIQUES COMPACTES
            // ============================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.surface,
              child: Row(
                children: [
                  _buildCompactStat(
                    label: 'Total',
                    value: provider.promotionsCount,
                    color: AppColors.info,
                  ),
                  _buildCompactStat(
                    label: 'Actives',
                    value: provider.activeCount,
                    color: AppColors.success,
                  ),
                  _buildCompactStat(
                    label: 'À venir',
                    value: provider.upcomingCount,
                    color: AppColors.warning,
                  ),
                  _buildCompactStat(
                    label: 'Expirées',
                    value: provider.expiredCount,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ============================================
            // LISTE DES PROMOTIONS EN CARTES
            // ============================================
            Expanded(
              child: provider.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.local_offer_outlined,
                      title: 'Aucune promotion',
                      message: 'Créez votre première promotion.',
                      actionLabel: 'Nouvelle promotion',
                      onAction: () => _navigateToCreate(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.promotions.length,
                      itemBuilder: (context, index) {
                        final promotion = provider.promotions[index];
                        return _buildPromotionCard(promotion, provider);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Statistique compacte.
  Widget _buildCompactStat({
    required String label,
    required int value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
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

  // ============================================
  // CARTE PROMOTION
  // ============================================

  Widget _buildPromotionCard(dynamic promotion, AdminPromotionProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // LIGNE 1 : Icône + Nom + Statut + Modifier
          // ============================================
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPromotionColor(promotion).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_offer_outlined,
                  size: 20,
                  color: _getPromotionColor(promotion),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promotion.name ?? 'Promotion',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      promotion.discountValueFormatted ?? '',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(promotion),
              IconButton(
                onPressed: () => _navigateToEdit(promotion),
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.info),
                tooltip: 'Modifier',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ============================================
          // LIGNE 2 : Période
          // ============================================
          Text(
            promotion.periodFormatted ?? '',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: 10),

          // Séparateur
          Container(height: 1, color: AppColors.borderColor),

          const SizedBox(height: 8),

          // ============================================
          // LIGNE 3 : Actions contextuelles
          // ============================================
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (promotion.isCurrentlyActive == true)
                _buildActionButton(
                  label: 'Pause',
                  icon: Icons.pause_circle_outline,
                  color: AppColors.warning,
                  onTap: () => provider.pausePromotion(promotion.id),
                ),
              if (promotion.isPaused == true)
                _buildActionButton(
                  label: 'Reprendre',
                  icon: Icons.play_circle_outline,
                  color: AppColors.success,
                  onTap: () => provider.resumePromotion(promotion.id),
                ),
              if (promotion.isUpcoming == true || promotion.isExpired == true)
                _buildActionButton(
                  label: 'Activer',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  onTap: () => provider.activatePromotion(promotion.id),
                ),
              const SizedBox(width: 6),
              _buildActionButton(
                label: 'Annuler',
                icon: Icons.cancel_outlined,
                color: AppColors.error,
                onTap: () => _confirmCancelPromotion(provider, promotion),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Petit bouton d'action.
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Badge de statut.
  Widget _buildStatusBadge(dynamic promotion) {
    Color bgColor;
    Color textColor;
    String label;

    if (promotion.isCurrentlyActive == true) {
      bgColor = AppColors.successLight;
      textColor = AppColors.successDark;
      label = 'Active';
    } else if (promotion.isUpcoming == true) {
      bgColor = AppColors.infoLight;
      textColor = AppColors.infoDark;
      label = 'À venir';
    } else if (promotion.isExpired == true) {
      bgColor = AppColors.statusInactiveBg;
      textColor = AppColors.statusInactiveText;
      label = 'Expirée';
    } else if (promotion.isPaused == true) {
      bgColor = AppColors.warningLight;
      textColor = AppColors.warningDark;
      label = 'Pause';
    } else {
      bgColor = AppColors.errorLight;
      textColor = AppColors.errorDark;
      label = 'Annulée';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  /// Couleur selon le statut.
  Color _getPromotionColor(dynamic promotion) {
    if (promotion.isCurrentlyActive == true) return AppColors.success;
    if (promotion.isUpcoming == true) return AppColors.info;
    if (promotion.isExpired == true) return AppColors.textTertiary;
    if (promotion.isPaused == true) return AppColors.warning;
    return AppColors.error;
  }

  // ============================================
  // NAVIGATION ET ACTIONS
  // ============================================

  void _navigateToCreate() {
    Navigator.of(context).pushNamed(AppRoutes.adminPromotionForm);
  }

  void _navigateToEdit(dynamic promotion) {
    Navigator.of(context).pushNamed(
      AppRoutes.adminPromotionForm,
      arguments: {'promotion_id': promotion.id},
    );
  }

  Future<void> _confirmCancelPromotion(AdminPromotionProvider provider, dynamic promotion) async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Annuler cette promotion ?',
      message: 'Cette promotion sera définitivement annulée.',
      type: AdminDialogType.danger,
      confirmLabel: 'Annuler la promotion',
    );

    if (result == true) {
      await provider.cancelPromotion(promotion.id);
    }
  }
}