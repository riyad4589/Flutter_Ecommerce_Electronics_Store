import '../../core/database/database_helper.dart';
import '../../core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<String?> getToken();
  Future<void> saveToken(
      String token, String userId, String userName, String userEmail,
      {String? username, String? profileImage});
  Future<void> deleteToken();
  Future<Map<String, dynamic>?> getUserInfo();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final DatabaseHelper databaseHelper;

  AuthLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<String?> getToken() async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'auth_tokens',
        orderBy: 'id DESC',
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return maps.first['token'] as String?;
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la récupération du token');
    }
  }

  @override
  Future<void> saveToken(
      String token, String userId, String userName, String userEmail,
      {String? username, String? profileImage}) async {
    try {
      final db = await databaseHelper.database;

      // Supprimer les anciens tokens
      await db.delete('auth_tokens');

      // Insérer le nouveau token
      await db.insert(
        'auth_tokens',
        {
          'token': token,
          'user_id': userId,
          'user_name': userName,
          'user_email': userEmail,
          'user_username': username,
          'profile_image': profileImage,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la sauvegarde du token');
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      final db = await databaseHelper.database;
      await db.delete('auth_tokens');
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la suppression du token');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'auth_tokens',
        orderBy: 'id DESC',
        limit: 1,
      );

      if (maps.isEmpty) return null;

      return {
        'token': maps.first['token'] as String,
        'userId': maps.first['user_id'] as String,
        'userName': maps.first['user_name'] as String,
        'userEmail': maps.first['user_email'] as String,
        'username': maps.first['user_username'] as String?,
        'profileImage': maps.first['profile_image'] as String?,
      };
    } catch (e) {
      throw CacheException(
          message: 'Erreur lors de la récupération des infos utilisateur');
    }
  }
}
