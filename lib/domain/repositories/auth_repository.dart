import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(
      String name, String email, String password,
      {String? profileImagePath});
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getLoggedInUser();
  Future<Either<Failure, User>> updateProfile(
      String userId, String name, String email,
      {String? profileImagePath});
}
