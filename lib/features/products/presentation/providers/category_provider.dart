// ============================================
// PROVIDER DES CATÉGORIES
// ============================================
// Gère l'état des catégories avec recherche,
// filtres et sélection intelligente.
// ============================================

import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';

enum CategoryStatus {
  initial,
  loading,
  loaded,
  error,
}

class CategoryProvider extends ChangeNotifier {
  final ProductRepository _productRepository;

  CategoryProvider({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  CategoryStatus _status = CategoryStatus.initial;
  String? _errorMessage;

  // ============================================
  // LISTES
  // ============================================

  List<Category> _categories = [];
  Category? _selectedCategory;
  String _searchQuery = '';

  // ============================================
  // GETTERS DE BASE
  // ============================================

  CategoryStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CategoryStatus.loading;
  bool get hasError => _status == CategoryStatus.error;
  bool get hasCategories => _categories.isNotEmpty;
  bool get isEmpty => _categories.isEmpty;

  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;

  /// Nombre total de catégories
  int get categoriesCount => _categories.length;

  /// Catégories racines (sans parent)
  List<Category> get rootCategories {
    return _categories.where((category) => category.isRoot).toList();
  }

  /// Catégories enfants (avec parent)
  List<Category> get childCategories {
    return _categories.where((category) => !category.isRoot).toList();
  }

  /// Catégories en vedette
  List<Category> get featuredCategories {
    return _categories.where((category) => category.isFeatured).toList();
  }

  /// Catégories actives
  List<Category> get activeCategories {
    return _categories.where((category) => category.isActive).toList();
  }

  /// Catégories avec produits
  List<Category> get categoriesWithProducts {
    return _categories.where((category) => category.effectiveProductsCount > 0).toList();
  }

  /// Catégories triées par position
  List<Category> get categoriesByPosition {
    final sorted = [..._categories];
    sorted.sort((a, b) => a.position.compareTo(b.position));
    return sorted;
  }

  /// Catégories triées par nombre de produits
  List<Category> get categoriesByProductsCount {
    final sorted = [..._categories];
    sorted.sort((a, b) => b.effectiveProductsCount.compareTo(a.effectiveProductsCount));
    return sorted;
  }

  /// Catégories filtrées (recherche)
  List<Category> get filteredCategories {
    if (_searchQuery.isEmpty) {
      return _categories;
    }

    return _categories.where((category) {
      return category.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          category.slug.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (category.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  /// Charger toutes les catégories
  Future<void> loadCategories() async {
    _setStatus(CategoryStatus.loading);
    _clearError();

    try {
      _categories = await _productRepository.getCategories();
      _setStatus(CategoryStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(CategoryStatus.error);
    }

    notifyListeners();
  }

  /// Rafraîchir les catégories
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  // ============================================
  // SÉLECTION
  // ============================================

  /// Sélectionner une catégorie
  void selectCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Sélectionner par ID
  void selectCategoryById(int id) {
    _selectedCategory = getCategoryById(id);
    notifyListeners();
  }

  /// Désélectionner la catégorie
  void clearSelection() {
    _selectedCategory = null;
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

  /// Rechercher une catégorie par ID
  Category? getCategoryById(int id) {
    for (final category in _categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  /// Récupérer les catégories parentes
  List<Category> getParentCategories() {
    return _categories.where((category) => category.isRoot).toList();
  }

  /// Récupérer les catégories enfants d'une catégorie
  List<Category> getChildCategories(int parentId) {
    return _categories.where((category) => category.parentId == parentId).toList();
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

  void _setStatus(CategoryStatus newStatus) {
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
    return 'CategoryProvider(status: $_status, categories: ${_categories.length}, '
        'search: "$_searchQuery")';
  }
}