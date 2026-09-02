// Écran de profil utilisateur complet
// Affiche les informations, statistiques, menu et déconnexion

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_stats_card.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigation vers paramètres
            },
            icon: const Icon(
              Icons.settings,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du profil
            ProfileHeader(
              name: user?.fullName ?? 'Utilisateur',
              email: user?.email ?? 'email@example.com',
              avatarUrl: user?.avatar,
              role: user?.roles.isNotEmpty == true
                  ? user!.roles.first
                  : 'Client',
              onEdit: () {
                Navigator.of(context).pushNamed(AppRoutes.editProfile);
              },
              onAvatarTap: () {
                _showAvatarDialog(context, user?.avatar, user?.fullName ?? '');
              },
            ),
            
            const SizedBox(height: 20),
            
            // Statistiques
            Row(
              children: [
                Expanded(
                  child: ProfileStatsCard(
                    icon: Icons.shopping_bag,
                    value: '${user?.totalOrders ?? 0}',
                    label: 'Commandes',
                    iconColor: AppColors.primary,
                    iconBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.orders);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ProfileStatsCard(
                    icon: Icons.favorite,
                    value: '${authProvider.user?.totalOrders ?? 0}',
                    label: 'Favoris',
                    iconColor: AppColors.error,
                    iconBackgroundColor: AppColors.error.withValues(alpha: 0.1),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.favorites);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ProfileStatsCard(
                    icon: Icons.wallet,
                    value: _formatAmount(user?.totalSpent ?? 0),
                    label: 'Dépensé',
                    iconColor: AppColors.success,
                    iconBackgroundColor: AppColors.success.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 25),
            
            // Section Mes Activités
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
            
            ProfileMenuItem(
              icon: Icons.shopping_bag,
              title: 'Mes commandes',
              subtitle: 'Voir l\'historique de vos achats',
              iconColor: AppColors.primary,
              iconBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
              badge: '${user?.totalOrders ?? 0}',
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.orders);
              },
            ),
            
            const SizedBox(height: 10),
            
            ProfileMenuItem(
              icon: Icons.favorite,
              title: 'Mes favoris',
              subtitle: 'Vos produits sauvegardés',
              iconColor: AppColors.error,
              iconBackgroundColor: AppColors.error.withValues(alpha: 0.1),
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.favorites);
              },
            ),
            
            const SizedBox(height: 10),
            
            ProfileMenuItem(
              icon: Icons.star,
              title: 'Mes avis',
              subtitle: 'Les avis que vous avez laissés',
              iconColor: AppColors.warning,
              iconBackgroundColor: AppColors.warning.withValues(alpha: 0.1),
              onTap: () {
                // TODO: Navigation vers avis
              },
            ),
            
            const SizedBox(height: 10),
            
            ProfileMenuItem(
              icon: Icons.location_on,
              title: 'Mes adresses',
              subtitle: 'Gérer vos adresses de livraison',
              iconColor: AppColors.info,
              iconBackgroundColor: AppColors.info.withValues(alpha: 0.1),
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.addresses);
              },
            ),
            
            const SizedBox(height: 25),
            
            // Section Paramètres
            const Text(
              'PARAMÈTRES',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
            
            const SizedBox(height: 12),
            
            ProfileMenuItem(
              icon: Icons.lock,
              title: 'Changer mot de passe',
              subtitle: 'Modifier votre mot de passe',
              iconColor: AppColors.primary,
              iconBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.changePassword);
              },
            ),
            
            const SizedBox(height: 10),
            
            ProfileMenuItem(
              icon: Icons.language,
              title: 'Langue',
              subtitle: 'Français',
              iconColor: AppColors.warning,
              iconBackgroundColor: AppColors.warning.withValues(alpha: 0.1),
              onTap: () {
                // TODO: Navigation vers langue
              },
            ),
            
            const SizedBox(height: 10),
            
            ProfileMenuItem(
              icon: Icons.dark_mode,
              title: 'Mode sombre',
              subtitle: 'Désactivé',
              iconColor: AppColors.primaryDark,
              iconBackgroundColor: AppColors.primaryDark.withValues(alpha: 0.1),
              onTap: () {
                // TODO: Toggle mode sombre
              },
            ),
            
            const SizedBox(height: 10),
            
            ProfileMenuItem(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Gérer vos notifications',
              iconColor: AppColors.info,
              iconBackgroundColor: AppColors.info.withValues(alpha: 0.1),
              onTap: () {
                // TODO: Navigation vers notifications
              },
            ),
            
            const SizedBox(height: 25),
            
            // Section Support
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
            
            ProfileMenuItem(
              icon: Icons.help,
              title: 'Aide & Support',
              subtitle: 'FAQ, contactez-nous',
              iconColor: AppColors.info,
              iconBackgroundColor: AppColors.info.withValues(alpha: 0.1),
              onTap: () {
                // TODO: Navigation vers support
              },
            ),
            
            const SizedBox(height: 10),
            
            ProfileMenuItem(
              icon: Icons.description,
              title: 'Conditions d\'utilisation',
              iconColor: AppColors.textSecondary,
              iconBackgroundColor: AppColors.background,
              onTap: () {
                // TODO: Navigation vers CGU
              },
            ),
            
            const SizedBox(height: 10),
            
            ProfileMenuItem(
              icon: Icons.info,
              title: 'À propos de ShopPro',
              subtitle: 'Version 1.0.0',
              iconColor: AppColors.textSecondary,
              iconBackgroundColor: AppColors.background,
              onTap: () {
                // TODO: Navigation vers à propos
              },
            ),
            
            const SizedBox(height: 30),
            
            // Bouton Déconnexion
            ProfileMenuItem(
              icon: Icons.logout,
              title: 'Se déconnecter',
              iconColor: AppColors.error,
              iconBackgroundColor: AppColors.error.withValues(alpha: 0.1),
              isDestructive: true,
              showArrow: false,
              onTap: () {
                _showLogoutDialog(context, authProvider);
              },
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Formater le montant
  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  // Dialog pour afficher l'avatar en grand
  void _showAvatarDialog(BuildContext context, String? avatarUrl, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(dialogContext).pop(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 15),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dialog de confirmation de déconnexion
  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Se déconnecter ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
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
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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