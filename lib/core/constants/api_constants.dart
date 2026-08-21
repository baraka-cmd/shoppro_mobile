//Constantes de l'API
//
// Ce fichier centralise toutes les URLs et endpoints de l'API.
// En production, utilisez une configuration sécurisée.

class ApiConstants {
  // 🖥️ URL de base de l'API
  // ⚠️ Pour émulateur Android, utilisez 10.0.2.2 au lieu de localhost
  // ⚠️ Pour appareil physique, utilisez l'IP de votre machine
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  
  // 🔐 Endpoints d'authentification
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
  // Dans ApiConstants, ajoute :
  static const String refreshToken = '/auth/refresh-token';
  
  // ⏱️ Timeouts
  static const int connectionTimeout = 30000; // 30 secondes
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // 📦 Endpoints des produits
static const String products = '/products';
static const String productDetails = '/products/';
static const String featuredProducts = '/products/featured';
static const String popularProducts = '/products/popular';
static const String recentProducts = '/products/recent';
static const String onSaleProducts = '/products/on-sale';
static const String searchProducts = '/products/search';
static const String filterProducts = '/products/filter';

// 🏷️ Endpoints des catégories
static const String categories = '/categories';
static const String categoryDetails = '/categories/';
static const String categoryProducts = '/categories/';
static const String categorySubcategories = '/categories/';

// 🏷️ Endpoints des marques
static const String brands = '/brands';
static const String brandDetails = '/brands/';
static const String brandProducts = '/brands/';
}