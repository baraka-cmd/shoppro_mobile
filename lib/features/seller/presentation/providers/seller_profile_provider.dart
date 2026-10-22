// ============================================
// PROVIDER : SellerProfileProvider
// ============================================
// Gestion d'état pour le profil boutique vendeur.
//
// Responsabilités :
//   - Charger le profil au démarrage
//   - Mettre à jour les informations du profil
//   - Uploader le logo et la bannière
//   - Soumettre le KYC
//   - Gérer les erreurs
//   - Cache local du profil (évite les rechargements)
//
// Pattern :
//   - ChangeNotifier (Provider)
//   - États via enums
//   - Notification listeners après chaque changement
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Domain
import '../../domain/entities/seller_profile.dart';

// Data
import '../../data/sources/seller_profile_api.dart';

// ============================================
// ENUMS
// ============================================

enum SellerProfileStatus {
  initial,
  loading,
  loaded,
  error,
  forbidden,
  unauthorized,
}

enum SellerProfileActionStatus {
  idle,
  updating,
  uploadingLogo,
  uploadingBanner,
  submittingKyc,
  error,
}

// ============================================
// PROVIDER PRINCIPAL
// ============================================

class SellerProfileProvider extends ChangeNotifier {
  final SellerProfileApi _api;

  SellerProfileProvider({SellerProfileApi? api})
      : _api = api ?? SellerProfileApi();

  // ============================================
  // ÉTAT : PROFIL
  // ============================================

  SellerProfileStatus _status = SellerProfileStatus.initial;
  SellerProfile? _profile;
  String? _errorMessage;
  String? _kycStatus;

  // ============================================
  // ÉTAT : ACTION
  // ============================================

  SellerProfileActionStatus _actionStatus = SellerProfileActionStatus.idle;
  String? _actionError;
  String? _actionSuccessMessage;

  // ============================================
  // GETTERS : PROFIL
  // ============================================

  SellerProfileStatus get status => _status;
  SellerProfile? get profile => _profile;
  String? get errorMessage => _errorMessage;
  String? get kycStatus => _kycStatus;

  bool get isLoading => _status == SellerProfileStatus.loading;
  bool get isLoaded => _status == SellerProfileStatus.loaded;
  bool get hasError => _status == SellerProfileStatus.error;
  bool get isForbidden => _status == SellerProfileStatus.forbidden;
  bool get isUnauthorized => _status == SellerProfileStatus.unauthorized;

  bool get hasProfile => _profile != null;

  // ============================================
  // GETTERS : ACTION
  // ============================================

  SellerProfileActionStatus get actionStatus => _actionStatus;
  String? get actionError => _actionError;
  String? get actionSuccessMessage => _actionSuccessMessage;

  bool get isUpdating => _actionStatus == SellerProfileActionStatus.updating;
  bool get isUploadingLogo =>
      _actionStatus == SellerProfileActionStatus.uploadingLogo;
  bool get isUploadingBanner =>
      _actionStatus == SellerProfileActionStatus.uploadingBanner;
  bool get isSubmittingKyc =>
      _actionStatus == SellerProfileActionStatus.submittingKyc;
  bool get hasActionError =>
      _actionStatus == SellerProfileActionStatus.error;

  bool get isPerformingAction =>
      _actionStatus != SellerProfileActionStatus.idle &&
      _actionStatus != SellerProfileActionStatus.error;

  // ============================================
  // CHARGEMENT DU PROFIL
  // ============================================

  /// Charge le profil boutique.
  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (isLoading && !forceRefresh) return;

    _status = SellerProfileStatus.loading;
    _errorMessage = null;
    _kycStatus = null;
    notifyListeners();

    try {
      final profile = await _api.getProfile();
      _profile = profile;
      _status = SellerProfileStatus.loaded;
    } on SellerProfileForbiddenException catch (e) {
      _status = SellerProfileStatus.forbidden;
      _errorMessage = e.message;
      _kycStatus = e.code;
    } on SellerProfileUnauthorizedException catch (e) {
      _status = SellerProfileStatus.unauthorized;
      _errorMessage = e.message;
    } catch (e) {
      _status = SellerProfileStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Rafraîchit le profil.
  Future<void> refresh() async {
    await loadProfile(forceRefresh: true);
  }

  // ============================================
  // MISE À JOUR DU PROFIL
  // ============================================

  /// Met à jour les informations du profil.
  ///
  /// [data] : Map des champs à mettre à jour.
  /// Exemples :
  ///   - shop_name
  ///   - description
  ///   - phone
  ///   - email
  ///   - address
  ///   - city
  ///   - country
  Future<SellerProfile?> updateProfile(Map<String, dynamic> data) async {
    _actionStatus = SellerProfileActionStatus.updating;
    _actionError = null;
    _actionSuccessMessage = null;
    notifyListeners();

    try {
      final updatedProfile = await _api.updateProfile(data);
      _profile = updatedProfile;
      _actionStatus = SellerProfileActionStatus.idle;
      _actionSuccessMessage = 'Profil mis à jour';
      notifyListeners();
      return updatedProfile;
    } catch (e) {
      _actionStatus = SellerProfileActionStatus.error;
      _actionError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // UPLOAD LOGO
  // ============================================

  /// Upload le logo de la boutique.
  Future<SellerProfile?> uploadLogo(String imagePath) async {
    _actionStatus = SellerProfileActionStatus.uploadingLogo;
    _actionError = null;
    _actionSuccessMessage = null;
    notifyListeners();

    try {
      final updatedProfile = await _api.uploadLogo(imagePath);
      _profile = updatedProfile;
      _actionStatus = SellerProfileActionStatus.idle;
      _actionSuccessMessage = 'Logo mis à jour';
      notifyListeners();
      return updatedProfile;
    } catch (e) {
      _actionStatus = SellerProfileActionStatus.error;
      _actionError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // UPLOAD BANNER
  // ============================================

  /// Upload la bannière de la boutique.
  Future<SellerProfile?> uploadBanner(String imagePath) async {
    _actionStatus = SellerProfileActionStatus.uploadingBanner;
    _actionError = null;
    _actionSuccessMessage = null;
    notifyListeners();

    try {
      final updatedProfile = await _api.uploadBanner(imagePath);
      _profile = updatedProfile;
      _actionStatus = SellerProfileActionStatus.idle;
      _actionSuccessMessage = 'Bannière mise à jour';
      notifyListeners();
      return updatedProfile;
    } catch (e) {
      _actionStatus = SellerProfileActionStatus.error;
      _actionError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // SUBMIT KYC
  // ============================================

  /// Soumet le KYC pour vérification.
  Future<SellerProfile?> submitKyc({
    required String idType,
    required String idNumber,
    required String idDocumentPath,
    String? businessLicensePath,
    String? selfiePath,
    String? kycNotes,
  }) async {
    _actionStatus = SellerProfileActionStatus.submittingKyc;
    _actionError = null;
    _actionSuccessMessage = null;
    notifyListeners();

    try {
      final updatedProfile = await _api.submitKyc(
        idType: idType,
        idNumber: idNumber,
        idDocumentPath: idDocumentPath,
        businessLicensePath: businessLicensePath,
        selfiePath: selfiePath,
        kycNotes: kycNotes,
      );

      _profile = updatedProfile;
      _actionStatus = SellerProfileActionStatus.idle;
      _actionSuccessMessage =
          'KYC soumis. Vérification sous 24-48h.';
      notifyListeners();
      return updatedProfile;
    } catch (e) {
      _actionStatus = SellerProfileActionStatus.error;
      _actionError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // RESET / CLEAR
  // ============================================

  /// Efface les erreurs et messages de succès.
  void clearErrors() {
    _errorMessage = null;
    _actionError = null;
    _actionSuccessMessage = null;

    if (_status == SellerProfileStatus.error) {
      _status = hasProfile
          ? SellerProfileStatus.loaded
          : SellerProfileStatus.initial;
    }

    if (_actionStatus == SellerProfileActionStatus.error) {
      _actionStatus = SellerProfileActionStatus.idle;
    }

    notifyListeners();
  }

  /// Efface le message de succès (après affichage).
  void clearSuccessMessage() {
    _actionSuccessMessage = null;
    notifyListeners();
  }

  /// Réinitialise complètement le provider (logout).
  void reset() {
    _status = SellerProfileStatus.initial;
    _actionStatus = SellerProfileActionStatus.idle;
    _profile = null;
    _errorMessage = null;
    _actionError = null;
    _actionSuccessMessage = null;
    _kycStatus = null;
    notifyListeners();
  }

  @override
  String toString() {
    return 'SellerProfileProvider(status: $_status, '
        'shop: ${_profile?.shopName ?? "N/A"}, '
        'actionStatus: $_actionStatus)';
  }

  Future<void> dismissOnboarding() async {
  try {
    await _api.dismissOnboarding();
    if (_profile != null) {
      _profile = _profile!.copyWith(
        // Ajoute un champ onboardingDismissedAt à l'entité si nécessaire
      );
      notifyListeners();
    }
  } catch (e) {
    debugPrint('❌ Erreur dismissOnboarding: $e');
  }
}
}