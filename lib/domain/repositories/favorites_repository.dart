import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/product.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<Product>>> getFavorites(String userId);
  Future<Either<Failure, void>> addFavorite(String userId, Product product);
  Future<Either<Failure, void>> removeFavorite(String userId, String productId);
  Future<Either<Failure, bool>> isFavorite(String userId, String productId);
}
