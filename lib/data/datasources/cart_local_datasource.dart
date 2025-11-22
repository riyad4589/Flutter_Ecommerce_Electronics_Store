import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/error/exceptions.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems(String userId);
  Future<void> addToCart(String userId, CartItemModel cartItem);
  Future<void> updateCartItem(String userId, String productId, int quantity);
  Future<void> removeFromCart(String userId, String productId);
  Future<void> clearCart(String userId);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final DatabaseHelper databaseHelper;

  CartLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'cart_items',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      return maps.map((map) {
        final product = ProductModel(
          id: map['product_id'] as String,
          name: map['product_name'] as String,
          description: map['product_description'] as String? ?? '',
          price: map['price'] as double,
          discountPrice: map['discount_price'] as double?,
          imageUrl: map['image_url'] as String,
          categoryId: map['category_id'] as String,
          brand: map['brand'] as String,
          rating: map['rating'] as double,
          reviewCount: map['review_count'] as int,
        );

        return CartItemModel(
          product: product,
          quantity: map['quantity'] as int,
        );
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la récupération du panier');
    }
  }

  @override
  Future<void> addToCart(String userId, CartItemModel cartItem) async {
    try {
      final db = await databaseHelper.database;

      // Vérifier si le produit existe déjà
      final existing = await db.query(
        'cart_items',
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, cartItem.product.id],
      );

      if (existing.isNotEmpty) {
        // Augmenter la quantité
        final currentQuantity = existing.first['quantity'] as int;
        await db.update(
          'cart_items',
          {'quantity': currentQuantity + cartItem.quantity},
          where: 'user_id = ? AND product_id = ?',
          whereArgs: [userId, cartItem.product.id],
        );
      } else {
        // Ajouter le nouveau produit
        await db.insert(
          'cart_items',
          {
            'user_id': userId,
            'product_id': cartItem.product.id,
            'product_name': cartItem.product.name,
            'product_description': cartItem.product.description,
            'price': cartItem.product.price,
            'discount_price': cartItem.product.discountPrice,
            'image_url': cartItem.product.imageUrl,
            'category_id': cartItem.product.categoryId,
            'brand': cartItem.product.brand,
            'rating': cartItem.product.rating,
            'review_count': cartItem.product.reviewCount,
            'quantity': cartItem.quantity,
            'created_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      throw CacheException(message: 'Erreur lors de l\'ajout au panier');
    }
  }

  @override
  Future<void> updateCartItem(
      String userId, String productId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(userId, productId);
      } else {
        final db = await databaseHelper.database;
        await db.update(
          'cart_items',
          {'quantity': quantity},
          where: 'user_id = ? AND product_id = ?',
          whereArgs: [userId, productId],
        );
      }
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la mise à jour du panier');
    }
  }

  @override
  Future<void> removeFromCart(String userId, String productId) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        'cart_items',
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, productId],
      );
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la suppression du produit');
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        'cart_items',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la suppression du panier');
    }
  }
}
