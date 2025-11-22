import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/orders_repository.dart';

class DeleteOrder implements UseCase<void, String> {
  final OrdersRepository repository;

  DeleteOrder(this.repository);

  @override
  Future<Either<Failure, void>> call(String orderId) async {
    return await repository.deleteOrder(orderId);
  }
}
