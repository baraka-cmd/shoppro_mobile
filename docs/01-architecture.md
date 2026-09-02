📦 FICHIER : docs/01-architecture.md

---

```markdown
# 🏗️ ARCHITECTURE DU PROJET - SHOPPRO

---

## 📐 ARCHITECTURE GÉNÉRALE

ShopPro utilise une architecture **Clean Architecture** adaptée à Flutter.

```

┌─────────────────────────────────────────────────┐
│              PRÉSENTATION (UI)                  │
│         Widgets, Screens, Pages                 │
│         Providers (ChangeNotifier)              │
└──────────────────┬──────────────────────────────┘
↓
┌─────────────────────────────────────────────────┐
│              DOMAINE (Business Logic)           │
│         Entities, Repositories (Interfaces)     │
└──────────────────┬──────────────────────────────┘
↓
┌─────────────────────────────────────────────────┐
│              DATA (Implémentation)              │
│         Models, Repositories Impl, Sources      │
│         (API Local, Remote)                     │
└─────────────────────────────────────────────────┘

```

---

## 📂 STRUCTURE PAR FEATURE

Chaque feature suit la même structure :

```

lib/features/[feature_name]/
├── domain/                    # Couche métier
│   ├── entities/              # Entités pures (pas de dépendances)
│   │   └── [entity].dart
│   └── repositories/          # Interfaces des repositories
│       └── [repository].dart
│
├── data/                      # Couche données
│   ├── models/                # Modèles avec JSON
│   │   └── [model].dart
│   ├── repositories/          # Implémentations
│   │   └── [repository]_impl.dart
│   └── sources/               # Sources de données
│       ├── [local]_data_source.dart
│       └── [api].dart
│
└── presentation/              # Couche UI
├── pages/                 # Écrans
│   └── [screen].dart
├── widgets/               # Widgets spécifiques
│   └── [widget].dart
└── providers/             # Providers d'état
└── [provider].dart

```

---

## 📋 LISTE DES FEATURES

| Feature | Dossier | Description |
|---------|---------|-------------|
| Auth | `features/auth/` | Authentification et gestion utilisateur |
| Products | `features/products/` | Catalogue produits |
| Categories | `features/categories/` | Navigation par catégories |
| Search | `features/search/` | Recherche et filtres |
| Cart | `features/cart/` | Panier d'achat |
| Favorites | `features/favorites/` | Liste de souhaits |
| Orders | `features/orders/` | Commandes et checkout |
| Navigation | `features/navigation/` | Menu selon rôle |
| Profile | `features/profile/` | Écran profil utilisateur |
| Home | `features/home/` | Écran d'accueil |

---

## 🔄 FLUX DE DONNÉES

### 1. Récupération des produits

```

ProductProvider
↓ (appelle)
ProductRepository (interface)
↓ (implémenté par)
ProductRepositoryImpl
↓ (utilise)
ProductApi (Dio HTTP)
↓ (requête vers)
Laravel API
↓ (répond avec)
JSON
↓ (converti en)
ProductModel
↓ (transformé en)
Product (Entity)
↓ (affiché dans)
ProductCard (Widget)

```

### 2. Ajout au panier

```

ProductDetailScreen
↓ (appelle)
CartProvider.addItem()
↓ (appelle)
CartRepository.addItem()
↓ (sauvegarde dans)
SharedPreferences
↓ (notifie)
CartScreen (écoute les changements)

```

### 3. Authentification

```

LoginScreen
↓ (appelle)
AuthProvider.login()
↓ (appelle)
AuthRepository.login()
↓ (requête vers)
Laravel API /auth/login
↓ (répond avec)
Token + User
↓ (sauvegarde dans)
SecureStorage

```

---

## 🗄️ STOCKAGE DES DONNÉES

| Donnée | Stockage | Clé |
|--------|----------|-----|
| Token | SecureStorage | `auth_token` |
| User | SecureStorage | `user_data` |
| Panier | SharedPreferences | `cart_data` |
| Favoris | SharedPreferences | `favorites_data` |
| Commandes | SharedPreferences | `orders_data` |
| Historique recherche | SharedPreferences | `search_history` |
| Récents consultés | SharedPreferences | `recently_viewed_products` |

---

## 🎨 THÈME ET STYLE

### Fichier : `lib/core/theme/app_theme.dart`

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Poppins',
    primaryColor: AppColors.primary,
    // ...
  );
}
```

Fichier : lib/core/constants/app_colors.dart

```dart
class AppColors {
  static const Color primary = Color(0xFF2C3E50);
  static const Color secondary = Color(0xFFE67E22);
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  // ...
}
```

---

🔌 CONFIGURATION RÉSEAU

Fichier : lib/core/network/api_client.dart

```dart
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  
  void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        // Intercepteurs pour token
        // Gestion des erreurs 401
      ),
    );
  }
}
```

Fichier : lib/core/constants/api_constants.dart

```dart
class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  // Endpoints...
}
```

---

🧭 NAVIGATION

Fichier : lib/routes/app_routes.dart

Toutes les routes sont définies comme constantes :

```dart
class AppRoutes {
  static const String home = '/home';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetail = '/order/detail';
  static const String favorites = '/favorites';
  // ...
}
```

Fichier : lib/routes/route_generator.dart

```dart
class RouteGenerator {
  static Route<dynamic>? generate(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _buildRoute(settings: settings, page: const HomeScreen());
      // ...
    }
  }
}
```

---

📦 GESTION D'ÉTAT (PROVIDERS)

Provider enregistrés dans main.dart :

Provider Rôle
AuthProvider État authentification
ProductProvider État produits
CategoryProvider État catégories
BrandProvider État marques
SearchProvider État recherche
CartProvider État panier
FavoriteProvider État favoris
OrderProvider État commandes

---

✅ BONNES PRATIQUES

1. Entités : Pas de dépendances Flutter
2. Modèles : Sérialisation JSON uniquement
3. Repositories : Interface dans domain, implémentation dans data
4. Providers : Toujours dans presentation
5. Widgets réutilisables : Dans un dossier widgets/
6. Constantes : Dans core/constants/
7. Thème : Dans core/theme/

```

---

## 📋 RÉSUMÉ

Ce fichier documente :
- ✅ Architecture en 3 couches
- ✅ Structure par feature
- ✅ Flux de données
- ✅ Stockage
- ✅ Thème
- ✅ Navigation
- ✅ Providers

---

**Veux-tu le contenu du fichier `02-structure.md` ?** 🚀