// ============================================
// WIDGET : SellerOrderTimeline
// ============================================
// Timeline verticale montrant l'historique d'une commande vendeur.
//
// Design :
//   - Ligne verticale à gauche avec cercles numérotés
//   - Chaque étape = icône + label + date + description
//   - États : complété (vert), actuel (orange pulsant), à venir (gris)
//   - Connecteurs animés entre les étapes
//
// Étapes affichées :
//   1. Commande reçue         (toujours complétée)
//   2. Acceptée               (si seller_status >= accepted)
//   3. En préparation         (si seller_status >= preparing)
//   4. Expédiée               (si seller_status >= shipped)
//   5. Livrée                 (si seller_status == delivered)
//
// Cas spécial : commande annulée → affiche un état spécial
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Domain
import '../../domain/entities/seller_order.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class SellerOrderTimeline extends StatelessWidget {
  final SellerOrder order;

  const SellerOrderTimeline({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    // Cas spécial : commande annulée
    if (order.isCancelled) {
      return _buildCancelledState();
    }

    final steps = _buildSteps();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(
            children: [
              const Icon(
                Icons.timeline_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              const Text(
                'Suivi de la commande',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Étapes
          ...List.generate(steps.length, (index) {
            return _buildStep(
              step: steps[index],
              isLast: index == steps.length - 1,
            );
          }),
        ],
      ),
    );
  }

  // ============================================
  // CONSTRUCTION DES ÉTAPES
  // ============================================

  List<_TimelineStep> _buildSteps() {
    final status = order.status;
    final sellerStatus = _getDominantSellerStatus();

    // Déterminer l'index de l'étape actuelle
    int currentIndex = _getCurrentStepIndex(status, sellerStatus);

    return [
      _TimelineStep(
        icon: Icons.shopping_cart_checkout_rounded,
        label: 'Commande reçue',
        description: 'Votre commande a été passée',
        date: order.createdAt,
        state: _getStepState(0, currentIndex),
      ),
      _TimelineStep(
        icon: Icons.check_circle_outline_rounded,
        label: 'Acceptée',
        description: 'Vous avez accepté la commande',
        date: _getAcceptedDate(),
        state: _getStepState(1, currentIndex),
      ),
      _TimelineStep(
        icon: Icons.inventory_2_outlined,
        label: 'En préparation',
        description: 'Le colis est en cours de préparation',
        date: null,
        state: _getStepState(2, currentIndex),
      ),
      _TimelineStep(
        icon: Icons.local_shipping_outlined,
        label: 'Expédiée',
        description: 'Le colis a été remis au transporteur',
        date: _getShippedDate(),
        state: _getStepState(3, currentIndex),
      ),
      _TimelineStep(
        icon: Icons.check_circle_rounded,
        label: 'Livrée',
        description: 'Le colis a été remis au client',
        date: null,
        state: _getStepState(4, currentIndex),
      ),
    ];
  }

  // ============================================
  // ÉTAPE : RENDU
  // ============================================

  Widget _buildStep({
    required _TimelineStep step,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Colonne gauche : icône + ligne
          Column(
            children: [
              _buildIcon(step),
              if (!isLast) _buildConnector(step),
            ],
          ),

          const SizedBox(width: 12),

          // Colonne droite : texte
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: _buildStepContent(step),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // ICÔNE
  // ============================================

  Widget _buildIcon(_TimelineStep step) {
    final isCompleted = step.state == _StepState.completed;
    final isCurrent = step.state == _StepState.current;
    final isCancelled = step.state == _StepState.cancelled;

    Color bgColor;
    Color iconColor;
    IconData icon = step.icon;

    if (isCancelled) {
      bgColor = AppColors.error;
      iconColor = Colors.white;
      icon = Icons.cancel_rounded;
    } else if (isCompleted) {
      bgColor = AppColors.success;
      iconColor = Colors.white;
    } else if (isCurrent) {
      bgColor = AppColors.warning;
      iconColor = Colors.white;
    } else {
      bgColor = AppColors.surfaceAlt;
      iconColor = AppColors.textTertiary;
    }

    // Pulse pour l'étape actuelle
    if (isCurrent) {
      return _PulsingIcon(
        bgColor: bgColor,
        iconColor: iconColor,
        icon: icon,
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: isCompleted || isCancelled
            ? [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(icon, size: 16, color: iconColor),
    );
  }

  // ============================================
  // CONNECTEUR
  // ============================================

  Widget _buildConnector(_TimelineStep step) {
    final isCompleted = step.state == _StepState.completed;
    final isCancelled = step.state == _StepState.cancelled;

    return Expanded(
      child: Container(
        width: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isCancelled
              ? AppColors.error
              : isCompleted
                  ? AppColors.success
                  : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  // ============================================
  // CONTENU
  // ============================================

  Widget _buildStepContent(_TimelineStep step) {
    final isCompleted = step.state == _StepState.completed;
    final isCurrent = step.state == _StepState.current;
    final isUpcoming = step.state == _StepState.upcoming;

    final titleColor = isCompleted || isCurrent
        ? AppColors.textPrimary
        : AppColors.textTertiary;

    final descColor = isCompleted || isCurrent
        ? AppColors.textSecondary
        : AppColors.textLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                step.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: isCompleted || isCurrent
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: titleColor,
                ),
              ),
            ),
            if (isCurrent && !isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'En cours',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          step.description,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: descColor,
            height: 1.3,
          ),
        ),
        if (step.date != null && !isUpcoming) ...[
          const SizedBox(height: 4),
          Text(
            _formatDate(step.date!),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================
  // ÉTAT ANNULÉ
  // ============================================

  Widget _buildCancelledState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Commande annulée',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.errorDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.customerNote ?? 'Cette commande a été annulée.',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.errorDark,
                    height: 1.3,
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
  // HELPERS
  // ============================================

  /// Détermine le statut "dominant" parmi les items du vendeur.
  String _getDominantSellerStatus() {
    if (order.items.isEmpty) return 'to_accept';

    // Priorité : plus avancé en premier
    final priorities = [
      'delivered',
      'shipped',
      'ready_to_ship',
      'preparing',
      'accepted',
      'to_accept',
    ];

    for (final status in priorities) {
      if (order.items.any((i) => i.sellerStatus == status)) {
        return status;
      }
    }

    return 'to_accept';
  }

  /// Détermine l'index de l'étape actuelle.
  int _getCurrentStepIndex(String status, String sellerStatus) {
    // Basé sur le statut global
    switch (status) {
      case 'delivered':
        return 4;
      case 'shipped':
        return 3;
      case 'processing':
        // Basé sur le seller_status
        if (sellerStatus == 'ready_to_ship') return 3;
        if (sellerStatus == 'preparing') return 2;
        if (sellerStatus == 'accepted') return 1;
        return 2;
      default:
        if (sellerStatus == 'accepted') return 1;
        return 0;
    }
  }

  /// Retourne l'état d'une étape selon son index.
  _StepState _getStepState(int stepIndex, int currentIndex) {
    if (stepIndex < currentIndex) return _StepState.completed;
    if (stepIndex == currentIndex) return _StepState.current;
    return _StepState.upcoming;
  }

  /// Date d'acceptation (premier item accepté).
  DateTime? _getAcceptedDate() {
    for (final item in order.items) {
      if (item.acceptedAt != null) return item.acceptedAt;
    }
    return null;
  }

  /// Date d'expédition (premier item expédié).
  DateTime? _getShippedDate() {
    for (final item in order.items) {
      if (item.shippedAt != null) return item.shippedAt;
    }
    return null;
  }

  String _formatDate(DateTime date) {
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'aoû', 'sep', 'oct', 'nov', 'déc',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} à '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================
// CLASSE INTERNE : _TimelineStep
// ============================================

class _TimelineStep {
  final IconData icon;
  final String label;
  final String description;
  final DateTime? date;
  final _StepState state;

  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.description,
    required this.state,
    this.date,
  });
}

// ============================================
// ENUM INTERNE : _StepState
// ============================================

enum _StepState {
  completed,
  current,
  upcoming,
  cancelled,
}

// ============================================
// WIDGET : _PulsingIcon
// ============================================
// Icône pulsante pour l'étape actuelle.
// ============================================

class _PulsingIcon extends StatefulWidget {
  final Color bgColor;
  final Color iconColor;
  final IconData icon;

  const _PulsingIcon({
    required this.bgColor,
    required this.iconColor,
    required this.icon,
  });

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 0.15);
        final opacity = 0.4 + (_controller.value * 0.3);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Halo
            Transform.scale(
              scale: scale,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.bgColor.withValues(alpha: opacity * 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Icône
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: 16,
                color: widget.iconColor,
              ),
            ),
          ],
        );
      },
    );
  }
}