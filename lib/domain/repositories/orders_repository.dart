import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/order.dart' as entities;

abstract class OrdersRepository {
  Future<Either<Failure, List<entities.Order>>> getOrders(String userId);
  Future<Either<Failure, entities.Order>> createOrder(entities.Order order);
  Future<Either<Failure, entities.Order>> getOrderById(String orderId);
  Future<Either<Failure, void>> cancelOrder(String orderId);
  Future<Either<Failure, void>> deleteOrder(String orderId);
}
