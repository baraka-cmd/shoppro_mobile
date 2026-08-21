// Modèle pour les slides d'onboarding
// Contient les données affichées sur chaque page d'introduction

import 'package:flutter/material.dart';

class OnboardingModel {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const OnboardingModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  // Liste des slides d'onboarding
  static List<OnboardingModel> get slides => [
        const OnboardingModel(
          title: 'Bienvenue sur ShopPro',
          description:
              'Découvrez une nouvelle façon de faire vos achats en ligne. Des milliers de produits vous attendent.',
          icon: Icons.shopping_bag,
          backgroundColor: Color(0xFF2C3E50),
          iconColor: Colors.white,
        ),
        const OnboardingModel(
          title: 'Des milliers de produits',
          description:
              'Parcourez notre catalogue complet : électronique, mode, maison, beauté et bien plus encore.',
          icon: Icons.category,
          backgroundColor: Color(0xFFE67E22),
          iconColor: Colors.white,
        ),
        const OnboardingModel(
          title: 'Paiement sécurisé',
          description:
              'Payez en toute sécurité avec Mobile Money, carte bancaire ou à la livraison.',
          icon: Icons.lock,
          backgroundColor: Color(0xFF27AE60),
          iconColor: Colors.white,
        ),
        const OnboardingModel(
          title: 'Livraison rapide',
          description:
              'Recevez vos commandes rapidement partout au Cameroun et en Afrique.',
          icon: Icons.local_shipping,
          backgroundColor: Color(0xFF3498DB),
          iconColor: Colors.white,
        ),
      ];
}