// Interface du repository d'authentification
// 
// Cette interface définit le contrat que le repository doit respecter.
// La couche domaine dépend de cette abstraction, pas de l'implémentation.

import '../entities/user.dart';

abstract class AuthRepository {
  // Inscription d'un utilisateur
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  });

  // Connexion d'un utilisateur
  Future<User> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  // Déconnexion
  Future<void> logout();

  // Récupérer le profil
  Future<User> getProfile();

  // Mettre à jour le profil
  Future<User> updateProfile(Map<String, dynamic> data);

  // Changer le mot de passe
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  // Mot de passe oublié
  Future<void> forgotPassword(String email);

  // Récupérer l'utilisateur stocké localement
  Future<User?> getStoredUser();

  // Sauvegarder l'utilisateur localement
  Future<void> saveUser(User user);

  // Supprimer l'utilisateur stocké
  Future<void> deleteStoredUser();

  // Vérifier si un utilisateur est connecté
  Future<bool> isLoggedIn();

  // Récupérer le token
  Future<String?> getToken();

  // Sauvegarder le token
  Future<void> saveToken(String token);

  // Supprimer le token
  Future<void> deleteToken();
}