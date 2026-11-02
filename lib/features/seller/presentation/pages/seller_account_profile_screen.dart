import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/seller_scaffold.dart';

/// Profil personnel du compte vendeur, distinct des informations de la boutique.
class SellerAccountProfileScreen extends StatelessWidget {
  const SellerAccountProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return SellerScaffold(
      currentIndex: -1,
      title: 'Mon profil',
      subtitle: 'Informations de votre compte vendeur',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.borderColor.withValues(alpha: 0.6),
              ),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.warning.withValues(alpha: 0.12),
                  backgroundImage: user?.avatar != null
                      ? NetworkImage(user!.avatar!)
                      : null,
                  child: user?.avatar == null
                      ? const Icon(
                          Icons.person_outline,
                          size: 34,
                          color: AppColors.warning,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? 'Vendeur',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'Adresse e-mail non renseignée',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _AccountInfoTile(
            icon: Icons.phone_outlined,
            label: 'Téléphone',
            value: user?.phone,
          ),
          _AccountInfoTile(
            icon: Icons.location_city_outlined,
            label: 'Ville',
            value: user?.city,
          ),
          _AccountInfoTile(
            icon: Icons.public_outlined,
            label: 'Pays',
            value: user?.country,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Modifier mes informations'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountInfoTile extends StatelessWidget {
  const _AccountInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value?.trim().isNotEmpty == true
        ? value!.trim()
        : 'Non renseigné';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
