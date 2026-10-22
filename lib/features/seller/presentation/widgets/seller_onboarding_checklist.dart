// ============================================
// WIDGET : SellerOnboardingChecklist
// ============================================
// Checklist d'onboarding affichée en haut du dashboard vendeur.
//
// Objectifs :
//   - Guider le vendeur à travers les 5 étapes essentielles
//   - Afficher une progression visuelle claire
//   - Fournir un CTA contextuel pour chaque étape
//   - Disparaître automatiquement quand complété
//   - Permettre de masquer manuellement
//
// Étapes (5) :
//   1. Profil boutique complété (nom + logo + description)
//   2. KYC validé
//   3. Premier produit publié
//   4. Première commande reçue
//   5. Première commande expédiée
//
// Design :
//   - Card avec gradient subtil orange
//   - Barre de progression animée
//   - Chaque étape = ligne avec checkbox + label + CTA
//   - Bouton "Masquer" en bas
//   - Animation d'entrée (slide + fade)
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Domain
import '../../domain/entities/seller_profile.dart';

// Presentation
import '../providers/seller_profile_provider.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class SellerOnboardingChecklist extends StatelessWidget {
  /// Callback quand le vendeur masque la checklist.
  final VoidCallback? onDismiss;

  /// Afficher un effet de slide à l'entrée.
  final bool animate;

  const SellerOnboardingChecklist({
    super.key,
    this.onDismiss,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerProfileProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;

        // Pas de profil → ne rien afficher
        if (profile == null) {
          return const SizedBox.shrink();
        }

        // Calculer la progression
        final steps = _computeSteps(profile);
        final completedCount = steps.where((s) => s.isCompleted).length;
        final totalCount = steps.length;
        final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
        final isCompleted = completedCount == totalCount;

        // Ne pas afficher si complété (mais laisser le parent gérer)
        if (isCompleted && !provider.profile!.isKycPending) {
          return const SizedBox.shrink();
        }

        Widget content = _buildChecklist(
          context: context,
          profile: profile,
          steps: steps,
          completedCount: completedCount,
          totalCount: totalCount,
          progress: progress,
        );

        // Animation d'entrée
        if (animate) {
          content = TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: content,
          );
        }

        return content;
      },
    );
  }

  // ============================================
  // CALCUL DES ÉTAPES
  // ============================================

  List<_OnboardingStep> _computeSteps(SellerProfile profile) {
    return [
      _OnboardingStep(
        id: 'profile_completed',
        icon: Icons.storefront_outlined,
        title: 'Complétez votre profil boutique',
        description: 'Ajoutez un logo, une description et vos coordonnées',
        isCompleted: _isProfileCompleted(profile),
        ctaLabel: 'Modifier',
        onTapRoute: AppRoutes.sellerProfile,
      ),
      _OnboardingStep(
        id: 'kyc_validated',
        icon: Icons.verified_user_outlined,
        title: 'Validez votre KYC',
        description: 'Vérifiez votre identité pour vendre en toute sécurité',
        isCompleted: profile.isKycVerified,
        ctaLabel: profile.isKycVerified ? null : 'Commencer',
        onTapRoute: AppRoutes.sellerProfile,
      ),
      _OnboardingStep(
        id: 'first_product_published',
        icon: Icons.inventory_2_outlined,
        title: 'Publiez votre premier produit',
        description: 'Ajoutez au moins un produit visible par les clients',
        isCompleted: profile.productsCount > 0,
        ctaLabel: profile.productsCount > 0 ? null : 'Créer',
        onTapRoute: AppRoutes.sellerProductForm,
      ),
      _OnboardingStep(
        id: 'first_order_received',
        icon: Icons.receipt_long_outlined,
        title: 'Recevez votre première commande',
        description: 'Un client doit commander l\'un de vos produits',
        isCompleted: profile.ordersCount > 0,
        ctaLabel: null,
      ),
      _OnboardingStep(
        id: 'first_order_shipped',
        icon: Icons.local_shipping_outlined,
        title: 'Expédiez votre première commande',
        description: 'Acceptez, préparez et expédiez avec un numéro de suivi',
        isCompleted: _hasShippedOrder(profile),
        ctaLabel: profile.ordersCount > 0 ? 'Voir' : null,
        onTapRoute: AppRoutes.sellerOrders,
      ),
    ];
  }

  bool _isProfileCompleted(SellerProfile profile) {
    return profile.shopName.isNotEmpty &&
        profile.hasDescription &&
        profile.hasLogo &&
        profile.hasPhone;
  }

  bool _hasShippedOrder(SellerProfile profile) {
    // On ne peut pas savoir directement depuis le profil
    // On utilise un heuristique : si ordersCount > 0 et (salesCount > 0)
    // → au moins une commande a été traitée
    return profile.ordersCount > 0 && profile.salesCount > 0;
  }

  // ============================================
  // CONTENU
  // ============================================

  Widget _buildChecklist({
    required BuildContext context,
    required SellerProfile profile,
    required List<_OnboardingStep> steps,
    required int completedCount,
    required int totalCount,
    required double progress,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.08),
            AppColors.warning.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // HEADER
          // ============================================
          _buildHeader(completedCount, totalCount),

          const SizedBox(height: 12),

          // ============================================
          // BARRE DE PROGRESSION
          // ============================================
          _buildProgressBar(progress, completedCount, totalCount),

          const SizedBox(height: 16),

          // ============================================
          // ÉTAPES
          // ============================================
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return _buildStepRow(
              context,
              step,
              isLast: index == steps.length - 1,
            );
          }),

          // ============================================
          // BOUTON MASQUER
          // ============================================
          if (onDismiss != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.borderColor),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: onDismiss,
                icon: const Icon(
                  Icons.visibility_off_outlined,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                label: const Text(
                  'Masquer la checklist',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================
  // HEADER
  // ============================================

  Widget _buildHeader(int completedCount, int totalCount) {
    return Row(
      children: [
        // Icône animée
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.rocket_launch_rounded,
            size: 20,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Finalisez votre boutique',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$completedCount sur $totalCount étapes complétées',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Badge count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.warning,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$completedCount/$totalCount',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // BARRE DE PROGRESSION
  // ============================================

  Widget _buildProgressBar(
    double progress,
    int completedCount,
    int totalCount,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          // Fond
          Container(
            height: 8,
            color: AppColors.background,
          ),
          // Progression animée
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.warning.withValues(alpha: 0.7),
                        AppColors.warning,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================
  // LIGNE D'ÉTAPE
  // ============================================

  Widget _buildStepRow(
    BuildContext context,
    _OnboardingStep step, {
    required bool isLast,
  }) {
    final isCompleted = step.isCompleted;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          _buildCheckbox(isCompleted),

          const SizedBox(width: 10),

          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          fontWeight: isCompleted
                              ? FontWeight.w500
                              : FontWeight.w600,
                          color: isCompleted
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                          height: 1.3,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    // CTA
                    if (!isCompleted && step.ctaLabel != null) ...[
                      const SizedBox(width: 8),
                      _buildCtaButton(context, step),
                    ],
                  ],
                ),
                if (!isCompleted && step.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.description,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool isCompleted) {
    if (isCompleted) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 14,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.5,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.circle_outlined,
          size: 10,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context, _OnboardingStep step) {
    return GestureDetector(
      onTap: () {
        if (step.onTapRoute != null) {
          Navigator.of(context).pushNamed(step.onTapRoute!);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          step.ctaLabel!,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ============================================
// CLASSE INTERNE : _OnboardingStep
// ============================================

class _OnboardingStep {
  final String id;
  final IconData icon;
  final String title;
  final String description;
  final bool isCompleted;
  final String? ctaLabel;
  final String? onTapRoute;

  const _OnboardingStep({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.isCompleted,
    this.ctaLabel,
    this.onTapRoute,
  });
}