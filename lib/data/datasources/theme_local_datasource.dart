import '../../core/database/database_helper.dart';

abstract class ThemeLocalDataSource {
  Future<String?> getThemeMode(String userId);
  Future<void> saveThemeMode(String userId, String themeMode);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  final DatabaseHelper databaseHelper;

  ThemeLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<String?> getThemeMode(String userId) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first['theme_mode'] as String?;
    }
    return null;
  }

  @override
  Future<void> saveThemeMode(String userId, String themeMode) async {
    final db = await databaseHelper.database;

    // Vérifier si l'enregistrement existe
    final existing = await db.query(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (existing.isNotEmpty) {
      // Mettre à jour
      await db.update(
        'user_preferences',
        {'theme_mode': themeMode},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } else {
      // Insérer
      await db.insert('user_preferences', {
        'user_id': userId,
        'theme_mode': themeMode,
      });
    }
  }
}
