import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/exceptions.dart';
import '../../core/services/firebase_service.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

abstract class CartFirebaseDataSource {
  /// Récupère tous les items du panier
  Future<List<CartItemModel>> getCartItems(String userId);

  /// Ajoute un produit au panier
  Future<void> addToCart(String userId, CartItemModel item);

  /// Met à jour la quantité d'un item
  Future<void> updateQuantity(String userId, String productId, int quantity);

  /// Supprime un item du panier
  Future<void> removeFromCart(String userId, String productId);

  /// Vide le panier
  Future<void> clearCart(String userId);

  /// Stream pour écouter les changements du panier
  Stream<List<CartItemModel>> watchCartItems(String userId);
}

class CartFirebaseDataSourceImpl implements CartFirebaseDataSource {
  final FirebaseService _firebaseService;

  CartFirebaseDataSourceImpl({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  CollectionReference<Map<String, dynamic>> _cartCollection(String userId) =>
      _firebaseService.cartCollection(userId);

  @override
  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      if (userId.isEmpty) return [];

      final snapshot = await _cartCollection(userId).get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CartItemModel(
          product: ProductModel(
            id: data['productId'] ?? doc.id,
            name: data['productName'] ?? '',
            description: data['description'] ?? '',
            price: (data['price'] as num?)?.toDouble() ?? 0.0,
            discountPrice: (data['discountPrice'] as num?)?.toDouble(),
            imageUrl: data['imageUrl'] ?? '',
            categoryId: data['categoryId'] ?? '',
            brand: data['brand'] ?? '',
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            reviewCount: data['reviewCount'] as int? ?? 0,
          ),
          quantity: data['quantity'] as int? ?? 1,
        );
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la récupération du panier');
    }
  }

  @override
  Future<void> addToCart(String userId, CartItemModel item) async {
    try {
      if (userId.isEmpty) {
        throw CacheException(message: 'Utilisateur non connecté');
      }

      final productId = item.product.id;
      final docRef = _cartCollection(userId).doc(productId);

      // Vérifier si le produit existe déjà
      final existingDoc = await docRef.get();

      if (existingDoc.exists) {
        // Mettre à jour la quantité
        final currentQuantity = existingDoc.data()?['quantity'] as int? ?? 0;
        await docRef.update({
          'quantity': currentQuantity + item.quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Ajouter nouveau produit
        await docRef.set({
          'productId': item.product.id,
          'productName': item.product.name,
          'description': item.product.description,
          'price': item.product.price,
          'discountPrice': item.product.discountPrice,
          'imageUrl': item.product.imageUrl,
          'categoryId': item.product.categoryId,
          'brand': item.product.brand,
          'rating': item.product.rating,
          'reviewCount': item.product.reviewCount,
          'quantity': item.quantity,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Erreur lors de l\'ajout au panier');
    }
  }

  @override
  Future<void> updateQuantity(
      String userId, String productId, int quantity) async {
    try {
      if (userId.isEmpty) {
        throw CacheException(message: 'Utilisateur non connecté');
      }

      if (quantity <= 0) {
        await removeFromCart(userId, productId);
        return;
      }

      await _cartCollection(userId).doc(productId).update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
          message: 'Erreur lors de la mise à jour de la quantité');
    }
  }

  @override
  Future<void> removeFromCart(String userId, String productId) async {
    try {
      if (userId.isEmpty) {
        throw CacheException(message: 'Utilisateur non connecté');
      }

      await _cartCollection(userId).doc(productId).delete();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Erreur lors de la suppression du produit');
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      if (userId.isEmpty) return;

      final batch = _firebaseService.firestore.batch();
      final snapshot = await _cartCollection(userId).get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw CacheException(message: 'Erreur lors du vidage du panier');
    }
  }

  @override
  Stream<List<CartItemModel>> watchCartItems(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _cartCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CartItemModel(
          product: ProductModel(
            id: data['productId'] ?? doc.id,
            name: data['productName'] ?? '',
            description: data['description'] ?? '',
            price: (data['price'] as num?)?.toDouble() ?? 0.0,
            discountPrice: (data['discountPrice'] as num?)?.toDouble(),
            imageUrl: data['imageUrl'] ?? '',
            categoryId: data['categoryId'] ?? '',
            brand: data['brand'] ?? '',
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            reviewCount: data['reviewCount'] as int? ?? 0,
          ),
          quantity: data['quantity'] as int? ?? 1,
        );
      }).toList();
    });
  }
}
