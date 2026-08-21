// Sélecteur de mode de paiement
// Permet de choisir entre différentes méthodes de paiement

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

  // Carte de méthode de paiement
  Widget _buildPaymentCard(PaymentMethodData method, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = method;
        });
        widget.onMethodSelected?.call(method);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio
            Container(
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
                    ? method.color.withValues(alpha: 0.1)
                    : AppColors.background,
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
          ],
        ),
      ),
    );
  }
}

// Données de méthode de paiement
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