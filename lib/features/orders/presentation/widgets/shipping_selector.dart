// ============================================
// SÉLECTEUR DE MODE DE LIVRAISON - PREMIUM
// ============================================
// Permet de choisir entre différentes méthodes
// avec animations et états. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ShippingSelector extends StatefulWidget {
  final List<ShippingMethodData> methods;
  final ShippingMethodData? selectedMethod;
  final ValueChanged<ShippingMethodData?>? onMethodSelected;

  const ShippingSelector({
    super.key,
    required this.methods,
    this.selectedMethod,
    this.onMethodSelected,
  });

  @override
  State<ShippingSelector> createState() => _ShippingSelectorState();
}

class _ShippingSelectorState extends State<ShippingSelector> {
  ShippingMethodData? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedMethod;
  }

  @override
  void didUpdateWidget(ShippingSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMethod != oldWidget.selectedMethod) {
      _selected = widget.selectedMethod;
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
        const Text(
          'MODE DE LIVRAISON',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 10),

        // Liste des méthodes
        ...widget.methods.map((method) {
          final isSelected = _selected?.id == method.id;
          return _buildShippingCard(method, isSelected);
        }),
      ],
    );
  }

  // ============================================
  // CARTE DE MÉTHODE DE LIVRAISON
  // ============================================

  Widget _buildShippingCard(ShippingMethodData method, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = method;
        });
        widget.onMethodSelected?.call(method);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textLight,
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

            const SizedBox(width: 10),

            // Icône
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                method.icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),

            const SizedBox(width: 10),

            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.deliveryTimeLabel,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Prix
            Text(
              method.costLabel,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: method.isFree ? AppColors.success : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// DONNÉES DE MÉTHODE DE LIVRAISON
// ============================================

class ShippingMethodData {
  final int id;
  final String name;
  final String code;
  final double cost;
  final int minDays;
  final int maxDays;
  final IconData icon;

  const ShippingMethodData({
    required this.id,
    required this.name,
    required this.code,
    this.cost = 0,
    this.minDays = 1,
    this.maxDays = 7,
    this.icon = Icons.local_shipping,
  });

  /// Livraison gratuite ?
  bool get isFree => cost <= 0;

  /// Délai formaté
  String get deliveryTimeLabel {
    if (minDays == maxDays) {
      return '$minDays jour(s)';
    }
    return '$minDays à $maxDays jours';
  }

  /// Coût formaté
  String get costLabel {
    if (isFree) return 'Gratuite';
    return '${cost.toStringAsFixed(0)} FCFA';
  }
}