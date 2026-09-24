// ============================================
// SOURCE DE DONNÉES LOCALE LÉGAL - PREMIUM
// ============================================
// Gère le cache local des documents légaux
// avec SharedPreferences. Design ShopPro.
// ============================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/legal_document_model.dart';

class LegalLocalDataSource {
  static final LegalLocalDataSource _instance = LegalLocalDataSource._internal();
  factory LegalLocalDataSource() => _instance;
  LegalLocalDataSource._internal();

  static const String _documentsKey = 'cached_legal_documents';
  static const String _lastSyncKey = 'legal_last_sync';

  // ============================================
  // DOCUMENTS CACHE
  // ============================================

  /// Sauvegarder les documents en cache
  Future<void> saveDocuments(List<LegalDocumentModel> documents) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final documentsJson = jsonEncode(
        documents.map((d) => d.toJson()).toList(),
      );
      await prefs.setString(_documentsKey, documentsJson);
      await _updateLastSync();
    } catch (e) {
      debugPrint('❌ Erreur saveDocuments cache: $e');
    }
  }

  /// Récupérer les documents depuis le cache
  Future<List<LegalDocumentModel>> getCachedDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final documentsJson = prefs.getString(_documentsKey);

      if (documentsJson == null || documentsJson.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(documentsJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => LegalDocumentModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur getCachedDocuments: $e');
      return [];
    }
  }

  /// Récupérer un document par slug depuis le cache
  Future<LegalDocumentModel?> getCachedDocumentBySlug(String slug) async {
    final documents = await getCachedDocuments();
    for (final document in documents) {
      if (document.slug == slug) {
        return document;
      }
    }
    return null;
  }

  /// Récupérer un document par type depuis le cache
  Future<LegalDocumentModel?> getCachedDocumentByType(String type) async {
    final documents = await getCachedDocuments();
    for (final document in documents) {
      if (document.type == type) {
        return document;
      }
    }
    return null;
  }

  /// Effacer le cache des documents
  Future<void> clearDocumentsCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_documentsKey);
    } catch (e) {
      debugPrint('❌ Erreur clearDocumentsCache: $e');
    }
  }

  // ============================================
  // SYNCHRONISATION
  // ============================================

  /// Mettre à jour la date de dernière synchronisation
  Future<void> _updateLastSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('❌ Erreur updateLastSync legal: $e');
    }
  }

  /// Récupérer la date de dernière synchronisation
  Future<DateTime?> getLastSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString(_lastSyncKey);
      return lastSync != null ? DateTime.tryParse(lastSync) : null;
    } catch (e) {
      return null;
    }
  }

  /// Vérifier si le cache est récent (moins de 7 jours)
  Future<bool> isCacheFresh() async {
    final lastSync = await getLastSync();
    if (lastSync == null) return false;
    return DateTime.now().difference(lastSync).inDays < 7;
  }

  /// Vérifier si le cache existe
  Future<bool> hasCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_documentsKey);
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // EFFACEMENT COMPLET
  // ============================================

  /// Effacer tout le cache
  Future<void> clearAll() async {
    await clearDocumentsCache();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSyncKey);
    } catch (e) {
      debugPrint('❌ Erreur clearAll legal: $e');
    }
  }
}