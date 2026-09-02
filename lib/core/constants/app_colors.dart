// ============================================
// PALETTE DE COULEURS - SHOPPRO
// ============================================
// Design moderne et professionnel.
// 3 couleurs principales :
// - Bleu Profond (#1E3A5F) : Navigation, titres, boutons
// - Ambre Doré (#F59E0B) : Accents, badges, highlights
// - Blanc/Gris (#F8FAFC) : Fonds, cartes, espace
// ============================================

import 'package:flutter/material.dart';

class AppColors {
  // ============================================
  // 🎨 COULEUR PRINCIPALE - BLEU PROFOND
  // ============================================
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF2D4A6E);
  static const Color primaryDark = Color(0xFF0F172A);
  
  // ============================================
  // 🎨 COULEUR SECONDAIRE - AMBRE DORÉ
  // ============================================
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryLight = Color(0xFFFEF3C7);
  static const Color secondaryDark = Color(0xFF92400E);
  
  // ============================================
  // 🎨 COULEUR D'ACCENT - BLEU CLAIR
  // ============================================
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentLight = Color(0xFFDBEAFE);
  static const Color accentDark = Color(0xFF1E40AF);
  
  // ============================================
  // 🎨 COULEURS DE FOND
  // ============================================
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F5F9);
  static const Color surfaceHover = Color(0xFFF1F5F9);
  
  // ============================================
  // 🎨 COULEURS DE TEXTE
  // ============================================
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF0F172A);
  
  // ============================================
  // 🎨 COULEURS FONCTIONNELLES
  // ============================================
  
  // Succès (Vert)
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);
  
  // Avertissement (Ambre)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);
  
  // Erreur (Rouge doux)
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);
  
  // Info (Bleu)
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E40AF);
  
  // ============================================
  // 🎨 COULEURS SPÉCIFIQUES E-COMMERCE
  // ============================================
  
  // Prix
  static const Color priceColor = Color(0xFFEF4444);
  static const Color priceDiscountColor = Color(0xFF10B981);
  static const Color oldPriceColor = Color(0xFF94A3B8);
  
  // Notes et évaluations
  static const Color ratingColor = Color(0xFFF59E0B);
  static const Color ratingEmptyColor = Color(0xFFE2E8F0);
  
  // Badges
  static const Color badgeColor = Color(0xFFEF4444);
  static const Color badgeNewColor = Color(0xFF10B981);
  static const Color badgeBestSellerColor = Color(0xFFF59E0B);
  static const Color badgeFeaturedColor = Color(0xFF3B82F6);
  
  // Bordures
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color borderColorDark = Color(0xFFCBD5E1);
  
  // ============================================
  // 🎨 COULEURS ADMIN (BACKOFFICE)
  // ============================================
  static const Color adminSidebarBackground = Color(0xFF1E3A5F);
  static const Color adminSidebarActive = Color(0xFF2D4A6E);
  static const Color adminSidebarText = Color(0xFF94A3B8);
  static const Color adminSidebarTextActive = Color(0xFFFFFFFF);
  static const Color adminAccent = Color(0xFFF59E0B);
  static const Color adminLogoutColor = Color(0xFFF87171);
  static const Color adminHeaderBackground = Color(0xFFFFFFFF);
  
  // ============================================
  // 🎨 GRADIENTS
  // ============================================
  
  // Gradient principal (Bleu profond → Bleu clair)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradient accent (Ambre → Orange doux)
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradient succès (Vert)
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradient sidebar
  static const LinearGradient sidebarGradient = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ============================================
  // 🎨 OMBRES
  // ============================================
  
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
  
  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
  
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
  
  // ============================================
  // 🎨 STATUTS (Badges)
  // ============================================
  
  // Statut : En attente
  static const Color statusPendingBg = Color(0xFFFEF3C7);
  static const Color statusPendingText = Color(0xFF92400E);
  
  // Statut : Confirmé
  static const Color statusConfirmedBg = Color(0xFFDBEAFE);
  static const Color statusConfirmedText = Color(0xFF1E40AF);
  
  // Statut : Livré / Succès
  static const Color statusDeliveredBg = Color(0xFFD1FAE5);
  static const Color statusDeliveredText = Color(0xFF065F46);
  
  // Statut : Annulé / Erreur
  static const Color statusCancelledBg = Color(0xFFFEE2E2);
  static const Color statusCancelledText = Color(0xFF991B1B);
  
  // Statut : Spam / Violet
  static const Color statusSpamBg = Color(0xFFF3E8FF);
  static const Color statusSpamText = Color(0xFF6B21A8);
  
  // Statut : Inactif / Gris
  static const Color statusInactiveBg = Color(0xFFF1F5F9);
  static const Color statusInactiveText = Color(0xFF64748B);
}