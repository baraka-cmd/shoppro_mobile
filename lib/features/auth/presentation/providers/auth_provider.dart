// ============================================
// PROVIDER D'AUTHENTIFICATION - VERSION SENIOR
// ============================================
// Gère l'état de l'authentification avec :
// - Redirection intelligente par rôle
// - Vérification du statut du compte
// - Journalisation (debugPrint)
// - Méthodes de contrôle d'accès
// - Timeout sur l'initialisation
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
  // GETTERS DE BASE
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
// GETTERS DE STATUT (simplifié)
// ============================================

/// Vrai si le compte est actif.
bool get isActiveUser => true; // Par défaut actif (à adapter si User a un statut)

/// Vrai si le compte est banni.
bool get isBanned => false; // Par défaut non banni

/// Vrai si le compte est suspendu.
bool get isSuspended => false; // Par défaut non suspendu

/// Peut accéder aux routes admin ?
bool canAccessAdmin() => isAdmin;

/// Peut accéder aux routes vendeur ?
bool canAccessSeller() => (isSeller || isAdmin);

/// Peut accéder aux routes client ?
bool canAccessClient() => isAuthenticated;

  // ============================================
  // NOM DU RÔLE
  // ============================================

  /// Nom lisible du rôle principal pour l'affichage.
  String get roleName {
    if (isAdmin) return 'Administrateur';
    if (isSeller) return 'Vendeur';
    if (isClient) return 'Client';
    return 'Invité';
  }

  // ============================================
  // REDIRECTION PAR RÔLE
  // ============================================

  /// Retourne la route de redirection selon le rôle et le statut.
  ///
  /// Priorité : Non authentifié → Login, Banni/Suspendu → Login,
  /// Admin → /admin/dashboard, Vendeur → /seller/dashboard, Client → /home.
  String getRedirectRoute() {
    // 1. Vérifier l'authentification
    if (!isAuthenticated) {
      debugPrint('🔴 AuthProvider: Non authentifié → Login');
      return AppRoutes.login;
    }

    // 2. Vérifier le statut du compte
    if (isBanned) {
      debugPrint('🔴 AuthProvider: Compte banni → Login');
      return AppRoutes.login;
    }

    if (isSuspended) {
      debugPrint('🔴 AuthProvider: Compte suspendu → Login');
      return AppRoutes.login;
    }

    if (!isActiveUser) {
      debugPrint('🔴 AuthProvider: Compte inactif → Login');
      return AppRoutes.login;
    }

    // 3. Redirection selon le rôle
    if (isAdmin) {
      debugPrint('🟣 AuthProvider: Admin → /admin/dashboard');
      return AppRoutes.adminDashboard;
    }

    if (isSeller) {
      debugPrint('🟠 AuthProvider: Vendeur → /seller/dashboard');
      return AppRoutes.sellerDashboard;
    }

    if (isClient) {
      debugPrint('🟢 AuthProvider: Client → /home');
      return AppRoutes.home;
    }

    // 4. Rôle inconnu
    debugPrint('🔴 AuthProvider: Rôle inconnu → Login');
    return AppRoutes.login;
  }

  // ============================================
  // INITIALISATION
  // ============================================

  /// Initialise le provider en vérifiant la session locale.
  ///
  /// Vérifie si un utilisateur est stocké et restaure la session.
  /// Timeout de 5 secondes pour éviter le blocage.
  Future<void> init() async {
    _setLoading(true);
    debugPrint('🔄 AuthProvider: Initialisation...');

    try {
      final isLoggedIn = await _authRepository
          .isLoggedIn()
          .timeout(const Duration(seconds: 5));

      if (isLoggedIn) {
        final storedUser = await _authRepository
            .getStoredUser()
            .timeout(const Duration(seconds: 5));

        if (storedUser != null) {
          _user = storedUser;
          _status = AuthStatus.authenticated;
          debugPrint('✅ AuthProvider: Session restaurée - ${storedUser.name}');
        } else {
          _status = AuthStatus.unauthenticated;
          debugPrint('⚠️ AuthProvider: Aucun utilisateur stocké');
        }
      } else {
        _status = AuthStatus.unauthenticated;
        debugPrint('⚠️ AuthProvider: Pas de session active');
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      debugPrint('❌ AuthProvider: Erreur init: $e');
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
    debugPrint('🔄 AuthProvider: Inscription...');

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
      debugPrint('✅ AuthProvider: Inscription réussie - ${user.name}');
      return true;
    } catch (e) {
      _setError(e.toString());
      _status = AuthStatus.error;
      _setLoading(false);
      notifyListeners();
      debugPrint('❌ AuthProvider: Erreur inscription: $e');
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
    debugPrint('🔄 AuthProvider: Connexion...');

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
      debugPrint('✅ AuthProvider: Connexion réussie - ${roleName}');
      return true;
    } catch (e) {
      _setError(e.toString());
      _status = AuthStatus.error;
      _setLoading(false);
      notifyListeners();
      debugPrint('❌ AuthProvider: Erreur connexion: $e');
      return false;
    }
  }

  // ============================================
  // DÉCONNEXION
  // ============================================

  Future<void> logout() async {
    _setLoading(true);
    debugPrint('🔄 AuthProvider: Déconnexion...');

    try {
      await _authRepository.logout();
      debugPrint('✅ AuthProvider: Déconnexion réussie');
    } catch (e) {
      debugPrint('⚠️ AuthProvider: Erreur logout: $e');
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
      debugPrint('✅ AuthProvider: Profil mis à jour');
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      debugPrint('❌ AuthProvider: Erreur updateProfile: $e');
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
      debugPrint('✅ AuthProvider: Mot de passe changé');
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      debugPrint('❌ AuthProvider: Erreur changePassword: $e');
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
      debugPrint('✅ AuthProvider: Email envoyé');
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      debugPrint('❌ AuthProvider: Erreur forgotPassword: $e');
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

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AuthProvider(status: $_status, user: ${_user?.name ?? 'null'}, '
        'role: $roleName, active: $isActiveUser)';
  }
}