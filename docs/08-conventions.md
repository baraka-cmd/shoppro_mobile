📦 FICHIER : docs/08-conventions.md

---

```markdown
# 📝 CONVENTIONS DE CODE - SHOPPRO

---

## 🎨 STYLE DE CODE

### 1. Nommage des fichiers

| Type | Convention | Exemple |
|------|-----------|---------|
| Écran | `snake_case_screen.dart` | `login_screen.dart` |
| Widget | `snake_case.dart` | `product_card.dart` |
| Provider | `snake_case_provider.dart` | `cart_provider.dart` |
| Repository | `snake_case_repository.dart` | `product_repository.dart` |
| Entité | `snake_case.dart` | `product.dart` |
| Modèle | `snake_case_model.dart` | `product_model.dart` |

### 2. Nommage des classes

| Type | Convention | Exemple |
|------|-----------|---------|
| Écran | `PascalCaseScreen` | `LoginScreen` |
| Widget | `PascalCaseWidget` | `ProductCard` |
| Provider | `PascalCaseProvider` | `CartProvider` |
| Repository | `PascalCaseRepository` | `ProductRepository` |
| Entité | `PascalCase` | `Product` |
| Modèle | `PascalCaseModel` | `ProductModel` |

### 3. Nommage des variables

| Type | Convention | Exemple |
|------|-----------|---------|
| Variable locale | `camelCase` | `currentUser` |
| Constante | `UPPER_SNAKE_CASE` | `MAX_ITEMS` |
| Private | `_camelCase` | `_selectedItem` |
| Booléen | `is_` ou `has_` | `isLoading`, `hasError` |

---

## 📂 ORGANISATION DES DOSSIERS

### Structure par feature

```

lib/features/[feature]/
├── domain/
│   ├── entities/
│   └── repositories/
├── data/
│   ├── models/
│   ├── repositories/
│   └── sources/
└── presentation/
├── pages/
├── widgets/
└── providers/

```

### Règles
1. **Entités** : Pas d'imports Flutter (pur Dart)
2. **Modèles** : Sérialisation JSON uniquement
3. **Repositories** : Interface dans `domain/`, implémentation dans `data/`
4. **Providers** : Toujours dans `presentation/providers/`
5. **Widgets réutilisables** : Toujours dans `widgets/`

---

## 🎨 COULEURS

### Utilisation de `AppColors`

```dart
// ✅ BON
color: AppColors.primary,

// ❌ MAUVAIS
color: Color(0xFF2C3E50),
```

Palette complète

Nom Code Usage
primary #2C3E50 Boutons, titres, navigation
secondary #E67E22 Accents, badges
accent #3498DB Informations
background #F5F6FA Fond d'écran
surface #FFFFFF Cartes, conteneurs
textPrimary #2C3E50 Texte principal
textSecondary #7F8C8D Texte secondaire
textLight #BDC3C7 Texte léger
success #27AE60 Succès, stock
warning #F39C12 Avertissements
error #E74C3C Erreurs, prix réduits
info #3498DB Informations

---

🔤 POLICE

Utilisation de Poppins

```dart
// ✅ TOUJOURS préciser la police
Text(
  'Bonjour',
  style: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w600,
  ),
),
```

Tailles standard

Taille Usage
10 Très petit (badges)
12 Petit (labels)
13 Normal (descriptions)
14 Moyen (texte)
16 Grand (sous-titres)
18 Très grand (titres)
20+ Enorme (titres principaux)

---

📏 ESPACEMENT

Marges standard

Valeur Usage
4 Espacement minimal
8 Espacement petit
10 Espacement standard
12 Espacement moyen
15 Espacement large
20 Espacement très large
25 Espacement entre sections

Padding standard

```dart
// ✅ BON
padding: const EdgeInsets.all(20),

// ✅ BON
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),

// ✅ BON
padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
```

---

🔄 PROVIDERS

Pattern standard

```dart
class ExampleProvider extends ChangeNotifier {
  // État
  Status _status = Status.initial;
  String? _errorMessage;

  // Getters
  Status get status => _status;
  String? get errorMessage => _errorMessage;

  // Actions
  Future<void> loadData() async {
    _status = Status.loading;
    notifyListeners();

    try {
      // Charger
      _status = Status.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = Status.error;
    }

    notifyListeners();
  }
}
```

---

📝 WIDGETS

Pattern standard

```dart
class ExampleWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const ExampleWidget({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ...
      ),
    );
  }
}
```

---

🔗 NAVIGATION

Utiliser AppRoutes

```dart
// ✅ BON
Navigator.of(context).pushNamed(AppRoutes.cart);

// ❌ MAUVAIS
Navigator.of(context).pushNamed('/cart');
```

---

📦 IMPORTS

Ordre des imports

```dart
// 1. Flutter
import 'package:flutter/material.dart';

// 2. Packages externes
import 'package:provider/provider.dart';

// 3. Core
import '../../../../core/constants/app_colors.dart';

// 4. Features
import '../providers/example_provider.dart';

// 5. Widgets
import '../widgets/example_widget.dart';
```

---

✅ BONNES PRATIQUES

1. Toujours utiliser const pour les widgets constants
2. Toujours vérifier mounted avant setState
3. Toujours gérer les erreurs avec try/catch
4. Toujours formater les prix avec la méthode dédiée
5. Toujours utiliser fullImageUrl pour les images
6. Toujours sauvegarder localement les données importantes
7. Toujours notifier les listeners après changement d'état

```

---

## 📋 RÉSUMÉ

Ce fichier documente :
- ✅ Conventions de nommage
- ✅ Organisation des dossiers
- ✅ Couleurs et polices
- ✅ Espacement
- ✅ Patterns Provider/Widget
- ✅ Navigation
- ✅ Imports
- ✅ Bonnes pratiques

---

## 🎉 BASE DE CONNAISSANCES TERMINÉE !

### Les 9 fichiers créés :

| Fichier | Contenu |
|---------|---------|
| `00-contexte.md` | Vue d'ensemble |
| `01-architecture.md` | Architecture |
| `02-structure.md` | Structure des fichiers |
| `03-providers.md` | Providers |
| `04-routes.md` | Routes |
| `05-widgets.md` | Widgets |
| `06-progress.md` | Avancement |
| `07-prochaines-etapes.md` | À faire |
| `08-conventions.md` | Conventions |

---

**Tu peux maintenant envoyer ces fichiers à un nouveau chat pour reprendre le projet !** 🚀