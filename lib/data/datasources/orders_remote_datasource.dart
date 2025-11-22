import 'package:dio/dio.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getOrders(String userId);
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel> getOrderById(String orderId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  OrdersRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    try {
      final response = await dio.get('$baseUrl/orders');
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      print('🌐 OrdersRemoteDataSource: Envoi POST vers $baseUrl/orders');
      print('🌐 Données envoyées: ${order.toJson()}');
      final response = await dio.post('$baseUrl/orders', data: order.toJson());
      print('✅ Réponse reçue: ${response.statusCode}');
      print('✅ Données réponse: ${response.data}');
      return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      print('❌ Erreur dans createOrder: $e');
      rethrow;
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await dio.get('$baseUrl/orders/$orderId');
      return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
