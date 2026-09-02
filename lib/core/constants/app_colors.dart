// ============================================
// PALETTE DE COULEURS - SHOPPRO
// ============================================
// Design System complet basé sur le Bleu Royal.
// Palette moderne, professionnelle et chaleureuse.
// ============================================

import 'package:flutter/material.dart';

class AppColors {
  // ============================================
  // 🎨 COULEURS PRINCIPALES
  // ============================================
  
  /// Bleu Royal - Couleur principale
  /// Utilisation : Boutons principaux, prix, navigation active, liens
  static const Color primary = Color(0xFF2563EB);
  
  /// Bleu clair - État actif, hover
  static const Color primaryLight = Color(0xFF3B82F6);
  
  /// Bleu nuit - Sidebar admin, AppBar, fonds sombres
  static const Color primaryDark = Color(0xFF1E3A5F);
  
  /// Bleu très clair - Fonds légers d'info
  static const Color primarySoft = Color(0xFFDBEAFE);
  
  // ============================================
  // 🎨 COULEURS FONCTIONNELLES
  // ============================================
  
  /// Vert - Succès, disponible, livraison gratuite
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);
  
  /// Orange/Or - Étoiles, promotions, offres spéciales
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);
  
  /// Rouge - Erreurs, suppression, annulation
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);
  
  /// Corail - Promotions fortes, attention urgente
  static const Color promo = Color(0xFFFF6B6B);
  static const Color promoLight = Color(0xFFFFE4E4);
  static const Color promoDark = Color(0xFFCC3333);
  
  /// Info - Informations neutres
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E40AF);
  
  // ============================================
  // 🎨 TEXTE
  // ============================================
  
  /// Bleu nuit - Titres, texte important
  static const Color textPrimary = Color(0xFF111827);
  
  /// Gris - Descriptions, texte secondaire
  static const Color textSecondary = Color(0xFF6B7280);
  
  /// Gris clair - Texte discret
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  /// Gris très clair - Placeholder
  static const Color textLight = Color(0xFFD1D5DB);
  
  /// Blanc - Texte sur fonds colorés
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF111827);
  
  // ============================================
  // 🎨 SURFACES ET FONDS
  // ============================================
  
  /// Blanc - Fond principal
  static const Color background = Color(0xFFFFFFFF);
  
  /// Gris clair - Cartes, zones secondaires
  static const Color surface = Color(0xFFF3F4F6);
  
  /// Gris légèrement plus foncé - Surfaces alternées
  static const Color surfaceAlt = Color(0xFFF9FAFB);
  
  /// Crème - Sections chaleureuses spéciales
  static const Color cream = Color(0xFFFFF9F2);
  
  /// Gris hover
  static const Color surfaceHover = Color(0xFFF3F4F6);
  
  /// Blanc pur - Cartes sur fond gris
  static const Color card = Color(0xFFFFFFFF);
  
  // ============================================
  // 🎨 BORDURES
  // ============================================
  
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color borderColorDark = Color(0xFFD1D5DB);
  
  // ============================================
  // 🎨 COULEURS E-COMMERCE SPÉCIFIQUES
  // ============================================
  
  /// Prix actuel
  static const Color priceColor = Color(0xFF2563EB);
  
  /// Prix barré (ancien prix)
  static const Color oldPriceColor = Color(0xFF9CA3AF);
  
  /// Réduction / Promotion
  static const Color discountColor = Color(0xFFFF6B6B);
  
  /// Étoiles / Notes
  static const Color ratingColor = Color(0xFFF59E0B);
  
  /// Étoile vide
  static const Color ratingEmptyColor = Color(0xFFE5E7EB);
  
  /// Badge "Nouveau"
  static const Color badgeNewColor = Color(0xFF10B981);
  
  /// Badge "Bestseller"
  static const Color badgeBestSellerColor = Color(0xFFF59E0B);
  
  /// Badge "Vedette"
  static const Color badgeFeaturedColor = Color(0xFF3B82F6);
  
  /// Badge "Promo"
  static const Color badgePromoColor = Color(0xFFFF6B6B);
  
  // ============================================
  // 🎨 STATUTS (BADGES)
  // ============================================
  
  // En attente
  static const Color statusPendingBg = Color(0xFFFEF3C7);
  static const Color statusPendingText = Color(0xFF92400E);
  
  // Confirmé
  static const Color statusConfirmedBg = Color(0xFFDBEAFE);
  static const Color statusConfirmedText = Color(0xFF1E40AF);
  
  // Livré / Succès
  static const Color statusDeliveredBg = Color(0xFFD1FAE5);
  static const Color statusDeliveredText = Color(0xFF065F46);
  
  // Annulé / Erreur
  static const Color statusCancelledBg = Color(0xFFFEE2E2);
  static const Color statusCancelledText = Color(0xFF991B1B);
  
  // Spam
  static const Color statusSpamBg = Color(0xFFF3E8FF);
  static const Color statusSpamText = Color(0xFF6B21A8);
  
  // Inactif
  static const Color statusInactiveBg = Color(0xFFF3F4F6);
  static const Color statusInactiveText = Color(0xFF6B7280);
  
  // ============================================
  // 🎨 GRADIENTS
  // ============================================
  
  /// Gradient principal (Bleu royal → Bleu clair)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradient accueil (Blanc → Crème subtil)
  static const LinearGradient welcomeGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF9F2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  /// Gradient succès
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradient sidebar admin
  static const LinearGradient sidebarGradient = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  /// Gradient promotion (Corail → Orange)
  static const LinearGradient promoGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ============================================
  // 🎨 OMBRES
  // ============================================
  
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF111827).withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
  
  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: const Color(0xFF111827).withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
  
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF111827).withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
  
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: const Color(0xFF2563EB).withValues(alpha: 0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
  
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
}