// Interface du repository des adresses
// Définit le contrat que le repository doit respecter

import '../entities/address.dart';

abstract class AddressRepository {
  /// Récupérer toutes les adresses
  Future<List<Address>> getAddresses();

  /// Récupérer une adresse par ID
  Future<Address?> getAddressById(int addressId);

  /// Récupérer l'adresse par défaut
  Future<Address?> getDefaultAddress();

  /// Ajouter une adresse
  Future<List<Address>> addAddress(Address address);

  /// Mettre à jour une adresse
  Future<List<Address>> updateAddress(Address address);

  /// Supprimer une adresse
  Future<List<Address>> removeAddress(int addressId);

  /// Définir une adresse comme défaut
  Future<List<Address>> setDefaultAddress(int addressId);

  /// Récupérer les adresses par type
  Future<List<Address>> getAddressesByType(String type);

  /// Récupérer le nombre d'adresses
  Future<int> getAddressesCount();

  /// Vérifier si des adresses existent
  Future<bool> hasAddresses();

  /// Sauvegarder les adresses localement
  Future<void> saveAddresses(List<Address> addresses);

  /// Synchroniser avec le backend
  Future<List<Address>> syncWithBackend();

  /// Effacer toutes les adresses
  Future<void> clearAddresses();
}