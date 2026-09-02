//Constantes globales de l'application
// 
// Toutes les constantes utilisées dans l'application.

class AppConstants {
  // 📱 Informations
  static const String appName = 'ShopPro';
  static const String appVersion = '1.0.0';
  
  // 🔑 Clés de stockage
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // ⏱️ Durées
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
  
  // 💰 Devise
  static const String currency = 'FCFA';
  static const String currencySymbol = 'FCFA';
  
  // 🚚 Livraison
  static const double deliveryFee = 2000;
  static const double freeDeliveryThreshold = 50000;
  
  // 📄 Pagination
  static const int itemsPerPage = 10;
  
  
}