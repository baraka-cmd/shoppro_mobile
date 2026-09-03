// ============================================
// SÉLECTEUR DE MODE DE PAIEMENT - VERSION PREMIUM
// ============================================
// Permet de choisir entre différentes méthodes
// de paiement avec animations. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentSelector extends StatefulWidget {
  final List<PaymentMethodData> methods;
  final PaymentMethodData? selectedMethod;
  final ValueChanged<PaymentMethodData?>? onMethodSelected;

  const PaymentSelector({
    super.key,
    required this.methods,
    this.selectedMethod,
    this.onMethodSelected,
  });

  @override
  State<PaymentSelector> createState() => _PaymentSelectorState();
}

class _PaymentSelectorState extends State<PaymentSelector> {
  PaymentMethodData? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedMethod;
  }

  @override
  void didUpdateWidget(PaymentSelector oldWidget) {
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
          'MODE DE PAIEMENT',
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
          return _buildPaymentCard(method, isSelected);
        }),
      ],
    );
  }

  // ============================================
  // CARTE DE MÉTHODE DE PAIEMENT
  // ============================================

  Widget _buildPaymentCard(PaymentMethodData method, bool isSelected) {
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
              ? method.color.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? method.color : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: method.color.withValues(alpha: 0.2),
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
                  color: isSelected ? method.color : AppColors.textLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: method.color,
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
                    ? method.color.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                method.icon,
                size: 20,
                color: isSelected ? method.color : AppColors.textSecondary,
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
                  if (method.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      method.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Check si sélectionné
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 18,
                color: method.color,
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// DONNÉES DE MÉTHODE DE PAIEMENT
// ============================================

class PaymentMethodData {
  final int id;
  final String name;
  final String code;
  final String? description;
  final IconData icon;
  final Color color;

  const PaymentMethodData({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.icon = Icons.payment,
    this.color = AppColors.primary,
  });
}