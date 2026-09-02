// ============================================
// CONSTANTES DE L'API - VERSION COMPLÈTE
// ============================================
// Ce fichier centralise toutes les URLs et endpoints de l'API.
// En production, utilisez une configuration sécurisée.
// ============================================

class ApiConstants {
  // 🖥️ URL de base de l'API
  // ⚠️ Pour émulateur Android, utilisez 10.0.2.2 au lieu de localhost
  // ⚠️ Pour appareil physique, utilisez l'IP de votre machine
  static const String baseUrl = 'http://127.0.0.1:8001/api/v1';

  // ⏱️ Timeouts
  static const int connectionTimeout = 30000; // 30 secondes
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // ============================================
  // 🔐 AUTHENTIFICATION
  // ============================================
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/profile';
  static const String changePassword = '/auth/change-password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String uploadAvatar = '/auth/upload-avatar';
  static const String checkToken = '/auth/check-token';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String refreshToken = '/auth/refresh-token';

  // ============================================
  // 📦 PRODUITS
  // ============================================
  static const String products = '/products';
  static const String productDetails = '/products/';
  static const String featuredProducts = '/products/featured';
  static const String popularProducts = '/products/popular';
  static const String recentProducts = '/products/recent';
  static const String onSaleProducts = '/products/on-sale';
  static const String searchProducts = '/products/search';
  static const String filterProducts = '/products/filter';

  // ============================================
  // 🏷️ CATÉGORIES
  // ============================================
  static const String categories = '/categories';
  static const String categoryDetails = '/categories/';
  static const String categoryProducts = '/categories/';
  static const String categorySubcategories = '/categories/';

  // ============================================
  // 🏷️ MARQUES
  // ============================================
  static const String brands = '/brands';
  static const String brandDetails = '/brands/';
  static const String brandProducts = '/brands/';

  // ============================================
  // 👑 ADMIN - CATÉGORIES
  // ============================================
  static const String adminCategories = '/admin/categories';

  // ============================================
  // 👑 ADMIN - MARQUES
  // ============================================
  static const String adminBrands = '/admin/brands';

  // ============================================
  // 👑 ADMIN - PRODUITS
  // ============================================
  static const String adminProducts = '/admin/products';

  
}