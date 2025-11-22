import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';
import '../models/product_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  FavoritesRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Product>>> getFavorites(String userId) async {
    try {
      final favorites = await localDataSource.getFavorites(userId);
      return Right(favorites);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(
      String userId, Product product) async {
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
      await localDataSource.addFavorite(userId, productModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(
      String userId, String productId) async {
    try {
      await localDataSource.removeFavorite(userId, productId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(
      String userId, String productId) async {
    try {
      final result = await localDataSource.isFavorite(userId, productId);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
