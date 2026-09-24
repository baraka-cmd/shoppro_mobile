// ============================================
// IMPLÉMENTATION DU REPOSITORY LÉGAL - PREMIUM
// ============================================
// Gère la logique métier avec API et cache local.
// Design ShopPro.
// ============================================

import '../../domain/entities/legal_document.dart';
import '../../domain/repositories/legal_repository.dart';
import '../models/legal_document_model.dart';
import '../sources/legal_api.dart';
import '../sources/legal_local_data_source.dart';

class LegalRepositoryImpl implements LegalRepository {
  final LegalApi _legalApi;
  final LegalLocalDataSource _localDataSource;

  LegalRepositoryImpl({
    LegalApi? legalApi,
    LegalLocalDataSource? localDataSource,
  })  : _legalApi = legalApi ?? LegalApi(),
        _localDataSource = localDataSource ?? LegalLocalDataSource();

  // ============================================
  // DOCUMENTS LÉGAUX
  // ============================================

  @override
  Future<List<LegalDocument>> getLegalDocuments() async {
    try {
      final documents = await _legalApi.getLegalDocuments();
      await _localDataSource.saveDocuments(documents);
      return documents;
    } catch (e) {
      final cachedDocuments = await _localDataSource.getCachedDocuments();
      if (cachedDocuments.isNotEmpty) {
        return cachedDocuments;
      }
      rethrow;
    }
  }

  @override
  Future<LegalDocument?> getDocumentBySlug(String slug) async {
    try {
      final document = await _legalApi.getDocumentBySlug(slug);
      return document;
    } catch (e) {
      return await _localDataSource.getCachedDocumentBySlug(slug);
    }
  }

  @override
  Future<LegalDocument?> getDocumentByType(String type) async {
    try {
      final document = await _legalApi.getDocumentByType(type);
      return document;
    } catch (e) {
      return await _localDataSource.getCachedDocumentByType(type);
    }
  }

  // ============================================
  // DOCUMENTS SPÉCIFIQUES
  // ============================================

  @override
  Future<LegalDocument?> getTermsConditions() async {
    return await getDocumentByType(LegalDocument.typeTermsConditions);
  }

  @override
  Future<LegalDocument?> getPrivacyPolicy() async {
    return await getDocumentByType(LegalDocument.typePrivacyPolicy);
  }

  @override
  Future<LegalDocument?> getRefundPolicy() async {
    return await getDocumentByType(LegalDocument.typeRefundPolicy);
  }

  @override
  Future<LegalDocument?> getShippingPolicy() async {
    return await getDocumentByType(LegalDocument.typeShippingPolicy);
  }

  @override
  Future<LegalDocument?> getAbout() async {
    return await getDocumentByType(LegalDocument.typeAbout);
  }

  // ============================================
  // SYNCHRONISATION
  // ============================================

  @override
  Future<void> syncWithBackend() async {
    try {
      final documents = await _legalApi.getLegalDocuments();
      await _localDataSource.saveDocuments(documents);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isSynced() async {
    return await _localDataSource.isCacheFresh();
  }

  // ============================================
  // CACHE LOCAL
  // ============================================

  @override
  Future<List<LegalDocument>> getCachedDocuments() async {
    return await _localDataSource.getCachedDocuments();
  }

  @override
  Future<void> saveDocuments(List<LegalDocument> documents) async {
    final documentModels = documents
        .map((document) => LegalDocumentModel.fromEntity(document))
        .toList();
    await _localDataSource.saveDocuments(documentModels);
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearAll();
  }
}