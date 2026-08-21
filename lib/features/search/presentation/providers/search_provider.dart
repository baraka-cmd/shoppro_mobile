// Provider de recherche
// Gère l'état de la recherche, les suggestions et l'historique

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../products/data/repositories/product_repository_impl.dart';

enum SearchStatus {
  initial,
  searching,
  results,
  suggestions,
  error,
  empty,
}

class SearchProvider extends ChangeNotifier {
  final ProductRepository _productRepository;

  SearchProvider({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepositoryImpl();

  // État
  SearchStatus _status = SearchStatus.initial;
  String _query = '';
  String? _errorMessage;
  List<Product> _results = [];
  List<Product> _suggestions = [];
  List<String> _history = [];

  // Getters
  SearchStatus get status => _status;
  String get query => _query;
  String? get errorMessage => _errorMessage;
  List<Product> get results => _results;
  List<Product> get suggestions => _suggestions;
  List<String> get history => _history;
  bool get isSearching => _status == SearchStatus.searching;
  bool get hasResults => _results.isNotEmpty;
  bool get hasSuggestions => _suggestions.isNotEmpty;

  /// Rechercher des produits
  Future<void> search(String query) async {
    _query = query.trim();

    if (_query.isEmpty) {
      _status = SearchStatus.initial;
      _results = [];
      _suggestions = [];
      notifyListeners();
      return;
    }

    _status = SearchStatus.searching;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _productRepository.searchProducts(query: _query);

      if (results.isEmpty) {
        _status = SearchStatus.empty;
      } else {
        _status = SearchStatus.results;
        _results = results;
      }

      // Sauvegarder dans l'historique
      await _addToHistory(_query);
    } catch (e) {
      _status = SearchStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Rechercher des suggestions (debounce)
  Future<void> searchSuggestions(String query) async {
    _query = query.trim();

    if (_query.isEmpty) {
      _status = SearchStatus.initial;
      _suggestions = [];
      notifyListeners();
      return;
    }

    try {
      final suggestions = await _productRepository.searchProducts(
        query: _query,
        perPage: 5,
      );

      _suggestions = suggestions;
      _status = SearchStatus.suggestions;
    } catch (e) {
      _suggestions = [];
    }

    notifyListeners();
  }

  /// Effacer la recherche
  void clearSearch() {
    _query = '';
    _results = [];
    _suggestions = [];
    _status = SearchStatus.initial;
    notifyListeners();
  }

  /// Filtrer avec filtres avancés
  Future<void> searchWithFilters({
    required String query,
    int? categoryId,
    int? brandId,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    double? minRating,
    bool? onSale,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
  }) async {
    _status = SearchStatus.searching;
    notifyListeners();

    try {
      final results = await _productRepository.filterProducts(
        categoryId: categoryId,
        brandId: brandId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        inStock: inStock,
        minRating: minRating,
        onSale: onSale,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );

      _results = results;
      _status = results.isEmpty ? SearchStatus.empty : SearchStatus.results;
    } catch (e) {
      _status = SearchStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Trier les résultats
  void sortResults(String sortBy, String sortDirection) {
    switch (sortBy) {
      case 'price':
        _results.sort((a, b) => sortDirection == 'asc'
            ? a.currentPrice.compareTo(b.currentPrice)
            : b.currentPrice.compareTo(a.currentPrice));
        break;
      case 'rating':
        _results.sort((a, b) => sortDirection == 'asc'
            ? a.averageRating.compareTo(b.averageRating)
            : b.averageRating.compareTo(a.averageRating));
        break;
      case 'popularity':
        _results.sort((a, b) => sortDirection == 'asc'
            ? a.salesCount.compareTo(b.salesCount)
            : b.salesCount.compareTo(a.salesCount));
        break;
      default:
        break;
    }

    notifyListeners();
  }

  /// Charger l'historique depuis SharedPreferences
  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _history = prefs.getStringList('search_history') ?? [];
    notifyListeners();
  }

  /// Effacer l'historique
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    _history = [];
    notifyListeners();
  }

  /// Ajouter une recherche à l'historique
  Future<void> _addToHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('search_history') ?? [];

    // Supprimer si déjà présent
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());

    // Ajouter au début
    history.insert(0, query);

    // Limiter à 10 éléments
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    await prefs.setStringList('search_history', history);

    // Mettre à jour la liste en mémoire
    _history = history;
  }
}