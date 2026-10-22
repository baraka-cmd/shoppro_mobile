// ============================================
// ÉCRAN : SellerComingSoonScreen
// ============================================
// Écran placeholder affiché pour le vendeur tant que
// son module complet n'est pas encore développé.
//
// Objectifs :
// - Débloquer la navigation vendeur (Phase 0)
// - Informer clairement l'utilisateur
// - Proposer des actions utiles (retour, déconnexion)
// - Design mobile-first professionnel
// - Style aligné sur ShopPro (Poppins, AppColors, mobile)
//
// Ce fichier sera remplacé en Phase 5 par le vrai
// SellerDashboardScreen quand le module sera prêt.
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Routes
import '../../../../routes/app_routes.dart';

// Auth
import '../../../auth/presentation/providers/auth_provider.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran informatif affiché au vendeur pendant la construction
/// de son espace boutique.
///
/// Peut être utilisé pour n'importe quelle sous-section
/// vendeur via le paramètre [sectionName] :
/// - "Espace Vendeur" (dashboard)
/// - "Mes Produits"
/// - "Mes Commandes"
/// - "Mes Statistiques"
/// - "Mes Stocks"
class SellerComingSoonScreen extends StatelessWidget {
  /// Nom de la section (affiché dans l'AppBar).
  /// Si null, affiche "Espace Vendeur" par défaut.
  final String? sectionName;

  const SellerComingSoonScreen({super.key, this.sectionName});

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.user?.name ?? 'Vendeur';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, authProvider),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ============================================
              // ILLUSTRATION + TITRE
              // ============================================
              _buildHeroSection(userName),

              const SizedBox(height: 32),

              // ============================================
              // CARTE "BIENTÔT DISPONIBLE"
              // ============================================
              _buildFeaturesCard(),

              const SizedBox(height: 24),

              // ============================================
              // NOTE INFORMATIVE
              // ============================================
              _buildInfoNote(),

              const SizedBox(height: 32),

              // ============================================
              // ACTIONS
              // ============================================
              _buildPrimaryButton(context),

              const SizedBox(height: 12),

              _buildSecondaryButton(context, authProvider),

              const SizedBox(height: 24),

              // ============================================
              // FOOTER
              // ============================================
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // APPBAR
  // ============================================

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.textPrimary,
        ),
        onPressed: () => _handleBack(context),
        tooltip: 'Retour',
      ),
      title: Text(
        sectionName ?? 'Espace Vendeur',
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.logout_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          onPressed: () => _handleLogout(context, authProvider),
          tooltip: 'Se déconnecter',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ============================================
  // SECTION HERO (ICÔNE + TITRE)
  // ============================================

  Widget _buildHeroSection(String userName) {
    return Column(
      children: [
        // Icône circulaire avec effet glow
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.warning.withValues(alpha: 0.15),
                AppColors.warning.withValues(alpha: 0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.warning.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.storefront_rounded,
                size: 36,
                color: AppColors.warning,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Titre
        Text(
          'Bonjour $userName 👋',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 10),

        // Sous-titre
        const Text(
          'Votre espace boutique est en cours de préparation',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================
  // CARTE "BIENTÔT DISPONIBLE"
  // ============================================

  Widget _buildFeaturesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec badge
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  size: 20,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Bientôt disponible',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Liste des fonctionnalités
          _buildFeatureRow(
            icon: Icons.dashboard_rounded,
            title: 'Tableau de bord personnalisé',
            subtitle: 'Suivez vos ventes et performances en temps réel',
          ),
          _buildFeatureRow(
            icon: Icons.inventory_2_rounded,
            title: 'Gestion de votre catalogue',
            subtitle: 'Publiez et gérez vos produits en quelques clics',
          ),
          _buildFeatureRow(
            icon: Icons.receipt_long_rounded,
            title: 'Suivi des commandes',
            subtitle: 'Acceptez, préparez et expédiez vos commandes',
          ),
          _buildFeatureRow(
            icon: Icons.bar_chart_rounded,
            title: 'Statistiques détaillées',
            subtitle: 'Analysez vos performances et votre croissance',
          ),
          _buildFeatureRow(
            icon: Icons.payments_rounded,
            title: 'Gestion des gains',
            subtitle: 'Suivez vos revenus et demandez vos versements',
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// Ligne de fonctionnalité à venir.
  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                    height: 1.4,
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
  // NOTE INFORMATIVE
  // ============================================

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.info,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'En attendant, vous pouvez continuer à utiliser l\'application '
              'comme client. Vos futures données de vendeur seront conservées.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.info.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // BOUTON PRINCIPAL
  // ============================================

  Widget _buildPrimaryButton(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _handleBack(context),
        icon: const Icon(
          Icons.storefront_rounded,
          size: 20,
          color: Colors.white,
        ),
        label: const Text(
          'Continuer comme client',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ============================================
  // BOUTON SECONDAIRE (DÉCONNEXION)
  // ============================================

  Widget _buildSecondaryButton(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context, authProvider),
        icon: const Icon(
          Icons.logout_rounded,
          size: 20,
          color: AppColors.textSecondary,
        ),
        label: const Text(
          'Se déconnecter',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ============================================
  // FOOTER
  // ============================================

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.borderColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Le module vendeur sera disponible prochainement',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  // ============================================
  // ACTIONS — RETOUR
  // ============================================

  void _handleBack(BuildContext context) {
    // Le vendeur peut continuer à utiliser l'app côté client
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  // ============================================
  // ACTIONS — DÉCONNEXION
  // ============================================

  Future<void> _handleLogout(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final confirmed = await _showLogoutConfirmation(context);
    if (confirmed != true || !context.mounted) return;

    await authProvider.logout();
    if (!context.mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  // ============================================
  // DIALOG DE CONFIRMATION
  // ============================================

  Future<bool?> _showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 26,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),

                // Titre
                const Text(
                  'Se déconnecter ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Message
                const Text(
                  'Vous serez redirigé vers la page de connexion.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(
                              color: AppColors.borderColor,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Annuler',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Se déconnecter',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
  }
}