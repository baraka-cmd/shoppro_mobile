// ============================================
// REPOSITORY INTERFACE : AdminSettingRepository
// ============================================
// Interface définissant le contrat pour la gestion des paramètres
// de configuration de l'application depuis le backoffice admin.
//
// Cette interface est dans la couche DOMAIN (métier) et ne dépend
// d'aucune implémentation concrète. Elle sera implémentée dans
// la couche DATA par AdminSettingRepositoryImpl.
//
// Opérations couvertes :
// - Liste des paramètres par groupe
// - Récupération par clé
// - Mise à jour des paramètres
// - Gestion des groupes
// - Cache des paramètres
// ============================================

// ============================================
// IMPORTS
// ============================================

// Entities (même feature admin)
import '../entities/admin_setting.dart';

// ============================================
// INTERFACE PRINCIPALE
// ============================================

/// Contrat pour le repository de gestion des paramètres.
///
/// Cette interface définit toutes les opérations de lecture
/// et de mise à jour des paramètres de configuration.
abstract class AdminSettingRepository {
  // ============================================
  // LECTURE
  // ============================================

  /// Récupère tous les paramètres.
  ///
  /// Paramètres :
  /// - [group] : Filtrer par groupe (optionnel)
  /// - [isPublic] : Filtrer par visibilité (optionnel)
  /// - [isActive] : Filtrer par statut (optionnel)
  ///
  /// Retourne une liste de [AdminSetting].
  Future<List<AdminSetting>> getSettings({
    AdminSettingGroup? group,
    bool? isPublic,
    bool? isActive,
  });

  /// Récupère tous les paramètres groupés.
  ///
  /// Retourne une map avec le format :
  /// ```dart
  /// {
  ///   AdminSettingGroup.general: [AdminSetting, ...],
  ///   AdminSettingGroup.store: [AdminSetting, ...],
  ///   ...
  /// }
  /// ```
  Future<Map<AdminSettingGroup, List<AdminSetting>>> getGroupedSettings();

  /// Récupère un paramètre par sa clé.
  ///
  /// Paramètres :
  /// - [key] : Clé unique du paramètre (ex: "app_name")
  ///
  /// Retourne un [AdminSetting] ou null si introuvable.
  Future<AdminSetting?> getSettingByKey(String key);

  /// Récupère la valeur d'un paramètre en String.
  ///
  /// Paramètres :
  /// - [key] : Clé du paramètre
  /// - [defaultValue] : Valeur par défaut si introuvable
  Future<String> getSettingValue(String key, {String defaultValue = ''});

  /// Récupère la valeur d'un paramètre en booléen.
  ///
  /// Paramètres :
  /// - [key] : Clé du paramètre
  /// - [defaultValue] : Valeur par défaut
  Future<bool> getBoolSetting(String key, {bool defaultValue = false});

  /// Récupère la valeur d'un paramètre en entier.
  ///
  /// Paramètres :
  /// - [key] : Clé du paramètre
  /// - [defaultValue] : Valeur par défaut
  Future<int> getIntSetting(String key, {int defaultValue = 0});

  /// Récupère la valeur d'un paramètre en décimal.
  ///
  /// Paramètres :
  /// - [key] : Clé du paramètre
  /// - [defaultValue] : Valeur par défaut
  Future<double> getDoubleSetting(String key, {double defaultValue = 0});

  // ============================================
  // GROUPES
  // ============================================

  /// Récupère les paramètres du groupe général.
  Future<List<AdminSetting>> getGeneralSettings();

  /// Récupère les paramètres du groupe boutique.
  Future<List<AdminSetting>> getStoreSettings();

  /// Récupère les paramètres du groupe livraison.
  Future<List<AdminSetting>> getShippingSettings();

  /// Récupère les paramètres du groupe paiement.
  Future<List<AdminSetting>> getPaymentSettings();

  /// Récupère les paramètres du groupe notifications.
  Future<List<AdminSetting>> getNotificationSettings();

  /// Récupère les paramètres du groupe sécurité.
  Future<List<AdminSetting>> getSecuritySettings();

  /// Récupère les paramètres du groupe SEO.
  Future<List<AdminSetting>> getSeoSettings();

  /// Récupère les paramètres du groupe réseaux sociaux.
  Future<List<AdminSetting>> getSocialSettings();

  /// Récupère les paramètres du groupe email.
  Future<List<AdminSetting>> getEmailSettings();

  /// Récupère les paramètres du groupe API.
  Future<List<AdminSetting>> getApiSettings();

  // ============================================
  // PARAMÈTRES SPÉCIFIQUES
  // ============================================

  /// Récupère le nom de l'application.
  Future<String> getAppName();

  /// Récupère le logo de l'application.
  Future<String?> getAppLogo();

  /// Récupère la devise par défaut.
  Future<String> getDefaultCurrency();

  /// Récupère la langue par défaut.
  Future<String> getDefaultLanguage();

  /// Récupère le pays par défaut.
  Future<String> getDefaultCountry();

  /// Récupère les frais de livraison par défaut.
  Future<double> getDefaultShippingFee();

  /// Récupère le seuil de livraison gratuite.
  Future<double> getFreeShippingThreshold();

  /// Récupère le taux de taxe par défaut.
  Future<double> getDefaultTaxRate();

  /// Récupère l'email de contact.
  Future<String> getContactEmail();

  /// Récupère le téléphone de contact.
  Future<String> getContactPhone();

  /// Récupère l'adresse de la boutique.
  Future<String> getStoreAddress();

  // ============================================
  // MISE À JOUR
  // ============================================

  /// Met à jour un paramètre.
  ///
  /// Paramètres :
  /// - [setting] : Le paramètre avec la nouvelle valeur
  ///
  /// Retourne le paramètre mis à jour.
  Future<AdminSetting> updateSetting(AdminSetting setting);

  /// Met à jour la valeur d'un paramètre par sa clé.
  ///
  /// Paramètres :
  /// - [key] : Clé du paramètre
  /// - [value] : Nouvelle valeur
  ///
  /// Retourne true si la mise à jour a réussi.
  Future<bool> updateSettingValue(String key, String value);

  /// Met à jour plusieurs paramètres en même temps.
  ///
  /// Paramètres :
  /// - [settings] : Liste des paramètres à mettre à jour
  ///
  /// Retourne le nombre de paramètres mis à jour.
  Future<int> bulkUpdateSettings(List<AdminSetting> settings);

  /// Met à jour tous les paramètres d'un groupe.
  ///
  /// Paramètres :
  /// - [group] : Groupe à mettre à jour
  /// - [settings] : Nouveaux paramètres du groupe
  ///
  /// Retourne le nombre de paramètres mis à jour.
  Future<int> updateGroupSettings(
    AdminSettingGroup group,
    List<AdminSetting> settings,
  );

  // ============================================
  // CRÉATION ET SUPPRESSION
  // ============================================

  /// Crée un nouveau paramètre.
  ///
  /// Paramètres :
  /// - [setting] : Le paramètre à créer (sans ID)
  ///
  /// Retourne le paramètre créé avec son ID.
  ///
  /// Lance une [Exception] si la clé existe déjà.
  Future<AdminSetting> createSetting(AdminSetting setting);

  /// Supprime un paramètre.
  ///
  /// Paramètres :
  /// - [key] : Clé du paramètre à supprimer
  ///
  /// Retourne true si la suppression a réussi.
  Future<bool> deleteSetting(String key);

  /// Active un paramètre.
  ///
  /// Paramètres :
  /// - [key] : Clé du paramètre
  Future<bool> activateSetting(String key);

  /// Désactive un paramètre.
  ///
  /// Paramètres :
  /// - [key] : Clé du paramètre
  Future<bool> deactivateSetting(String key);

  // ============================================
  // VALIDATION
  // ============================================

  /// Vérifie si une clé existe.
  ///
  /// Paramètres :
  /// - [key] : Clé à vérifier
  Future<bool> keyExists(String key);

  /// Vérifie si une clé est disponible.
  ///
  /// Paramètres :
  /// - [key] : Clé à vérifier
  ///
  /// Retourne true si la clé est disponible.
  Future<bool> isKeyAvailable(String key);

  /// Valide la valeur d'un paramètre.
  ///
  /// Paramètres :
  /// - [setting] : Le paramètre à valider
  ///
  /// Retourne true si la valeur est valide.
  Future<bool> validateSettingValue(AdminSetting setting);

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Récupère le nombre total de paramètres.
  Future<int> getTotalSettingsCount();

  /// Récupère le nombre de paramètres par groupe.
  ///
  /// Retourne une map :
  /// ```dart
  /// {
  ///   'general': 5,
  ///   'store': 8,
  ///   'shipping': 6,
  ///   ...
  /// }
  /// ```
  Future<Map<String, int>> getSettingsCountByGroup();

  /// Récupère le nombre de paramètres publics.
  Future<int> getPublicSettingsCount();

  /// Récupère le nombre de paramètres privés.
  Future<int> getPrivateSettingsCount();

  // ============================================
  // CACHE
  // ============================================

  /// Rafraîchit le cache des paramètres.
  Future<void> refreshCache();

  /// Efface le cache des paramètres.
  Future<void> clearCache();

  /// Vérifie si les paramètres sont en cache.
  Future<bool> hasCachedSettings();

  /// Récupère les paramètres depuis le cache.
  Future<List<AdminSetting>?> getCachedSettings();
}