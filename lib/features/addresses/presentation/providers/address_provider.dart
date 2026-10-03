// ============================================
// PROVIDER DES ADRESSES - VERSION PREMIUM
// ============================================
// Gère l'état des adresses avec actions complètes,
// défaut intelligent et annulation.
//
// ⚠️ L'API Laravel est la source principale.
// ============================================

import 'package:flutter/foundation.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../../data/repositories/address_repository_impl.dart';

enum AddressStatus {
  initial,
  loading,
  loaded,
  saving,
  deleting,
  error,
}

class AddressProvider extends ChangeNotifier {
  final AddressRepository _addressRepository;

  AddressProvider({AddressRepository? addressRepository})
      : _addressRepository = addressRepository ?? AddressRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  AddressStatus _status = AddressStatus.initial;
  List<Address> _addresses = [];
  String? _errorMessage;
  int _updatingAddressId = -1;

  // ============================================
  // GETTERS DE BASE
  // ============================================

  AddressStatus get status => _status;
  List<Address> get addresses => _addresses;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AddressStatus.loading;
  bool get isSaving => _status == AddressStatus.saving;
  bool get isDeleting => _status == AddressStatus.deleting;
  bool get hasError => _status == AddressStatus.error;
  bool get isEmpty => _addresses.isEmpty;
  int get addressesCount => _addresses.length;

  int get updatingAddressId => _updatingAddressId;

  // ============================================
  // GETTERS DÉRIVÉS
  // ============================================

  Address? get defaultAddress {
    for (final address in _addresses) {
      if (address.isDefault && address.isActive) return address;
    }
    return _addresses.isNotEmpty ? _addresses.first : null;
  }

  List<Address> get activeAddresses {
    return _addresses.where((a) => a.isActive).toList();
  }

  List<Address> get addressesWithGps {
    return _addresses.where((a) => a.hasGps).toList();
  }

  List<Address> getHomeAddresses() =>
      _addresses.where((a) => a.type == 'home').toList();
  List<Address> getWorkAddresses() =>
      _addresses.where((a) => a.type == 'work').toList();
  List<Address> getShopAddresses() =>
      _addresses.where((a) => a.type == 'shop').toList();
  List<Address> getOtherAddresses() =>
      _addresses.where((a) => a.type == 'other').toList();

  // ============================================
  // CHARGEMENT (API)
  // ============================================

  Future<void> loadAddresses() async {
    _setStatus(AddressStatus.loading);
    _clearError();

    try {
      _addresses = await _addressRepository.getAddresses();
      _setStatus(AddressStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(AddressStatus.error);
    }

    notifyListeners();
  }

  Future<void> refreshAddresses() async {
    await loadAddresses();
  }

  // ============================================
  // AJOUT (API)
  // ============================================

  /// Ajouter une adresse côté serveur.
  /// Retourne l'adresse créée (avec son ID serveur).
  Future<Address?> addAddress({
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
  }) async {
    _setStatus(AddressStatus.saving);
    _clearError();

    try {
      final address = await _addressRepository.createAddress(
        fullName: fullName,
        phone: phone,
        email: email,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        type: type,
        isDefault: isDefault,
        latitude: latitude,
        longitude: longitude,
        deliveryInstructions: deliveryInstructions,
      );

      // Recharger la liste
      _addresses = await _addressRepository.getAddresses();
      _setStatus(AddressStatus.loaded);
      notifyListeners();
      return address;
    } catch (e) {
      _setError(e.toString());
      _setStatus(AddressStatus.error);
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // MODIFICATION (API)
  // ============================================

  /// Mettre à jour une adresse côté serveur.
  Future<bool> updateAddress({
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
  }) async {
    _setStatus(AddressStatus.saving);
    _updatingAddressId = id;
    _clearError();

    try {
      await _addressRepository.updateAddress(
        id: id,
        fullName: fullName,
        phone: phone,
        email: email,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        type: type,
        isDefault: isDefault,
        latitude: latitude,
        longitude: longitude,
        deliveryInstructions: deliveryInstructions,
      );

      // Recharger la liste
      _addresses = await _addressRepository.getAddresses();
      _updatingAddressId = -1;
      _setStatus(AddressStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingAddressId = -1;
      _setError(e.toString());
      _setStatus(AddressStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // SUPPRESSION (API)
  // ============================================

  Future<bool> removeAddress(int addressId) async {
    _setStatus(AddressStatus.deleting);
    _updatingAddressId = addressId;

    try {
      await _addressRepository.deleteAddress(addressId);
      _addresses = await _addressRepository.getAddresses();
      _updatingAddressId = -1;
      _setStatus(AddressStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingAddressId = -1;
      _setError(e.toString());
      _setStatus(AddressStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // ADRESSE PAR DÉFAUT (API)
  // ============================================

  Future<bool> setDefaultAddress(int addressId) async {
    _setStatus(AddressStatus.saving);
    _updatingAddressId = addressId;

    try {
      await _addressRepository.setDefaultAddress(addressId);
      _addresses = await _addressRepository.getAddresses();
      _updatingAddressId = -1;
      _setStatus(AddressStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingAddressId = -1;
      _setError(e.toString());
      _setStatus(AddressStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // RECHERCHE
  // ============================================

  Address? getAddressById(int addressId) {
    for (final address in _addresses) {
      if (address.id == addressId) {
        return address;
      }
    }
    return null;
  }

  // ============================================
  // ANNULATION (Undo - cache local)
  // ============================================

  Future<bool> undoLastAction() async {
    try {
      final restored = await _addressRepository.restoreAddressesSnapshot();
      if (restored != null) {
        _addresses = restored;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ============================================
  // EFFACEMENT
  // ============================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
  // MÉTHODES PRIVÉES
  // ============================================

  void _setStatus(AddressStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AddressProvider(status: $_status, addresses: ${_addresses.length}, '
        'default: ${defaultAddress?.id ?? 'none'}, updating: $_updatingAddressId)';
  }
}