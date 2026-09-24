// ============================================
// SOURCE DE DONNÉES LOCALE SUPPORT - PREMIUM
// ============================================
// Gère le cache local des FAQs et catégories
// avec SharedPreferences. Design ShopPro.
// ============================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/faq_model.dart';
import '../models/faq_category_model.dart';

class SupportLocalDataSource {
  static final SupportLocalDataSource _instance = SupportLocalDataSource._internal();
  factory SupportLocalDataSource() => _instance;
  SupportLocalDataSource._internal();

  static const String _faqsKey = 'cached_faqs';
  static const String _faqCategoriesKey = 'cached_faq_categories';
  static const String _lastSyncKey = 'support_last_sync';

  // ============================================
  // FAQ CACHE
  // ============================================

  /// Sauvegarder les FAQs en cache
  Future<void> saveFaqs(List<FaqModel> faqs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final faqsJson = jsonEncode(
        faqs.map((f) => f.toJson()).toList(),
      );
      await prefs.setString(_faqsKey, faqsJson);
      await _updateLastSync();
    } catch (e) {
      debugPrint('❌ Erreur saveFaqs cache: $e');
    }
  }

  /// Récupérer les FAQs depuis le cache
  Future<List<FaqModel>> getCachedFaqs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final faqsJson = prefs.getString(_faqsKey);

      if (faqsJson == null || faqsJson.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(faqsJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => FaqModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur getCachedFaqs: $e');
      return [];
    }
  }

  /// Effacer le cache des FAQs
  Future<void> clearFaqsCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_faqsKey);
    } catch (e) {
      debugPrint('❌ Erreur clearFaqsCache: $e');
    }
  }

  // ============================================
  // CATÉGORIES FAQ CACHE
  // ============================================

  /// Sauvegarder les catégories en cache
  Future<void> saveFaqCategories(List<FaqCategoryModel> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = jsonEncode(
        categories.map((c) => c.toJson()).toList(),
      );
      await prefs.setString(_faqCategoriesKey, categoriesJson);
      await _updateLastSync();
    } catch (e) {
      debugPrint('❌ Erreur saveFaqCategories cache: $e');
    }
  }

  /// Récupérer les catégories depuis le cache
  Future<List<FaqCategoryModel>> getCachedFaqCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString(_faqCategoriesKey);

      if (categoriesJson == null || categoriesJson.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(categoriesJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => FaqCategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur getCachedFaqCategories: $e');
      return [];
    }
  }

  /// Effacer le cache des catégories
  Future<void> clearFaqCategoriesCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_faqCategoriesKey);
    } catch (e) {
      debugPrint('❌ Erreur clearFaqCategoriesCache: $e');
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
      debugPrint('❌ Erreur updateLastSync: $e');
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

  /// Vérifier si le cache est récent (moins de 24h)
  Future<bool> isCacheFresh() async {
    final lastSync = await getLastSync();
    if (lastSync == null) return false;
    return DateTime.now().difference(lastSync).inHours < 24;
  }

  /// Vérifier si le cache existe
  Future<bool> hasCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_faqsKey) || prefs.containsKey(_faqCategoriesKey);
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // EFFACEMENT COMPLET
  // ============================================

  /// Effacer tout le cache
  Future<void> clearAll() async {
    await clearFaqsCache();
    await clearFaqCategoriesCache();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSyncKey);
    } catch (e) {
      debugPrint('❌ Erreur clearAll cache: $e');
    }
  }
}