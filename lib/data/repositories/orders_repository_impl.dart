import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/order.dart' as entities;
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_local_datasource.dart';
import '../datasources/orders_remote_datasource.dart';
import '../models/order_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;
  final OrdersLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  OrdersRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<entities.Order>>> getOrders(String userId) async {
    try {
      // Essayer de récupérer depuis l'API
      if (await networkInfo.isConnected) {
        final remoteOrders = await remoteDataSource.getOrders(userId);
        // Sauvegarder en local
        for (final order in remoteOrders) {
          await localDataSource.saveOrder(order);
        }
        return Right(remoteOrders);
      } else {
        // Pas de connexion, récupérer depuis le cache local
        final localOrders = await localDataSource.getOrders(userId);
        return Right(localOrders);
      }
    } catch (e) {
      // En cas d'erreur, essayer le cache local
      try {
        final localOrders = await localDataSource.getOrders(userId);
        return Right(localOrders);
      } catch (e) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, entities.Order>> createOrder(
      entities.Order order) async {
    try {
      print('🔍 OrdersRepository: Création de commande...');
      print('🔍 Vérification connexion réseau...');

      final orderModel = OrderModel(
        id: order.id,
        userId: order.userId,
        items: order.items,
        totalAmount: order.totalAmount,
        orderDate: order.orderDate,
        status: order.status,
      );

      if (await networkInfo.isConnected) {
        print('✅ Réseau connecté');
        try {
          print('🔍 Envoi de la commande à l\'API...');
          print('🔍 OrderModel: ${orderModel.toJson()}');
          final createdOrder = await remoteDataSource.createOrder(orderModel);
          print('✅ Commande créée avec succès sur le serveur');
          // Sauvegarder localement
          await localDataSource.saveOrder(createdOrder);
          print('✅ Commande sauvegardée localement');
          return Right(createdOrder);
        } catch (e) {
          print('⚠️ Erreur API, sauvegarde locale uniquement: $e');
          // Si l'API échoue, sauvegarder quand même localement
          await localDataSource.saveOrder(orderModel);
          print('✅ Commande sauvegardée localement (mode hors ligne)');
          return Right(orderModel);
        }
      } else {
        print('❌ Pas de connexion réseau, sauvegarde locale');
        // Sauvegarder localement même sans connexion
        await localDataSource.saveOrder(orderModel);
        print('✅ Commande sauvegardée localement (mode hors ligne)');
        return Right(orderModel);
      }
    } catch (e, stackTrace) {
      print('❌ Erreur lors de la création de commande: $e');
      print('❌ StackTrace: $stackTrace');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, entities.Order>> getOrderById(String orderId) async {
    try {
      if (await networkInfo.isConnected) {
        final order = await remoteDataSource.getOrderById(orderId);
        return Right(order);
      } else {
        final order = await localDataSource.getOrderById(orderId);
        if (order != null) {
          return Right(order);
        } else {
          return Left(CacheFailure());
        }
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    try {
      // Mettre à jour le statut en local
      await localDataSource.updateOrderStatus(orderId, 'cancelled');

      // TODO: Appeler l'API pour mettre à jour sur le serveur
      // if (await networkInfo.isConnected) {
      //   await remoteDataSource.updateOrderStatus(orderId, 'cancelled');
      // }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteOrder(String orderId) async {
    try {
      // Supprimer de la base de données locale
      await localDataSource.deleteOrder(orderId);

      // TODO: Appeler l'API pour supprimer du serveur
      // if (await networkInfo.isConnected) {
      //   await remoteDataSource.deleteOrder(orderId);
      // }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
