// ============================================
// PAGE : AdminUserDetailScreen
// ============================================
// Écran de détail d'un utilisateur administré.
// Design moderne avec profil et statistiques.
//
// Structure :
// - Sidebar de navigation
// - Header avec titre
// - Carte de profil
// - Statistiques d'activité
// - Commandes de l'utilisateur
// - Actions (activer, bannir, changer rôle)
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Providers (même feature admin)
import '../providers/admin_user_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_confirm_dialog.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de détail d'un utilisateur.
///
/// Affiche :
/// - Le profil complet
/// - Les statistiques d'activité
/// - L'historique des commandes
/// - Les actions de gestion
class AdminUserDetailScreen extends StatefulWidget {
  /// ID de l'utilisateur
  final int userId;

  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    // Charger les détails de l'utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<AdminUserProvider>().loadUserDetail(widget.userId);
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
Widget build(BuildContext context) {
  return AdminScaffold(
    title: 'Marques',
    subtitle: 'Gérez vos marques et partenaires',
    currentRoute: AppRoutes.adminBrands,
    onNavigate: (route) {
      if (route.isNotEmpty) {
        Navigator.of(context).pushNamed(route);
      }
    },
    onNotificationsTap: () {
      Navigator.of(context).pushNamed(AppRoutes.adminNotifications);
    },
    onLogout: () {
      // Déconnexion
    },
    child: _buildContent(),
  );
}
  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================
        // PROFIL + STATISTIQUES (2 colonnes)
        // ============================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil (1/3)
            Expanded(
              flex: 1,
              child: _buildProfileCard(),
            ),
            const SizedBox(width: 16),
            // Statistiques (2/3)
            Expanded(
              flex: 2,
              child: _buildStatsCard(),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ============================================
        // COMMANDES RÉCENTES
        // ============================================
        _buildOrdersSection(),

        const SizedBox(height: 16),

        // ============================================
        // ACTIONS
        // ============================================
        _buildActionsSection(),
      ],
    );
  }

  // ============================================
  // SECTION : PROFIL
  // ============================================

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: AppColors.mediumShadow,
            ),
            child: const Center(
              child: Text(
                'JD',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Nom
          const Text(
            'Jean Dupont',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          const Text(
            'jean@example.com',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          // Badge rôle
          _buildRoleBadge(),
          const SizedBox(height: 16),
          // Séparateur
          Container(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 16),
          // Informations
          _buildProfileInfoRow(Icons.phone_outlined, '+237 6 50 00 00 00'),
          _buildProfileInfoRow(Icons.location_on_outlined, 'Douala, Cameroun'),
          _buildProfileInfoRow(Icons.calendar_today, 'Membre depuis août 2026'),
        ],
      ),
    );
  }

  /// Badge de rôle.
  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Client',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.successDark,
        ),
      ),
    );
  }

  /// Ligne d'information du profil.
  Widget _buildProfileInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SECTION : STATISTIQUES
  // ============================================

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques d\'activité',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.receipt_long_outlined,
                label: 'Commandes',
                value: '15',
                color: AppColors.info,
                bgColor: AppColors.infoLight,
              ),
              const SizedBox(width: 12),
              _buildStatItem(
                icon: Icons.payments_outlined,
                label: 'Total dépensé',
                value: '450 000 FCFA',
                color: AppColors.success,
                bgColor: AppColors.successLight,
              ),
              const SizedBox(width: 12),
              _buildStatItem(
                icon: Icons.star_outline,
                label: 'Avis postés',
                value: '8',
                color: AppColors.secondary,
                bgColor: AppColors.warningLight,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.favorite_outline,
                label: 'Favoris',
                value: '23',
                color: const Color(0xFFEC4899),
                bgColor: const Color(0xFFFCE7F3),
              ),
              const SizedBox(width: 12),
              _buildStatItem(
                icon: Icons.login,
                label: 'Dernière connexion',
                value: 'Il y a 2 jours',
                color: AppColors.textTertiary,
                bgColor: AppColors.surfaceAlt,
              ),
              const SizedBox(width: 12),
              _buildStatItem(
                icon: Icons.access_time,
                label: 'Membre depuis',
                value: '6 mois',
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF3E8FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Item de statistique.
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // SECTION : COMMANDES RÉCENTES
  // ============================================

  Widget _buildOrdersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Commandes récentes',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Commandes de démonstration
          ...List.generate(3, (index) => _buildOrderRow(index)),
        ],
      ),
    );
  }

  /// Ligne de commande.
  Widget _buildOrderRow(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CMD-2026-${(index + 1).toString().padLeft(4, '0')}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '31 août 2026',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          _buildOrderStatusBadge(index),
          const SizedBox(width: 10),
          Text(
            '${25000 + (index * 5000)} FCFA',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Badge de statut de commande.
  Widget _buildOrderStatusBadge(int index) {
    Color bgColor;
    Color textColor;
    String label;

    switch (index) {
      case 0:
        bgColor = AppColors.statusDeliveredBg;
        textColor = AppColors.statusDeliveredText;
        label = 'Livrée';
        break;
      case 1:
        bgColor = AppColors.infoLight;
        textColor = AppColors.infoDark;
        label = 'Expédiée';
        break;
      default:
        bgColor = AppColors.statusPendingBg;
        textColor = AppColors.statusPendingText;
        label = 'En attente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ============================================
  // SECTION : ACTIONS
  // ============================================

  Widget _buildActionsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Activer',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
            onTap: () => _confirmAction('Activer cet utilisateur ?'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'Changer rôle',
            icon: Icons.swap_horiz,
            color: AppColors.info,
            onTap: () => _showRoleDialog(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'Suspendre',
            icon: Icons.pause_circle_outline,
            color: AppColors.warning,
            onTap: () => _confirmAction('Suspendre cet utilisateur ?'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'Bannir',
            icon: Icons.block,
            color: AppColors.error,
            onTap: () => _confirmBan(),
          ),
        ),
      ],
    );
  }

  /// Bouton d'action.
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // DIALOGS ET CONFIRMATIONS
  // ============================================

  Future<void> _confirmAction(String message) async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: message,
      message: 'Cette action sera enregistrée.',
      type: AdminDialogType.confirm,
      confirmLabel: 'Confirmer',
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action effectuée'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmBan() async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Bannir cet utilisateur ?',
      message: 'L\'utilisateur ne pourra plus accéder à son compte.',
      type: AdminDialogType.danger,
      confirmLabel: 'Bannir',
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur banni'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showRoleDialog() async {
    final role = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Changer le rôle',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRoleOption(dialogContext, 'Client', Icons.person_outline, 'client'),
                const SizedBox(height: 8),
                _buildRoleOption(dialogContext, 'Vendeur', Icons.storefront_outlined, 'seller'),
                const SizedBox(height: 8),
                _buildRoleOption(dialogContext, 'Admin', Icons.admin_panel_settings_outlined, 'admin'),
              ],
            ),
          ),
        );
      },
    );

    if (role != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rôle changé en $role'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Option de rôle.
  Widget _buildRoleOption(BuildContext dialogContext, String label, IconData icon, String role) {
    return Material(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => Navigator.of(dialogContext).pop(role),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}