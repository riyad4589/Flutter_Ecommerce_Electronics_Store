import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';

class UserLocalDataSource {
  final DatabaseHelper databaseHelper;

  UserLocalDataSource({required this.databaseHelper});

  Future<void> saveUser({
    required String id,
    required String name,
    required String email,
    required String username,
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
        'profile_image': profileImage,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final db = await databaseHelper.database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await databaseHelper.database;
    final results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await databaseHelper.database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateUser({
    required String id,
    String? name,
    String? email,
    String? username,
    String? profileImage,
  }) async {
    final db = await databaseHelper.database;
    final now = DateTime.now().toIso8601String();

    final updates = <String, dynamic>{
      'updated_at': now,
    };

    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (username != null) updates['username'] = username;
    if (profileImage != null) updates['profile_image'] = profileImage;

    await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteUser(String userId) async {
    final db = await databaseHelper.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await databaseHelper.database;
    return await db.query('users', orderBy: 'created_at DESC');
  }
}
