// ============================================
// PAGE : AdminReviewsScreen
// ============================================
// Écran de modération des avis clients mobile.
// Design avec cartes verticales et filtres en chips.
//
// Structure :
// - AdminScaffold (AppBar + Drawer + BottomNavBar)
// - Filtres par statut (chips scrollables)
// - Liste de cartes avis verticales
// - Actions de modération contextuelles
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
import '../providers/admin_review_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_confirm_dialog.dart';
import '../../domain/entities/admin_review.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de modération des avis mobile.
///
/// Affiche :
/// - Les avis en cartes verticales
/// - Les filtres par statut
/// - Les actions de modération
class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminReviewProvider>().loadReviews();
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Avis clients',
      subtitle: 'Modérez les avis',
      currentRoute: AppRoutes.adminReviews,
      onNavigate: (route) {
        if (route.isNotEmpty) {
          Navigator.of(context).pushNamed(route);
        }
      },
      onNotificationsTap: () {
        Navigator.of(context).pushNamed(AppRoutes.adminNotifications);
      },
      onLogout: () {},
      child: _buildContent(),
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent() {
    return Consumer<AdminReviewProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: AdminLoadingState(
              type: AdminLoadingType.list,
              itemCount: 6,
            ),
          );
        }

        if (provider.hasError) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AdminErrorState(
              message: provider.errorMessage ?? 'Erreur inconnue',
              onRetry: provider.loadReviews,
            ),
          );
        }

        return Column(
          children: [
            // ============================================
            // FILTRES PAR STATUT (CHIPS SCROLLABLES)
            // ============================================
            _buildStatusTabs(provider),

            const SizedBox(height: 8),

            // ============================================
            // LISTE DES AVIS EN CARTES
            // ============================================
            Expanded(
              child: provider.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.star_outline,
                      title: 'Aucun avis',
                      message: 'Les avis clients apparaîtront ici.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.reviews.length,
                      itemBuilder: (context, index) {
                        final review = provider.reviews[index];
                        return _buildReviewCard(review, provider);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // FILTRES PAR STATUT
  // ============================================

  Widget _buildStatusTabs(AdminReviewProvider provider) {
    final tabs = [
      {'label': 'Tous', 'status': null},
      {'label': 'En attente', 'status': 'pending'},
      {'label': 'Approuvés', 'status': 'approved'},
      {'label': 'Rejetés', 'status': 'rejected'},
      {'label': 'Spam', 'status': 'spam'},
    ];

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = provider.filterStatus?.code == tab['status'];

          return Material(
            color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                final statusCode = tab['status'] as String?;
                if (statusCode == null) {
                  provider.clearFilters();
                } else {
                  // Convertir le code en enum AdminReviewStatus
                  final status = AdminReviewStatus.fromCode(statusCode);
                  provider.filterByStatus(status);
                }
              },

              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child: Text(
                  tab['label'] as String,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // CARTE AVIS
  // ============================================

  Widget _buildReviewCard(dynamic review, AdminReviewProvider provider) {
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
          // LIGNE 1 : Avatar + Nom + Étoiles + Statut
          // ============================================
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(review.userName ?? 'U'),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'Utilisateur',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Étoiles
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < (review.rating ?? 0) ? Icons.star : Icons.star_border,
                          size: 13,
                          color: AppColors.secondary,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(review),
            ],
          ),

          const SizedBox(height: 10),

          // ============================================
          // LIGNE 2 : Contenu de l'avis
          // ============================================
          Text(
            review.content ?? '',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Produit concerné
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  review.productName ?? 'Produit',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Séparateur
          Container(height: 1, color: AppColors.borderColor),

          const SizedBox(height: 8),

          // ============================================
          // LIGNE 3 : Actions de modération
          // ============================================
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (review.isPending == true) ...[
                _buildActionButton(
                  label: 'Approuver',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  onTap: () => provider.approveReview(review.id),
                ),
                const SizedBox(width: 6),
                _buildActionButton(
                  label: 'Rejeter',
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                  onTap: () => _confirmReject(provider, review),
                ),
                const SizedBox(width: 6),
              ],
              if (review.isApproved == true) ...[
                _buildActionButton(
                  label: 'Répondre',
                  icon: Icons.reply_outlined,
                  color: AppColors.info,
                  onTap: () => _showRespondDialog(provider, review),
                ),
                const SizedBox(width: 6),
              ],
              if (review.isSpam != true)
                _buildActionButton(
                  label: 'Spam',
                  icon: Icons.report_outlined,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => provider.markAsSpam(review.id),
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
  Widget _buildStatusBadge(dynamic review) {
    Color bgColor;
    Color textColor;
    String label;

    if (review.isPending == true) {
      bgColor = AppColors.warningLight;
      textColor = AppColors.warningDark;
      label = 'En attente';
    } else if (review.isApproved == true) {
      bgColor = AppColors.successLight;
      textColor = AppColors.successDark;
      label = 'Approuvé';
    } else if (review.isRejected == true) {
      bgColor = AppColors.errorLight;
      textColor = AppColors.errorDark;
      label = 'Rejeté';
    } else if (review.isSpam == true) {
      bgColor = AppColors.statusSpamBg;
      textColor = AppColors.statusSpamText;
      label = 'Spam';
    } else {
      bgColor = AppColors.statusInactiveBg;
      textColor = AppColors.statusInactiveText;
      label = 'Inconnu';
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

  /// Extrait les initiales.
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  // ============================================
  // ACTIONS
  // ============================================

  Future<void> _confirmReject(AdminReviewProvider provider, dynamic review) async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Rejeter cet avis ?',
      message: 'L\'avis sera masqué aux clients.',
      type: AdminDialogType.warning,
      confirmLabel: 'Rejeter',
    );

    if (result == true) {
      await provider.rejectReview(review.id);
    }
  }

  Future<void> _showRespondDialog(AdminReviewProvider provider, dynamic review) async {
    final controller = TextEditingController();

    final response = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Répondre à l\'avis',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Votre réponse...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(controller.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'Envoyer',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (response != null && response.isNotEmpty) {
      await provider.respondToReview(review.id, response);
    }
  }
}