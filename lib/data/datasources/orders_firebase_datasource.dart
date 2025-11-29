import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/exceptions.dart';
import '../../core/services/firebase_service.dart';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

abstract class OrdersFirebaseDataSource {
  /// Récupère toutes les commandes d'un utilisateur
  Future<List<OrderModel>> getOrders(String userId);
  
  /// Récupère une commande par ID
  Future<OrderModel?> getOrderById(String orderId);
  
  /// Crée une nouvelle commande
  Future<OrderModel> createOrder(String userId, List<CartItemModel> items, double totalAmount);
  
  /// Met à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  
  /// Annule une commande
  Future<void> cancelOrder(String orderId);
  
  /// Supprime une commande
  Future<void> deleteOrder(String orderId);
  
  /// Stream pour écouter les changements des commandes
  Stream<List<OrderModel>> watchOrders(String userId);
  
  /// Récupère toutes les commandes (admin)
  Future<List<OrderModel>> getAllOrders();
}

class OrdersFirebaseDataSourceImpl implements OrdersFirebaseDataSource {
  final FirebaseService _firebaseService;

  OrdersFirebaseDataSourceImpl({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firebaseService.ordersCollection;

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    try {
      if (userId.isEmpty) return [];
      
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true)
          .get();
      
      return await Future.wait(
        snapshot.docs.map((doc) => _orderFromSnapshot(doc)).toList(),
      );
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la récupération des commandes');
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (!doc.exists) return null;
      
      return await _orderFromSnapshot(doc);
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la récupération de la commande');
    }
  }

  @override
  Future<OrderModel> createOrder(String userId, List<CartItemModel> items, double totalAmount) async {
    try {
      if (userId.isEmpty) {
        throw CacheException(message: 'Utilisateur non connecté');
      }
      
      final orderId = _ordersCollection.doc().id;
      final orderDate = DateTime.now();
      
      // Créer le document de commande
      final orderData = {
        'id': orderId,
        'userId': userId,
        'totalAmount': totalAmount,
        'status': OrderStatus.pending.toString().split('.').last,
        'orderDate': Timestamp.fromDate(orderDate),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _ordersCollection.doc(orderId).set(orderData);
      
      // Ajouter les items de la commande
      final itemsCollection = _firebaseService.orderItemsCollection(orderId);
      final batch = _firebaseService.firestore.batch();
      
      for (final item in items) {
        final itemRef = itemsCollection.doc(item.product.id);
        batch.set(itemRef, {
          'productId': item.product.id,
          'productName': item.product.name,
          'price': item.product.discountPrice ?? item.product.price,
          'quantity': item.quantity,
          'imageUrl': item.product.imageUrl,
          'brand': item.product.brand,
          'categoryId': item.product.categoryId,
        });
      }
      
      await batch.commit();
      
      return OrderModel(
        id: orderId,
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        orderDate: orderDate,
        status: OrderStatus.pending,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Erreur lors de la création de la commande');
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la mise à jour du statut');
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, OrderStatus.cancelled);
    } catch (e) {
      throw CacheException(message: 'Erreur lors de l\'annulation de la commande');
    }
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    try {
      // Supprimer d'abord les items
      final itemsCollection = _firebaseService.orderItemsCollection(orderId);
      final itemsSnapshot = await itemsCollection.get();
      
      final batch = _firebaseService.firestore.batch();
      for (final doc in itemsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Supprimer la commande
      batch.delete(_ordersCollection.doc(orderId));
      
      await batch.commit();
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la suppression de la commande');
    }
  }

  @override
  Stream<List<OrderModel>> watchOrders(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      return await Future.wait(
        snapshot.docs.map((doc) => _orderFromSnapshot(doc)).toList(),
      );
    });
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _ordersCollection
          .orderBy('orderDate', descending: true)
          .get();
      
      return await Future.wait(
        snapshot.docs.map((doc) => _orderFromSnapshot(doc)).toList(),
      );
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la récupération des commandes');
    }
  }

  /// Convertit un snapshot Firestore en OrderModel
  Future<OrderModel> _orderFromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data()!;
    final orderId = doc.id;
    
    // Récupérer les items de la commande
    final itemsSnapshot = await _firebaseService.orderItemsCollection(orderId).get();
    
    final items = itemsSnapshot.docs.map((itemDoc) {
      final itemData = itemDoc.data();
      return CartItemModel(
        product: ProductModel(
          id: itemData['productId'] ?? itemDoc.id,
          name: itemData['productName'] ?? '',
          description: '',
          price: (itemData['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: itemData['imageUrl'] ?? '',
          categoryId: itemData['categoryId'] ?? '',
          brand: itemData['brand'] ?? '',
        ),
        quantity: itemData['quantity'] as int? ?? 1,
      );
    }).toList();
    
    // Parser le statut
    final statusString = data['status'] as String? ?? 'pending';
    final status = OrderStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusString,
      orElse: () => OrderStatus.pending,
    );
    
    // Parser la date
    DateTime orderDate;
    final orderDateField = data['orderDate'];
    if (orderDateField is Timestamp) {
      orderDate = orderDateField.toDate();
    } else if (orderDateField is String) {
      orderDate = DateTime.parse(orderDateField);
    } else {
      orderDate = DateTime.now();
    }
    
    return OrderModel(
      id: orderId,
      userId: data['userId'] ?? '',
      items: items,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      orderDate: orderDate,
      status: status,
    );
  }
}
