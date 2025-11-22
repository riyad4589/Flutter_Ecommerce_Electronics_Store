import 'package:flutter/material.dart';
import '../../domain/entities/order.dart' as entities;
import '../../domain/usecases/orders/create_order.dart';
import '../../domain/usecases/orders/get_orders.dart';
import '../../domain/usecases/orders/cancel_order.dart';
import '../../domain/usecases/orders/delete_order.dart';

class OrdersProvider with ChangeNotifier {
  final GetOrders getOrdersUseCase;
  final CreateOrder createOrderUseCase;
  final CancelOrder cancelOrderUseCase;
  final DeleteOrder deleteOrderUseCase;
  final String userId;

  OrdersProvider({
    required this.getOrdersUseCase,
    required this.createOrderUseCase,
    required this.cancelOrderUseCase,
    required this.deleteOrderUseCase,
    required this.userId,
  }) {
    if (userId.isNotEmpty) {
      loadOrders();
    }
  }

  List<entities.Order> _orders = [];
  bool _isLoading = false;
  bool _isCreatingOrder = false;
  String? _errorMessage;

  List<entities.Order> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isCreatingOrder => _isCreatingOrder;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders() async {
    if (userId.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getOrdersUseCase(userId);
    result.fold(
      (failure) {
        _errorMessage = 'Erreur lors du chargement des commandes';
        _isLoading = false;
        notifyListeners();
      },
      (orders) {
        _orders = orders;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> placeOrder(entities.Order order) async {
    _isCreatingOrder = true;
    _errorMessage = null;
    notifyListeners();

    final result = await createOrderUseCase(order);
    return result.fold(
      (failure) {
        _errorMessage = 'Erreur lors de la création de la commande';
        _isCreatingOrder = false;
        notifyListeners();
        return false;
      },
      (createdOrder) {
        _orders.insert(0, createdOrder);
        _isCreatingOrder = false;
        notifyListeners();
        return true;
      },
    );
  }

  entities.Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    _errorMessage = null;
    notifyListeners();

    // Trouver l'index de la commande
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      _errorMessage = 'Commande introuvable';
      notifyListeners();
      return false;
    }

    // Appeler le use case pour annuler la commande
    final result = await cancelOrderUseCase(orderId);
    return result.fold(
      (failure) {
        _errorMessage = 'Erreur lors de l\'annulation de la commande';
        notifyListeners();
        return false;
      },
      (_) {
        // Créer une copie de la commande avec le statut annulé
        final order = _orders[index];
        final cancelledOrder = entities.Order(
          id: order.id,
          userId: order.userId,
          items: order.items,
          totalAmount: order.totalAmount,
          orderDate: order.orderDate,
          status: entities.OrderStatus.cancelled,
        );

        // Mettre à jour localement
        _orders[index] = cancelledOrder;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> deleteOrder(String orderId) async {
    _errorMessage = null;
    notifyListeners();

    // Appeler le use case pour supprimer la commande
    final result = await deleteOrderUseCase(orderId);
    return result.fold(
      (failure) {
        _errorMessage = 'Erreur lors de la suppression de la commande';
        notifyListeners();
        return false;
      },
      (_) {
        // Supprimer de la liste locale
        _orders.removeWhere((order) => order.id == orderId);
        notifyListeners();
        return true;
      },
    );
  }
}
