import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({this.message = 'An unexpected error occurred'});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({super.message, this.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Failed to cache data'});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed'});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No Internet Connection'});
}
