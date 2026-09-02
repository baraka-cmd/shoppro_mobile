// ============================================
// PROVIDER : AdminSettingProvider
// ============================================
// Provider de gestion d'état pour les paramètres de configuration.
// Utilise ChangeNotifier pour notifier les widgets des changements.
//
// Responsabilités :
// - Chargement des paramètres groupés
// - Mise à jour des paramètres
// - Gestion des groupes
// - Cache des paramètres
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_setting.dart';

// Repositories (même feature admin)
import '../../domain/repositories/admin_setting_repository.dart';

// Repositories Impl (même feature admin)
import '../../data/repositories/admin_setting_repository_impl.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

/// États possibles du provider paramètres
enum AdminSettingStatus {
  initial,
  loading,
  loaded,
  saving,
  error,
}

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Provider de gestion des paramètres.
///
/// Gère :
/// - Le chargement des paramètres par groupe
/// - La mise à jour des valeurs
/// - La création et suppression
/// - Le cache local
class AdminSettingProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminSettingRepository _repository;

  // ============================================
  // ÉTAT
  // ============================================

  AdminSettingStatus _status = AdminSettingStatus.initial;
  Map<AdminSettingGroup, List<AdminSetting>> _groupedSettings = {};
  String? _errorMessage;
  AdminSettingGroup? _selectedGroup;
  bool _hasUnsavedChanges = false;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminSettingProvider({AdminSettingRepository? repository})
      : _repository = repository ?? AdminSettingRepositoryImpl();

  // ============================================
  // GETTERS
  // ============================================

  AdminSettingStatus get status => _status;
  Map<AdminSettingGroup, List<AdminSetting>> get groupedSettings =>
      Map.unmodifiable(_groupedSettings);
  String? get errorMessage => _errorMessage;
  AdminSettingGroup? get selectedGroup => _selectedGroup;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get isLoading => _status == AdminSettingStatus.loading;
  bool get isLoaded => _status == AdminSettingStatus.loaded;
  bool get isSaving => _status == AdminSettingStatus.saving;
  bool get hasError => _status == AdminSettingStatus.error;

  /// Nombre total de paramètres
  int get totalSettingsCount =>
      _groupedSettings.values.fold(0, (sum, list) => sum + list.length);

  /// Nombre de groupes chargés
  int get groupsCount => _groupedSettings.length;

  /// Tous les paramètres (liste plate)
  List<AdminSetting> get allSettings =>
      _groupedSettings.values.expand((e) => e).toList();

  /// Paramètres du groupe sélectionné
  List<AdminSetting> get selectedGroupSettings {
    if (_selectedGroup == null) return [];
    return _groupedSettings[_selectedGroup] ?? [];
  }

  /// Paramètres publics
  List<AdminSetting> get publicSettings =>
      allSettings.where((s) => s.isPublic).toList();

  /// Paramètres privés
  List<AdminSetting> get privateSettings =>
      allSettings.where((s) => !s.isPublic).toList();

  /// Paramètres actifs
  List<AdminSetting> get activeSettings =>
      allSettings.where((s) => s.isActive).toList();

  // ============================================
  // ACTIONS PRINCIPALES
  // ============================================

  /// Charge tous les paramètres groupés.
  Future<void> loadSettings() async {
    _status = AdminSettingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final grouped = await _repository.getGroupedSettings();
      _groupedSettings = grouped;
      _hasUnsavedChanges = false;
      _status = AdminSettingStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminSettingStatus.error;
      debugPrint('Erreur loadSettings: $e');
    }

    notifyListeners();
  }

  /// Rafraîchit sans loader.
  Future<void> refreshSettings() async {
    try {
      final grouped = await _repository.getGroupedSettings();
      _groupedSettings = grouped;
      _status = AdminSettingStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur refreshSettings: $e');
    }

    notifyListeners();
  }

  /// Sélectionne un groupe.
  void selectGroup(AdminSettingGroup? group) {
    _selectedGroup = group;
    notifyListeners();
  }

  // ============================================
  // LECTURE PAR GROUPE
  // ============================================

  /// Charge les paramètres d'un groupe spécifique.
  Future<void> loadGroup(AdminSettingGroup group) async {
    _selectedGroup = group;
    _status = AdminSettingStatus.loading;
    notifyListeners();

    try {
      final settings = await _repository.getSettings(group: group);
      _groupedSettings[group] = settings;
      _status = AdminSettingStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminSettingStatus.error;
      debugPrint('Erreur loadGroup: $e');
    }

    notifyListeners();
  }

  /// Récupère un paramètre par sa clé.
  Future<AdminSetting?> getSetting(String key) async {
    try {
      return await _repository.getSettingByKey(key);
    } catch (e) {
      debugPrint('Erreur getSetting: $e');
      return null;
    }
  }

  /// Récupère la valeur d'un paramètre en String.
  Future<String> getValue(String key, {String defaultValue = ''}) async {
    return _repository.getSettingValue(key, defaultValue: defaultValue);
  }

  /// Récupère la valeur d'un paramètre en booléen.
  Future<bool> getBoolValue(String key, {bool defaultValue = false}) async {
    return _repository.getBoolSetting(key, defaultValue: defaultValue);
  }

  /// Récupère la valeur d'un paramètre en entier.
  Future<int> getIntValue(String key, {int defaultValue = 0}) async {
    return _repository.getIntSetting(key, defaultValue: defaultValue);
  }

  // ============================================
  // MISE À JOUR
  // ============================================

  /// Met à jour un paramètre.
  Future<bool> updateSetting(AdminSetting setting) async {
    _status = AdminSettingStatus.saving;
    notifyListeners();

    try {
      final updated = await _repository.updateSetting(setting);
      _updateInGroup(updated);
      _hasUnsavedChanges = false;
      _status = AdminSettingStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminSettingStatus.error;
      debugPrint('Erreur updateSetting: $e');
      notifyListeners();
      return false;
    }
  }

  /// Met à jour la valeur d'un paramètre par clé.
  Future<bool> updateValue(String key, String value) async {
    _hasUnsavedChanges = true;
    notifyListeners();

    try {
      final success = await _repository.updateSettingValue(key, value);
      if (success) {
        _hasUnsavedChanges = false;
        await refreshSettings();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur updateValue: $e');
      notifyListeners();
      return false;
    }
  }

  /// Met à jour plusieurs paramètres en même temps.
  Future<int> bulkUpdate(List<AdminSetting> settings) async {
    final count = await _repository.bulkUpdateSettings(settings);
    if (count > 0) {
      _hasUnsavedChanges = false;
      await refreshSettings();
    }
    return count;
  }

  /// Sauvegarde les modifications en attente.
  Future<bool> saveChanges() async {
    if (!_hasUnsavedChanges) return true;
    final count = await bulkUpdate(allSettings);
    return count > 0;
  }

  // ============================================
  // CRÉATION ET SUPPRESSION
  // ============================================

  /// Crée un nouveau paramètre.
  Future<bool> createSetting(AdminSetting setting) async {
    _status = AdminSettingStatus.saving;
    notifyListeners();

    try {
      final created = await _repository.createSetting(setting);
      _addToGroup(created);
      _status = AdminSettingStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminSettingStatus.error;
      debugPrint('Erreur createSetting: $e');
      notifyListeners();
      return false;
    }
  }

  /// Supprime un paramètre.
  Future<bool> deleteSetting(String key) async {
    try {
      final success = await _repository.deleteSetting(key);
      if (success) {
        _removeFromGroup(key);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Active un paramètre.
  Future<bool> activateSetting(String key) async {
    try {
      final success = await _repository.activateSetting(key);
      if (success) {
        await refreshSettings();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Désactive un paramètre.
  Future<bool> deactivateSetting(String key) async {
    try {
      final success = await _repository.deactivateSetting(key);
      if (success) {
        await refreshSettings();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // VALIDATION
  // ============================================

  /// Vérifie si une clé existe.
  Future<bool> keyExists(String key) async {
    return _repository.keyExists(key);
  }

  /// Vérifie si une clé est disponible.
  Future<bool> isKeyAvailable(String key) async {
    return _repository.isKeyAvailable(key);
  }

  /// Valide la valeur d'un paramètre.
  Future<bool> validateValue(AdminSetting setting) async {
    return _repository.validateSettingValue(setting);
  }

  // ============================================
  // PARAMÈTRES SPÉCIFIQUES
  // ============================================

  /// Nom de l'application.
  Future<String> getAppName() async => _repository.getAppName();

  /// Devise par défaut.
  Future<String> getDefaultCurrency() async => _repository.getDefaultCurrency();

  /// Langue par défaut.
  Future<String> getDefaultLanguage() async => _repository.getDefaultLanguage();

  /// Seuil de livraison gratuite.
  Future<double> getFreeShippingThreshold() async =>
      _repository.getFreeShippingThreshold();

  /// Taux de taxe par défaut.
  Future<double> getDefaultTaxRate() async => _repository.getDefaultTaxRate();

  /// Email de contact.
  Future<String> getContactEmail() async => _repository.getContactEmail();

  // ============================================
  // CACHE
  // ============================================

  /// Rafraîchit le cache.
  Future<void> refreshCache() async => _repository.refreshCache();

  /// Efface le cache.
  Future<void> clearCache() async => _repository.clearCache();

  /// Vérifie si le cache existe.
  Future<bool> hasCachedData() async => _repository.hasCachedSettings();

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Met à jour un paramètre dans le groupe.
  void _updateInGroup(AdminSetting setting) {
    final group = setting.group;
    final list = _groupedSettings[group] ?? [];
    final index = list.indexWhere((s) => s.key == setting.key);
    if (index != -1) {
      list[index] = setting;
    } else {
      list.add(setting);
    }
    _groupedSettings[group] = list;
  }

  /// Ajoute un paramètre au groupe.
  void _addToGroup(AdminSetting setting) {
    final group = setting.group;
    final list = _groupedSettings[group] ?? [];
    list.add(setting);
    _groupedSettings[group] = list;
  }

  /// Retire un paramètre du groupe.
  void _removeFromGroup(String key) {
    _groupedSettings.forEach((group, list) {
      list.removeWhere((s) => s.key == key);
    });
  }

  // ============================================
  // RÉINITIALISATION
  // ============================================

  /// Réinitialise le provider.
  void reset() {
    _status = AdminSettingStatus.initial;
    _groupedSettings = {};
    _errorMessage = null;
    _selectedGroup = null;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminSettingProvider(status: $_status, groups: $groupsCount, '
        'settings: $totalSettingsCount, unsaved: $_hasUnsavedChanges)';
  }
}