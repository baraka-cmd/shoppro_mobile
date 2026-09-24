// ============================================
// ÉCRAN DE PROFIL UTILISATEUR - VERSION PREMIUM
// ============================================
// Affiche les informations, statistiques, menu
// et déconnexion. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../favorites/presentation/providers/favorite_provider.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_stats_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();
    final orderProvider = context.watch<OrderProvider>();

    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.cream,

      // ============================================
      // APP BAR
      // ============================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),

        title: const Text(
          'Mon Profil',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        // ============================================
        // NOTIFICATIONS
        // ============================================
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.notifications,
              );
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none,
                  color: AppColors.textPrimary,
                  size: 22,
                ),

                if (notificationProvider.unreadCount > 0)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        notificationProvider.unreadCount > 9
                            ? '9+'
                            : '${notificationProvider.unreadCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      // ============================================
      // CONTENU
      // ============================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // EN-TÊTE DU PROFIL
            // ============================================
            ProfileHeader(
              name: user?.fullName ?? 'Utilisateur',
              email: user?.email ?? 'email@example.com',
              avatarUrl: user?.avatar,
              role: user?.roles.isNotEmpty == true
                  ? user!.roles.first
                  : 'Client',

              onEdit: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.editProfile,
                );
              },

              onAvatarTap: () {
                _showAvatarDialog(
                  context,
                  user?.avatar,
                  user?.fullName ?? '',
                );
              },
            ),

            const SizedBox(height: 20),

            // ============================================
            // STATISTIQUES
            // ============================================
            Row(
              children: [
                // ========================================
                // COMMANDES
                // ========================================
                Expanded(
                  child: ProfileStatsCard(
                    icon: Icons.shopping_bag_outlined,
                    value: '${orderProvider.ordersCount}',
                    label: 'Commandes',
                    iconColor: AppColors.primary,
                    iconBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.1),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.orders,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // ========================================
                // FAVORIS
                // ========================================
                Expanded(
                  child: ProfileStatsCard(
                    icon: Icons.favorite_outline,
                    value: '${favoriteProvider.favoritesCount}',
                    label: 'Favoris',
                    iconColor: AppColors.error,
                    iconBackgroundColor:
                        AppColors.error.withValues(alpha: 0.1),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.favorites,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // ========================================
                // TOTAL DÉPENSÉ
                // ========================================
                Expanded(
                  child: ProfileStatsCard(
                    icon: Icons.wallet_outlined,
                    value: _formatAmount(
                      user?.totalSpent ?? 0,
                    ),
                    label: 'Dépensé',
                    iconColor: AppColors.success,
                    iconBackgroundColor:
                        AppColors.success.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ============================================
            // SECTION MES ACTIVITÉS
            // ============================================
            const Text(
              'MES ACTIVITÉS',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // ============================================
            // MES COMMANDES
            // ============================================
            ProfileMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Mes commandes',
              subtitle: 'Voir l\'historique de vos achats',
              iconColor: AppColors.primary,
              iconBackgroundColor:
                  AppColors.primary.withValues(alpha: 0.1),
              badge: '${orderProvider.ordersCount}',
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.orders,
                );
              },
            ),

            const SizedBox(height: 10),

            // ============================================
            // MES FAVORIS
            // ============================================
            ProfileMenuItem(
              icon: Icons.favorite_outline,
              title: 'Mes favoris',
              subtitle: 'Vos produits sauvegardés',
              iconColor: AppColors.error,
              iconBackgroundColor:
                  AppColors.error.withValues(alpha: 0.1),
              badge: '${favoriteProvider.favoritesCount}',
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.favorites,
                );
              },
            ),

            const SizedBox(height: 10),

            // ============================================
            // MES ADRESSES
            // ============================================
            ProfileMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Mes adresses',
              subtitle: 'Gérer vos adresses de livraison',
              iconColor: AppColors.info,
              iconBackgroundColor:
                  AppColors.info.withValues(alpha: 0.1),
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.addresses,
                );
              },
            ),

            const SizedBox(height: 25),

            // ============================================
            // SECTION SÉCURITÉ
            // ============================================
            const Text(
              'SÉCURITÉ',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // ============================================
            // CHANGER MOT DE PASSE
            // ============================================
            ProfileMenuItem(
              icon: Icons.lock_outline,
              title: 'Changer mot de passe',
              subtitle: 'Modifier votre mot de passe',
              iconColor: AppColors.primary,
              iconBackgroundColor:
                  AppColors.primary.withValues(alpha: 0.1),
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.changePassword,
                );
              },
            ),

            const SizedBox(height: 10),

            // ============================================
            // NOTIFICATIONS
            // ============================================
            ProfileMenuItem(
              icon: Icons.notifications_none,
              title: 'Notifications',
              subtitle: notificationProvider.unreadCount > 0
                  ? '${notificationProvider.unreadCount} non lue(s)'
                  : 'Gérer vos notifications',
              iconColor: AppColors.info,
              iconBackgroundColor:
                  AppColors.info.withValues(alpha: 0.1),
              badge: notificationProvider.unreadCount > 0
                  ? '${notificationProvider.unreadCount}'
                  : null,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.notifications,
                );
              },
            ),

            const SizedBox(height: 25),

            // ============================================
            // SECTION SUPPORT
            // ============================================
            const Text(
              'SUPPORT',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // ============================================
            // AIDE & SUPPORT
            // ============================================
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Aide & Support',
              subtitle: 'FAQ, assistance et contact',
              iconColor: AppColors.info,
              iconBackgroundColor:
                  AppColors.info.withValues(alpha: 0.1),
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.support,
                );
              },
            ),

            const SizedBox(height: 10),

            // ============================================
            // CONDITIONS D'UTILISATION
            // ============================================
            ProfileMenuItem(
              icon: Icons.description_outlined,
              title: 'Conditions d\'utilisation',
              subtitle: 'Consultez les conditions de ShopPro',
              iconColor: AppColors.textSecondary,
              iconBackgroundColor: AppColors.surface,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.termsConditions,
                );
              },
            ),

            const SizedBox(height: 10),

            // ============================================
            // POLITIQUE DE CONFIDENTIALITÉ
            // ============================================
            ProfileMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Politique de confidentialité',
              subtitle: 'Comment vos données sont utilisées',
              iconColor: AppColors.textSecondary,
              iconBackgroundColor: AppColors.surface,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.privacyPolicy,
                );
              },
            ),

            const SizedBox(height: 10),

            // ============================================
            // À PROPOS
            // ============================================
            ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'À propos de ShopPro',
              subtitle: 'Version 1.0.0',
              iconColor: AppColors.textSecondary,
              iconBackgroundColor: AppColors.surface,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.about,
                );
              },
            ),

            const SizedBox(height: 30),

            // ============================================
            // BOUTON DÉCONNEXION
            // ============================================
            ProfileMenuItem(
              icon: Icons.logout,
              title: 'Se déconnecter',
              iconColor: AppColors.error,
              iconBackgroundColor:
                  AppColors.error.withValues(alpha: 0.1),
              isDestructive: true,
              showArrow: false,
              onTap: () {
                _showLogoutDialog(
                  context,
                  authProvider,
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================
  // FORMATEUR DE MONTANT
  // ============================================

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }

    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }

    return amount.toStringAsFixed(0);
  }

  // ============================================
  // DIALOG AVATAR
  // ============================================

  void _showAvatarDialog(
    BuildContext context,
    String? avatarUrl,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ========================================
                  // AVATAR AGRANDI
                  // ========================================
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: avatarUrl != null &&
                            avatarUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return _buildAvatarFallback(
                                  name,
                                );
                              },
                            ),
                          )
                        : _buildAvatarFallback(name),
                  ),

                  const SizedBox(height: 15),

                  // ========================================
                  // NOM
                  // ========================================
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // ============================================
              // BOUTON FERMER
              // ============================================
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================
  // FALLBACK POUR L'AVATAR
  // ============================================

  Widget _buildAvatarFallback(String name) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty
              ? name[0].toUpperCase()
              : '?',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  // ============================================
  // DIALOG DÉCONNEXION
  // ============================================

  void _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          // ==========================================
          // TITRE
          // ==========================================
          title: const Text(
            'Se déconnecter ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          // ==========================================
          // MESSAGE
          // ==========================================
          content: const Text(
            'Vous devrez vous reconnecter pour accéder à votre compte.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          // ==========================================
          // ACTIONS
          // ==========================================
          actions: [
            // ========================================
            // ANNULER
            // ========================================
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // ========================================
            // DÉCONNEXION
            // ========================================
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                await authProvider.logout();

                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Déconnexion',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}