// ============================================
// REPOSITORY IMPL : AdminSettingRepositoryImpl
// ============================================
// Implémentation concrète du repository de gestion des paramètres.
// Cette classe implémente l'interface [AdminSettingRepository]
// et orchestre les appels API avec le cache local.
//
// Responsabilités :
// - Appels API via AdminSettingApi
// - Mise en cache avec SharedPreferences
// - Gestion des groupes de paramètres
// - Gestion des erreurs
// ============================================

// ============================================
// IMPORTS
// ============================================

// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages externes
import 'package:shared_preferences/shared_preferences.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_setting.dart';

// Repositories interfaces (même feature admin)
import '../../domain/repositories/admin_setting_repository.dart';

// Models (même feature admin)
import '../models/admin_setting_model.dart';

// Sources (même feature admin)
import '../sources/admin_setting_api.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Implémentation du repository de gestion des paramètres.
///
/// Gère la lecture et la mise à jour des paramètres de configuration.
class AdminSettingRepositoryImpl implements AdminSettingRepository {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminSettingApi _api;
  final SharedPreferences? _prefs;

  // ============================================
  // CLÉS DE CACHE
  // ============================================

  static const String _cacheKeySettings = 'admin_settings';
  static const String _cacheKeyTimestamp = 'admin_settings_timestamp';
  static const Duration _cacheValidity = Duration(minutes: 15);

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminSettingRepositoryImpl({
    AdminSettingApi? api,
    SharedPreferences? prefs,
  })  : _api = api ?? AdminSettingApi(),
        _prefs = prefs;

  // ============================================
  // LECTURE
  // ============================================

  @override
  Future<List<AdminSetting>> getSettings({
    AdminSettingGroup? group,
    bool? isPublic,
    bool? isActive,
  }) async {
    try {
      final response = await _api.getSettings(
        group: group?.code,
        isPublic: isPublic,
        isActive: isActive,
      );

      final data = response['data'];
      if (data is List) {
        final settings = data
            .map((e) => AdminSettingModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await _cacheSettings(settings);
        return settings;
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getSettings: $e');

      // Fallback : cache
      final cached = await getCachedSettings();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }

      rethrow;
    }
  }

  @override
  Future<Map<AdminSettingGroup, List<AdminSetting>>> getGroupedSettings() async {
    final settings = await getSettings();
    final grouped = <AdminSettingGroup, List<AdminSetting>>{};

    for (final setting in settings) {
      grouped.putIfAbsent(setting.group, () => []).add(setting);
    }

    return grouped;
  }

  @override
  Future<AdminSetting?> getSettingByKey(String key) async {
    try {
      final response = await _api.getSettingByKey(key);
      final data = response['data'];
      if (data is Map) {
        return AdminSettingModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getSettingByKey: $e');
      rethrow;
    }
  }

  @override
  Future<String> getSettingValue(String key, {String defaultValue = ''}) async {
    final setting = await getSettingByKey(key);
    return setting?.value ?? defaultValue;
  }

  @override
  Future<bool> getBoolSetting(String key, {bool defaultValue = false}) async {
    final setting = await getSettingByKey(key);
    if (setting == null) return defaultValue;
    return setting.boolValue;
  }

  @override
  Future<int> getIntSetting(String key, {int defaultValue = 0}) async {
    final setting = await getSettingByKey(key);
    if (setting == null) return defaultValue;
    return setting.intValue;
  }

  @override
  Future<double> getDoubleSetting(String key, {double defaultValue = 0}) async {
    final setting = await getSettingByKey(key);
    if (setting == null) return defaultValue;
    return setting.doubleValue;
  }

  // ============================================
  // GROUPES
  // ============================================

  @override
  Future<List<AdminSetting>> getGeneralSettings() async {
    return getSettings(group: AdminSettingGroup.general);
  }

  @override
  Future<List<AdminSetting>> getStoreSettings() async {
    return getSettings(group: AdminSettingGroup.store);
  }

  @override
  Future<List<AdminSetting>> getShippingSettings() async {
    return getSettings(group: AdminSettingGroup.shipping);
  }

  @override
  Future<List<AdminSetting>> getPaymentSettings() async {
    return getSettings(group: AdminSettingGroup.payment);
  }

  @override
  Future<List<AdminSetting>> getNotificationSettings() async {
    return getSettings(group: AdminSettingGroup.notifications);
  }

  @override
  Future<List<AdminSetting>> getSecuritySettings() async {
    return getSettings(group: AdminSettingGroup.security);
  }

  @override
  Future<List<AdminSetting>> getSeoSettings() async {
    return getSettings(group: AdminSettingGroup.seo);
  }

  @override
  Future<List<AdminSetting>> getSocialSettings() async {
    return getSettings(group: AdminSettingGroup.social);
  }

  @override
  Future<List<AdminSetting>> getEmailSettings() async {
    return getSettings(group: AdminSettingGroup.email);
  }

  @override
  Future<List<AdminSetting>> getApiSettings() async {
    return getSettings(group: AdminSettingGroup.api);
  }

  // ============================================
  // PARAMÈTRES SPÉCIFIQUES
  // ============================================

  @override
  Future<String> getAppName() async {
    return getSettingValue('app_name', defaultValue: 'ShopPro');
  }

  @override
  Future<String?> getAppLogo() async {
    final setting = await getSettingByKey('app_logo');
    return setting?.value;
  }

  @override
  Future<String> getDefaultCurrency() async {
    return getSettingValue('default_currency', defaultValue: 'FCFA');
  }

  @override
  Future<String> getDefaultLanguage() async {
    return getSettingValue('default_language', defaultValue: 'fr');
  }

  @override
  Future<String> getDefaultCountry() async {
    return getSettingValue('default_country', defaultValue: 'Cameroun');
  }

  @override
  Future<double> getDefaultShippingFee() async {
    return getDoubleSetting('default_shipping_fee', defaultValue: 0);
  }

  @override
  Future<double> getFreeShippingThreshold() async {
    return getDoubleSetting('free_shipping_threshold', defaultValue: 50000);
  }

  @override
  Future<double> getDefaultTaxRate() async {
    return getDoubleSetting('default_tax_rate', defaultValue: 0);
  }

  @override
  Future<String> getContactEmail() async {
    return getSettingValue('contact_email', defaultValue: 'contact@shoppro.com');
  }

  @override
  Future<String> getContactPhone() async {
    return getSettingValue('contact_phone', defaultValue: '+237 6 00 00 00 00');
  }

  @override
  Future<String> getStoreAddress() async {
    return getSettingValue('store_address', defaultValue: '');
  }

  // ============================================
  // MISE À JOUR
  // ============================================

  @override
  Future<AdminSetting> updateSetting(AdminSetting setting) async {
    try {
      final model = AdminSettingModel.fromEntity(setting);
      final response = await _api.updateSetting(setting.key, model.value);
      final data = response['data'];
      final updated = AdminSettingModel.fromJson(Map<String, dynamic>.from(data as Map));
      await _cacheSettings([updated]);
      return updated;
    } catch (e) {
      debugPrint('Erreur updateSetting: $e');
      rethrow;
    }
  }

  @override
  Future<bool> updateSettingValue(String key, String value) async {
    try {
      final response = await _api.updateSetting(key, value);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur updateSettingValue: $e');
      rethrow;
    }
  }

  @override
  Future<int> bulkUpdateSettings(List<AdminSetting> settings) async {
    var count = 0;
    for (final setting in settings) {
      if (await updateSettingValue(setting.key, setting.value)) {
        count++;
      }
    }
    return count;
  }

  @override
  Future<int> updateGroupSettings(
    AdminSettingGroup group,
    List<AdminSetting> settings,
  ) async {
    var count = 0;
    for (final setting in settings) {
      if (setting.group == group) {
        if (await updateSettingValue(setting.key, setting.value)) {
          count++;
        }
      }
    }
    return count;
  }

  // ============================================
  // CRÉATION ET SUPPRESSION
  // ============================================

  @override
  Future<AdminSetting> createSetting(AdminSetting setting) async {
    try {
      final model = AdminSettingModel.fromEntity(setting);
      final response = await _api.createSetting(model.toJson());
      final data = response['data'];
      return AdminSettingModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('Erreur createSetting: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteSetting(String key) async {
    try {
      final response = await _api.deleteSetting(key);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur deleteSetting: $e');
      rethrow;
    }
  }

  @override
  Future<bool> activateSetting(String key) async {
    try {
      final response = await _api.activateSetting(key);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur activateSetting: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deactivateSetting(String key) async {
    try {
      final response = await _api.deactivateSetting(key);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur deactivateSetting: $e');
      rethrow;
    }
  }

  // ============================================
  // VALIDATION
  // ============================================

  @override
  Future<bool> keyExists(String key) async {
    final setting = await getSettingByKey(key);
    return setting != null;
  }

  @override
  Future<bool> isKeyAvailable(String key) async {
    return !(await keyExists(key));
  }

  @override
  Future<bool> validateSettingValue(AdminSetting setting) async {
    final model = AdminSettingModel.fromEntity(setting);
    return model.hasValidValue;
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  @override
  Future<int> getTotalSettingsCount() async {
    try {
      final response = await _api.getTotalSettingsCount();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getTotalSettingsCount: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getSettingsCountByGroup() async {
    try {
      final response = await _api.getSettingsCountByGroup();
      final data = response['data'];
      if (data is Map) {
        return Map<String, int>.from(
          data.map((key, value) => MapEntry(key.toString(), (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getSettingsCountByGroup: $e');
      rethrow;
    }
  }

  @override
  Future<int> getPublicSettingsCount() async {
    final settings = await getSettings(isPublic: true);
    return settings.length;
  }

  @override
  Future<int> getPrivateSettingsCount() async {
    final settings = await getSettings(isPublic: false);
    return settings.length;
  }

  // ============================================
  // CACHE
  // ============================================

  @override
  Future<void> refreshCache() async {
    try {
      final settings = await getSettings();
      await _cacheSettings(settings);
      debugPrint('Cache des paramètres rafraîchi');
    } catch (e) {
      debugPrint('Erreur refreshCache: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeySettings);
      await prefs.remove(_cacheKeyTimestamp);
      debugPrint('Cache des paramètres effacé');
    } catch (e) {
      debugPrint('Erreur clearCache: $e');
    }
  }

  @override
  Future<bool> hasCachedSettings() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKeySettings);
    return cached != null && cached.isNotEmpty;
  }

  @override
  Future<List<AdminSetting>?> getCachedSettings() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKeySettings);

      if (cached == null || cached.isEmpty) return null;

      // Vérifier la validité
      final timestamp = prefs.getInt(_cacheKeyTimestamp);
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheValidity) {
          return null;
        }
      }

      final json = jsonDecode(cached) as List;
      return json
          .map((e) => AdminSettingModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('Erreur getCachedSettings: $e');
      return null;
    }
  }

  // ============================================
  // HELPERS PRIVÉS DE CACHE
  // ============================================

  /// Met en cache la liste des paramètres.
  Future<void> _cacheSettings(List<AdminSetting> settings) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final jsonList = settings
          .map((s) => AdminSettingModel.fromEntity(s).toJson())
          .toList();
      await prefs.setString(_cacheKeySettings, jsonEncode(jsonList));
      await prefs.setInt(_cacheKeyTimestamp, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Erreur _cacheSettings: $e');
    }
  }
}