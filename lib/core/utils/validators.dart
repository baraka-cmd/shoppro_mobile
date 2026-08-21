// Validateurs de formulaires
// 
// Fonctions de validation réutilisables pour les formulaires.

import 'package:email_validator/email_validator.dart';

class Validators {
  // Valider un email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'adresse email est obligatoire';
    }
    
    if (!EmailValidator.validate(value.trim())) {
      return 'L\'adresse email est invalide';
    }
    
    return null;
  }

  // Valider un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }
    
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    
    return null;
  }

  // Valider la confirmation du mot de passe
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est obligatoire';
    }
    
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }

  // Valider un nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom est obligatoire';
    }
    
    if (value.length < 3) {
      return 'Le nom doit contenir au moins 3 caractères';
    }
    
    if (value.length > 255) {
      return 'Le nom ne peut pas dépasser 255 caractères';
    }
    
    return null;
  }

  // Valider un téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }
    
    final phoneRegex = RegExp(r'^\+?[0-9\s-]{8,20}$');
    
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Le numéro de téléphone est invalide';
    }
    
    return null;
  }
}