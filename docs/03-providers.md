📦 FICHIER : docs/03-providers.md

---

```markdown
# 🔄 PROVIDERS - GESTION D'ÉTAT - SHOPPRO

---

## 📋 LISTE DE TOUS LES PROVIDERS

| Provider | Fichier | État géré |
|----------|---------|-----------|
| AuthProvider | `auth_provider.dart` | Authentification |
| ProductProvider | `product_provider.dart` | Produits |
| CategoryProvider | `category_provider.dart` | Catégories |
| BrandProvider | `brand_provider.dart` | Marques |
| SearchProvider | `search_provider.dart` | Recherche |
| CartProvider | `cart_provider.dart` | Panier |
| FavoriteProvider | `favorite_provider.dart` | Favoris |
| OrderProvider | `order_provider.dart` | Commandes |

---

## 🔐 AuthProvider

### Fichier : `features/auth/presentation/providers/auth_provider.dart`

### États
```dart
enum AuthStatus {
  initial,        // État initial
  loading,        // Chargement
  authenticated,  // Connecté
  unauthenticated, // Déconnecté
  error,          // Erreur
}
```

Actions principales

· init() - Vérifier si connecté au démarrage
· register() - Inscription
· login() - Connexion
· logout() - Déconnexion
· updateProfile() - Modifier profil
· changePassword() - Changer mot de passe
· forgotPassword() - Mot de passe oublié

Getters

· isAuthenticated - Connecté ?
· isAdmin - Est admin ?
· isSeller - Est vendeur ?
· isClient - Est client ?
· user - Utilisateur actuel
· errorMessage - Message d'erreur

---

📦 ProductProvider

Fichier : features/products/presentation/providers/product_provider.dart

États

```dart
enum ProductStatus {
  initial,
  loading,
  loaded,
  loadingMore,  // Pagination
  error,
}
```

Actions principales

· loadProducts() - Charger page 1
· loadMoreProducts() - Charger page suivante
· loadFeaturedProducts() - Produits en vedette
· loadPopularProducts() - Produits populaires
· loadRecentProducts() - Produits récents
· loadOnSaleProducts() - Produits en promo
· loadAllSections() - Tout charger
· searchProducts() - Rechercher
· filterProducts() - Filtrer
· loadSimilarProducts() - Produits similaires
· refreshProducts() - Rafraîchir

Getters

· products - Liste principale
· featuredProducts - En vedette
· popularProducts - Populaires
· recentProducts - Récents
· onSaleProducts - En promo
· searchResults - Résultats recherche
· similarProducts - Similaires
· hasMore - Plus de pages ?
· currentPage - Page actuelle

---

🏷️ CategoryProvider

Fichier : features/products/presentation/providers/category_provider.dart

États

```dart
enum CategoryStatus {
  initial,
  loading,
  loaded,
  error,
}
```

Actions principales

· loadCategories() - Charger
· refreshCategories() - Rafraîchir
· selectCategory() - Sélectionner
· clearSelection() - Désélectionner
· searchCategories() - Rechercher
· getCategoryById() - Par ID

Getters

· categories - Toutes les catégories
· rootCategories - Catégories racines
· featuredCategories - En vedette
· activeCategories - Actives
· selectedCategory - Sélectionnée

---

🏪 BrandProvider

Fichier : features/products/presentation/providers/brand_provider.dart

États

```dart
enum BrandStatus {
  initial,
  loading,
  loaded,
  error,
}
```

Actions principales

· loadBrands() - Charger
· refreshBrands() - Rafraîchir
· selectBrand() - Sélectionner
· clearSelection() - Désélectionner
· searchBrands() - Rechercher
· getBrandById() - Par ID
· filterByCountry() - Par pays

Getters

· brands - Toutes les marques
· featuredBrands - En vedette
· activeBrands - Actives
· brandsWithProducts - Avec produits
· brandsByRating - Triées par note
· availableCountries - Pays disponibles

---

🔍 SearchProvider

Fichier : features/search/presentation/providers/search_provider.dart

États

```dart
enum SearchStatus {
  initial,
  searching,
  results,
  suggestions,
  error,
  empty,
}
```

Actions principales

· search() - Recherche complète
· searchSuggestions() - Suggestions
· searchWithFilters() - Filtres avancés
· sortResults() - Trier
· clearSearch() - Effacer
· loadHistory() - Charger historique
· clearHistory() - Effacer historique

Getters

· results - Résultats
· suggestions - Suggestions
· history - Historique
· query - Requête actuelle
· isSearching - Recherche en cours

---

🛒 CartProvider

Fichier : features/cart/presentation/providers/cart_provider.dart

États

```dart
enum CartStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}
```

Actions principales

· loadCart() - Charger
· addItem() - Ajouter article
· removeItem() - Supprimer
· updateQuantity() - Modifier quantité
· incrementQuantity() - +1
· decrementQuantity() - -1
· clearCart() - Vider
· saveForLater() - Sauvegarder pour plus tard
· moveToCart() - Remettre dans panier
· applyCoupon() - Appliquer code promo
· removeCoupon() - Retirer code promo
· restoreAbandonedCart() - Restaurer panier abandonné

Getters

· cart - Panier complet
· totalQuantity - Quantité totale
· totalItems - Nombre d'articles
· subtotal - Sous-total
· total - Total final
· isEmpty - Panier vide ?

---

❤️ FavoriteProvider

Fichier : features/favorites/presentation/providers/favorite_provider.dart

États

```dart
enum FavoriteStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}
```

Actions principales

· loadFavorites() - Charger
· addFavorite() - Ajouter
· removeFavorite() - Supprimer
· toggleFavorite() - Toggle
· isFavorite() - Vérifier
· togglePriceAlert() - Alerte prix
· clearFavorites() - Tout vider

Getters

· favorites - Tous les favoris
· inStockFavorites - En stock
· onSaleFavorites - En promo
· priceAlertFavorites - Avec alerte
· favoritesCount - Compteur

---

📦 OrderProvider

Fichier : features/orders/presentation/providers/order_provider.dart

États

```dart
enum OrderStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  error,
}
```

Actions principales

· loadOrders() - Charger
· createOrder() - Créer commande
· cancelOrder() - Annuler
· returnOrder() - Retourner
· getOrderById() - Par ID
· getOrderTimeline() - Timeline

Getters

· orders - Toutes les commandes
· activeOrders - En cours
· deliveredOrders - Livrées
· cancelledOrders - Annulées
· ordersCount - Compteur

---

📝 ENREGISTREMENT DANS main.dart

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
    ChangeNotifierProvider<ProductProvider>(create: (_) => ProductProvider()),
    ChangeNotifierProvider<CategoryProvider>(create: (_) => CategoryProvider()),
    ChangeNotifierProvider<BrandProvider>(create: (_) => BrandProvider()),
    ChangeNotifierProvider<SearchProvider>(create: (_) => SearchProvider()),
    ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
    ChangeNotifierProvider<FavoriteProvider>(create: (_) => FavoriteProvider()),
    ChangeNotifierProvider<OrderProvider>(create: (_) => OrderProvider()),
  ],
  child: const ShopProApp(),
)
```

```

---

## 📋 RÉSUMÉ

Ce fichier documente :
- ✅ Les 8 providers
- ✅ Leurs états
- ✅ Leurs actions
- ✅ Leurs getters
- ✅ Leur enregistrement

---

---

## 🔄 PROVIDERS AJOUTÉS (31/08/2026)

### AddressProvider
- **Fichier** : `features/addresses/presentation/providers/address_provider.dart`
- **Actions** : loadAddresses, addAddress, updateAddress, removeAddress, setDefaultAddress
- **Getters** : addresses, defaultAddress, addressesCount

### PaymentProvider
- **Fichier** : `features/payment/presentation/providers/payment_provider.dart`
- **Actions** : createPayment, simulatePayment, confirmPayment, failPayment, refundPayment, generateReceipt
- **États** : initial, loading, loaded, processing, success, failed, error

### NotificationProvider
- **Fichier** : `features/notifications/presentation/providers/notification_provider.dart`
- **Actions** : loadNotifications, addNotification, markAsRead, markAllAsRead, removeNotification, clearAll
- **Getters** : notifications, unreadCount, totalCount

### BannerProvider
- **Fichier** : `features/home/presentation/providers/banner_provider.dart`
- **Actions** : loadBanners, loadHomeTopBanners, refreshBanners
- **Getters** : banners, homeTopBanners, homeMiddleBanners, homeBottomBanners

### StockProvider
- **Fichier** : `features/stock/presentation/providers/stock_provider.dart`
- **Actions** : loadStocks, loadMovements, reserveStock, releaseStock, adjustStock, hasStockAlert
- **Getters** : stocks, movements, lowStocks, outOfStock, lowStockCount