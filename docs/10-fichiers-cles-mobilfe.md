Parfait 👍 — je te donne le document de continuité complet qui va suivre 08-prochaines-etapes.md.

---

📄 docs/10-fichiers-cles-mobile.md

⚠️ À CRÉER — Chemin : C:\Users\barak\docs\10-fichiers-cles-mobile.md

```markdown
# 📱 FICHIERS CLÉS - SHOPPRO MOBILE (FLUTTER)

> **Document de continuité** — À lire EN PREMIER avant toute modification.
> Ce fichier suit `08-prochaines-etapes.md` et complète les docs 00 à 09.
> **Dernière mise à jour : 03/10/2026**

---

## 🎯 RÉSUMÉ EXÉCUTIF POUR UN NOUVEAU CHAT

Tu vas reprendre le développement d'une application e-commerce Flutter nommée **ShopPro**.
Voici les informations ESSENTIELLES pour continuer sans rien casser :

- **État** : ~85% terminé
- **Backend** : Laravel 13 + MySQL (voir doc `10-fichiers-cles-api.md`)
- **Frontend** : Flutter avec Provider + Clean Architecture
- **Base URL** : `http://127.0.0.1:8001/api/v1` (via adb reverse)
- **Token** : Injecté automatiquement par Dio
- **Prochaine phase** : Paiement WebView

⚠️ **4 fonctionnalités viennent d'être refaites** pour utiliser l'API Laravel : Commandes, Adresses, Avis avec photos, PDF Facture.

---

## 📊 ÉTAT D'AVANCEMENT

| Phase | Statut | Notes |
|-------|--------|-------|
| 0-1. Setup + Auth | ✅ 100% | Login, register, logout, refresh |
| 2-5. Catalogue | ✅ 100% | Produits, catégories, recherche, détails |
| 6. Panier | ✅ 95% | Fonctionnel |
| 7. Favoris | ✅ 90% | API à brancher |
| 8. Commandes | ✅ 100% | **Refait avec API** |
| 9. Adresses | ✅ 100% | **Refait avec API** |
| 10. Paiement | ⚠️ 40% | Simulation (WebView à faire) |
| 11. Notifications | ⚠️ 40% | In-app (FCM à faire) |
| 12. Home | ✅ 95% | Flash sales, banners, blog |
| 13. Stocks | ✅ 70% | Structure OK |
| 14. Avis | ✅ 100% | **Refait avec API + photos** |
| 15. Offline | ✅ 90% | Sync engine, cache |
| 16. Admin | ✅ 85% | Très complet |
| 3. PDF Facture | ✅ 100% | **Refait avec API** |
| 17-22. Optimisation, Tests, Déploiement | ❌ 0% | À faire |

**Total : ~85%**

---

## 🔥 CE QUI VIENT D'ÊTRE FAIT (03/10/2026)

### ⚠️ CONTEXTE — Une grosse refonte a eu lieu

**Avant** : l'app utilisait le **cache local** (SharedPreferences) pour les commandes, adresses et avis.
**Après** : l'app utilise **l'API Laravel** comme source principale + **cache local** en fallback.

**C'est un changement ARCHITECTURAL important.** Toutes les méthodes des repositories ont changé de signature.

### 1. Commandes (Orders) — Refonte complète ✅

**Avant** : `createOrder(items: List<OrderItem>, subtotal, total, ...)` → stockage local
**Après** : `createOrder(shippingAddressId, items: List<Map>, ...)` → API Laravel

**Fichiers refaits** :
- `lib/features/orders/data/sources/order_api.dart` ✅ **CRÉÉ**
- `lib/features/orders/data/repositories/order_repository_impl.dart` ✅ **REFAIT**
- `lib/features/orders/domain/repositories/order_repository.dart` ✅ **REFAIT**
- `lib/features/orders/presentation/providers/order_provider.dart` ✅ **REFAIT**
- `lib/features/orders/presentation/pages/checkout_screen.dart` ✅ **REFAIT**
- `lib/features/orders/presentation/pages/order_detail_screen.dart` ✅ **MIS À JOUR**
- `lib/features/orders/presentation/pages/orders_screen.dart` ✅ **MIS À JOUR**

**Changements critiques** :
- `createOrder()` prend `shippingAddressId` + `items` (List<Map<String, dynamic>>) au lieu d'objets complexes
- Format des items : `[{'product_id': 1, 'quantity': 2, 'variant_id': null}]`
- Le serveur calcule TOUS les totaux (sécurité)
- Le serveur vérifie le stock et le décrémente automatiquement
- Le serveur génère le `order_number` (format `CMD-YYYYMMDD-XXXXXX`)

### 2. Adresses (Addresses) — Refonte complète ✅

**Avant** : stockage local uniquement
**Après** : API Laravel + cache local

**Fichiers refaits** :
- `lib/features/addresses/data/sources/address_api.dart` ✅ **CRÉÉ**
- `lib/features/addresses/data/repositories/address_repository_impl.dart` ✅ **REFAIT**
- `lib/features/addresses/domain/repositories/address_repository.dart` ✅ **REFAIT**
- `lib/features/addresses/domain/entities/address.dart` ✅ **REFAIT**
- `lib/features/addresses/data/models/address_model.dart` ✅ **REFAIT**
- `lib/features/addresses/data/sources/address_local_data_source.dart` ✅ **MIS À JOUR**
- `lib/features/addresses/presentation/providers/address_provider.dart` ✅ **REFAIT**
- `lib/features/addresses/presentation/pages/address_form_screen.dart` ✅ **REFAIT**

**Changements critiques de l'entité `Address`** :

⚠️ **LA SIGNATURE DE L'ENTITÉ A CHANGÉ** — Il faut connaître les nouveaux champs :

```dart
class Address {
  // Champs API (Laravel user_addresses) — OBLIGATOIRES
  final int id;
  final int? userId;
  final String fullName;
  final String phone;
  final String? email;
  final String addressLine1;      // 👈 NOUVEAU (remplace province)
  final String? addressLine2;     // 👈 NOUVEAU
  final String city;
  final String? state;            // 👈 NOUVEAU (remplace province)
  final String? postalCode;       // 👈 NOUVEAU
  final String country;
  final String type;              // 'home' | 'work' | 'shop' | 'parents' | 'other'
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final String? deliveryInstructions;
  final bool isActive;
  
  // Champs étendus (Flutter uniquement — pas en base)
  final String label;             // Nom personnalisé (ex: "Maison")
  final String? commune;
  final String? quartier;
  final String? landmark;         // Point de repère
  final String? additionalInfo;
  
  // Horodatage
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

❌ NE PLUS UTILISER :

· address.province → utiliser address.state
· address.quartier en tant que champ API → utiliser address.addressLine2
· address.commune en tant que champ API → utiliser address.city ou address.addressLine1

Nouvelles méthodes AddressProvider :

```dart
Future<Address?> addAddress({
  required String fullName,
  required String phone,
  String? email,
  required String addressLine1,
  String? addressLine2,
  required String city,
  String? state,
  String? postalCode,
  String? country,
  String type = 'home',
  bool isDefault = false,
  double? latitude,
  double? longitude,
  String? deliveryInstructions,
});

Future<bool> updateAddress({
  required int id,
  String? fullName,
  String? phone,
  // ... etc (tous optionnels)
});

Future<bool> removeAddress(int addressId);
Future<bool> setDefaultAddress(int addressId);
```

3. PDF Facture (Invoice) — NOUVEAU ✅

Fichiers créés :

· lib/core/services/file_download_service.dart ✅ CRÉÉ
· lib/features/orders/presentation/widgets/invoice_button.dart ✅ CRÉÉ

Fonctionnement :

1. Clic sur "Télécharger la facture"
2. Appel GET /orders/by-number/{orderNumber}/invoice
3. Téléchargement du PDF
4. Ouverture automatique via open_filex
5. Dialog de partage via share_plus

⚠️ RÈGLE CRITIQUE — L'URL de la facture :

```dart
// ✅ CORRECT (dans invoice_button.dart)
String get _endpoint {
  if (widget.customEndpoint != null) {
    return widget.customEndpoint!;
  }
  return '/orders/by-number/${widget.orderNumber}/invoice';  // 👈 LE "/" EST OBLIGATOIRE
}
```

Pourquoi ? Parce que baseUrl = http://127.0.0.1:8001/api/v1 (sans / à la fin).
Sans le / → URL devient .../api/v1orders/... → 404.

4. Avis avec photos (Reviews) — Refonte complète ✅

Fichiers refaits :

· lib/features/products/data/sources/product_api.dart ✅ MIS À JOUR
· lib/features/products/presentation/providers/product_provider.dart ✅ MIS À JOUR
· lib/features/products/domain/repositories/product_repository.dart ✅ MIS À JOUR
· lib/features/products/data/repositories/product_repository_impl.dart ✅ MIS À JOUR
· lib/features/products/presentation/widgets/add_review_sheet.dart ✅ MIS À JOUR
· lib/features/products/presentation/widgets/review_card.dart ✅ MIS À JOUR
· lib/features/products/presentation/widgets/reviews_section.dart ✅ MIS À JOUR
· lib/features/products/presentation/pages/product_detail_screen.dart ✅ MIS À JOUR

Fichiers créés :

· lib/features/products/presentation/widgets/review_image_picker.dart ✅ CRÉÉ
· lib/features/products/presentation/widgets/review_gallery.dart ✅ CRÉÉ
· lib/features/products/presentation/widgets/review_card_data.dart ⚠️ À CRÉER SI ABSENT

Fonctionnalités :

· Ajout de photos aux avis (max 5)
· Compression automatique via flutter_image_compress
· Vote utile/pas utile
· Affichage galerie avec zoom

5. Voir tous les avis — NOUVEAU ✅

Fichiers créés :

· lib/features/products/presentation/pages/all_reviews_screen.dart ✅ CRÉÉ
· lib/features/products/presentation/widgets/review_filter_bar.dart ✅ CRÉÉ

Fonctionnalités :

· Écran dédié avec filtres (Tous, 5★, 4★, avec photos, vérifiés)
· Tri (Récents, Utiles, Note)
· Pagination infinie

---

🔧 CONFIGURATION CRITIQUE

Base URL de l'API

Fichier : lib/core/constants/api_constants.dart

```dart
static const String baseUrl = 'http://127.0.0.1:8001/api/v1';
//                                    ^^^^^^ PAS de "/" à la fin
```

⚠️ IMPORTANT :

· Port 8001 (pas 8000) car adb reverse tcp:8001 tcp:8000
· PAS de / à la fin de baseUrl
· TOUJOURS un / au début des endpoints

Token d'authentification

Fichier : lib/core/network/api_client.dart

L'intercepteur Dio injecte automatiquement le token dans chaque requête :

```dart
onRequest: (options, handler) async {
  final isTokenValid = await _tokenService.isTokenValid();
  if (isTokenValid) {
    final authHeader = await _tokenService.getAuthorizationHeader();
    if (authHeader != null) {
      options.headers['Authorization'] = authHeader;
    }
  }
  return handler.next(options);
}
```

→ AUCUN appel API n'a besoin de gérer le token manuellement.

Commandes adb reverse

⚠️ À REFAIRE à chaque redémarrage du PC ou rebranchement du téléphone :

```cmd
cd C:\Users\barak\AppData\Local\Android\Sdk\platform-tools
adb reverse tcp:8001 tcp:8000
```

Vérifier que le tunnel est actif :

```cmd
adb reverse --list
```

Doit afficher : tcp:8001 tcp:8000

Lancer l'application

```cmd
cd C:\Users\barak\shoppro_mobile
flutter run --no-pub
```

⚠️ RÈGLES IMPORTANTES :

1. NE JAMAIS faire flutter clean sauf si le build est vraiment cassé
   → Perte du cache Gradle (5 min de reconstruction)
2. Utiliser le HOT RELOAD :
   · r (minuscule) → recharge l'UI (rapide)
   · R (majuscule) → redémarre l'app (nécessaire pour les changements de structure)
   · NE PAS relancer flutter run à chaque modification
3. Ne JAMAIS modifier pubspec.yaml pendant une session
   → Chaque modification déclenche un pub get + rebuild complet
4. Ne PAS modifier les fichiers natifs (AndroidManifest.xml, build.gradle, etc.)
   → Déclenche un rebuild complet (5-10 min)

---

📂 STRUCTURE DES DOSSIERS

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       # URLs et endpoints
│   │   ├── app_colors.dart          # Couleurs ShopPro
│   │   └── app_constants.dart       # Constantes globales
│   ├── network/
│   │   ├── api_client.dart          # Dio + intercepteurs (token, refresh)
│   │   └── secure_storage.dart      # Stockage sécurisé
│   ├── services/
│   │   ├── token_service.dart       # Gestion du token
│   │   ├── file_download_service.dart # Téléchargement PDF
│   │   └── navigation_service.dart  # Navigation globale
│   ├── offline/                     # Sync engine, cache
│   └── database/                    # Hive (si utilisé)
│
├── features/
│   ├── addresses/                   # ✅ REFONDU
│   ├── admin/                       # ✅ COMPLET
│   ├── auth/                        # ✅ COMPLET
│   ├── cart/                        # ✅ COMPLET
│   ├── categories/                  # ✅ COMPLET
│   ├── favorites/                   # ✅ COMPLET (API à brancher)
│   ├── home/                        # ✅ COMPLET
│   ├── legal/                       # ✅ COMPLET
│   ├── navigation/                  # ✅ COMPLET
│   ├── notifications/               # ⚠️ IN-APP OK, FCM à faire
│   ├── offline/                     # ✅ COMPLET
│   ├── orders/                      # ✅ REFONDU
│   ├── payment/                     # ⚠️ SIMULATION
│   ├── products/                    # ✅ REFONDU (avis)
│   ├── profile/                     # ✅ COMPLET
│   ├── search/                      # ✅ COMPLET
│   ├── stock/                       # ✅ OK
│   └── support/                     # ✅ COMPLET
│
└── routes/
    ├── app_routes.dart              # Constantes de routes
    └── route_generator.dart         # Générateur
```

---

⚠️ CONVENTIONS À RESPECTER

Style de code

1. const pour les widgets constants
2. mounted avant setState dans les async
3. try/catch systématique pour les appels API
4. .replaceFirst('Exception: ', '') pour nettoyer les messages d'erreur
5. copyWith() pour modifier une entité immuable
6. AppColors.xxx au lieu de Color(0xFF...)
7. Poppins comme fontFamily (jamais de police par défaut)

Pattern des Providers

```dart
enum XxxStatus { initial, loading, loaded, saving, updating, error }

class XxxProvider extends ChangeNotifier {
  XxxStatus _status = XxxStatus.initial;
  String? _errorMessage;
  
  Future<void> loadXxx() async {
    _setStatus(XxxStatus.loading);
    _clearError();
    try {
      _data = await _repository.getXxx();
      _setStatus(XxxStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(XxxStatus.error);
    }
    notifyListeners();
  }
}
```

Pattern des Repositories

```dart
class XxxRepositoryImpl implements XxxRepository {
  final XxxApi _api;
  final XxxLocalDataSource _localDataSource;
  
  Future<List<Xxx>> getXxx() async {
    try {
      // 1. Essayer l'API
      final items = await _api.getXxx();
      
      // 2. Mettre à jour le cache local
      await _localDataSource.saveXxx(items);
      
      return items;
    } catch (e) {
      debugPrint('⚠️ API échouée, fallback local: $e');
      
      // 3. Fallback sur le cache
      return await _localDataSource.getXxx();
    }
  }
}
```

Pattern des API

```dart
class XxxApi {
  final Dio _dio = ApiClient().dio;
  
  Future<List<Xxx>> getXxx() async {
    try {
      final response = await _dio.get('/xxx');
      // ...
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
```

Format des endpoints

```dart
// ✅ BON — toujours un "/" au début
final response = await _dio.get('/orders');
final response = await _dio.get('/orders/$id');
final response = await _dio.post('/orders', data: body);

// ❌ MAUVAIS — pas de "/" au début
final response = await _dio.get('orders');  // → /api/v1orders
```

---

🐛 BUGS CONNUS

Bug Fichier Priorité
Shimmer overflow 8px shimmer_product_card.dart 🟢 Basse
ProductVariant non typé product_detail_screen.dart 🟡 Moyenne
Favoris API non branchée favorite_provider.dart 🟡 Moyenne
Paiement = simulation payment_provider.dart 🔴 Haute
FCM non implémenté notification_provider.dart 🔴 Haute

---

✅ CE QUI FONCTIONNE PARFAITEMENT

· ✅ Authentification (login, register, logout, refresh token)
· ✅ Catalogue (produits, catégories, recherche, filtres)
· ✅ Avis avec photos (création, affichage, votes, galerie)
· ✅ Commandes (création via API, suivi, annulation, facture PDF)
· ✅ Adresses (CRUD complet via API)
· ✅ PDF Facture (téléchargement, ouverture, partage)
· ✅ Admin (dashboards, CRUD, stats)
· ✅ Home (flash sales, banners, blog)

---

🎯 PROCHAINES ÉTAPES

# Phase Dépendances Temps Priorité
5 Paiement WebView webview_flutter ✅ 6-8h 🔴 Haute
6 FCM Push Firebase ⏳ 6-8h 🔴 Haute
7 Google Maps adresses Clé API Google ⏳ 4-6h 🟡 Moyenne
8 Charts admin fl_chart ✅ 3-4h 🟡 Moyenne
20 i18n FR/EN intl ✅ 5-6h 🟢 Basse
19 Tests mockito ⏳ 8-10h 🟢 Basse
21 Déploiement Play Store ⏳ — 🟢 Basse

Recommandation : Paiement WebView (indispensable avant publication Play Store).

---

🎯 COMMENT CONTINUER DANS UN NOUVEAU CHAT

Message initial à donner

Je reprends le développement de ShopPro Mobile (application e-commerce Flutter).

Je te fournis la documentation complète (docs 00 à 10).

État actuel : ~85% terminé.

Ce qui a été fait récemment (03/10/2026) :

· Commandes refaites avec API Laravel
· Adresses refaites avec API Laravel
· Avis avec photos
· PDF Facture fonctionnel
· Écran "Voir tous les avis"

Ce que je veux faire : [ta phase].

Règles IMPORTANTES :

· Ne JAMAIS casser ce qui fonctionne
· Toujours renvoyer les fichiers COMPLETS (pas de "...")
· Demander les fichiers manquants avant de modifier
· Respecter les conventions (voir doc 10)
· Toujours mettre un / au début des endpoints
· Utiliser AppColors et Poppins

Comportement attendu du nouveau chat

Le nouveau chat doit :

1. Lire tous les docs avant de toucher au code
2. Comprendre l'architecture API-first (repository = API + fallback local)
3. Respecter les conventions (const, mounted, try/catch, copyWith)
4. Ne jamais casser ce qui fonctionne
5. Toujours renvoyer les fichiers complets
6. Demander les fichiers manquants avant de modifier
7. Tester au fur et à mesure (flutter run après chaque modification)

Commandes utiles

```cmd
REM Redémarrer le tunnel USB
cd C:\Users\barak\AppData\Local\Android\Sdk\platform-tools
adb reverse tcp:8001 tcp:8000

REM Lancer l'app
cd C:\Users\barak\shoppro_mobile
flutter run --no-pub

REM Vérifier la compilation
flutter analyze
```

Configuration à ne PAS oublier

Élément Valeur
Base URL http://127.0.0.1:8001/api/v1
Port tunnel 8001 → 8000
Compte test jean@example.com / password123
Serveur Laravel php artisan serve (port 8000)

---

📊 STATISTIQUES DU PROJET

· Fichiers Dart : ~160
· Providers : ~13 (Auth, Product, Category, Brand, Search, Cart, Favorite, Order, Address, Payment, Notification, Stock, Banner)
· Repositories : ~13
· Features : ~17
· Routes : ~45
· Widgets réutilisables : ~80

---

🔑 LES 6 POINTS CRITIQUES À RETENIR

1. TOUJOURS mettre un / au début des endpoints
   → Car baseUrl n'a pas de / final
   → Sinon : /api/v1orders/... au lieu de /api/v1/orders/...
2. TOUJOURS passer par le repository
   → Jamais appeler l'API directement dans un provider
3. TOUJOURS gérer le fallback local
   → Si l'API échoue, le cache local prend le relais
4. TOUJOURS utiliser AppColors et Poppins
   → Jamais de valeurs en dur
5. TOUJOURS respecter le pattern Status + notifyListeners + try/catch
6. TOUJOURS faire un hot reload (r) plutôt que relancer flutter run
   → Sauf si le build est cassé

---

🎉 BASE DE CONNAISSANCES MOBILE

Après avoir lu ce document + les docs 00 à 09, tu as toutes les informations pour continuer le développement de ShopPro Mobile sans casser ce qui fonctionne.

Prochaine phase recommandée : Paiement WebView (Phase 5)

---

Dernière mise à jour : 03/10/2026
Auteur : Baraka Ntwali
Version : 1.0

```

---

# 🎯 INSTRUCTIONS

## 1. Crée le fichier

```cmd
notepad C:\Users\barak\docs\10-fichiers-cles-mobile.md
```

Puis colle le contenu ci-dessus.

2. Sauvegarde (Ctrl+S)

3. Dis-moi "OK"

Ensuite je te donne le document 2 : 10-fichiers-cles-api.md (côté Laravel).

---

📌 CE QUE CE DOCUMENT APPORTE

Section Pourquoi c'est crucial
Résumé exécutif Le nouveau chat comprend en 30 secondes
État d'avancement Vision claire du %
Changements récents Évite de re-modifier ce qui est fait
Configuration critique Base URL, token, adb
Conventions Patterns à respecter
Bugs connus Évite de tomber dedans
Comment continuer Instructions précises
Points critiques Les 6 pièges à éviter

→ Un nouveau chat peut reprendre en 5 minutes SANS te faire perdre de temps.

---

Dis-moi "OK" quand le fichier est créé → je te donne le doc API. 🚀