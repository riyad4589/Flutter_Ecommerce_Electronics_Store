import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/error/exceptions.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

abstract class ProductLocalDataSource {
  Future<void> init();
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<ProductModel?> getProductById(String productId);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<CategoryModel>> getCategories();
  Future<void> cacheProducts(List<ProductModel> products);
  Future<void> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
  Stream<List<ProductModel>> watchProducts();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  Database? _db;
  final StreamController<List<ProductModel>> _controller =
      StreamController.broadcast();

  @override
  Future<void> init() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'ecommerce_local.db');

      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE products (
              id TEXT PRIMARY KEY,
              name TEXT,
              description TEXT,
              price REAL,
              discountPrice REAL,
              imageUrl TEXT,
              categoryId TEXT,
              brand TEXT,
              rating REAL,
              reviewCount INTEGER
            )
          ''');

          await db.execute('''
            CREATE TABLE categories (
              id TEXT PRIMARY KEY,
              name TEXT,
              imageUrl TEXT
            )
          ''');
        },
      );
    } catch (e) {
      throw const CacheException(message: 'Erreur initialisation DB locale');
    }
  }

  Database _ensureDb() {
    if (_db == null) throw const CacheException(message: 'DB locale non initialisée');
    return _db!;
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final db = _ensureDb();
    final batch = db.batch();

    for (final p in products) {
      batch.insert('products', p.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
    _notifyWatchers();
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final db = _ensureDb();
      final maps = await db.query('products', orderBy: 'rowid DESC');
      return maps.map((m) => ProductModel.fromMap(m)).toList();
    } catch (e) {
      throw const CacheException(message: 'Erreur lecture produits locaux');
    }
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final db = _ensureDb();
      final maps =
          await db.query('products', where: 'id = ?', whereArgs: [productId]);
      if (maps.isEmpty) return null;
      return ProductModel.fromMap(maps.first);
    } catch (e) {
      throw const CacheException(message: 'Erreur lecture produit local');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final db = _ensureDb();
      final maps = await db
          .query('products', where: 'categoryId = ?', whereArgs: [categoryId]);
      return maps.map((m) => ProductModel.fromMap(m)).toList();
    } catch (e) {
      throw const CacheException(message: 'Erreur lecture produits par catégorie');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      if (query.isEmpty) return [];
      final q = '%${query.toLowerCase()}%';
      final db = _ensureDb();
      final maps = await db.rawQuery(
        'SELECT * FROM products WHERE LOWER(name) LIKE ? OR LOWER(description) LIKE ? OR LOWER(brand) LIKE ?',
        [q, q, q],
      );
      return maps.map((m) => ProductModel.fromMap(m)).toList();
    } catch (e) {
      throw const CacheException(message: 'Erreur recherche locale');
    }
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    try {
      final db = _ensureDb();
      await db.insert('products', product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      _notifyWatchers();
    } catch (e) {
      throw const CacheException(message: 'Erreur ajout produit local');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      final db = _ensureDb();
      await db.update('products', product.toMap(),
          where: 'id = ?', whereArgs: [product.id]);
      _notifyWatchers();
    } catch (e) {
      throw const CacheException(message: 'Erreur mise à jour produit local');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      final db = _ensureDb();
      await db.delete('products', where: 'id = ?', whereArgs: [productId]);
      _notifyWatchers();
    } catch (e) {
      throw const CacheException(message: 'Erreur suppression produit local');
    }
  }

  void _notifyWatchers() async {
    try {
      final list = await getProducts();
      if (!_controller.isClosed) _controller.add(list);
    } catch (_) {}
  }

  @override
  Stream<List<ProductModel>> watchProducts() {
    // Emit current cache then subsequent changes
    Future.microtask(() async {
      try {
        final list = await getProducts();
        if (!_controller.isClosed) _controller.add(list);
      } catch (_) {}
    });
    return _controller.stream;
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final db = _ensureDb();
      final maps = await db.query('categories', orderBy: 'name');
      return maps.map((m) => CategoryModel.fromMap(m)).toList();
    } catch (e) {
      throw const CacheException(message: 'Erreur lecture catégories locales');
    }
  }
}
