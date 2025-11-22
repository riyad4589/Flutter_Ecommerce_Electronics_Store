import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';

/// Data source pour gérer les utilisateurs dans la base de données locale
class UserLocalDataSource {
  final DatabaseHelper databaseHelper;

  UserLocalDataSource({required this.databaseHelper});

  /// Sauvegarder un utilisateur dans la base de données
  Future<void> saveUser({
    required String id,
    required String name,
    required String email,
    String? username,
    String? password,
    String? profileImage,
  }) async {
    final db = await databaseHelper.database;
    final now = DateTime.now().toIso8601String();

    await db.insert(
      'users',
      {
        'id': id,
        'name': name,
        'email': email,
        'username': username,
        'password': password,
        'profile_image': profileImage,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupérer un utilisateur par son ID
  Future<Map<String, dynamic>?> getUser(String userId) async {
    final db = await databaseHelper.database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Récupérer un utilisateur par son username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await databaseHelper.database;
    final results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Récupérer un utilisateur par son email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await databaseHelper.database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Mettre à jour un utilisateur
  Future<void> updateUser({
    required String id,
    String? name,
    String? email,
    String? username,
    String? password,
    String? profileImage,
  }) async {
    final db = await databaseHelper.database;
    final now = DateTime.now().toIso8601String();

    final updateData = <String, dynamic>{
      'updated_at': now,
    };

    if (name != null) updateData['name'] = name;
    if (email != null) updateData['email'] = email;
    if (username != null) updateData['username'] = username;
    if (password != null) updateData['password'] = password;
    if (profileImage != null) updateData['profile_image'] = profileImage;

    await db.update(
      'users',
      updateData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    final db = await databaseHelper.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Récupérer tous les utilisateurs
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await databaseHelper.database;
    return await db.query('users', orderBy: 'created_at DESC');
  }
}
