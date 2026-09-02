// ============================================
// MODÈLE POUR LES SLIDES D'ONBOARDING
// ============================================
// Design inspiré des grandes applications (Food Express, Airbnb).
// Chaque slide contient :
// - Une grande illustration
// - Un fond organique (blob) aux couleurs pastel
// - Un titre court et percutant
// - Une description brève
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';

// ============================================
// MODÈLE PRINCIPAL
// ============================================

class OnboardingModel {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Chemin de l'image d'illustration (grande, format large)
  final String imagePath;

  /// Titre court et percutant
  final String title;

  /// Description brève (1-2 lignes max)
  final String description;

  /// Couleur du blob (fond organique derrière l'image)
  final Color blobColor;

  /// Couleur d'accent (pour le dot actif et les détails)
  final Color accentColor;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const OnboardingModel({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.blobColor,
    required this.accentColor,
  });

  // ============================================
  // SLIDES D'ONBOARDING (4 slides)
  // ============================================

  static List<OnboardingModel> get slides => [
        // ============================================
        // SLIDE 1 : Découverte e-commerce
        // ============================================
        const OnboardingModel(
          imagePath: 'assets/images/onboarding/slide1.jpg',
          title: 'Achetez en toute\nsimplicité',
          description:
              'Des milliers de produits sélectionnés\npour vous, livrés à votre porte.',
          blobColor: Color(0xFFDBEAFE), // Bleu pastel très léger
          accentColor: Color(0xFF2563EB), // Bleu Royal
        ),

        // ============================================
        // SLIDE 2 : Livraison rapide
        // ============================================
        const OnboardingModel(
          imagePath: 'assets/images/onboarding/slide2.jpg',
          title: 'Livraison rapide\net fiable',
          description:
              'Recevez vos commandes en un temps\nrecord partout au Cameroun.',
          blobColor: Color(0xFFD1FAE5), // Vert pastel très léger
          accentColor: Color(0xFF10B981), // Vert succès
        ),

        // ============================================
        // SLIDE 3 : Paiement sécurisé
        // ============================================
        const OnboardingModel(
          imagePath: 'assets/images/onboarding/slide3.jpg',
          title: 'Paiement 100%\nsécurisé',
          description:
              'Mobile Money, carte bancaire ou\nà la livraison. Vous choisissez.',
          blobColor: Color(0xFFFEF3C7), // Orange pastel très léger
          accentColor: Color(0xFFF59E0B), // Orange/Or
        ),

        // ============================================
        // SLIDE 4 : Bienvenue / Commencer
        // ============================================
        const OnboardingModel(
          imagePath: 'assets/images/onboarding/slide4.jpg',
          title: 'Prêt à commencer\nvotre shopping ?',
          description:
              'Créez votre compte et découvrez\nune nouvelle expérience d\'achat.',
          blobColor: Color(0xFFFFE4E4), // Corail pastel très léger
          accentColor: Color(0xFFFF6B6B), // Corail
        ),
      ];
}