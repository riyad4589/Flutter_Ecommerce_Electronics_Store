import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/error/exceptions.dart';
import '../../core/services/firebase_service.dart';
import '../models/user_model.dart';

abstract class AuthFirebaseDataSource {
  /// Connexion avec email/mot de passe
  Future<UserModel> login(String email, String password);

  /// Inscription avec email/mot de passe
  Future<UserModel> register(String name, String email, String password,
      {String? profileImagePath});

  /// Déconnexion
  Future<void> logout();

  /// Obtenir l'utilisateur actuellement connecté
  Future<UserModel?> getCurrentUser();

  /// Mettre à jour le profil utilisateur
  Future<UserModel> updateProfile(String userId, String name, String email,
      {String? profileImagePath});

  /// Stream pour écouter les changements d'auth
  Stream<firebase_auth.User?> get authStateChanges;
}

class AuthFirebaseDataSourceImpl implements AuthFirebaseDataSource {
  final FirebaseService _firebaseService;

  AuthFirebaseDataSourceImpl({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  firebase_auth.FirebaseAuth get _auth => _firebaseService.auth;
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  FirebaseStorage get _storage => _firebaseService.storage;
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firebaseService.usersCollection;

  @override
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw ServerException(message: 'Échec de la connexion');
      }

      // Récupérer les données utilisateur depuis Firestore
      final userDoc =
          await _usersCollection.doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        throw ServerException(
            message: 'Utilisateur non trouvé dans la base de données');
      }

      final userData = userDoc.data()!;
      return UserModel(
        id: userCredential.user!.uid,
        name: userData['name'] ?? '',
        email: userData['email'] ?? email,
        username: userData['username'],
        profileImage: userData['profileImage'],
        token: await userCredential.user!.getIdToken(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Erreur lors de la connexion: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password,
      {String? profileImagePath}) async {
    try {
      // Créer le compte Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw ServerException(message: 'Échec de la création du compte');
      }

      final userId = userCredential.user!.uid;
      String? profileImageUrl;

      // Upload de l'image de profil si fournie
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        profileImageUrl = await _uploadProfileImage(userId, profileImagePath);
      }

      // Générer un username unique à partir de l'email
      final username = email.split('@').first;

      // Créer le document utilisateur dans Firestore
      final userData = {
        'id': userId,
        'name': name,
        'email': email,
        'username': username,
        'profileImage': profileImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _usersCollection.doc(userId).set(userData);

      // Mettre à jour le displayName dans Firebase Auth
      await userCredential.user!.updateDisplayName(name);
      if (profileImageUrl != null) {
        await userCredential.user!.updatePhotoURL(profileImageUrl);
      }

      return UserModel(
        id: userId,
        name: name,
        email: email,
        username: username,
        profileImage: profileImageUrl,
        token: await userCredential.user!.getIdToken(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Erreur lors de l\'inscription: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw ServerException(message: 'Erreur lors de la déconnexion');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await _usersCollection.doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // L'utilisateur existe dans Auth mais pas dans Firestore
        // Créer le document
        await _usersCollection.doc(firebaseUser.uid).set({
          'id': firebaseUser.uid,
          'name': firebaseUser.displayName ?? 'Utilisateur',
          'email': firebaseUser.email ?? '',
          'username': firebaseUser.email?.split('@').first ?? 'user',
          'profileImage': firebaseUser.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Utilisateur',
          email: firebaseUser.email ?? '',
          username: firebaseUser.email?.split('@').first,
          profileImage: firebaseUser.photoURL,
          token: await firebaseUser.getIdToken(),
        );
      }

      final userData = userDoc.data()!;
      return UserModel(
        id: firebaseUser.uid,
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        username: userData['username'],
        profileImage: userData['profileImage'],
        token: await firebaseUser.getIdToken(),
      );
    } catch (e) {
      throw ServerException(
          message: 'Erreur lors de la récupération de l\'utilisateur');
    }
  }

  @override
  Future<UserModel> updateProfile(String userId, String name, String email,
      {String? profileImagePath}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != userId) {
        throw ServerException(message: 'Utilisateur non authentifié');
      }

      String? profileImageUrl;

      // Upload nouvelle image si fournie
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        profileImageUrl = await _uploadProfileImage(userId, profileImagePath);
      }

      // Mettre à jour Firestore
      final updateData = <String, dynamic>{
        'name': name,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (profileImageUrl != null) {
        updateData['profileImage'] = profileImageUrl;
      }

      await _usersCollection.doc(userId).update(updateData);

      // Mettre à jour Firebase Auth
      await currentUser.updateDisplayName(name);
      if (email != currentUser.email) {
        await currentUser.verifyBeforeUpdateEmail(email);
      }
      if (profileImageUrl != null) {
        await currentUser.updatePhotoURL(profileImageUrl);
      }

      // Récupérer les données mises à jour
      final userDoc = await _usersCollection.doc(userId).get();
      final userData = userDoc.data()!;

      return UserModel(
        id: userId,
        name: userData['name'] ?? name,
        email: userData['email'] ?? email,
        username: userData['username'],
        profileImage: userData['profileImage'] ?? profileImageUrl,
        token: await currentUser.getIdToken(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Erreur lors de la mise à jour du profil');
    }
  }

  /// Upload une image de profil vers Firebase Storage
  Future<String> _uploadProfileImage(String userId, String imagePath) async {
    try {
      final file = File(imagePath);
      final ref = _storage.ref().child('profile_images/$userId.jpg');

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw ServerException(message: 'Erreur lors de l\'upload de l\'image');
    }
  }

  /// Gère les erreurs Firebase Auth et retourne un message localisé
  ServerException _handleFirebaseAuthError(
      firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return ServerException(
            message: 'Aucun utilisateur trouvé avec cet email');
      case 'wrong-password':
        return ServerException(message: 'Mot de passe incorrect');
      case 'email-already-in-use':
        return ServerException(message: 'Cet email est déjà utilisé');
      case 'invalid-email':
        return ServerException(message: 'Adresse email invalide');
      case 'weak-password':
        return ServerException(message: 'Le mot de passe est trop faible');
      case 'operation-not-allowed':
        return ServerException(message: 'Opération non autorisée');
      case 'user-disabled':
        return ServerException(message: 'Ce compte a été désactivé');
      case 'too-many-requests':
        return ServerException(
            message: 'Trop de tentatives. Réessayez plus tard');
      case 'network-request-failed':
        return ServerException(
            message: 'Erreur réseau. Vérifiez votre connexion');
      default:
        return ServerException(
            message: e.message ?? 'Erreur d\'authentification');
    }
  }
}
