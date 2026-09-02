// ============================================
// PROVIDER D'AUTHENTIFICATION
// ============================================
// Gère l'état de l'authentification dans l'application.
// Notifie les widgets des changements d'état.
// Inclut la redirection selon le rôle.
// ============================================

// ============================================
// IMPORTS
// ============================================
import 'package:flutter/foundation.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

// ============================================
// PROVIDER PRINCIPAL
// ============================================

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // ============================================
  // GETTERS
  // ============================================
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isSeller => _user?.isSeller ?? false;
  bool get isClient => _user?.isClient ?? false;

  // ============================================
  // REDIRECTION PAR RÔLE
  // ============================================

  /// Retourne la route de redirection selon le rôle de l'utilisateur.
  String getRedirectRoute() {
    if (isAdmin) {
      return AppRoutes.adminDashboard;
    }
    if (isSeller) {
      return AppRoutes.sellerDashboard;
    }
    return AppRoutes.home;
  }

  // ============================================
  // INITIALISATION
  // ============================================

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
      debugPrint('Erreur init AuthProvider: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // ============================================
  // INSCRIPTION
  // ============================================

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

  // ============================================
  // CONNEXION
  // ============================================

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
      debugPrint('Connexion réussie - Rôle: ${user.isAdmin ? "Admin" : user.isSeller ? "Vendeur" : "Client"}');
      return true;
    } catch (e) {
      _setError(e.toString());
      _status = AuthStatus.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // DÉCONNEXION
  // ============================================

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authRepository.logout();
    } catch (e) {
      debugPrint('Erreur logout: $e');
    } finally {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      notifyListeners();
    }
  }

  // ============================================
  // MISE À JOUR DU PROFIL
  // ============================================

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

  // ============================================
  // CHANGEMENT DE MOT DE PASSE
  // ============================================

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

  // ============================================
  // MOT DE PASSE OUBLIÉ
  // ============================================

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

  // ============================================
  // MÉTHODES UTILITAIRES
  // ============================================

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // ============================================
  // MÉTHODES PRIVÉES
  // ============================================

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