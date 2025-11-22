import 'package:flutter/material.dart';
import '../../data/datasources/cart_local_datasource.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';

enum CartStatus { initial, loading, loaded, error }

class CartProvider extends ChangeNotifier {
  final CartLocalDataSource cartLocalDataSource;
  String? _currentUserId;

  CartProvider({required this.cartLocalDataSource});

  CartStatus _status = CartStatus.initial;
  List<CartItem> _cartItems = [];
  String? _errorMessage;

  CartStatus get status => _status;
  List<CartItem> get cartItems => _cartItems;
  String? get errorMessage => _errorMessage;

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _cartItems.fold(
      0,
      (sum, item) =>
          sum +
          (item.product.discountPrice ?? item.product.price) * item.quantity);

  void setUserId(String userId) {
    _currentUserId = userId;
    loadCart();
  }

  Future<void> loadCart() async {
    if (_currentUserId == null) return;

    _status = CartStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _cartItems = await cartLocalDataSource.getCartItems(_currentUserId!);
      _status = CartStatus.loaded;
    } catch (e) {
      _status = CartStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (_currentUserId == null) return;

    try {
      final productModel = ProductModel(
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

      final cartItem = CartItemModel(
        product: productModel,
        quantity: quantity,
      );

      await cartLocalDataSource.addToCart(_currentUserId!, cartItem);
      await loadCart();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (_currentUserId == null) return;

    try {
      await cartLocalDataSource.updateCartItem(
          _currentUserId!, productId, quantity);
      await loadCart();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeItem(String productId) async {
    if (_currentUserId == null) return;

    try {
      await cartLocalDataSource.removeFromCart(_currentUserId!, productId);
      await loadCart();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    if (_currentUserId == null) return;

    try {
      await cartLocalDataSource.clearCart(_currentUserId!);
      await loadCart();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
