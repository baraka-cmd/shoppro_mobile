// ============================================
// PAGE : AdminOrderDetailScreen
// ============================================
// Écran de détail d'une commande administrée.
// Design moderne avec timeline et actions.
//
// Structure :
// - Sidebar de navigation
// - Header avec titre
// - Résumé de la commande
// - Items de la commande
// - Timeline de suivi
// - Actions (confirmer, expédier, livrer, annuler)
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
import '../providers/admin_order_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_confirm_dialog.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de détail d'une commande.
///
/// Affiche :
/// - Le résumé complet de la commande
/// - Les articles commandés
/// - La timeline de suivi
/// - Les actions possibles selon le statut
class AdminOrderDetailScreen extends StatefulWidget {
  /// ID de la commande
  final int orderId;

  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    // Charger les détails de la commande
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<AdminOrderProvider>().loadOrderDetail(widget.orderId);
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
        // RÉSUMÉ DE LA COMMANDE
        // ============================================
        _buildSummarySection(),

        const SizedBox(height: 16),

        // ============================================
        // ARTICLES + TIMELINE (2 colonnes)
        // ============================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Articles (2/3)
            Expanded(
              flex: 2,
              child: _buildItemsSection(),
            ),
            const SizedBox(width: 16),
            // Timeline (1/3)
            Expanded(
              flex: 1,
              child: _buildTimelineSection(),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ============================================
        // INFORMATIONS CLIENT ET LIVRAISON
        // ============================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildCustomerSection(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildShippingSection(),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ============================================
        // ACTIONS
        // ============================================
        _buildActionsSection(),
      ],
    );
  }

  // ============================================
  // SECTION : RÉSUMÉ
  // ============================================

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // Statut
          _buildSummaryItem(
            icon: Icons.info_outline,
            label: 'Statut',
            value: 'En attente',
            color: AppColors.warning,
            bgColor: AppColors.warningLight,
          ),
          const SizedBox(width: 16),
          // Paiement
          _buildSummaryItem(
            icon: Icons.payments_outlined,
            label: 'Paiement',
            value: 'Non payé',
            color: AppColors.error,
            bgColor: AppColors.errorLight,
          ),
          const SizedBox(width: 16),
          // Total
          _buildSummaryItem(
            icon: Icons.receipt_long_outlined,
            label: 'Total',
            value: '85 000 FCFA',
            color: AppColors.primary,
            bgColor: AppColors.infoLight,
          ),
          const SizedBox(width: 16),
          // Date
          _buildSummaryItem(
            icon: Icons.calendar_today,
            label: 'Date',
            value: '31 août 2026',
            color: AppColors.textTertiary,
            bgColor: AppColors.surfaceAlt,
          ),
        ],
      ),
    );
  }

  /// Élément de résumé.
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // SECTION : ARTICLES
  // ============================================

  Widget _buildItemsSection() {
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
            'Articles commandés',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Items de démonstration
          ...List.generate(3, (index) => _buildOrderItem(index)),
          const SizedBox(height: 12),
          // Sous-total et total
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildTotalRow('Sous-total', '75 000 FCFA'),
                const SizedBox(height: 6),
                _buildTotalRow('Livraison', '5 000 FCFA'),
                const SizedBox(height: 6),
                _buildTotalRow('Taxe', '5 000 FCFA'),
                const SizedBox(height: 10),
                Container(
                  height: 1,
                  color: AppColors.borderColor,
                ),
                const SizedBox(height: 10),
                _buildTotalRow('Total', '85 000 FCFA', isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Item de commande.
  Widget _buildOrderItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produit ${index + 1}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Quantité: 2',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${25000 + (index * 10000)} FCFA',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Ligne de total.
  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
            color: isTotal ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ============================================
  // SECTION : TIMELINE
  // ============================================

  Widget _buildTimelineSection() {
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
            'Suivi de la commande',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            icon: Icons.receipt_long_outlined,
            label: 'Commande passée',
            date: '31 août 2026 - 10:00',
            isCompleted: true,
            isCurrent: false,
          ),
          _buildTimelineItem(
            icon: Icons.hourglass_empty,
            label: 'En attente de confirmation',
            date: '31 août 2026 - 10:05',
            isCompleted: true,
            isCurrent: false,
          ),
          _buildTimelineItem(
            icon: Icons.check_circle_outline,
            label: 'Confirmée',
            date: 'En attente...',
            isCompleted: false,
            isCurrent: true,
          ),
          _buildTimelineItem(
            icon: Icons.local_shipping_outlined,
            label: 'Expédiée',
            date: 'À venir',
            isCompleted: false,
            isCurrent: false,
          ),
          _buildTimelineItem(
            icon: Icons.home_outlined,
            label: 'Livrée',
            date: 'À venir',
            isCompleted: false,
            isCurrent: false,
          ),
        ],
      ),
    );
  }

  /// Item de timeline.
  Widget _buildTimelineItem({
    required IconData icon,
    required String label,
    required String date,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    final color = isCompleted
        ? AppColors.success
        : isCurrent
            ? AppColors.warning
            : AppColors.textLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? color.withOpacity(0.1)
                    : AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            if (label != 'Livrée')
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? AppColors.success : AppColors.borderColor,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: isCompleted || isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isCompleted || isCurrent ? AppColors.textPrimary : AppColors.textLight,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // SECTION : CLIENT
  // ============================================

  Widget _buildCustomerSection() {
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
            'Informations client',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person_outline, 'Jean Dupont'),
          _buildInfoRow(Icons.email_outlined, 'jean@example.com'),
          _buildInfoRow(Icons.phone_outlined, '+237 6 50 00 00 00'),
          _buildInfoRow(Icons.location_on_outlined, 'Douala, Cameroun'),
        ],
      ),
    );
  }

  /// Ligne d'information.
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SECTION : LIVRAISON
  // ============================================

  Widget _buildShippingSection() {
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
            'Adresse de livraison',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Akwa, Douala\nCameroun',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_shipping_outlined, size: 14, color: AppColors.info),
                SizedBox(width: 6),
                Text(
                  'Livraison standard',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.infoDark,
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
  // SECTION : ACTIONS
  // ============================================

  Widget _buildActionsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Confirmer',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
            onTap: () => _confirmAction('Confirmer cette commande ?'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'Expédier',
            icon: Icons.local_shipping_outlined,
            color: AppColors.info,
            onTap: () => _confirmAction('Expédier cette commande ?'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'Livrer',
            icon: Icons.home_outlined,
            color: AppColors.primary,
            onTap: () => _confirmAction('Marquer comme livrée ?'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'Annuler',
            icon: Icons.cancel_outlined,
            color: AppColors.error,
            onTap: () => _confirmCancel(),
          ),
        ),
      ],
    );
  }

  /// Bouton d'action principal.
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
  // CONFIRMATIONS
  // ============================================

  Future<void> _confirmAction(String message) async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: message,
      message: 'Cette action sera enregistrée dans l\'historique.',
      type: AdminDialogType.confirm,
      confirmLabel: 'Confirmer',
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action effectuée avec succès'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmCancel() async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Annuler cette commande ?',
      message: 'Cette action est irréversible.',
      type: AdminDialogType.danger,
      confirmLabel: 'Annuler la commande',
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande annulée'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}