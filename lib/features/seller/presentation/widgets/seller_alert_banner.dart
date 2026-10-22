// ============================================
// WIDGET : SellerAlertBanner
// ============================================
// Bannière d'alerte affichée sur le dashboard vendeur.
//
// Design :
//   - Icône colorée (selon le niveau : info / warning / danger)
//   - Message lisible
//   - Badge count (si plusieurs alertes du même type)
//   - Bouton "Agir" (optionnel) pour rediriger
//   - Animation d'entrée fluide
//
// Niveaux :
//   - info    : bleu (AppColors.info)
//   - warning : orange (AppColors.warning)
//   - danger  : rouge (AppColors.error)
//
// UX :
//   - Tap sur la bannière → action
//   - Swipe-to-dismiss possible (optionnel via Dismissible)
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Domain
import '../../domain/entities/seller_dashboard.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class SellerAlertBanner extends StatelessWidget {
  /// L'alerte à afficher.
  final DashboardAlert alert;

  /// Callback au tap (optionnel).
  final VoidCallback? onTap;

  /// Callback pour fermer la bannière (optionnel).
  final VoidCallback? onDismiss;

  /// Animation d'entrée.
  final bool animate;

  /// Index pour décaler l'animation.
  final int animationIndex;

  const SellerAlertBanner({
    super.key,
    required this.alert,
    this.onTap,
    this.onDismiss,
    this.animate = true,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = _AlertTheme.fromLevel(alert.level);

    Widget content = _buildContent(theme);

    // Animation d'entrée
    if (animate) {
      content = _AnimatedSlideIn(
        index: animationIndex,
        child: content,
      );
    }

    // Swipe-to-dismiss (si activé)
    if (onDismiss != null) {
      content = Dismissible(
        key: ValueKey('alert_${alert.type}_$animationIndex'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismiss?.call(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        child: content,
      );
    }

    return content;
  }

  // ============================================
  // CONTENU
  // ============================================

  Widget _buildContent(_AlertTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.borderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.accentColor.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // ============================================
                // ICÔNE
                // ============================================
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.iconBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _resolveIcon(),
                    size: 20,
                    color: theme.accentColor,
                  ),
                ),

                const SizedBox(width: 12),

                // ============================================
                // MESSAGE + BADGE
                // ============================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _resolveTitle(),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.accentColor,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (alert.hasCount) ...[
                            const SizedBox(width: 6),
                            _buildCountBadge(theme),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        alert.message,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // ============================================
                // FLÈCHE (si actionnable)
                // ============================================
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: theme.accentColor.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // BADGE COUNT
  // ============================================

  Widget _buildCountBadge(_AlertTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: theme.accentColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        alert.count > 99 ? '99+' : '${alert.count}',
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.1,
        ),
      ),
    );
  }

  // ============================================
  // ICÔNE
  // ============================================

  IconData _resolveIcon() {
    // Icônes basées sur le type d'alerte (envoyé par le backend)
    switch (alert.type) {
      case 'stock_low':
        return Icons.inventory_2_outlined;
      case 'stock_out':
        return Icons.error_outline_rounded;
      case 'orders_to_accept':
        return Icons.pending_actions_rounded;
      case 'orders_to_ship':
        return Icons.local_shipping_outlined;
      case 'reviews_pending':
        return Icons.rate_review_outlined;
      case 'kyc_pending':
        return Icons.verified_user_outlined;
      case 'kyc_rejected':
        return Icons.gpp_bad_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  // ============================================
  // TITRE
  // ============================================

  String _resolveTitle() {
    switch (alert.type) {
      case 'stock_low':
        return 'Stock faible';
      case 'stock_out':
        return 'Rupture de stock';
      case 'orders_to_accept':
        return 'Commandes à accepter';
      case 'orders_to_ship':
        return 'Commandes à expédier';
      case 'reviews_pending':
        return 'Avis à modérer';
      case 'kyc_pending':
        return 'KYC en attente';
      case 'kyc_rejected':
        return 'KYC refusé';
      default:
        return 'Attention';
    }
  }
}

// ============================================
// THÈME PAR NIVEAU
// ============================================

class _AlertTheme {
  final Color accentColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;

  const _AlertTheme({
    required this.accentColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
  });

  factory _AlertTheme.fromLevel(String level) {
    switch (level) {
      case 'danger':
        return const _AlertTheme(
          accentColor: AppColors.error,
          backgroundColor: AppColors.errorLight,
          borderColor: Color(0xFFFECACA),
          iconBackgroundColor: Color(0xFFFEE2E2),
        );
      case 'warning':
        return const _AlertTheme(
          accentColor: AppColors.warning,
          backgroundColor: AppColors.warningLight,
          borderColor: Color(0xFFFDE68A),
          iconBackgroundColor: Color(0xFFFEF3C7),
        );
      case 'info':
      default:
        return const _AlertTheme(
          accentColor: AppColors.info,
          backgroundColor: AppColors.infoLight,
          borderColor: Color(0xFFBFDBFE),
          iconBackgroundColor: Color(0xFFDBEAFE),
        );
    }
  }
}

// ============================================
// ANIMATION D'ENTRÉE
// ============================================

class _AnimatedSlideIn extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedSlideIn({
    required this.child,
    required this.index,
  });

  @override
  State<_AnimatedSlideIn> createState() => _AnimatedSlideInState();
}

class _AnimatedSlideInState extends State<_AnimatedSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Délai progressif basé sur l'index
    final delay = Duration(milliseconds: 80 * widget.index);

    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

// ============================================
// WIDGET : SellerAlertsList
// ============================================
// Affiche une liste d'alertes avec gestion des taps.
// ============================================

class SellerAlertsList extends StatelessWidget {
  /// Liste des alertes.
  final List<DashboardAlert> alerts;

  /// Callback quand on tape sur une alerte.
  final void Function(DashboardAlert alert)? onAlertTap;

  /// Callback quand on ferme une alerte.
  final void Function(DashboardAlert alert)? onAlertDismiss;

  const SellerAlertsList({
    super.key,
    required this.alerts,
    this.onAlertTap,
    this.onAlertDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(alerts.length, (index) {
        final alert = alerts[index];

        return SellerAlertBanner(
          alert: alert,
          animationIndex: index,
          onTap: onAlertTap != null ? () => onAlertTap!(alert) : null,
          onDismiss:
              onAlertDismiss != null ? () => onAlertDismiss!(alert) : null,
        );
      }),
    );
  }
}