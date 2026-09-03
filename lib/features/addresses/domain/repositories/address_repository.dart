// ============================================
// INTERFACE DU REPOSITORY DES ADRESSES - PREMIUM
// ============================================
// Définit le contrat que le repository doit
// respecter. Gestion complète des adresses
// avec snapshot et synchronisation.
// ============================================

import '../entities/address.dart';

abstract class AddressRepository {
  // ============================================
  // LECTURE
  // ============================================

  /// Récupérer toutes les adresses
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
  // CRÉATION
  // ============================================

  /// Ajouter une adresse
  Future<List<Address>> addAddress(Address address);

  /// Ajouter plusieurs adresses
  Future<List<Address>> addAddresses(List<Address> addresses);

  // ============================================
  // MODIFICATION
  // ============================================

  /// Mettre à jour une adresse
  Future<List<Address>> updateAddress(Address address);

  /// Définir une adresse comme défaut
  Future<List<Address>> setDefaultAddress(int addressId);

  /// Activer/désactiver une adresse
  Future<List<Address>> toggleAddressActive(int addressId);

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprimer une adresse
  Future<List<Address>> removeAddress(int addressId);

  /// Supprimer plusieurs adresses
  Future<List<Address>> removeAddresses(List<int> addressIds);

  /// Effacer toutes les adresses
  Future<void> clearAddresses();

  // ============================================
  // SAUVEGARDE
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