import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';

/// Service principal Firebase - remplace complètement DatabaseHelper
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._();
  static FirebaseService get instance => _instance;

  FirebaseService._();

  // Instances Firebase
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  firebase_auth.FirebaseAuth get auth => firebase_auth.FirebaseAuth.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;

  // Collections Firestore
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get productsCollection =>
      firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get categoriesCollection =>
      firestore.collection('categories');

  CollectionReference<Map<String, dynamic>> get ordersCollection =>
      firestore.collection('orders');

  // Sous-collections pour un utilisateur
  CollectionReference<Map<String, dynamic>> cartCollection(String userId) =>
      usersCollection.doc(userId).collection('cart');

  CollectionReference<Map<String, dynamic>> favoritesCollection(
          String userId) =>
      usersCollection.doc(userId).collection('favorites');

  CollectionReference<Map<String, dynamic>> userOrdersCollection(
          String userId) =>
      usersCollection.doc(userId).collection('orders');

  // Sous-collection pour les items d'une commande
  CollectionReference<Map<String, dynamic>> orderItemsCollection(
          String orderId) =>
      ordersCollection.doc(orderId).collection('items');
}
