import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/product_model.dart';

abstract class FavoritesLocalDataSource {
  Future<List<ProductModel>> getFavorites(String userId);
  Future<void> addFavorite(String userId, ProductModel product);
  Future<void> removeFavorite(String userId, String productId);
  Future<bool> isFavorite(String userId, String productId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final DatabaseHelper databaseHelper;

  FavoritesLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<ProductModel>> getFavorites(String userId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) {
      return ProductModel(
        id: map['product_id'] as String,
        name: map['product_name'] as String,
        description: map['product_description'] as String? ?? '',
        price: map['price'] as double,
        discountPrice: map['discount_price'] as double?,
        imageUrl: map['image_url'] as String? ?? '',
        categoryId: map['category_id'] as String? ?? '',
        brand: map['brand'] as String? ?? '',
        rating: map['rating'] as double? ?? 0.0,
        reviewCount: map['review_count'] as int? ?? 0,
      );
    }).toList();
  }

  @override
  Future<void> addFavorite(String userId, ProductModel product) async {
    final db = await databaseHelper.database;
    await db.insert(
      'favorites',
      {
        'user_id': userId,
        'product_id': product.id,
        'product_name': product.name,
        'product_description': product.description,
        'price': product.price,
        'discount_price': product.discountPrice,
        'image_url': product.imageUrl,
        'category_id': product.categoryId,
        'brand': product.brand,
        'rating': product.rating,
        'review_count': product.reviewCount,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeFavorite(String userId, String productId) async {
    final db = await databaseHelper.database;
    await db.delete(
      'favorites',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
  }

  @override
  Future<bool> isFavorite(String userId, String productId) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'favorites',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
