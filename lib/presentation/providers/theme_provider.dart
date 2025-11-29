import 'package:flutter/material.dart';
import '../../data/datasources/theme_firebase_datasource.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider with ChangeNotifier {
  final ThemeFirebaseDataSource themeFirebaseDataSource;
  String? _currentUserId;

  AppThemeMode _themeMode = AppThemeMode.light;

  ThemeProvider({required this.themeFirebaseDataSource});

  AppThemeMode get themeMode => _themeMode;

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  String get themeModeText {
    switch (_themeMode) {
      case AppThemeMode.light:
        return 'Clair';
      case AppThemeMode.dark:
        return 'Sombre';
      case AppThemeMode.system:
        return 'Système';
    }
  }

  void setUserId(String userId) {
    _currentUserId = userId;
    loadTheme();
  }

  Future<void> loadTheme() async {
    if (_currentUserId == null) return;

    try {
      final savedTheme =
          await themeFirebaseDataSource.getThemeMode(_currentUserId!);
      if (savedTheme != null) {
        _themeMode = _parseThemeMode(savedTheme);
        notifyListeners();
      }
    } catch (e) {
      // Garder le thème par défaut en cas d'erreur
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    if (_currentUserId != null) {
      try {
        await themeFirebaseDataSource.saveThemeMode(
            _currentUserId!, _themeModeToString(mode));
      } catch (e) {
        // Ignorer les erreurs de sauvegarde
      }
    }
  }

  String _themeModeToString(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  AppThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      default:
        return AppThemeMode.light;
    }
  }
}
