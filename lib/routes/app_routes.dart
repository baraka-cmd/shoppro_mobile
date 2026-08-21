// Routes de l'application
// Définition des noms de routes utilisés dans la navigation

class AppRoutes {
  // ============================================
  // 🚀 DÉMARRAGE
  // ============================================
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  
  // ============================================
  // 🔐 AUTHENTIFICATION
  // ============================================
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // ============================================
  // 🏠 PRINCIPAL
  // ============================================
  static const String home = '/home';
  
  // ============================================
  // 👤 PROFIL
  // ============================================
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  
  // ============================================
  // 🛒 PANIER & COMMANDES
  // ============================================
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetail = '/order/detail';
  
  // ============================================
  // ❤️ FAVORIS
  // ============================================
  static const String favorites = '/favorites';
  
  // ============================================
  // 📍 ADRESSES
  // ============================================
  static const String addresses = '/addresses';
  
  // ============================================
  // 📦 PRODUITS & CATÉGORIES
  // ============================================
  static const String productList = '/product/list';
  static const String productDetail = '/product/detail';
  static const String productGrid = '/product/grid';
  static const String categoryDetail = '/category/detail';
  
  // ============================================
  // 👑 ROUTES ADMIN
  // ============================================
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProducts = '/admin/products';
  static const String adminUsers = '/admin/users';
  static const String adminOrders = '/admin/orders';
  static const String adminSettings = '/admin/settings';

  // ============================================
  // 🏪 ROUTES VENDEUR
  // ============================================
  static const String sellerDashboard = '/seller/dashboard';
  static const String sellerProducts = '/seller/products';
  static const String sellerOrders = '/seller/orders';
  static const String sellerStats = '/seller/stats';

  // ============================================
  // 👤 ROUTES CLIENT
  // ============================================
  static const String clientCart = '/cart';
  static const String clientCheckout = '/checkout';
  static const String clientOrders = '/orders';
  static const String clientFavorites = '/favorites';
  static const String clientAddresses = '/addresses';

  // Ajouter
static const String categoryList = '/categories';

static const String search = '/search';



}