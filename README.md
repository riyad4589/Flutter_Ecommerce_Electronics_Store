# 🛍️ Electronics Store - Application E-commerce Flutter

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-3.0-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Une application e-commerce spécialisée en électronique développée avec Flutter, offrant une expérience utilisateur fluide et professionnelle pour l'achat de produits électroniques.

[Fonctionnalités](#-fonctionnalités) • [Installation](#-installation) • [Architecture](#-architecture) • [Technologies](#-technologies) • [Screenshots](#-screenshots) • [Contributeurs](#-Contributeurs)

</div>

---

## 📋 Table des matières

- [À propos](#-à-propos)
- [Fonctionnalités](#-fonctionnalités)
- [Technologies utilisées](#-technologies-utilisées)
- [Architecture](#-architecture)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Utilisation](#-utilisation)
- [Structure du projet](#-structure-du-projet)
- [API Mock](#-api-mock)
- [Captures d'écran](#-captures-décran)
- [Contributeurs](#-Contributeurs)

---

## 🎯 À propos

**Electronics Store** est une application mobile e-commerce spécialisée dans la vente de produits électroniques, développée avec Flutter dans le cadre d'un projet universitaire. L'application offre une expérience d'achat moderne pour smartphones, ordinateurs, tablettes, audio, photo/vidéo, gaming et accessoires électroniques, avec une interface utilisateur élégante, des animations fluides et une architecture robuste suivant les principes de Clean Architecture.

### Objectifs du projet

- ✅ Créer une application e-commerce fonctionnelle et complète
- ✅ Implémenter une architecture propre et maintenable (Clean Architecture)
- ✅ Offrir une expérience utilisateur moderne et fluide
- ✅ Gérer l'authentification et les sessions utilisateurs
- ✅ Intégrer une base de données locale (SQLite)
- ✅ Développer un panel d'administration complet

---

## ✨ Fonctionnalités

### 🔐 Authentification
- Inscription avec validation des champs
- Connexion avec gestion de session
- Déconnexion sécurisée
- Persistance de la session
- Gestion des profils utilisateurs

### 🛒 Catalogue produits électroniques

- **7 catégories spécialisées** :
  - 📱 Smartphones (iPhone, Samsung, Google, Xiaomi)
  - 💻 Ordinateurs (MacBook, Dell, Lenovo, ASUS)
  - 📲 Tablettes (iPad, Galaxy Tab, Surface)
  - 🎧 Audio (Casques, Écouteurs, Enceintes)
  - 📷 Photo & Vidéo (Appareils photo, Drones, Caméras)
  - 🎮 Gaming (Consoles, Accessoires gaming)
  - 🔌 Accessoires (Électronique divers)
- Recherche avancée de produits électroniques
- Filtrage multi-critères (prix, popularité, note, marque)
- Détails complets avec spécifications techniques
- Système de notation et avis clients
- Images haute qualité optimisées avec cache

### 🛍️ Panier d'achat
- Ajout/suppression de produits
- Modification des quantités
- Calcul automatique du total
- Persistance du panier
- Animation fluide des actions

### ❤️ Favoris
- Gestion des produits favoris
- Synchronisation avec le compte
- Accès rapide aux produits préférés

### 📦 Commandes
- Historique des commandes
- Détails de chaque commande
- Suivi de statut (En cours, Livrée, Annulée)
- Annulation de commande

### 👤 Profil utilisateur
- Modification des informations
- Changement de mot de passe
- Gestion de photo de profil

### ⚙️ Administration
- Dashboard administrateur complet
- Gestion des utilisateurs (CRUD)
- Gestion des produits (CRUD)
- Gestion des catégories (CRUD)
- Gestion des commandes

---

## 🛠️ Technologies utilisées

### Framework & Langage
- **Flutter** 3.0+ - Framework UI multiplateforme
- **Dart** 3.0+ - Langage de programmation

### État & Navigation
- **Provider** ^6.1.2 - Gestion d'état
- **GoRouter** ^14.0.0 - Navigation déclarative et routing

### Base de données
- **SQLite** (sqflite ^2.3.0) - Base de données locale
- **Path Provider** ^2.1.3 - Gestion des chemins de fichiers

### Réseau & API
- **Dio** ^5.4.3 - Client HTTP
- **Pretty Dio Logger** ^1.3.1 - Logs formatés

### UI/UX
- **Shimmer** ^3.0.0 - Skeleton loading animations
- **Flutter Staggered Animations** ^1.1.1 - Animations avancées
- **Cached Network Image** ^3.3.1 - Cache d'images optimisé

### Utilitaires
- **Get It** ^7.6.7 - Injection de dépendances
- **Dartz** ^0.10.1 - Programmation fonctionnelle
- **Equatable** ^2.0.5 - Comparaison d'objets
- **Image Picker** ^1.0.7 - Sélection d'images

---

## 🏗️ Architecture

Le projet suit les principes de **Clean Architecture** avec une séparation claire des responsabilités :

```
lib/
├── core/                      # Code partagé
│   ├── constants/            # Constantes globales
│   ├── database/             # Configuration SQLite
│   ├── error/                # Gestion des erreurs
│   ├── network/              # Configuration réseau
│   ├── usecases/             # Use cases abstraits
│   └── utils/                # Utilitaires
│
├── data/                      # Couche de données
│   ├── datasources/          # Sources de données
│   │   ├── local/           # Base de données locale
│   │   └── remote/          # API externe
│   ├── models/               # Modèles de données
│   └── repositories/         # Implémentations repositories
│
├── domain/                    # Couche métier
│   ├── entities/             # Entités métier
│   ├── repositories/         # Interfaces repositories
│   └── usecases/             # Cas d'utilisation métier
│
└── presentation/             # Couche présentation
    ├── pages/                # Écrans de l'application
    ├── providers/            # Providers (état)
    ├── themes/               # Thèmes et styles
    └── widgets/              # Composants réutilisables
```

### Principes appliqués

✅ **Separation of Concerns** - Séparation claire des responsabilités  
✅ **Dependency Inversion** - Les dépendances pointent vers les abstractions  
✅ **Single Responsibility** - Chaque classe a une seule responsabilité  
✅ **Clean Code** - Code lisible et maintenable  
✅ **SOLID Principles** - Principes de conception orientée objet

---

## 📥 Installation

### Prérequis

- Flutter SDK 3.0 ou supérieur
- Dart SDK 3.0 ou supérieur
- Android Studio / VS Code
- Git

### Étapes d'installation

1. **Cloner le repository**
```bash
git clone https://github.com/votre-username/online-shop.git
cd online-shop
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Générer l'icône de l'application** (optionnel)
```bash
flutter pub run flutter_launcher_icons
```

4. **Lancer l'application**
```bash
# Mode debug
flutter run

# Mode release
flutter run --release
```

---

## ⚙️ Configuration

### Base de données

La base de données SQLite est automatiquement initialisée au premier lancement avec :
- **Nom du fichier** : `ecommerce.db`
- **Tables** : users, products, categories, cart_items, orders, order_items, favorites, addresses

### Configuration Mock API (pour développement)

Le projet inclut une API mock Node.js dans le dossier `api_mock/` :

```bash
cd api_mock
npm install
npm start
```

L'API mock sera disponible sur `http://localhost:3000`

---

## 🚀 Utilisation

### Connexion test

**Utilisateur standard :**
- Créez un nouveau compte via la page d'inscription

**Administrateur :**
- Email : `admin`
- Mot de passe : `admin123`

### Pages principales

L'application comprend les sections suivantes :

- **Accueil** - Page de lancement
- **Authentification** - Inscription et connexion
- **Produits** - Catalogue et détails des produits électroniques
- **Panier** - Gestion du panier d'achat
- **Commandes** - Historique et suivi des commandes
- **Favoris** - Produits favoris
- **Profil** - Informations utilisateur et paramètres
- **Dashboard Admin** - Panel d'administration (accessible via le profil admin)

---

## 📁 Structure du projet

```
online-shop/
│
├── android/                   # Configuration Android
├── ios/                       # Configuration iOS
├── web/                       # Configuration Web
├── windows/                   # Configuration Windows
├── macos/                     # Configuration macOS
├── linux/                     # Configuration Linux
│
├── assets/                    # Ressources statiques
│   └── images/               # Images de l'application
│
├── lib/                       # Code source Dart
│   ├── core/                 # Fonctionnalités partagées
│   ├── data/                 # Couche de données
│   ├── domain/               # Couche métier
│   ├── presentation/         # Couche UI
│   ├── injection_container.dart  # DI setup
│   └── main.dart            # Point d'entrée
│
├── test/                      # Tests
├── api_mock/                  # Serveur API mock (Node.js)
├── screenshots/               # Captures d'écran
│
├── pubspec.yaml              # Dépendances Flutter
├── analysis_options.yaml     # Règles d'analyse Dart
├── README.md                 # Ce fichier
└── RAPPORT.md                # Rapport de projet
```

## 🌐 API Mock

Un serveur Node.js est fourni pour le développement local dans le dossier `api_mock/`.

### Démarrage

```bash
cd api_mock
npm install
npm start
```

Le serveur démarre sur `http://localhost:3000`

### Endpoints disponibles

**Authentification**
- `POST /api/v1/auth/register` - Inscription
- `POST /api/v1/auth/login` - Connexion

**Produits**
- `GET /api/v1/products` - Liste des produits
- `GET /api/v1/products/:id` - Détails d'un produit
- `GET /api/v1/categories` - Liste des catégories

**Panier** (authentification requise)
- `GET /api/v1/cart` - Récupérer le panier
- `POST /api/v1/cart/add` - Ajouter un produit

**Commandes** (authentification requise)
- `GET /api/v1/orders` - Historique des commandes
- `POST /api/v1/orders` - Créer une commande

### Utilisation depuis émulateur

- **Android** : Utiliser `http://10.0.2.2:3000`
- **iOS** : Utiliser `http://localhost:3000`

---

# 📱 Captures d'écran

## 🚀 Page de Lancement

<div align="center">

| **Écran d'Accueil** |
|---------------------|
| <img src="screenshots/home.png" width="250"/> |

*Premier écran affiché au lancement de l'application*

</div>

---

## 🔐 Authentification

### 👤 Utilisateur

<div align="center">

| **Inscription** | **Connexion Utilisateur** |
|------------------|---------------------------|
| <img src="screenshots/user/signup.png" width="230"/> | <img src="screenshots/user/login-user.png" width="230"/> |

</div>

---

### 🛡️ Administrateur

<div align="center">

| **Connexion Administrateur** |
|------------------------------|
| <img src="screenshots/admin/admin-login.png" width="260"/> |

</div>


## 🎨 Interface Utilisateur

<div align="center">

| **Liste des Produits** | **Panier** | **Commandes** | **Suivi de commande** | **Profil** |
|------------------------|------------|----------------|-------------------------|------------|
| <img src="screenshots/user/produits.png" width="180"/> | <img src="screenshots/user/cart.png" width="180"/> | <img src="screenshots/user/commande.png" width="180"/> | <img src="screenshots/user/suivi.png" width="180"/> | <img src="screenshots/user/profile.png" width="180"/> |

</div>

---

## 🛠️ Panel d’Administration

<div align="center">

| **Dashboard** | **Liste des Produits** | **Produits par Client** | **Liste des Commandes** | **Liste des Utilisateurs** |
|---------------|------------------------|---------------------------|---------------------------|-------------------|
| <img src="screenshots/admin/dashboard.png" width="220"/> | <img src="screenshots/admin/products.png" width="220"/> | <img src="screenshots/admin/product-client.png" width="220"/> | <img src="screenshots/admin/all-commandes.png" width="220"/> | <img src="screenshots/admin/users.png" width="220"/> |

</div>


---

# 👤 Contributeurs

**MAJGHIROU Mohamed Riyad**

- GitHub: [@riyad4589](https://github.com/riyad4589)
- Email: [riyadmaj10@gmail.com](mailto:riyadmaj10@gmail.com)
- LinkedIn: [Mohamed Riyad MAJGHIROU](https://www.linkedin.com/in/mohamed-riyad-majghirou-5b62aa388/)


**AZZAM Mohamed**

- GitHub: [@Azzammoo10](https://github.com/Azzammoo10)
- Email: [azzam.moo10@gmail.com](mailto:azzam.moo10@gmail.com)
- LinkedIn: [Mohamed AZZAM](https://www.linkedin.com/in/mohamed-azzam-93115823a/)

---

<div align="center">

### ⭐ Si ce projet vous a été utile, n'hésitez pas à lui donner une étoile !


[⬆ Retour en haut](#️-electronics-store---application-e-commerce-flutter)

</div>