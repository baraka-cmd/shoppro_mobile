// Badge de rôle utilisateur
// Affiche le rôle avec icône, couleur et style adaptés

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/user_role.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;
  final bool showLabel;
  final bool compact;
  final bool outlined;

  const RoleBadge({
    super.key,
    required this.role,
    this.showLabel = true,
    this.compact = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : role.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: outlined
            ? Border.all(color: role.color, width: 1.5)
            : Border.all(color: role.color.withValues(alpha: 0.3), width: 1),
        boxShadow: outlined
            ? null
            : [
                BoxShadow(
                  color: role.color.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône
          Icon(
            role.icon,
            size: compact ? 12 : 14,
            color: role.color,
          ),
          
          if (showLabel) ...[
            SizedBox(width: compact ? 4 : 6),
            
            // Libellé
            Text(
              compact ? role.shortLabel : role.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.bold,
                color: role.color,
                letterSpacing: compact ? 0.5 : 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Variante : Badge de rôle avec taille personnalisée
class RoleBadgeLarge extends StatelessWidget {
  final UserRole role;

  const RoleBadgeLarge({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            role.color.withValues(alpha: 0.15),
            role.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: role.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: role.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              role.icon,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                role.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: role.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Niveau ${role.level}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: role.color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Variante : Badge de permission
class PermissionBadge extends StatelessWidget {
  final String permission;
  final bool isGranted;

  const PermissionBadge({
    super.key,
    required this.permission,
    required this.isGranted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isGranted
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGranted ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: isGranted ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 5),
          Text(
            permission,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isGranted ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}