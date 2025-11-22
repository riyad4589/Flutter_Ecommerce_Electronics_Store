import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoritesRepository repository;
  final String userId;

  FavoritesProvider({
    required this.repository,
    required this.userId,
  }) {
    loadFavorites();
  }

  List<Product> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getFavorites(userId);
    result.fold(
      (failure) {
        _errorMessage = 'Erreur lors du chargement des favoris';
        _isLoading = false;
        notifyListeners();
      },
      (favorites) {
        _favorites = favorites;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> toggleFavorite(Product product) async {
    final isFav = await isFavorite(product.id);

    if (isFav) {
      return await removeFavorite(product.id);
    } else {
      return await addFavorite(product);
    }
  }

  Future<bool> addFavorite(Product product) async {
    final result = await repository.addFavorite(userId, product);
    return result.fold(
      (failure) {
        _errorMessage = 'Erreur lors de l\'ajout aux favoris';
        notifyListeners();
        return false;
      },
      (_) {
        _favorites.add(product);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> removeFavorite(String productId) async {
    final result = await repository.removeFavorite(userId, productId);
    return result.fold(
      (failure) {
        _errorMessage = 'Erreur lors de la suppression des favoris';
        notifyListeners();
        return false;
      },
      (_) {
        _favorites.removeWhere((p) => p.id == productId);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> isFavorite(String productId) async {
    final result = await repository.isFavorite(userId, productId);
    return result.fold(
      (failure) => false,
      (isFav) => isFav,
    );
  }
}
