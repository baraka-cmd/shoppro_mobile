// ============================================
// CARTE D'ADRESSE - VERSION PREMIUM
// ============================================
// Affiche les informations complètes avec actions,
// badges et point de repère. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/address.dart';
import 'address_type_badge.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;
  final VoidCallback? onTap;
  final bool isSelectable;
  final bool isSelected;

  const AddressCard({
    super.key,
    required this.address,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
    this.onTap,
    this.isSelectable = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderColor.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ]
              : AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // EN-TÊTE : LABEL + BADGE DÉFAUT
            // ============================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AddressTypeBadge(type: address.type),
                    const SizedBox(width: 6),
                    if (address.label.isNotEmpty)
                      Text(
                        address.label,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                  ],
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 10,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'DÉFAUT',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // ============================================
            // NOM COMPLET
            // ============================================
            Text(
              address.fullName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 3),

            // ============================================
            // TÉLÉPHONE
            // ============================================
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  address.phone,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            // ============================================
            // EMAIL
            // ============================================
            if (address.email != null && address.email!.isNotEmpty) ...[
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    address.email!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 5),

            // ============================================
            // ADRESSE COMPLÈTE
            // ============================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    address.fullAddress,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),

            // ============================================
            // POINT DE REPÈRE
            // ============================================
            if (address.hasLandmark) ...[
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 12,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '📍 ${address.landmark}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // ============================================
            // INDICATEUR GPS
            // ============================================
            if (address.hasGps) ...[
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.gps_fixed,
                    size: 10,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Position GPS enregistrée',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],

            // ============================================
            // INSTRUCTIONS DE LIVRAISON
            // ============================================
            if (address.hasDeliveryInstructions) ...[
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 12,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      address.deliveryInstructions!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.warning,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // ============================================
            // INDICATEUR DE SÉLECTION
            // ============================================
            if (isSelectable) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textLight,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Container(
                          margin: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
              ),
            ],

            // ============================================
            // ACTIONS
            // ============================================
            if (!isSelectable &&
                (onEdit != null || onDelete != null || onSetDefault != null)) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.borderColor),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onSetDefault != null && !address.isDefault)
                    TextButton.icon(
                      onPressed: onSetDefault,
                      icon: const Icon(
                        Icons.star_border,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      label: const Text(
                        'Défaut',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Modifier',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 14,
                        color: AppColors.error,
                      ),
                      label: const Text(
                        'Supprimer',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}