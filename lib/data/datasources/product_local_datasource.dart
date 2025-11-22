import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';

class ProductLocalDataSource {
  final DatabaseHelper databaseHelper;

  ProductLocalDataSource({required this.databaseHelper});

  Future<void> saveProduct({
    required String id,
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    String? imageUrl,
    String? categoryId,
    String? brand,
    double? rating,
    int? reviewCount,
  }) async {
    final db = await databaseHelper.database;
    final now = DateTime.now().toIso8601String();

    await db.insert(
      'products',
      {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'discount_price': discountPrice,
        'image_url': imageUrl,
        'category_id': categoryId,
        'brand': brand,
        'rating': rating,
        'review_count': reviewCount,
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveProducts(List<Map<String, dynamic>> products) async {
    final db = await databaseHelper.database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (var product in products) {
      batch.insert(
        'products',
        {
          'id': product['id'],
          'name': product['name'],
          'description': product['description'],
          'price': product['price'],
          'discount_price': product['discountPrice'],
          'image_url': product['imageUrl'],
          'category_id': product['categoryId'],
          'brand': product['brand'],
          'rating': product['rating'],
          'review_count': product['reviewCount'],
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<Map<String, dynamic>?> getProduct(String productId) async {
    final db = await databaseHelper.database;
    final results = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await databaseHelper.database;
    return await db.query('products', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(
      String categoryId) async {
    final db = await databaseHelper.database;
    return await db.query(
      'products',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final db = await databaseHelper.database;
    return await db.query(
      'products',
      where: 'name LIKE ? OR description LIKE ? OR brand LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> deleteProduct(String productId) async {
    final db = await databaseHelper.database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> clearProducts() async {
    final db = await databaseHelper.database;
    await db.delete('products');
  }
}
