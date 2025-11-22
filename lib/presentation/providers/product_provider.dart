import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/datasources/product_local_datasource.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  final ProductRemoteDataSource productRemoteDataSource;
  final ProductLocalDataSource productLocalDataSource;

  ProductProvider({
    required this.productRemoteDataSource,
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
      _products = await productRemoteDataSource.getAllProducts();

      // Stocker les produits dans la base de données locale
      for (final product in _products) {
        await productLocalDataSource.saveProduct(
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          discountPrice: product.discountPrice,
          imageUrl: product.imageUrl,
          categoryId: product.categoryId,
          brand: product.brand,
          rating: product.rating,
          reviewCount: product.reviewCount,
        );
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
      _selectedProduct =
          await productRemoteDataSource.getProductById(productId);

      // Stocker le produit dans la base de données locale
      if (_selectedProduct != null) {
        await productLocalDataSource.saveProduct(
          id: _selectedProduct!.id,
          name: _selectedProduct!.name,
          description: _selectedProduct!.description,
          price: _selectedProduct!.price,
          discountPrice: _selectedProduct!.discountPrice,
          imageUrl: _selectedProduct!.imageUrl,
          categoryId: _selectedProduct!.categoryId,
          brand: _selectedProduct!.brand,
          rating: _selectedProduct!.rating,
          reviewCount: _selectedProduct!.reviewCount,
        );
      }

      _status = ProductStatus.loaded;
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
