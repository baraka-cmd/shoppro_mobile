// Widget pour un slide d'onboarding
// Version corrigée avec SingleChildScrollView pour éviter l'overflow

import 'package:flutter/material.dart';
import '../../data/models/onboarding_model.dart';

class OnboardingSlide extends StatelessWidget {
  final OnboardingModel model;

  const OnboardingSlide({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: model.backgroundColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône principale
              Container(
                width: size.width * 0.4,
                height: size.width * 0.4,
                constraints: const BoxConstraints(
                  maxWidth: 150,
                  maxHeight: 150,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  model.icon,
                  size: size.width * 0.15,
                  color: model.iconColor,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Titre
              Text(
                model.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Description
              Text(
                model.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}