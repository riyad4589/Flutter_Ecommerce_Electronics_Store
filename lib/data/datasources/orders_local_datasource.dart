import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';

abstract class OrdersLocalDataSource {
  Future<List<OrderModel>> getOrders(String userId);
  Future<void> saveOrder(OrderModel order);
  Future<OrderModel?> getOrderById(String orderId);
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> deleteOrder(String orderId);
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  final DatabaseHelper databaseHelper;

  OrdersLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    final db = await databaseHelper.database;

    // Récupérer les commandes
    final ordersData = await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    // Pour chaque commande, récupérer ses items
    final orders = <OrderModel>[];
    for (final orderData in ordersData) {
      final orderId = orderData['order_id'] as String;
      final itemsData = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      final items = itemsData.map((item) {
        final product = ProductModel(
          id: item['product_id'] as String,
          name: item['product_name'] as String,
          description: '',
          price: item['price'] as double,
          discountPrice: null,
          imageUrl: item['image_url'] as String? ?? '',
          categoryId: '',
          brand: '',
          rating: 0.0,
          reviewCount: 0,
        );
        return CartItem(product: product, quantity: item['quantity'] as int);
      }).toList();

      orders.add(
        OrderModel(
          id: orderId,
          userId: orderData['user_id'] as String,
          items: items,
          totalAmount: orderData['total_amount'] as double,
          orderDate: DateTime.parse(orderData['created_at'] as String),
          status: _parseOrderStatus(orderData['status'] as String),
        ),
      );
    }

    return orders;
  }

  @override
  Future<void> saveOrder(OrderModel order) async {
    final db = await databaseHelper.database;

    await db.transaction((txn) async {
      // Sauvegarder la commande
      await txn.insert(
          'orders',
          {
            'order_id': order.id,
            'user_id': order.userId,
            'total_amount': order.totalAmount,
            'status': order.status.toString().split('.').last,
            'shipping_address': '', // À compléter
            'payment_method': '', // À compléter
            'created_at': order.orderDate.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace);

      // Sauvegarder les items de la commande
      for (final item in order.items) {
        await txn.insert(
            'order_items',
            {
              'order_id': order.id,
              'product_id': item.product.id,
              'product_name': item.product.name,
              'price': item.product.price,
              'quantity': item.quantity,
              'image_url': item.product.imageUrl,
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    final db = await databaseHelper.database;

    final orderData = await db.query(
      'orders',
      where: 'order_id = ?',
      whereArgs: [orderId],
      limit: 1,
    );

    if (orderData.isEmpty) return null;

    final itemsData = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    final items = itemsData.map((item) {
      final product = ProductModel(
        id: item['product_id'] as String,
        name: item['product_name'] as String,
        description: '',
        price: item['price'] as double,
        discountPrice: null,
        imageUrl: item['image_url'] as String? ?? '',
        categoryId: '',
        brand: '',
        rating: 0.0,
        reviewCount: 0,
      );
      return CartItem(product: product, quantity: item['quantity'] as int);
    }).toList();

    final data = orderData.first;
    return OrderModel(
      id: data['order_id'] as String,
      userId: data['user_id'] as String,
      items: items,
      totalAmount: data['total_amount'] as double,
      orderDate: DateTime.parse(data['created_at'] as String),
      status: _parseOrderStatus(data['status'] as String),
    );
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    final db = await databaseHelper.database;
    await db.update(
      'orders',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    final db = await databaseHelper.database;
    await db.transaction((txn) async {
      // Supprimer les items de la commande
      await txn.delete(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
      // Supprimer la commande
      await txn.delete(
        'orders',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
    });
  }

  OrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
