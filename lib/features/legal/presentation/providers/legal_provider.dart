// ============================================
// PROVIDER LÉGAL - VERSION PREMIUM
// ============================================
// Gère l'état des documents légaux.
// Design ShopPro.
// ============================================

import 'package:flutter/foundation.dart';
import '../../domain/entities/legal_document.dart';
import '../../domain/repositories/legal_repository.dart';
import '../../data/repositories/legal_repository_impl.dart';

enum LegalStatus {
  initial,
  loading,
  loaded,
  syncing,
  error,
}

class LegalProvider extends ChangeNotifier {
  final LegalRepository _legalRepository;

  LegalProvider({LegalRepository? legalRepository})
      : _legalRepository = legalRepository ?? LegalRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  LegalStatus _status = LegalStatus.initial;
  String? _errorMessage;

  // ============================================
  // DONNÉES
  // ============================================

  List<LegalDocument> _documents = [];
  LegalDocument? _termsConditions;
  LegalDocument? _privacyPolicy;
  LegalDocument? _refundPolicy;
  LegalDocument? _shippingPolicy;
  LegalDocument? _about;
  LegalDocument? _currentDocument;

  // ============================================
  // GETTERS DE BASE
  // ============================================

  LegalStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == LegalStatus.loading;
  bool get isSyncing => _status == LegalStatus.syncing;
  bool get hasError => _status == LegalStatus.error;

  List<LegalDocument> get documents => _documents;
  LegalDocument? get termsConditions => _termsConditions;
  LegalDocument? get privacyPolicy => _privacyPolicy;
  LegalDocument? get refundPolicy => _refundPolicy;
  LegalDocument? get shippingPolicy => _shippingPolicy;
  LegalDocument? get about => _about;
  LegalDocument? get currentDocument => _currentDocument;

  // ============================================
  // CHARGEMENT
  // ============================================

  /// Charger tous les documents légaux
  Future<void> loadAllDocuments() async {
    _setStatus(LegalStatus.loading);
    _clearError();

    try {
      _documents = await _legalRepository.getLegalDocuments();

      // Remplir les documents spécifiques
      for (final document in _documents) {
        switch (document.type) {
          case LegalDocument.typeTermsConditions:
            _termsConditions = document;
            break;
          case LegalDocument.typePrivacyPolicy:
            _privacyPolicy = document;
            break;
          case LegalDocument.typeRefundPolicy:
            _refundPolicy = document;
            break;
          case LegalDocument.typeShippingPolicy:
            _shippingPolicy = document;
            break;
          case LegalDocument.typeAbout:
            _about = document;
            break;
        }
      }

      _setStatus(LegalStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(LegalStatus.error);
    }

    notifyListeners();
  }

  /// Charger les conditions d'utilisation
  Future<void> loadTermsConditions() async {
    _setStatus(LegalStatus.loading);
    _clearError();

    try {
      _termsConditions = await _legalRepository.getTermsConditions();
      _currentDocument = _termsConditions;
      _setStatus(LegalStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(LegalStatus.error);
    }

    notifyListeners();
  }

  /// Charger la politique de confidentialité
  Future<void> loadPrivacyPolicy() async {
    _setStatus(LegalStatus.loading);
    _clearError();

    try {
      _privacyPolicy = await _legalRepository.getPrivacyPolicy();
      _currentDocument = _privacyPolicy;
      _setStatus(LegalStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(LegalStatus.error);
    }

    notifyListeners();
  }

  /// Charger la politique de remboursement
  Future<void> loadRefundPolicy() async {
    _setStatus(LegalStatus.loading);
    _clearError();

    try {
      _refundPolicy = await _legalRepository.getRefundPolicy();
      _currentDocument = _refundPolicy;
      _setStatus(LegalStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(LegalStatus.error);
    }

    notifyListeners();
  }

  /// Charger la politique de livraison
  Future<void> loadShippingPolicy() async {
    _setStatus(LegalStatus.loading);
    _clearError();

    try {
      _shippingPolicy = await _legalRepository.getShippingPolicy();
      _currentDocument = _shippingPolicy;
      _setStatus(LegalStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(LegalStatus.error);
    }

    notifyListeners();
  }

  /// Charger la page À propos
  Future<void> loadAbout() async {
    _setStatus(LegalStatus.loading);
    _clearError();

    try {
      _about = await _legalRepository.getAbout();
      _currentDocument = _about;
      _setStatus(LegalStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(LegalStatus.error);
    }

    notifyListeners();
  }

  /// Charger un document par slug
  Future<void> loadDocumentBySlug(String slug) async {
    _setStatus(LegalStatus.loading);
    _clearError();

    try {
      _currentDocument = await _legalRepository.getDocumentBySlug(slug);
      _setStatus(LegalStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(LegalStatus.error);
    }

    notifyListeners();
  }

  // ============================================
  // SYNCHRONISATION
  // ============================================

  /// Synchroniser avec le backend
  Future<void> syncWithBackend() async {
    _setStatus(LegalStatus.syncing);

    try {
      await _legalRepository.syncWithBackend();
      await loadAllDocuments();
    } catch (e) {
      _setError(e.toString());
      _setStatus(LegalStatus.error);
    }

    notifyListeners();
  }

  // ============================================
  // EFFACEMENT
  // ============================================

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
  // MÉTHODES PRIVÉES
  // ============================================

  void _setStatus(LegalStatus newStatus) {
    _status = newStatus;
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
    return 'LegalProvider(status: $_status, documents: ${_documents.length}, '
        'terms: ${_termsConditions != null}, privacy: ${_privacyPolicy != null})';
  }
}