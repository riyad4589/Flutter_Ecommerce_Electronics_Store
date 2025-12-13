import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/exceptions.dart';
import '../../core/services/firebase_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

abstract class ProductFirebaseDataSource {
  /// Récupère tous les produits
  Future<List<ProductModel>> getProducts();
  
  /// Récupère les produits par catégorie
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  
  /// Récupère un produit par ID
  Future<ProductModel?> getProductById(String productId);
  
  /// Recherche de produits
  Future<List<ProductModel>> searchProducts(String query);
  
  /// Récupère toutes les catégories
  Future<List<CategoryModel>> getCategories();
  
  /// Ajoute un produit (admin)
  Future<ProductModel> addProduct(ProductModel product);
  
  /// Met à jour un produit (admin)
  Future<void> updateProduct(ProductModel product);
  
  /// Supprime un produit (admin)
  Future<void> deleteProduct(String productId);
  
  /// Stream pour écouter les changements des produits
  Stream<List<ProductModel>> watchProducts();
  
  /// Stream pour écouter les produits d'une catégorie
  Stream<List<ProductModel>> watchProductsByCategory(String categoryId);
}

class ProductFirebaseDataSourceImpl implements ProductFirebaseDataSource {
  final FirebaseService _firebaseService;

  ProductFirebaseDataSourceImpl({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firebaseService.productsCollection;

  CollectionReference<Map<String, dynamic>> get _categoriesCollection =>
      _firebaseService.categoriesCollection;

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final snapshot = await _productsCollection
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
    } catch (e) {
      throw const ServerException(message: 'Erreur lors de la récupération des produits');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final snapshot = await _productsCollection
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
    } catch (e) {
      throw const ServerException(message: 'Erreur lors de la récupération des produits');
    }
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (!doc.exists) return null;
      
      return _productFromDoc(doc);
    } catch (e) {
      throw const ServerException(message: 'Erreur lors de la récupération du produit');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      if (query.isEmpty) return [];
      
      final queryLower = query.toLowerCase();
      
      // Firebase ne supporte pas la recherche full-text nativement
      // On récupère tous les produits et on filtre côté client
      final snapshot = await _productsCollection.get();
      
      return snapshot.docs
          .map((doc) => _productFromDoc(doc))
          .where((product) =>
              product.name.toLowerCase().contains(queryLower) ||
              product.description.toLowerCase().contains(queryLower) ||
              product.brand.toLowerCase().contains(queryLower))
          .toList();
    } catch (e) {
      throw const ServerException(message: 'Erreur lors de la recherche');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _categoriesCollection
          .orderBy('name')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CategoryModel(
          id: doc.id,
          name: data['name'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw const ServerException(message: 'Erreur lors de la récupération des catégories');
    }
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      final docRef = _productsCollection.doc();
      final productId = docRef.id;
      
      final productData = {
        'id': productId,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'discountPrice': product.discountPrice,
        'imageUrl': product.imageUrl,
        'categoryId': product.categoryId,
        'brand': product.brand,
        'rating': product.rating,
        'reviewCount': product.reviewCount,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await docRef.set(productData);
      
      return ProductModel(
        id: productId,
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
    } catch (e) {
      throw const ServerException(message: 'Erreur lors de l\'ajout du produit');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _productsCollection.doc(product.id).update({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'discountPrice': product.discountPrice,
        'imageUrl': product.imageUrl,
        'categoryId': product.categoryId,
        'brand': product.brand,
        'rating': product.rating,
        'reviewCount': product.reviewCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw const ServerException(message: 'Erreur lors de la mise à jour du produit');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      throw const ServerException(message: 'Erreur lors de la suppression du produit');
    }
  }

  @override
  Stream<List<ProductModel>> watchProducts() {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
    });
  }

  @override
  Stream<List<ProductModel>> watchProductsByCategory(String categoryId) {
    return _productsCollection
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
    });
  }

  ProductModel _productFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProductModel(
      id: doc.id,
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
  }
}
