// ============================================
// BOUTON DE PARTAGE - VERSION PREMIUM
// ============================================
// Dialog de partage avec options multiples :
// copier le lien, WhatsApp, Facebook, SMS.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product.dart';

class ShareButton extends StatelessWidget {
  final Product product;
  final VoidCallback? onShared;
  final bool showLabel;

  const ShareButton({
    super.key,
    required this.product,
    this.onShared,
    this.showLabel = false,
  });

  @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () => _showShareDialog(context),
    child: const Icon(
      Icons.share_outlined,
      size: 18,
      color: AppColors.textPrimary,
    ),
  );
}
  // ============================================
  // DIALOG DE PARTAGE
  // ============================================

  void _showShareDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Partager le produit',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 15),

              // Informations produit
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.formattedCurrentPrice,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1),

              // Options de partage
              _buildShareOption(
                sheetContext,
                icon: Icons.link,
                label: 'Copier le lien',
                color: AppColors.primary,
                onTap: () => _copyLink(sheetContext),
              ),
              _buildShareOption(
                sheetContext,
                icon: Icons.chat,
                label: 'Partager sur WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => _copyLink(sheetContext),
              ),
              _buildShareOption(
                sheetContext,
                icon: Icons.facebook,
                label: 'Partager sur Facebook',
                color: const Color(0xFF1877F2),
                onTap: () => _copyLink(sheetContext),
              ),
              _buildShareOption(
                sheetContext,
                icon: Icons.sms,
                label: 'Partager par SMS',
                color: AppColors.warning,
                onTap: () => _copyLink(sheetContext),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ============================================
  // OPTION DE PARTAGE
  // ============================================

  Widget _buildShareOption(
    BuildContext sheetContext, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 18,
        color: AppColors.textLight,
      ),
      onTap: onTap,
    );
  }

  // ============================================
  // COPIER LE LIEN
  // ============================================

  void _copyLink(BuildContext sheetContext) {
    final link = 'https://shoppro.cd/product/${product.slug}';

    Clipboard.setData(ClipboardData(text: link));

    Navigator.of(sheetContext).pop();

    // SnackBar
    ScaffoldMessenger.of(sheetContext).showSnackBar(
      SnackBar(
        content: Text(
          'Lien copié : $link',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    onShared?.call();
  }
}