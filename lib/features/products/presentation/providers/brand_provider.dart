// ============================================
// PROVIDER DES MARQUES
// ============================================
// Gère l'état des marques avec filtres,
// tri et recherche intelligente.
// ============================================

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
  String _searchQuery = '';
  String? _countryFilter;

  // ============================================
  // GETTERS DE BASE
  // ============================================

  BrandStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == BrandStatus.loading;
  bool get hasError => _status == BrandStatus.error;
  bool get hasBrands => _brands.isNotEmpty;
  bool get isEmpty => _brands.isEmpty;

  List<Brand> get brands => _brands;
  Brand? get selectedBrand => _selectedBrand;

  /// Nombre total de marques
  int get brandsCount => _brands.length;

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

  /// Marques triées par nom (A-Z)
  List<Brand> get brandsByName {
    final sorted = [..._brands];
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  /// Marques filtrées (recherche + pays)
  List<Brand> get filteredBrands {
    var result = [..._brands];

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      result = result.where((brand) {
        return brand.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            brand.slug.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (brand.country?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Filtre par pays
    if (_countryFilter != null) {
      result = result.where((brand) => brand.country == _countryFilter).toList();
    }

    return result;
  }

  /// Pays disponibles (déduits des marques)
  List<String> get availableCountries {
    final countries = _brands
        .where((brand) => brand.country != null && brand.country!.isNotEmpty)
        .map((brand) => brand.country!)
        .toSet()
        .toList();
    countries.sort();
    return countries;
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

  /// Sélectionner par ID
  void selectBrandById(int id) {
    _selectedBrand = getBrandById(id);
    notifyListeners();
  }

  /// Désélectionner la marque
  void clearSelection() {
    _selectedBrand = null;
    notifyListeners();
  }

  // ============================================
  // RECHERCHE & FILTRES
  // ============================================

  /// Définir la requête de recherche
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  /// Effacer la recherche
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Définir le filtre par pays
  void setCountryFilter(String? country) {
    _countryFilter = country;
    notifyListeners();
  }

  /// Effacer le filtre par pays
  void clearCountryFilter() {
    _countryFilter = null;
    notifyListeners();
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

  /// Filtrer par pays (méthode directe)
  List<Brand> filterByCountry(String country) {
    return _brands.where((brand) => brand.country == country).toList();
  }

  /// Récupérer les marques par pays
  List<Brand> getBrandsByCountry(String country) {
    return filterByCountry(country);
  }

  // ============================================
  // EFFACEMENT
  // ============================================

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
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

  @override
  String toString() {
    return 'BrandProvider(status: $_status, brands: ${_brands.length}, '
        'search: "$_searchQuery", country: $_countryFilter)';
  }
}