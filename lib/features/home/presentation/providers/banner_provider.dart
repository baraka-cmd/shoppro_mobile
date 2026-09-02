// Provider des bannières
// Gère l'état des bannières et les actions

import 'package:flutter/foundation.dart';
import '../../data/models/banner_model.dart';
import '../../data/sources/banner_api.dart';

enum BannerStatus {
  initial,
  loading,
  loaded,
  error,
}

class BannerProvider extends ChangeNotifier {
  final BannerApi _bannerApi;

  BannerProvider({BannerApi? bannerApi})
      : _bannerApi = bannerApi ?? BannerApi();

  BannerStatus _status = BannerStatus.initial;
  List<BannerModel> _banners = [];
  List<BannerModel> _homeTopBanners = [];
  List<BannerModel> _homeMiddleBanners = [];
  List<BannerModel> _homeBottomBanners = [];
  String? _errorMessage;

  // Getters
  BannerStatus get status => _status;
  List<BannerModel> get banners => _banners;
  List<BannerModel> get homeTopBanners => _homeTopBanners;
  List<BannerModel> get homeMiddleBanners => _homeMiddleBanners;
  List<BannerModel> get homeBottomBanners => _homeBottomBanners;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == BannerStatus.loading;
  bool get hasError => _status == BannerStatus.error;
  bool get isEmpty => _banners.isEmpty;

  /// Charger toutes les bannières
  Future<void> loadBanners() async {
    _setStatus(BannerStatus.loading);
    _clearError();

    try {
      _banners = await _bannerApi.getBanners();

      // Filtrer par position
      _homeTopBanners = _banners.where((b) => b.position == 'home_top').toList();
      _homeMiddleBanners = _banners.where((b) => b.position == 'home_middle').toList();
      _homeBottomBanners = _banners.where((b) => b.position == 'home_bottom').toList();

      _setStatus(BannerStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(BannerStatus.error);
    }

    notifyListeners();
  }

  /// Charger les bannières du haut
  Future<void> loadHomeTopBanners() async {
    _setStatus(BannerStatus.loading);

    try {
      _homeTopBanners = await _bannerApi.getBannersByPosition('home_top');
      _setStatus(BannerStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(BannerStatus.error);
    }

    notifyListeners();
  }

  /// Rafraîchir les bannières
  Future<void> refreshBanners() async {
    await loadBanners();
  }

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
// CRUD BANNIÈRES
// ============================================

/// Crée une nouvelle bannière.
Future<bool> createBanner(Map<String, dynamic> data) async {
  try {
    // Utiliser le mécanisme existant du provider
    final banners = _banners;
    banners.insert(0, BannerModel.fromJson(data));
    _banners = banners;
    _status = BannerStatus.loaded;
    notifyListeners();
    return true;
  } catch (e) {
    debugPrint('Erreur createBanner: $e');
    notifyListeners();
    return false;
  }
}

/// Met à jour une bannière.
Future<bool> updateBanner(int id, Map<String, dynamic> data) async {
  try {
    final index = _banners.indexWhere((b) => b.id == id);
    if (index != -1) {
      _banners[index] = BannerModel.fromJson({...data, 'id': id});
      notifyListeners();
    }
    return true;
  } catch (e) {
    debugPrint('Erreur updateBanner: $e');
    notifyListeners();
    return false;
  }
}

/// Supprime une bannière.
Future<bool> deleteBanner(int id) async {
  try {
    _banners.removeWhere((b) => b.id == id);
    notifyListeners();
    return true;
  } catch (e) {
    debugPrint('Erreur deleteBanner: $e');
    notifyListeners();
    return false;
  }
}

  // Méthodes privées
  void _setStatus(BannerStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }
}