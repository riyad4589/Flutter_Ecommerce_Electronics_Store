import 'package:equatable/equatable.dart';
import 'cart_item.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class Order extends Equatable {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = OrderStatus.pending,
  });

  @override
  List<Object?> get props =>
      [id, userId, items, totalAmount, orderDate, status];
}
