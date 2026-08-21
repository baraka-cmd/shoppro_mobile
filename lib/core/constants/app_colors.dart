// Palette de couleurs de l'application
// 
// Couleurs professionnelles pour ShopPro.

import 'package:flutter/material.dart';

class AppColors {
  // 🎨 Couleurs principales
  static const Color primary = Color(0xFF2C3E50);
  static const Color primaryLight = Color(0xFF34495E);
  static const Color primaryDark = Color(0xFF1A252F);
  
  // 🎨 Couleurs secondaires
  static const Color secondary = Color(0xFFE67E22);
  static const Color accent = Color(0xFF3498DB);
  
  // 🎨 Couleurs de fond
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  
  // 🎨 Couleurs de texte
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);
  
  // 🎨 Couleurs fonctionnelles
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);
  
  // 🎨 Couleurs spécifiques
  static const Color priceColor = Color(0xFFE74C3C);
  static const Color discountColor = Color(0xFF27AE60);
  static const Color ratingColor = Color(0xFFF39C12);
  static const Color badgeColor = Color(0xFFE74C3C);
  static const Color borderColor = Color(0xFFE0E0E0);
  
  // 🎨 Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}