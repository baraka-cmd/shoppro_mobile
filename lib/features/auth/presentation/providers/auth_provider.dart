// Provider d'authentification
// 
// Gère l'état de l'authentification dans l'application.
// Notifie les widgets des changements d'état.

import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

enum AuthStatus {
  initial,      // État initial
  loading,      // Chargement en cours
  authenticated, // Connecté
  unauthenticated, // Déconnecté
  error,        // Erreur
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  // 📊 État actuel
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isSeller => _user?.isSeller ?? false;
  bool get isClient => _user?.isClient ?? false;

  // Initialiser le provider
  // Vérifie si un utilisateur est déjà connecté
  Future<void> init() async {
    _setLoading(true);
    
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      
      if (isLoggedIn) {
        final storedUser = await _authRepository.getStoredUser();
        
        if (storedUser != null) {
          _user = storedUser;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Inscription
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
      );
      
      _user = user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _status = AuthStatus.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Connexion
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      
      _user = user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _status = AuthStatus.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authRepository.logout();
    } finally {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      notifyListeners();
    }
  }

  // Mettre à jour le profil
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authRepository.updateProfile(data);
      _user = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Changer le mot de passe
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Mot de passe oublié
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authRepository.forgotPassword(email);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Réinitialiser l'erreur
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Méthodes privées
  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }
}