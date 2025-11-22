import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/user_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final UserLocalDataSource userLocalDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.userLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.login(email, password);
        // Sauvegarder le token
        await localDataSource.saveToken(
          userModel.token!,
          userModel.id,
          userModel.name,
          userModel.email,
          username: userModel.username,
          profileImage: userModel.profileImage,
        );
        // Sauvegarder l'utilisateur dans la table users
        await userLocalDataSource.saveUser(
          id: userModel.id,
          name: userModel.name,
          email: userModel.email,
          username: userModel.username,
          password: password,
          profileImage: userModel.profileImage,
        );
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(
            ServerFailure(message: e.message, statusCode: e.statusCode));
      } on DioException catch (e) {
        return Left(ServerFailure(
            message: e.message ?? 'Login failed',
            statusCode: e.response?.statusCode));
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
        final userModel =
            await remoteDataSource.register(name, email, password);

        // Utiliser le chemin de l'image fourni ou celui du serveur
        final imagePath = profileImagePath ?? userModel.profileImage;

        // Sauvegarder le token
        await localDataSource.saveToken(
          userModel.token!,
          userModel.id,
          userModel.name,
          userModel.email,
          username: userModel.username,
          profileImage: imagePath,
        );
        // Sauvegarder l'utilisateur dans la table users
        await userLocalDataSource.saveUser(
          id: userModel.id,
          name: userModel.name,
          email: userModel.email,
          username: userModel.username,
          password: password,
          profileImage: imagePath,
        );

        // Retourner l'utilisateur avec l'image locale
        return Right(userModel.copyWith(profileImage: imagePath));
      } on ServerException catch (e) {
        return Left(
            ServerFailure(message: e.message, statusCode: e.statusCode));
      } on DioException catch (e) {
        return Left(ServerFailure(
            message: e.message ?? 'Registration failed',
            statusCode: e.response?.statusCode));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.deleteToken();
      return const Right(null);
    } on CacheException {
      return const Left(
          CacheFailure(message: 'Failed to clear user data locally'));
    }
  }

  @override
  Future<Either<Failure, User?>> getLoggedInUser() async {
    try {
      final userInfo = await localDataSource.getUserInfo();
      if (userInfo == null) return const Right(null);

      // Reconstituer l'utilisateur depuis les infos stock\u00e9es
      return Right(User(
        id: userInfo['userId'],
        name: userInfo['userName'],
        email: userInfo['userEmail'],
        token: userInfo['token'],
        username: userInfo['username'],
        profileImage: userInfo['profileImage'],
      ));
    } on CacheException {
      return const Left(
          CacheFailure(message: 'No logged in user found locally'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(
      String userId, String name, String email,
      {String? profileImagePath}) async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) {
        return const Left(CacheFailure(message: 'Token non trouvé'));
      }

      // Récupérer l'utilisateur actuel depuis la base locale
      final currentUser = await userLocalDataSource.getUser(userId);
      if (currentUser == null) {
        return const Left(CacheFailure(message: 'Utilisateur non trouvé'));
      }

      final imagePath =
          profileImagePath ?? currentUser['profile_image'] as String?;

      // Essayer de mettre à jour sur le serveur si connecté
      if (await networkInfo.isConnected) {
        try {
          final userModel =
              await remoteDataSource.updateProfile(userId, name, email, token);

          // Utiliser les données du serveur avec l'image locale
          await localDataSource.saveToken(
            token,
            userModel.id,
            userModel.name,
            userModel.email,
            username: userModel.username,
            profileImage: imagePath,
          );

          await userLocalDataSource.updateUser(
            id: userModel.id,
            name: userModel.name,
            email: userModel.email,
            username: userModel.username,
            profileImage: imagePath,
          );

          return Right(userModel.copyWith(profileImage: imagePath));
        } catch (e) {
          // Si l'API échoue, continuer avec la mise à jour locale
          print('⚠️ Erreur API, mise à jour locale uniquement: $e');
        }
      }

      // Mise à jour locale uniquement (mode hors ligne ou erreur API)
      await localDataSource.saveToken(
        token,
        userId,
        name,
        email,
        username: currentUser['username'] as String?,
        profileImage: imagePath,
      );

      await userLocalDataSource.updateUser(
        id: userId,
        name: name,
        email: email,
        username: currentUser['username'] as String?,
        profileImage: imagePath,
      );

      return Right(User(
        id: userId,
        name: name,
        email: email,
        token: token,
        username: currentUser['username'] as String?,
        profileImage: imagePath,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur lors de la mise à jour: $e'));
    }
  }
}
