import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/order.dart' as entities;
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_firebase_datasource.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

/// Implémentation du repository des commandes utilisant Firebase
class OrdersRepositoryFirebaseImpl implements OrdersRepository {
  final OrdersFirebaseDataSource firebaseDataSource;
  final NetworkInfo networkInfo;

  OrdersRepositoryFirebaseImpl({
    required this.firebaseDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<entities.Order>>> getOrders(String userId) async {
    try {
      if (await networkInfo.isConnected) {
        final orders = await firebaseDataSource.getOrders(userId);
        return Right(orders);
      } else {
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erreur lors de la récupération des commandes'));
    }
  }

  @override
  Future<Either<Failure, entities.Order>> createOrder(
      entities.Order order) async {
    try {
      if (await networkInfo.isConnected) {
        // Convertir les items en CartItemModel
        final cartItems =
            order.items.map((item) => CartItemModel.fromEntity(item)).toList();

        final createdOrder = await firebaseDataSource.createOrder(
          order.userId,
          cartItems,
          order.totalAmount,
        );
        return Right(createdOrder);
      } else {
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(
          ServerFailure(message: 'Erreur lors de la création de la commande'));
    }
  }

  @override
  Future<Either<Failure, entities.Order>> getOrderById(String orderId) async {
    try {
      if (await networkInfo.isConnected) {
        final order = await firebaseDataSource.getOrderById(orderId);
        if (order != null) {
          return Right(order);
        } else {
          return const Left(CacheFailure(message: 'Commande non trouvée'));
        }
      } else {
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erreur lors de la récupération de la commande'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    try {
      if (await networkInfo.isConnected) {
        await firebaseDataSource.cancelOrder(orderId);
        return const Right(null);
      } else {
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erreur lors de l\'annulation de la commande'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOrder(String orderId) async {
    try {
      if (await networkInfo.isConnected) {
        await firebaseDataSource.deleteOrder(orderId);
        return const Right(null);
      } else {
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ServerFailure(
          message: 'Erreur lors de la suppression de la commande'));
    }
  }
}
