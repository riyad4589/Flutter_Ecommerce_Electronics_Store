import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firebase_service.dart';

abstract class ThemeFirebaseDataSource {
  /// Récupère le mode thème de l'utilisateur
  Future<String?> getThemeMode(String userId);
  
  /// Sauvegarde le mode thème
  Future<void> saveThemeMode(String userId, String themeMode);
}

class ThemeFirebaseDataSourceImpl implements ThemeFirebaseDataSource {
  final FirebaseService _firebaseService;

  ThemeFirebaseDataSourceImpl({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firebaseService.usersCollection;

  @override
  Future<String?> getThemeMode(String userId) async {
    try {
      if (userId.isEmpty) return 'light';
      
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) return 'light';
      
      return doc.data()?['themeMode'] as String? ?? 'light';
    } catch (e) {
      return 'light';
    }
  }

  @override
  Future<void> saveThemeMode(String userId, String themeMode) async {
    try {
      if (userId.isEmpty) return;
      
      await _usersCollection.doc(userId).set({
        'themeMode': themeMode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Silently fail for theme preference
    }
  }
}
