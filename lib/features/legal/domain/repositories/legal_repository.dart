// ============================================
// INTERFACE DU REPOSITORY LÉGAL - PREMIUM
// ============================================
// Définit le contrat que le repository doit
// respecter pour les documents légaux.
// ============================================

import '../entities/legal_document.dart';

abstract class LegalRepository {
  // ============================================
  // LECTURE
  // ============================================

  /// Récupérer tous les documents légaux
  Future<List<LegalDocument>> getLegalDocuments();

  /// Récupérer un document par son slug
  Future<LegalDocument?> getDocumentBySlug(String slug);

  /// Récupérer un document par son type
  Future<LegalDocument?> getDocumentByType(String type);

  // ============================================
  // DOCUMENTS SPÉCIFIQUES
  // ============================================

  /// Récupérer les conditions d'utilisation
  Future<LegalDocument?> getTermsConditions();

  /// Récupérer la politique de confidentialité
  Future<LegalDocument?> getPrivacyPolicy();

  /// Récupérer la politique de remboursement
  Future<LegalDocument?> getRefundPolicy();

  /// Récupérer la politique de livraison
  Future<LegalDocument?> getShippingPolicy();

  /// Récupérer la page À propos
  Future<LegalDocument?> getAbout();

  // ============================================
  // SYNCHRONISATION
  // ============================================

  /// Synchroniser avec le backend
  Future<void> syncWithBackend();

  /// Vérifier si les données sont synchronisées
  Future<bool> isSynced();

  // ============================================
  // CACHE LOCAL
  // ============================================

  /// Récupérer les documents depuis le cache
  Future<List<LegalDocument>> getCachedDocuments();

  /// Sauvegarder les documents en cache
  Future<void> saveDocuments(List<LegalDocument> documents);

  /// Effacer le cache
  Future<void> clearCache();
}