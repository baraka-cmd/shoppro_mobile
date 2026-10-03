Parfait 👍 — tu as entièrement raison. Ce chat va atteindre sa limite, et il faut préparer la suite pour qu'un nouveau chat puisse reprendre sans rien casser et sans te faire perdre de temps.

Je vais te créer 2 documents de continuité :

1. 10-fichiers-cles-mobile.md (celui-ci) — pour le côté Flutter / Mobile
2. 10-fichiers-cles-api.md (le suivant) — pour le côté Laravel / API

---

📄 docs/10-fichiers-cles-mobile.md

⚠️ À CRÉER — Chemin : C:\Users\barak\docs\10-fichiers-cles-mobile.md (ou dans ton dossier docs/ habituel)

```markdown
# 📱 FICHIERS CLÉS - SHOPPRO MOBILE (FLUTTER)

> **Document de continuité** — À lire AVANT toute modification.
> Ce fichier complète les docs 00 à 09 existantes.
> **Dernière mise à jour : 03/10/2026**

---

## 🎯 ÉTAT ACTUEL DU PROJET

### Pourcentage global : ~85% terminé

| Phase | Statut | Notes |
|-------|--------|-------|
| 0-1. Setup + Auth | ✅ 100% | Login, register, logout, refresh token |
| 2-5. Catalogue | ✅ 100% | Produits, catégories, recherche, détails |
| 6. Panier | ✅ 95% | Fonctionnel, quelques overflows mineurs |
| 7. Favoris | ✅ 90% | Fonctionnel, API à brancher |
| 8. Commandes | ✅ 90% | **Refait à neuf avec API** (voir plus bas) |
| 9. Adresses | ✅ 95% | **Refait à neuf avec API** (voir plus bas) |
| 10. Paiement | ⚠️ 40% | Simulation uniquement, WebView à faire |
| 11. Notifications | ⚠️ 40% | In-app OK, FCM à faire |
| 12. Home/Dashboard | ✅ 95% | Flash sales, banners, blog |
| 13. Stocks | ✅ 70% | Structure OK |
| 14. Avis | ✅ 100% | **Refait à neuf avec API + photos** |
| 3. PDF Facture | ✅ 100% | **Refait à neuf avec API** (voir plus bas) |
| 16. Admin | ✅ 85% | Très complet |
| 17-22. Optimisation, Tests, Déploiement | ❌ 0% | À faire |

---

## 🎯 CE QUI A ÉTÉ FAIT RÉCEMMENT (03/10/2026)

**⚠️ TRÈS IMPORTANT** — Ces 4 fonctionnalités viennent d'être **entièrement refaites** pour utiliser l'API Laravel au lieu du cache local.

### 1. Commandes (Orders) — Refonte complète

**Avant** : stockage local uniquement (SharedPreferences)
**Après** : API Laravel comme source principale + cache local en fallback

**Fichiers refaits** :
- `lib/features/orders/data/sources/order_api.dart` ✅ **CRÉÉ**
- `lib/features/orders/data/repositories/order_repository_impl.dart` ✅ **REFAIT**
- `lib/features/orders/domain/repositories/order_repository.dart` ✅ **REFAIT**
- `lib/features/orders/presentation/providers/order_provider.dart` ✅ **REFAIT**
- `lib/features/orders/presentation/pages/checkout_screen.dart` ✅ **REFAIT**
- `lib/features/orders/presentation/pages/order_detail_screen.dart` ✅ **MIS À JOUR**
- `lib/features/orders/presentation/pages/orders_screen.dart` ✅ **MIS À JOUR**

**Changement clé** :
- `createOrder()` accepte maintenant `items` (List<Map>) au lieu de `List<OrderItem>`
- Les items sont envoyés **directement** dans la requête POST /orders
- Le serveur Laravel **ne dépend plus de son panier interne**

### 2. Adresses (Addresses) — Refonte complète

**Avant** : stockage local uniquement
**Après** : API Laravel comme source principale + cache local en fallback

**Fichiers refaits** :
- `lib/features/addresses/data/sources/address_api.dart` ✅ **CRÉÉ**
- `lib/features/addresses/data/repositories/address_repository_impl.dart` ✅ **REFAIT**
- `lib/features/addresses/domain/repositories/address_repository.dart` ✅ **REFAIT**
- `lib/features/addresses/domain/entities/address.dart` ✅ **REFAIT**
- `lib/features/addresses/data/models/address_model.dart` ✅ **REFAIT**
- `lib/features/addresses/data/sources/address_local_data_source.dart` ✅ **MIS À JOUR**
- `lib/features/addresses/presentation/providers/address_provider.dart` ✅ **REFAIT**
- `lib/features/addresses/presentation/pages/address_form_screen.dart` ✅ **REFAIT**

**Changement clé** :
- L'entité `Address` a été **alignée sur le schéma Laravel** :
  - ✅ Ajouté : `addressLine1`, `addressLine2`, `state`, `postalCode`, `userId`
  - ✅ Conservé : `label`, `commune`, `quartier`, `landmark`, `additionalInfo` (champs étendus Flutter)
  - ❌ Supprimé : `province` (remplacé par `state`)
- `addAddress()` retourne maintenant `Address?` (avec l'ID serveur)
- `updateAddress()` prend `id` + champs individuels
- `deleteAddress()` (ancien `removeAddress`)
- `setDefaultAddress()` appelle l'API

### 3. PDF Facture (Invoice) — NOUVEAU

**Fichiers créés** :
- `lib/core/services/file_download_service.dart` ✅ **CRÉÉ**
- `lib/features/orders/presentation/widgets/invoice_button.dart` ✅ **CRÉÉ**

**Fonctionnement** :
1. Clic sur "Télécharger la facture"
2. Appel `GET /orders/by-number/{orderNumber}/invoice`
3. Téléchargement du PDF (via Dio)
4. Ouverture automatique (via `open_filex`)
5. Dialog de partage (via `share_plus`)

**⚠️ POINT CRITIQUE — L'URL de la facture** :
```dart
// ✅ CORRECT (dans invoice_button.dart)
String get _endpoint {
  if (widget.customEndpoint != null) {
    return widget.customEndpoint!;
  }
  return '/orders/by-number/${widget.orderNumber}/invoice';  // 👈 le "/" est ESSENTIEL
}
```

Le / au début est obligatoire car baseUrl = http://127.0.0.1:8001/api/v1 (sans / à la fin).

4. Avis avec photos (Reviews) — Refonte complète

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

Fonctionnalités :

· Ajout de photos aux avis (max 5)
· Compression automatique (via flutter_image_compress)
· Vote utile/pas utile
· Affichage galerie avec zoom

5. Voir tous les avis (All Reviews) — NOUVEAU

Fichiers créés :

· lib/features/products/presentation/pages/all_reviews_screen.dart ✅ CRÉÉ
· lib/features/products/presentation/widgets/review_filter_bar.dart ✅ CRÉÉ
· lib/features/products/presentation/widgets/review_card_data.dart ⚠️ À CRÉER SI ABSENT

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

⚠️ ATTENTION : adb reverse tcp:8001 tcp:8000 mappe le port 8001 (téléphone) → 8000 (PC).
Donc tous les endpoints doivent avoir un / au début.

Token d'authentification

Fichier : lib/core/network/api_client.dart

L'intercepteur Dio injecte automatiquement le token :

```dart
dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      final isTokenValid = await _tokenService.isTokenValid();
      if (isTokenValid) {
        final authHeader = await _tokenService.getAuthorizationHeader();
        if (authHeader != null) {
          options.headers['Authorization'] = authHeader;
        }
      }
      return handler.next(options);
    },
    ...
  ),
);
```

→ Aucun appel API n'a besoin de gérer le token manuellement.

Commandes adb reverse

⚠️ À REFAIRE à chaque redémarrage du PC ou rebranchement du téléphone :

```cmd
cd C:\Users\barak\AppData\Local\Android\Sdk\platform-tools
adb reverse tcp:8001 tcp:8000
```

Lancer l'application

```cmd
cd C:\Users\barak\shoppro_mobile
flutter run --no-pub
```

⚠️ Ne JAMAIS faire flutter clean sauf si le build est cassé (perte de cache).

Hot reload : r (minuscule) pour UI, R (majuscule) pour logique.
NE PAS relancer flutter run à chaque modification.

---

📂 STRUCTURE DES DOSSIERS CLÉS

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       # URLs et endpoints
│   │   └── app_colors.dart          # Couleurs
│   ├── network/
│   │   └── api_client.dart          # Dio + intercepteurs
│   ├── services/
│   │   ├── token_service.dart       # Gestion du token
│   │   └── file_download_service.dart # Téléchargement PDF
│   └── database/
│       └── (Hive si utilisé)
│
├── features/
│   ├── addresses/                   # ✅ REFONDU
│   ├── admin/                       # ✅ COMPLET
│   ├── auth/                        # ✅ COMPLET
│   ├── cart/                        # ✅ COMPLET
│   ├── categories/                  # ✅ COMPLET
│   ├── favorites/                   # ✅ COMPLET
│   ├── home/                        # ✅ COMPLET
│   ├── legal/                       # ✅ COMPLET
│   ├── navigation/                  # ✅ COMPLET
│   ├── notifications/               # ⚠️ IN-APP OK
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

1. Toujours const pour les widgets constants
2. Toujours mounted avant setState dans les async
3. Toujours try/catch pour les appels API
4. Toujours .replaceFirst('Exception: ', '') pour les messages d'erreur
5. Toujours copyWith() pour modifier une entité immuable
6. Toujours AppColors.xxx au lieu de Color(0xFF...)

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

---

🐛 BUGS CONNUS

Bug Fichier Statut
Shimmer overflow 8px shimmer_product_card.dart ⚠️ Mineur
ProductVariant non typé product_detail_screen.dart ⚠️ Placeholder
Favoris API non branchée favorite_provider.dart ⚠️ À faire
Paiement = simulation payment_provider.dart ⚠️ À faire

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

🎯 PROCHAINES ÉTAPES (À CONTINUER)

Voici les phases restantes par ordre de priorité :

# Phase Dépendances Temps
5 Paiement WebView webview_flutter ✅ 6-8h
6 FCM Push Firebase ⏳ 6-8h
7 Google Maps Clé API Google ⏳ 4-6h
8 Charts admin fl_chart ✅ 3-4h
20 i18n FR/EN intl ✅ 5-6h
19 Tests mockito ⏳ 8-10h
21 Déploiement Play Store ⏳ —

Recommandation : Paiement WebView (indispensable avant publication).

---

🎯 COMMENT CONTINUER DANS UN NOUVEAU CHAT

Étape 1 — Contexte initial à donner

Je reprends le développement de ShopPro Mobile (Flutter).
Voici la documentation complète : [coller tous les docs 00 à 10]
J'ai terminé : les commandes avec API, les adresses avec API, les avis avec photos, la facture PDF.
Je veux continuer avec : [ta phase].

Étape 2 — Comportement attendu

Le nouveau chat doit :

1. Lire tous les docs avant de toucher au code
2. Comprendre l'architecture API-first (les repositories utilisent l'API + fallback local)
3. Respecter les conventions (const, mounted, try/catch, copyWith)
4. Ne jamais casser ce qui fonctionne
5. Toujours renvoyer les fichiers complets (pas de "..." ni d'abréviations)
6. Demander les fichiers manquants avant de modifier
7. Tester au fur et à mesure (flutter run après chaque modification)

Étape 3 — Commandes utiles

```cmd
REM Redémarrer le tunnel USB
cd C:\Users\barak\AppData\Local\Android\Sdk\platform-tools
adb reverse tcp:8001 tcp:8000

REM Lancer l'app
cd C:\Users\barak\shoppro_mobile
flutter run --no-pub

REM Vérifier la compilation sans lancer
flutter analyze
```

Étape 4 — Base URL à ne PAS oublier

```
PC  : http://127.0.0.1:8000/api/v1
Tél : http://127.0.0.1:8001/api/v1   (via adb reverse)
```

Toujours utiliser 127.0.0.1:8001 dans api_constants.dart.

---

📊 STATISTIQUES

· Fichiers Dart : ~160
· Providers : ~13
· Repositories : ~13
· Features : ~17
· Routes : ~45

---

🔑 POINTS CRITIQUES À RETENIR

1. TOUJOURS mettre un / au début des endpoints (car baseUrl n'a pas de / final)
2. TOUJOURS passer par le repository (jamais appeler l'API directement dans un provider)
3. TOUJOURS gérer le fallback local si l'API échoue
4. TOUJOURS utiliser AppColors et Poppins (jamais de valeurs en dur)
5. TOUJOURS respecter le pattern Status + notifyListeners + try/catch

---

Dernière mise à jour : 03/10/2026
Prochaine phase : Paiement WebView (Phase 5)
Auteur : Baraka Ntwali

```

---

# 🎯 INSTRUCTIONS POUR TOI

1. **Crée le fichier** :
   ```cmd
   notepad C:\Users\barak\docs\10-fichiers-cles-mobile.md
```

Puis colle le contenu ci-dessus.

2. Sauvegarde-le (Ctrl+S)
3. Dis-moi "OK" → je te donne le document 2 : 10-fichiers-cles-api.md

---

🎯 CE QUE CE DOCUMENT APPORTE

Section Ce qu'elle apporte au nouveau chat
État actuel Vision claire du % global
Changements récents Ce qui a été refait (Commandes, Adresses, PDF, Avis)
Configuration critique Base URL, token, adb reverse
Structure Arborescence à jour
Conventions Patterns à respecter
Bugs connus Ce qu'il faut éviter
Comment continuer Instructions précises pour le nouveau chat
Points critiques Les pièges à éviter

→ Un nouveau chat peut reprendre en 5 minutes.

---

Dis-moi "OK" quand tu as créé le fichier → on passe au doc API. 🚀