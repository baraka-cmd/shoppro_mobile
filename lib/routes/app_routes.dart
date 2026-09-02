// ============================================
// ROUTES DE L'APPLICATION
// ============================================
// Définition de tous les noms de routes utilisés
// dans la navigation de l'application ShopPro.
// ============================================

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
  static const String addressForm = '/address/form';
  
  // ============================================
  // 📦 PRODUITS & CATÉGORIES
  // ============================================
  static const String productList = '/product/list';
  static const String productDetail = '/product/detail';
  static const String productGrid = '/product/grid';
  static const String categoryDetail = '/category/detail';
  static const String categoryList = '/categories';
  
  // ============================================
  // 🔍 RECHERCHE
  // ============================================
  static const String search = '/search';
  
  // ============================================
  // 💳 PAIEMENT
  // ============================================
  static const String payment = '/payment';
  
  // ============================================
  // 🔔 NOTIFICATIONS
  // ============================================
  static const String notifications = '/notifications';
  
  // ============================================
  // 📦 STOCK
  // ============================================
  static const String stockDetail = '/stock/detail';
  
  // ============================================
  // 👑 ROUTES ADMIN - DASHBOARD
  // ============================================
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStats = '/admin/stats';
  static const String adminSalesReport = '/admin/stats/sales-report';
  static const String adminNotifications = '/admin/notifications';
  
  // ============================================
  // 👑 ROUTES ADMIN - PRODUITS
  // ============================================
  static const String adminProducts = '/admin/products';
  static const String adminProductForm = '/admin/products/form';
  
  // ============================================
  // 👑 ROUTES ADMIN - CATÉGORIES
  // ============================================
  static const String adminCategories = '/admin/categories';
  static const String adminCategoryForm = '/admin/categories/form';
  
  // ============================================
  // 👑 ROUTES ADMIN - MARQUES
  // ============================================
  static const String adminBrands = '/admin/brands';
  static const String adminBrandForm = '/admin/brands/form';
  
  // ============================================
  // 👑 ROUTES ADMIN - COMMANDES
  // ============================================
  static const String adminOrders = '/admin/orders';
  static const String adminOrderDetail = '/admin/orders/detail';
  
  // ============================================
  // 👑 ROUTES ADMIN - UTILISATEURS
  // ============================================
  static const String adminUsers = '/admin/users';
  static const String adminUserDetail = '/admin/users/detail';
  
  // ============================================
  // 👑 ROUTES ADMIN - STOCKS
  // ============================================
  static const String adminStocks = '/admin/stocks';
  static const String adminStockMovements = '/admin/stocks/movements';
  
  // ============================================
  // 👑 ROUTES ADMIN - PROMOTIONS
  // ============================================
  static const String adminPromotions = '/admin/promotions';
  static const String adminPromotionForm = '/admin/promotions/form';
  
  // ============================================
  // 👑 ROUTES ADMIN - AVIS
  // ============================================
  static const String adminReviews = '/admin/reviews';
  
  // ============================================
  // 👑 ROUTES ADMIN - BANNIÈRES
  // ============================================
  static const String adminBanners = '/admin/banners';
  static const String adminBannerForm = '/admin/banners/form';
  
  // ============================================
  // 👑 ROUTES ADMIN - PARAMÈTRES
  // ============================================
  static const String adminSettings = '/admin/settings';
  
  // ============================================
  // 🏪 ROUTES VENDEUR
  // ============================================
  static const String sellerDashboard = '/seller/dashboard';
  static const String sellerProducts = '/seller/products';
  static const String sellerOrders = '/seller/orders';
  static const String sellerStats = '/seller/stats';
}