// Provider des marques
// Gère l'état des marques dans l'application

import 'package:flutter/foundation.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';

enum BrandStatus {
  initial,
  loading,
  loaded,
  error,
}

class BrandProvider extends ChangeNotifier {
  final ProductRepository _productRepository;

  BrandProvider({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  BrandStatus _status = BrandStatus.initial;
  String? _errorMessage;

  // ============================================
  // LISTES
  // ============================================

  List<Brand> _brands = [];
  Brand? _selectedBrand;

  // ============================================
  // GETTERS
  // ============================================

  BrandStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == BrandStatus.loading;
  bool get hasError => _status == BrandStatus.error;
  bool get hasBrands => _brands.isNotEmpty;

  List<Brand> get brands => _brands;
  Brand? get selectedBrand => _selectedBrand;

  /// Marques en vedette
  List<Brand> get featuredBrands {
    return _brands.where((brand) => brand.isFeatured).toList();
  }

  /// Marques actives
  List<Brand> get activeBrands {
    return _brands.where((brand) => brand.isActive).toList();
  }

  /// Marques avec produits
  List<Brand> get brandsWithProducts {
    return _brands.where((brand) => brand.hasProducts).toList();
  }

  /// Marques triées par note
  List<Brand> get brandsByRating {
    final sorted = [..._brands];
    sorted.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return sorted;
  }

  /// Marques triées par nombre de produits
  List<Brand> get brandsByProductsCount {
    final sorted = [..._brands];
    sorted.sort((a, b) => b.productsCount.compareTo(a.productsCount));
    return sorted;
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  /// Charger toutes les marques
  Future<void> loadBrands() async {
    _setStatus(BrandStatus.loading);
    _clearError();

    try {
      _brands = await _productRepository.getBrands();
      _setStatus(BrandStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(BrandStatus.error);
    }

    notifyListeners();
  }

  /// Rafraîchir les marques
  Future<void> refreshBrands() async {
    await loadBrands();
  }

  // ============================================
  // SÉLECTION
  // ============================================

  /// Sélectionner une marque
  void selectBrand(Brand? brand) {
    _selectedBrand = brand;
    notifyListeners();
  }

  /// Désélectionner la marque
  void clearSelection() {
    _selectedBrand = null;
    notifyListeners();
  }

  // ============================================
  // RECHERCHE
  // ============================================

  /// Rechercher une marque par nom
  List<Brand> searchBrands(String query) {
    if (query.trim().isEmpty) {
      return _brands;
    }

    return _brands.where((brand) {
      return brand.name.toLowerCase().contains(query.toLowerCase()) ||
          brand.slug.toLowerCase().contains(query.toLowerCase()) ||
          (brand.country?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  /// Rechercher une marque par ID
  Brand? getBrandById(int id) {
    for (final brand in _brands) {
      if (brand.id == id) {
        return brand;
      }
    }
    return null;
  }

  /// Filtrer par pays
  List<Brand> filterByCountry(String country) {
    return _brands.where((brand) => brand.country == country).toList();
  }

  /// Récupérer les pays disponibles
  List<String> get availableCountries {
    final countries = _brands
        .where((brand) => brand.country != null)
        .map((brand) => brand.country!)
        .toSet()
        .toList();
    countries.sort();
    return countries;
  }

  // ============================================
  // MÉTHODES PRIVÉES
  // ============================================

  void _setStatus(BrandStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }
}