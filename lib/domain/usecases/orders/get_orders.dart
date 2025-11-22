import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/order.dart' as entities;
import '../../repositories/orders_repository.dart';

class GetOrders implements UseCase<List<entities.Order>, String> {
  final OrdersRepository repository;

  GetOrders(this.repository);

  @override
  Future<Either<Failure, List<entities.Order>>> call(String userId) async {
    return await repository.getOrders(userId);
  }
}
