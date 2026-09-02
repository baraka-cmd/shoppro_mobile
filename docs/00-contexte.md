# 📚 CONTEXTE DU PROJET - SHOPPRO

---

## 🛍️ PRÉSENTATION GÉNÉRALE

**ShopPro** est une application mobile e-commerce complète développée avec :
- **Flutter** (frontend mobile)
- **Laravel** (backend API)
- **MySQL** (base de données)

---

## 🎯 OBJECTIFS DU PROJET

Créer une application e-commerce professionnelle avec :
- Catalogue de produits
- Panier d'achat
- Favoris (wishlist)
- Commandes avec suivi
- Paiement
- Gestion par rôles (Client, Vendeur, Admin)

---

## 🛠️ TECHNOLOGIES

### Frontend (Flutter)
| Technologie | Version | Usage |
|-------------|---------|-------|
| Flutter | 3.x+ | Framework mobile |
| Dart | 3.x+ | Langage |
| Provider | 6.x | Gestion d'état |
| Dio | 5.x | Client HTTP |
| SharedPreferences | 2.x | Stockage local |
| CachedNetworkImage | 3.x | Images avec cache |
| Shimmer | 3.x | Animations de chargement |

### Backend (Laravel)
| Technologie | Version | Usage |
|-------------|---------|-------|
| Laravel | 13.x | Framework API |
| PHP | 8.5 | Langage |
| MySQL | 8.x | Base de données |
| Sanctum | - | Authentification |
| Spatie | - | Rôles et permissions |

---

## 👥 RÔLES UTILISATEURS

| Rôle | Email | Mot de passe | Fonctionnalités |
|------|-------|--------------|-----------------|
| **Admin** | `admin@shoppro.com` | `password123` | Dashboard admin, CRUD produits, utilisateurs |
| **Vendeur** | `vendeur@shoppro.com` | `password123` | Dashboard vendeur, CRUD produits |
| **Client** | `jean@example.com` | `password123` | Shopping, panier, commandes |
| **Client** | `marie@example.com` | `password123` | Shopping, panier, commandes |

---

## 📱 FONCTIONNALITÉS PRINCIPALES

### ✅ Déjà implémentées
1. **Authentification**
   - Inscription
   - Connexion
   - Déconnexion
   - Profil utilisateur
   - Changement mot de passe

2. **Catalogue Produits**
   - Liste paginée
   - Grille
   - Détails produit
   - Galerie d'images
   - Badges (réduction, nouveau, bestseller)

3. **Catégories**
   - Liste avec icônes
   - Sous-catégories
   - Navigation par catégorie
   - Filtres

4. **Recherche**
   - Barre de recherche
   - Debounce (temps réel)
   - Historique
   - Suggestions

5. **Panier**
   - Ajouter au panier
   - Modifier quantité
   - Code promo
   - Sauvegarder pour plus tard
   - Résumé des totaux

6. **Favoris**
   - Ajouter/Supprimer
   - Liste avec filtres
   - Alertes prix

7. **Commandes**
   - Checkout complet
   - Historique
   - Détails avec timeline
   - Annulation
   - Retour

---

## 🎨 DESIGN

### Police
- **Poppins** (Google Fonts)

### Couleurs principales
| Couleur | Code | Usage |
|---------|------|-------|
| Bleu foncé | `#2C3E50` | Primaire |
| Orange | `#E67E22` | Secondaire |
| Vert | `#27AE60` | Succès |
| Rouge | `#E74C3C` | Erreur |
| Gris clair | `#F5F6FA` | Fond |

---

## 📂 STRUCTURE DES DOSSIERS
