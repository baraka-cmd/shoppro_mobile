// ============================================
// INTERFACE DU REPOSITORY DES ADRESSES - PREMIUM
// ============================================
// Définit le contrat que le repository doit
// respecter. Gestion complète des adresses
// avec snapshot et synchronisation.
//
// ⚠️ L'implémentation utilise l'API Laravel
//    comme source principale, avec cache local.
// ============================================

import '../entities/address.dart';

abstract class AddressRepository {
  // ============================================
  // LECTURE
  // ============================================

  /// Récupérer toutes les adresses (depuis l'API)
  Future<List<Address>> getAddresses();

  /// Récupérer les adresses actives
  Future<List<Address>> getActiveAddresses();

  /// Récupérer une adresse par ID
  Future<Address?> getAddressById(int addressId);

  /// Récupérer l'adresse par défaut
  Future<Address?> getDefaultAddress();

  /// Récupérer les adresses par type
  Future<List<Address>> getAddressesByType(String type);

  /// Récupérer le nombre d'adresses
  Future<int> getAddressesCount();

  /// Vérifier si des adresses existent
  Future<bool> hasAddresses();

  // ============================================
  // CRÉATION (API)
  // ============================================

  /// Créer une nouvelle adresse côté serveur.
  /// Retourne l'adresse créée (avec son ID serveur).
  Future<Address> createAddress({
    required String fullName,
    required String phone,
    String? email,
    required String addressLine1,
    String? addressLine2,
    required String city,
    String? state,
    String? postalCode,
    String? country,
    String type = 'home',
    bool isDefault = false,
    double? latitude,
    double? longitude,
    String? deliveryInstructions,
  });

  // ============================================
  // MODIFICATION (API)
  // ============================================

  /// Mettre à jour une adresse côté serveur.
  Future<Address> updateAddress({
    required int id,
    String? fullName,
    String? phone,
    String? email,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? type,
    bool? isDefault,
    double? latitude,
    double? longitude,
    String? deliveryInstructions,
  });

  /// Définir une adresse comme défaut côté serveur.
  Future<Address> setDefaultAddress(int addressId);

  /// Activer/désactiver une adresse (cache local uniquement)
  Future<List<Address>> toggleAddressActive(int addressId);

  // ============================================
  // SUPPRESSION (API)
  // ============================================

  /// Supprimer une adresse côté serveur (soft delete)
  Future<void> deleteAddress(int addressId);

  /// Supprimer plusieurs adresses (cache local uniquement)
  Future<List<Address>> removeAddresses(List<int> addressIds);

  /// Effacer toutes les adresses du cache local
  Future<void> clearAddresses();

  // ============================================
  // SAUVEGARDE (CACHE LOCAL)
  // ============================================

  /// Sauvegarder les adresses localement
  Future<void> saveAddresses(List<Address> addresses);

  /// Synchroniser avec le backend
  Future<List<Address>> syncWithBackend();

  /// Vérifier si les adresses sont synchronisées
  Future<bool> isAddressesSynced();

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  /// Sauvegarder le snapshot des adresses
  Future<void> saveAddressesSnapshot();

  /// Restaurer le snapshot des adresses
  Future<List<Address>> restoreAddressesSnapshot();

  /// Effacer le snapshot
  Future<void> clearAddressesSnapshot();
}