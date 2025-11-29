import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/datasources/product_firebase_datasource.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  final ProductRemoteDataSource productRemoteDataSource;
  final ProductFirebaseDataSource productFirebaseDataSource;

  ProductProvider({
    required this.productRemoteDataSource,
    required this.productFirebaseDataSource,
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
      // D'abord essayer de charger depuis l'API mock
      try {
        _products = await productRemoteDataSource.getAllProducts();
      } catch (e) {
        // Si l'API échoue, charger depuis Firebase
        _products = await productFirebaseDataSource.getProducts();
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
      // D'abord essayer de charger depuis l'API mock
      try {
        _selectedProduct =
            await productRemoteDataSource.getProductById(productId);
      } catch (e) {
        // Si l'API échoue, charger depuis Firebase
        _selectedProduct =
            await productFirebaseDataSource.getProductById(productId);
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
