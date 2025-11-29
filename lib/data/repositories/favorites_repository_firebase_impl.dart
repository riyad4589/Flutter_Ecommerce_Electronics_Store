import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_firebase_datasource.dart';
import '../models/product_model.dart';

/// Implémentation du repository des favoris utilisant Firebase
class FavoritesRepositoryFirebaseImpl implements FavoritesRepository {
  final FavoritesFirebaseDataSource firebaseDataSource;

  FavoritesRepositoryFirebaseImpl({required this.firebaseDataSource});

  @override
  Future<Either<Failure, List<Product>>> getFavorites(String userId) async {
    try {
      final favorites = await firebaseDataSource.getFavorites(userId);
      return Right(favorites);
    } catch (e) {
      return Left(CacheFailure(message: 'Erreur lors de la récupération des favoris'));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(String userId, Product product) async {
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
      await firebaseDataSource.addToFavorites(userId, productModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erreur lors de l\'ajout aux favoris'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String userId, String productId) async {
    try {
      await firebaseDataSource.removeFromFavorites(userId, productId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erreur lors de la suppression du favori'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String userId, String productId) async {
    try {
      final result = await firebaseDataSource.isFavorite(userId, productId);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: 'Erreur lors de la vérification'));
    }
  }
}
