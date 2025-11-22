import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../domain/entities/order.dart' as entities;
import '../../providers/orders_provider.dart';
import '../../themes/app_colors.dart';
import '../../widgets/common/skeleton_loader.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Future<void> _refreshOrders() async {
    await context.read<OrdersProvider>().loadOrders();
  }

  Color _getStatusColor(entities.OrderStatus status) {
    switch (status) {
      case entities.OrderStatus.pending:
        return AppColors.warning;
      case entities.OrderStatus.processing:
        return Colors.blue;
      case entities.OrderStatus.shipped:
        return Colors.orange;
      case entities.OrderStatus.delivered:
        return AppColors.success;
      case entities.OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusText(entities.OrderStatus status) {
    switch (status) {
      case entities.OrderStatus.pending:
        return 'En attente';
      case entities.OrderStatus.processing:
        return 'En traitement';
      case entities.OrderStatus.shipped:
        return 'Expédiée';
      case entities.OrderStatus.delivered:
        return 'Livrée';
      case entities.OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: ordersProvider.isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) => const ListItemSkeleton(),
            )
          : ordersProvider.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 100, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        ordersProvider.errorMessage!,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ordersProvider.loadOrders(),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : ordersProvider.orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 100,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'Vous n\'avez pas encore passé de commande.',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.go('/categories'),
                            child: const Text('Découvrir nos produits'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshOrders,
                      child: AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: ordersProvider.orders.length,
                          itemBuilder: (context, index) {
                            final order = ordersProvider.orders[index];
                            final statusColor = _getStatusColor(order.status);
                            final statusText = _getStatusText(order.status);

                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: InkWell(
                                      onTap: () {
                                        context
                                            .go('/order-tracking/${order.id}');
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Commande #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: statusColor
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(
                                                    statusText,
                                                    style: TextStyle(
                                                      color: statusColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                const Icon(Icons.calendar_today,
                                                    size: 16,
                                                    color: AppColors
                                                        .textSecondary),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                          color: AppColors
                                                              .textSecondary),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.shopping_bag,
                                                    size: 16,
                                                    color: AppColors
                                                        .textSecondary),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${order.items.length} article(s)',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                          color: AppColors
                                                              .textSecondary),
                                                ),
                                              ],
                                            ),
                                            const Divider(height: 24),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Total',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                                Text(
                                                  '${order.totalAmount.toStringAsFixed(2)} DH',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () {
                                                    context.go(
                                                        '/order-tracking/${order.id}');
                                                  },
                                                  icon: const Icon(
                                                      Icons.track_changes,
                                                      size: 18),
                                                  label: const Text(
                                                      'Suivre ma commande'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
    );
  }
}
