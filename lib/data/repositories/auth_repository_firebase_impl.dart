import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';

/// Implémentation du repository d'authentification utilisant Firebase
class AuthRepositoryFirebaseImpl implements AuthRepository {
  final AuthFirebaseDataSource firebaseDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryFirebaseImpl({
    required this.firebaseDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await firebaseDataSource.login(email, password);
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> register(
      String name, String email, String password,
      {String? profileImagePath}) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await firebaseDataSource.register(
          name,
          email,
          password,
          profileImagePath: profileImagePath,
        );
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await firebaseDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur lors de la déconnexion'));
    }
  }

  @override
  Future<Either<Failure, User?>> getLoggedInUser() async {
    try {
      final user = await firebaseDataSource.getCurrentUser();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur lors de la récupération de l\'utilisateur'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(
      String userId, String name, String email,
      {String? profileImagePath}) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await firebaseDataSource.updateProfile(
          userId,
          name,
          email,
          profileImagePath: profileImagePath,
        );
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: 'Erreur lors de la mise à jour du profil'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
