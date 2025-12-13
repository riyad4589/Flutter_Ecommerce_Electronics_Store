# 🛍️ Electronics Store - Application E-commerce Flutter

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Une application e-commerce spécialisée en électronique développée avec Flutter et Firebase, offrant une expérience utilisateur fluide et professionnelle pour l'achat de produits électroniques.

[Fonctionnalités](#-fonctionnalités) • [Installation](#-installation) • [Architecture](#architecture) • [Technologies](#technologies-utilisees) • [Screenshots](#-captures-décran) • [Contributeurs](#-contributeurs)

</div>

---

## 📋 Table des matières

- [À propos](#-à-propos)
- [Fonctionnalités](#-fonctionnalités)
- [Technologies utilisées](#technologies-utilisees)
- [Architecture](#architecture)
- [Installation](#-installation)
- [Configuration Firebase](#-configuration-firebase)
- [Utilisation](#-utilisation)
- [Structure du projet](#-structure-du-projet)
- [Captures d'écran](#-captures-décran)
- [Contributeurs](#-contributeurs)

---

## 🎯 À propos

**Electronics Store** est une application mobile e-commerce spécialisée dans la vente de produits électroniques, développée avec Flutter et **Firebase** dans le cadre d'un projet universitaire. L'application offre une expérience d'achat moderne pour smartphones, ordinateurs, tablettes, audio, photo/vidéo, gaming et accessoires électroniques, avec une interface utilisateur élégante, des animations fluides et une architecture robuste suivant les principes de Clean Architecture.

### Objectifs du projet

- ✅ Créer une application e-commerce fonctionnelle et complète
- ✅ Implémenter une architecture propre et maintenable (Clean Architecture)
- ✅ Offrir une expérience utilisateur moderne et fluide
- ✅ Gérer l'authentification avec **Firebase Authentication**
- ✅ Intégrer une base de données cloud (**Cloud Firestore**)
- ✅ Stockage d'images avec **Firebase Storage**
- ✅ Développer un panel d'administration complet

---

## ✨ Fonctionnalités

### 🔐 Authentification (Firebase Auth)
- Inscription avec validation des champs
- Connexion avec gestion de session
- Déconnexion sécurisée
- Persistance de la session automatique
- Gestion des profils utilisateurs
- Upload d'images de profil (Firebase Storage)

### 🛒 Catalogue produits électroniques

- **8 catégories spécialisées** :
  - 📱 Smartphones (iPhone, Samsung, Google, Xiaomi)
  - 💻 Ordinateurs (MacBook, Dell, Lenovo, ASUS)
  - 📲 Tablettes (iPad, Galaxy Tab, Surface)
  - 🎧 Audio (Casques, Écouteurs, Enceintes)
  - 📷 Photo & Vidéo (Appareils photo, Drones, Caméras)
  - 🎮 Gaming (Consoles, Accessoires gaming)
  - 🔌 Accessoires (Électronique divers)
  - ⌚ Montres connectées (Apple Watch, Samsung Galaxy Watch)
- Recherche avancée de produits électroniques
- Filtrage multi-critères (prix, popularité, note, marque)
- Détails complets avec spécifications techniques
- Système de notation et avis clients
- Images haute qualité optimisées avec cache

### 🛍️ Panier d'achat
- Ajout/suppression de produits
- Modification des quantités
- Calcul automatique du total
- Persistance du panier dans le cloud
- Animation fluide des actions

### ❤️ Favoris
- Gestion des produits favoris
- Synchronisation cloud avec le compte
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
- Accès basé sur le rôle utilisateur

---

<h2 id="technologies-utilisees">🛠️ Technologies utilisées</h2>

### Framework & Langage
- **Flutter** 3.0+ - Framework UI multiplateforme
- **Dart** 3.0+ - Langage de programmation

### Firebase (Backend as a Service)
- **Firebase Core** ^3.13.0 - Initialisation Firebase
- **Firebase Auth** ^5.7.0 - Authentification utilisateurs
- **Cloud Firestore** ^5.6.7 - Base de données NoSQL cloud
- **Firebase Storage** ^12.4.10 - Stockage de fichiers/images

### État & Navigation
- **Provider** ^6.1.2 - Gestion d'état
- **GoRouter** ^14.0.0 - Navigation déclarative et routing

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

<h2 id="architecture">🏗️ Architecture</h2>

Le projet suit les principes de **Clean Architecture** avec une séparation claire des responsabilités :

```
lib/
├── core/                      # Code partagé
│   ├── constants/            # Constantes globales
│   ├── error/                # Gestion des erreurs
│   ├── network/              # Configuration réseau
│   ├── usecases/             # Use cases abstraits
│   └── utils/                # Utilitaires (router, etc.)
│
├── data/                      # Couche de données
│   ├── datasources/          # Sources de données
│   │   ├── *_firebase_datasource.dart  # Firebase Firestore
│   │   └── *_remote_datasource.dart    # API externe
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
- Compte Firebase (pour la configuration)

### Étapes d'installation

1. **Cloner le repository**
```bash
git clone https://github.com/riyad4589/Flutter_Ecommerce_Electronics_Store.git
cd Flutter_Ecommerce_Electronics_Store
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer Firebase** (voir section suivante)

4. **Lancer l'application**
```bash
# Mode debug
flutter run

# Mode release
flutter run --release
```

---

## 🔥 Configuration Firebase

### 1. Créer un projet Firebase

1. Rendez-vous sur [Firebase Console](https://console.firebase.google.com/)
2. Créez un nouveau projet ou utilisez un projet existant
3. Activez les services suivants :
   - **Authentication** (Email/Password)
   - **Cloud Firestore**

### 2. Configurer FlutterFire

```bash
# Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurer Firebase pour votre projet
flutterfire configure
```

### 3. Structure Firestore

Le projet utilise les collections suivantes :

```
firestore/
├── users/              # Utilisateurs
│   ├── {userId}/
│   │   ├── cart/       # Panier de l'utilisateur
│   │   ├── favorites/  # Favoris de l'utilisateur
│   │   └── orders/     # Commandes de l'utilisateur
│
├── products/           # Catalogue de produits
├── categories/         # Catégories de produits
└── orders/             # Commandes globales (admin)
```

### 4. Règles de sécurité Firestore

Les règles de sécurité sont définies dans `firestore.rules` :
- Les utilisateurs peuvent accéder uniquement à leurs propres données
- Les admins (role: 'admin') peuvent accéder à toutes les données
- Les produits et catégories sont en lecture publique

---

## 🚀 Utilisation

### Comptes de test

**Utilisateur standard :**
- Créez un nouveau compte via la page d'inscription

**Administrateur :**
- Nom d'utilisateur : `admin`
- Mot de passe : `admin123`

### Pages principales

L'application comprend les sections suivantes :

- **Accueil** - Produits populaires et promotions
- **Catégories** - Navigation par catégorie de produits
- **Détails produit** - Informations complètes sur un produit
- **Panier** - Gestion du panier d'achat
- **Checkout** - Finalisation de commande
- **Commandes** - Historique et suivi des commandes
- **Favoris** - Produits favoris
- **Profil** - Informations utilisateur et paramètres
- **Dashboard Admin** - Panel d'administration complet

---

## 📁 Structure du projet

```
Flutter_Ecommerce_Electronics_Store/
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
│   ├── data/                 # Couche de données (Firebase)
│   ├── domain/               # Couche métier
│   ├── presentation/         # Couche UI
│   ├── injection_container.dart  # DI setup
│   └── main.dart            # Point d'entrée
│
├── scripts/                   # Scripts utilitaires
│   └── seed_firebase.js      # Script de seed Firestore
│
├── test/                      # Tests
├── screenshots/               # Captures d'écran
│
├── firebase.json             # Configuration Firebase
├── firestore.rules           # Règles de sécurité Firestore
├── firestore.indexes.json    # Index Firestore
├── pubspec.yaml              # Dépendances Flutter
├── analysis_options.yaml     # Règles d'analyse Dart
└── README.md                 # Ce fichier
```

---

## 🔒 Sécurité Firebase

### Règles Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Fonction admin
    function isAdmin() {
      return request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users: lecture/écriture propre, admin peut tout voir
    match /users/{userId} {
      allow get: if request.auth.uid == userId || isAdmin();
      allow list: if isAdmin();
      allow create: if request.auth != null;
      allow update: if request.auth.uid == userId || isAdmin();
      allow delete: if isAdmin();
    }
    
    // Products & Categories: lecture publique, écriture admin
    match /products/{productId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    // Orders: propriétaire ou admin
    match /orders/{orderId} {
      allow get: if isAdmin() || resource.data.userId == request.auth.uid;
      allow list: if isAdmin();
      allow create: if request.auth != null;
    }
  }
}
```

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

## 🛠️ Panel d'Administration

<div align="center">

| **Dashboard** | **Liste des Produits** | **Produits par Client** | **Liste des Commandes** | **Liste des Utilisateurs** |
|---------------|------------------------|---------------------------|---------------------------|-------------------|
| <img src="screenshots/admin/dashboard.png" width="220"/> | <img src="screenshots/admin/products.png" width="220"/> | <img src="screenshots/admin/product-client.png" width="220"/> | <img src="screenshots/admin/all-commandes.png" width="220"/> | <img src="screenshots/admin/users.png" width="220"/> |

</div>

---

## 🔧 Scripts utilitaires

### Seed Firebase (remplir la base de données)

```bash
cd scripts
npm install firebase-admin
node seed_firebase.js
```

Ce script crée :
- 8 catégories de produits
- 26 produits électroniques
- 1 compte administrateur

---

# 👤 Contributeurs

<p align="center">
<table align="center">
<tr>
<td align="center" width="300">
<a href="https://github.com/riyad4589">
<img src="https://github.com/riyad4589.png" width="150px;" style="border-radius: 50%;" alt="Mohamed Riyad MAJGHIROU"/><br /><br />
<b style="font-size: 18px;">Mohamed Riyad MAJGHIROU</b>
</a><br /><br />
<a href="mailto:riyadmaj10@gmail.com">📧 Email</a> •
<a href="https://www.linkedin.com/in/mohamed-riyad-majghirou-5b62aa388/">💼 LinkedIn</a>
<a href="https://www.riyadmaj.com/">🌐 Portfolio</a>

</td>
<td align="center" width="300">
<a href="https://github.com/Azzammoo10">
<img src="https://github.com/Azzammoo10.png" width="150px;" style="border-radius: 50%;" alt="Mohamed AZZAM"/><br /><br />
<b style="font-size: 18px;">Mohamed AZZAM</b>
</a><br /><br />
<a href="mailto:azzam.moo10@gmail.com">📧 Email</a> •
<a href="https://www.linkedin.com/in/mohamed-azzam-93115823a/">💼 LinkedIn</a> •
<a href="https://azzammo.com">🌐 Portfolio</a>
</td>
</tr>
</table>
</p>
---

<div align="center">

### ⭐ Si ce projet vous a été utile, n'hésitez pas à lui donner une étoile !


[⬆ Retour en haut](#️-electronics-store---application-e-commerce-flutter)

</div>
