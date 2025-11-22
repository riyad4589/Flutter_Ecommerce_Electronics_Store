# API Mock pour E-Commerce App

Serveur API REST mockée pour l'application Flutter e-commerce.

## Installation

```bash
npm install
```

## Démarrage

```bash
npm start
```

Le serveur démarre sur `http://localhost:3000`

## Endpoints disponibles

### Authentification
- `POST /api/v1/auth/register` - Inscription
- `POST /api/v1/auth/login` - Connexion

### Produits
- `GET /api/v1/products` - Liste des produits
- `GET /api/v1/products/:id` - Détails d'un produit
- `GET /api/v1/categories` - Liste des catégories

### Panier (authentification requise)
- `GET /api/v1/cart` - Récupérer le panier
- `POST /api/v1/cart/add` - Ajouter un produit au panier

### Commandes (authentification requise)
- `GET /api/v1/orders` - Historique des commandes
- `POST /api/v1/orders` - Créer une commande

## Utilisation depuis l'émulateur Android

L'URL à utiliser est `http://10.0.2.2:3000` au lieu de `http://localhost:3000`

## Utilisation depuis l'émulateur iOS

L'URL à utiliser est `http://localhost:3000`
