import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ecommerce.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajouter les nouvelles tables pour la version 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          username TEXT NOT NULL UNIQUE,
          profile_image TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS products (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          price REAL NOT NULL,
          discount_price REAL,
          image_url TEXT,
          category_id TEXT,
          brand TEXT,
          rating REAL,
          review_count INTEGER,
          created_at TEXT NOT NULL
        )
      ''');

      // Ajouter colonnes manquantes à auth_tokens
      await db.execute('''
        ALTER TABLE auth_tokens ADD COLUMN user_username TEXT
      ''');
      await db.execute('''
        ALTER TABLE auth_tokens ADD COLUMN profile_image TEXT
      ''');

      // Créer les index
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id)
      ''');
    }

    if (oldVersion < 3) {
      // Ajouter le champ password à la table users
      await db.execute('''
        ALTER TABLE users ADD COLUMN password TEXT
      ''');
    }

    if (oldVersion < 4) {
      // Créer les tables orders et order_items si elles n'existent pas
      await db.execute('''
        CREATE TABLE IF NOT EXISTS orders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id TEXT NOT NULL UNIQUE,
          user_id TEXT NOT NULL,
          total_amount REAL NOT NULL,
          status TEXT NOT NULL,
          shipping_address TEXT,
          payment_method TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS order_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id TEXT NOT NULL,
          product_id TEXT NOT NULL,
          product_name TEXT NOT NULL,
          price REAL NOT NULL,
          quantity INTEGER NOT NULL,
          image_url TEXT,
          FOREIGN KEY (order_id) REFERENCES orders(order_id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_preferences (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL UNIQUE,
          theme_mode TEXT NOT NULL DEFAULT 'light',
          notifications_enabled INTEGER NOT NULL DEFAULT 1,
          updated_at TEXT NOT NULL
        )
      ''');

      // Créer les index
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id)
      ''');
    }

    if (oldVersion < 5) {
      // S'assurer que user_preferences existe (au cas où elle n'aurait pas été créée)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_preferences (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL UNIQUE,
          theme_mode TEXT NOT NULL DEFAULT 'light',
          notifications_enabled INTEGER NOT NULL DEFAULT 1,
          updated_at TEXT NOT NULL
        )
      ''');

      // S'assurer que favorites existe
      await db.execute('''
        CREATE TABLE IF NOT EXISTS favorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          product_id TEXT NOT NULL,
          product_name TEXT NOT NULL,
          product_description TEXT,
          price REAL NOT NULL,
          discount_price REAL,
          image_url TEXT,
          category_id TEXT,
          brand TEXT,
          rating REAL,
          review_count INTEGER,
          created_at TEXT NOT NULL,
          UNIQUE(user_id, product_id)
        )
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Table pour les utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        username TEXT NOT NULL UNIQUE,
        password TEXT,
        profile_image TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Table pour les produits (cache local)
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        discount_price REAL,
        image_url TEXT,
        category_id TEXT,
        brand TEXT,
        rating REAL,
        review_count INTEGER,
        created_at TEXT NOT NULL
      )
    ''');

    // Table pour le panier
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        product_description TEXT,
        price REAL NOT NULL,
        discount_price REAL,
        image_url TEXT,
        category_id TEXT,
        brand TEXT,
        rating REAL,
        review_count INTEGER,
        quantity INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(user_id, product_id)
      )
    ''');

    // Table pour l'authentification
    await db.execute('''
      CREATE TABLE auth_tokens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        token TEXT NOT NULL,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        user_email TEXT NOT NULL,
        user_username TEXT,
        profile_image TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Table pour les favoris
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        product_description TEXT,
        price REAL NOT NULL,
        discount_price REAL,
        image_url TEXT,
        category_id TEXT,
        brand TEXT,
        rating REAL,
        review_count INTEGER,
        created_at TEXT NOT NULL,
        UNIQUE(user_id, product_id)
      )
    ''');

    // Table pour les commandes
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL UNIQUE,
        user_id TEXT NOT NULL,
        total_amount REAL NOT NULL,
        status TEXT NOT NULL,
        shipping_address TEXT,
        payment_method TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Table pour les items des commandes
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        image_url TEXT,
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
      )
    ''');

    // Table pour les préférences utilisateur (thème, etc.)
    await db.execute('''
      CREATE TABLE user_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL UNIQUE,
        theme_mode TEXT NOT NULL DEFAULT 'light',
        notifications_enabled INTEGER NOT NULL DEFAULT 1,
        updated_at TEXT NOT NULL
      )
    ''');

    // Index pour améliorer les performances
    await db.execute('''
      CREATE INDEX idx_users_email ON users(email)
    ''');
    await db.execute('''
      CREATE INDEX idx_users_username ON users(username)
    ''');
    await db.execute('''
      CREATE INDEX idx_products_category ON products(category_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_cart_user_id ON cart_items(user_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_favorites_user_id ON favorites(user_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_orders_user_id ON orders(user_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_order_items_order_id ON order_items(order_id)
    ''');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('users');
    await db.delete('products');
    await db.delete('cart_items');
    await db.delete('auth_tokens');
    await db.delete('favorites');
    await db.delete('orders');
    await db.delete('order_items');
    await db.delete('user_preferences');
  }

  Future<void> clearAuthTokens() async {
    final db = await database;
    await db.delete('auth_tokens');
  }

  Future<void> clearCartItems() async {
    final db = await database;
    await db.delete('cart_items');
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ecommerce.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
