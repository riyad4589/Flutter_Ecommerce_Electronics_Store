import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/order.dart' as entities;
import '../../repositories/orders_repository.dart';

class CreateOrder implements UseCase<entities.Order, entities.Order> {
  final OrdersRepository repository;

  CreateOrder(this.repository);

  @override
  Future<Either<Failure, entities.Order>> call(entities.Order order) async {
    return await repository.createOrder(order);
  }
}
