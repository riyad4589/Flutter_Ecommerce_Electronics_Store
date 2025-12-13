import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/datasources/product_firebase_datasource.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../../data/models/product_model.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  final ProductRemoteDataSource productRemoteDataSource;
  final ProductFirebaseDataSource productFirebaseDataSource;
  final ProductLocalDataSource productLocalDataSource;

  ProductProvider({
    required this.productRemoteDataSource,
    required this.productFirebaseDataSource,
    required this.productLocalDataSource,
  });

  ProductStatus _status = ProductStatus.initial;
  List<Product> _products = [];
  Product? _selectedProduct;
  String? _errorMessage;

  ProductStatus get status => _status;
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    _status = ProductStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Priorité: remote API -> Firebase -> local cache
      try {
        _products = await productRemoteDataSource.getAllProducts();
        // cache locally
        await productLocalDataSource.cacheProducts(
            _products.map((p) => ProductModel.fromEntity(p)).toList());
      } catch (e1) {
        try {
          _products = await productFirebaseDataSource.getProducts();
          await productLocalDataSource.cacheProducts(
              _products.map((p) => ProductModel.fromEntity(p)).toList());
        } catch (e2) {
          // fallback local
          final local = await productLocalDataSource.getProducts();
          _products = local.map((m) => m.toEntity()).toList();
        }
      }

      _status = ProductStatus.loaded;
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadProductById(String productId) async {
    _status = ProductStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Priorité: remote -> firebase -> local
      try {
        final p = await productRemoteDataSource.getProductById(productId);
        _selectedProduct = p;
      } catch (e1) {
        try {
          final p = await productFirebaseDataSource.getProductById(productId);
          _selectedProduct = p;
        } catch (e2) {
          final local = await productLocalDataSource.getProductById(productId);
          _selectedProduct = local?.toEntity();
        }
      }

      _status = ProductStatus.loaded;
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Récupérer un produit par ID
  Future<Product?> getProductById(String productId) async {
    try {
      // D'abord essayer Firebase
      final product = await productFirebaseDataSource.getProductById(productId);
      if (product != null) return product;

      // Sinon essayer l'API mock
      return await productRemoteDataSource.getProductById(productId);
    } catch (e) {
      return null;
    }
  }

  /// Recherche de produits
  Future<List<Product>> searchProducts(String query) async {
    try {
      return await productFirebaseDataSource.searchProducts(query);
    } catch (e) {
      return [];
    }
  }

  /// Charger les produits par catégorie
  Future<void> loadProductsByCategory(String categoryId) async {
    _status = ProductStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _products =
          await productFirebaseDataSource.getProductsByCategory(categoryId);
      _status = ProductStatus.loaded;
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
