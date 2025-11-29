import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/exceptions.dart';
import '../../core/services/firebase_service.dart';
import '../models/product_model.dart';

abstract class FavoritesFirebaseDataSource {
  /// Récupère tous les favoris
  Future<List<ProductModel>> getFavorites(String userId);
  
  /// Ajoute un produit aux favoris
  Future<void> addToFavorites(String userId, ProductModel product);
  
  /// Supprime un produit des favoris
  Future<void> removeFromFavorites(String userId, String productId);
  
  /// Vérifie si un produit est en favori
  Future<bool> isFavorite(String userId, String productId);
  
  /// Vide tous les favoris
  Future<void> clearFavorites(String userId);
  
  /// Stream pour écouter les changements des favoris
  Stream<List<ProductModel>> watchFavorites(String userId);
}

class FavoritesFirebaseDataSourceImpl implements FavoritesFirebaseDataSource {
  final FirebaseService _firebaseService;

  FavoritesFirebaseDataSourceImpl({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  CollectionReference<Map<String, dynamic>> _favoritesCollection(String userId) =>
      _firebaseService.favoritesCollection(userId);

  @override
  Future<List<ProductModel>> getFavorites(String userId) async {
    try {
      if (userId.isEmpty) return [];
      
      final snapshot = await _favoritesCollection(userId)
          .orderBy('addedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel(
          id: data['productId'] ?? doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          discountPrice: (data['discountPrice'] as num?)?.toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          categoryId: data['categoryId'] ?? '',
          brand: data['brand'] ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          reviewCount: data['reviewCount'] as int? ?? 0,
        );
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la récupération des favoris');
    }
  }

  @override
  Future<void> addToFavorites(String userId, ProductModel product) async {
    try {
      if (userId.isEmpty) {
        throw CacheException(message: 'Utilisateur non connecté');
      }
      
      await _favoritesCollection(userId).doc(product.id).set({
        'productId': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'discountPrice': product.discountPrice,
        'imageUrl': product.imageUrl,
        'categoryId': product.categoryId,
        'brand': product.brand,
        'rating': product.rating,
        'reviewCount': product.reviewCount,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Erreur lors de l\'ajout aux favoris');
    }
  }

  @override
  Future<void> removeFromFavorites(String userId, String productId) async {
    try {
      if (userId.isEmpty) {
        throw CacheException(message: 'Utilisateur non connecté');
      }
      
      await _favoritesCollection(userId).doc(productId).delete();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Erreur lors de la suppression du favori');
    }
  }

  @override
  Future<bool> isFavorite(String userId, String productId) async {
    try {
      if (userId.isEmpty) return false;
      
      final doc = await _favoritesCollection(userId).doc(productId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearFavorites(String userId) async {
    try {
      if (userId.isEmpty) return;
      
      final batch = _firebaseService.firestore.batch();
      final snapshot = await _favoritesCollection(userId).get();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw CacheException(message: 'Erreur lors du vidage des favoris');
    }
  }

  @override
  Stream<List<ProductModel>> watchFavorites(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    
    return _favoritesCollection(userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel(
          id: data['productId'] ?? doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          discountPrice: (data['discountPrice'] as num?)?.toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          categoryId: data['categoryId'] ?? '',
          brand: data['brand'] ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          reviewCount: data['reviewCount'] as int? ?? 0,
        );
      }).toList();
    });
  }
}
