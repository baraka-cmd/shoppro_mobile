// Widget d'affichage du prix
// Affiche le prix avec formatage, devise et options de style

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PriceDisplay extends StatelessWidget {
  final double price;
  final String currency;
  final PriceDisplaySize size;
  final PriceDisplayStyle style;
  final bool showCurrency;
  final bool showDecimal;
  final bool bold;
  final Color? customColor;

  const PriceDisplay({
    super.key,
    required this.price,
    this.currency = 'FCFA',
    this.size = PriceDisplaySize.medium,
    this.style = PriceDisplayStyle.normal,
    this.showCurrency = true,
    this.showDecimal = false,
    this.bold = true,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPrice = _formatPrice();
    final textColor = _getColor();

    return Text(
      formattedPrice,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: _getFontSize(),
        fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        color: textColor,
        letterSpacing: 0.3,
      ),
    );
  }

  // Formater le prix
  String _formatPrice() {
    final formatted = showDecimal
        ? price.toStringAsFixed(2)
        : price.toStringAsFixed(0);

    // Ajouter les séparateurs de milliers
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : null;

    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      buffer.write(integerPart[i]);
      if ((integerPart.length - 1 - i) % 3 == 0 && i != integerPart.length - 1) {
        buffer.write(' ');
      }
    }

    if (decimalPart != null) {
      buffer.write('.$decimalPart');
    }

    if (showCurrency) {
      buffer.write(' $currency');
    }

    return buffer.toString();
  }

  // Taille selon le style
  double _getFontSize() {
    switch (size) {
      case PriceDisplaySize.small:
        return 12;
      case PriceDisplaySize.medium:
        return 16;
      case PriceDisplaySize.large:
        return 20;
      case PriceDisplaySize.extraLarge:
        return 24;
    }
  }

  // Couleur selon le style
  Color _getColor() {
    if (customColor != null) return customColor!;

    switch (style) {
      case PriceDisplayStyle.normal:
        return AppColors.primary;
      case PriceDisplayStyle.discount:
        return AppColors.error;
      case PriceDisplayStyle.old:
        return AppColors.textLight;
      case PriceDisplayStyle.success:
        return AppColors.success;
    }
  }
}

// Taille du prix
enum PriceDisplaySize {
  small,
  medium,
  large,
  extraLarge,
}

// Style du prix
enum PriceDisplayStyle {
  normal,     // Bleu foncé
  discount,   // Rouge
  old,        // Gris (barré)
  success,    // Vert
}