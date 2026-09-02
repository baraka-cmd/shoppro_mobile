📦 FICHIER : docs/04-routes.md

---

```markdown
# 🧭 ROUTES - NAVIGATION - SHOPPRO

---

## 📋 FICHIERS DE ROUTES

| Fichier | Rôle |
|---------|------|
| `lib/routes/app_routes.dart` | Définition des noms de routes |
| `lib/routes/route_generator.dart` | Génération des routes avec paramètres |

---

## 🗺️ LISTE COMPLÈTE DES ROUTES

### 🚀 Démarrage
| Route | Constante | Écran |
|-------|-----------|-------|
| `/` | `splash` | SplashScreen |
| `/onboarding` | `onboarding` | OnboardingScreen |

### 🔐 Authentification
| Route | Constante | Écran |
|-------|-----------|-------|
| `/login` | `login` | LoginScreen |
| `/register` | `register` | RegisterScreen |
| `/forgot-password` | `forgotPassword` | ForgotPasswordScreen |

### 🏠 Principal
| Route | Constante | Écran |
|-------|-----------|-------|
| `/home` | `home` | HomeScreen |

### 👤 Profil
| Route | Constante | Écran |
|-------|-----------|-------|
| `/profile` | `profile` | ProfileScreen |
| `/profile/edit` | `editProfile` | EditProfileScreen |
| `/profile/change-password` | `changePassword` | ChangePasswordScreen |

### 🛒 Panier & Commandes
| Route | Constante | Écran |
|-------|-----------|-------|
| `/cart` | `cart` | CartScreen |
| `/checkout` | `checkout` | CheckoutScreen |
| `/orders` | `orders` | OrdersScreen |
| `/order/detail` | `orderDetail` | OrderDetailScreen |

### ❤️ Favoris
| Route | Constante | Écran |
|-------|-----------|-------|
| `/favorites` | `favorites` | FavoritesScreen |

### 📍 Adresses
| Route | Constante | Écran |
|-------|-----------|-------|
| `/addresses` | `addresses` | AddressListScreen |

### 📦 Produits & Catégories
| Route | Constante | Écran |
|-------|-----------|-------|
| `/product/list` | `productList` | ProductListScreen |
| `/product/detail` | `productDetail` | ProductDetailScreen |
| `/product/grid` | `productGrid` | ProductGridScreen |
| `/category/detail` | `categoryDetail` | CategoryDetailScreen |
| `/category/list` | `categoryList` | CategoryListScreen |

### 🔍 Recherche
| Route | Constante | Écran |
|-------|-----------|-------|
| `/search` | `search` | SearchScreen |

### 👑 Admin
| Route | Constante | Écran |
|-------|-----------|-------|
| `/admin/dashboard` | `adminDashboard` | AdminDashboard |
| `/admin/products` | `adminProducts` | AdminProducts |
| `/admin/users` | `adminUsers` | AdminUsers |
| `/admin/orders` | `adminOrders` | AdminOrders |
| `/admin/settings` | `adminSettings` | AdminSettings |

### 🏪 Vendeur
| Route | Constante | Écran |
|-------|-----------|-------|
| `/seller/dashboard` | `sellerDashboard` | SellerDashboard |
| `/seller/products` | `sellerProducts` | SellerProducts |
| `/seller/orders` | `sellerOrders` | SellerOrders |
| `/seller/stats` | `sellerStats` | SellerStats |

---

## 📝 ROUTES AVEC PARAMÈTRES

### ProductDetailScreen
```dart
Navigator.pushNamed(
  context,
  AppRoutes.productDetail,
  arguments: {'product_id': productId},
);
```

OrderDetailScreen

```dart
Navigator.pushNamed(
  context,
  AppRoutes.orderDetail,
  arguments: {'order_id': orderId},
);
```

CategoryDetailScreen

```dart
Navigator.pushNamed(
  context,
  AppRoutes.categoryDetail,
  arguments: {
    'category_id': categoryId,
    'category_name': categoryName,
  },
);
```

ProductListScreen

```dart
Navigator.pushNamed(
  context,
  AppRoutes.productList,
  arguments: {
    'title': 'Produits',
    'category_id': categoryId,  // Optionnel
    'brand_id': brandId,        // Optionnel
    'search_query': query,      // Optionnel
  },
);
```

---

🔄 NAVIGATION PAR RÔLE

Bottom Navigation (Client)

Index Onglet Route
0 Accueil Rien (reste)
1 Catégories /category/list
2 Panier /cart
3 Favoris /favorites
4 Profil /profile

Bottom Navigation (Vendeur)

Index Onglet Route
0 Dashboard /seller/dashboard
1 Produits /seller/products
2 Commandes /seller/orders
3 Stats /seller/stats
4 Profil /profile

Bottom Navigation (Admin)

Index Onglet Route
0 Dashboard /admin/dashboard
1 Produits /admin/products
2 Commandes /admin/orders
3 Utilisateurs /admin/users
4 Paramètres /admin/settings

---

🔧 ROUTES IMPLÉMENTÉES ✅ / À VENIR ❌

Route Statut
SplashScreen ✅
OnboardingScreen ✅
LoginScreen ✅
RegisterScreen ✅
ForgotPasswordScreen ✅
HomeScreen ✅
CartScreen ✅
CheckoutScreen ✅
OrdersScreen ✅
OrderDetailScreen ✅
FavoritesScreen ✅
ProductListScreen ✅
ProductDetailScreen ✅
CategoryListScreen ✅
CategoryDetailScreen ✅
SearchScreen ✅
ProfileScreen ✅
EditProfileScreen ✅
ChangePasswordScreen ✅
AddressListScreen ❌ À créer
Admin Dashboard ❌ À créer
Admin Products ❌ À créer
Admin Users ❌ À créer
Seller Dashboard ❌ À créer
Seller Products ❌ À créer

```

---

## 📋 RÉSUMÉ

Ce fichier documente :
- ✅ Les 30+ routes
- ✅ Les paramètres
- ✅ La navigation par rôle
- ✅ Les routes implémentées vs à venir
```

---

---

## 🔄 ROUTES AJOUTÉES (31/08/2026)

### 💳 Paiement
| Route | Constante | Écran |
|-------|-----------|-------|
| `/payment` | `payment` | PaymentScreen |

### 🔔 Notifications
| Route | Constante | Écran |
|-------|-----------|-------|
| `/notifications` | `notifications` | NotificationsScreen |

### 📦 Stock
| Route | Constante | Écran |
|-------|-----------|-------|
| `/stock/detail` | `stockDetail` | StockDetailScreen |

### 📍 Adresses
| Route | Constante | Écran |
|-------|-----------|-------|
| `/addresses` | `addresses` | AddressListScreen |
| `/address/form` | `addressForm` | AddressFormScreen |