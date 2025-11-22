import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../providers/orders_provider.dart';
import '../../../domain/entities/order.dart' as entities;

class OrderTrackingPage extends StatelessWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // Vérifier que orderId est valide
    if (orderId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Suivi de commande')),
        body: const Center(
          child: Text('ID de commande invalide'),
        ),
      );
    }

    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, _) {
        // Récupérer la vraie commande depuis le provider
        final order = ordersProvider.getOrderById(orderId);

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Suivi de commande')),
            body: const Center(
              child: Text('Commande introuvable'),
            ),
          );
        }

        // Générer les données pour l'affichage
        final maxLength = orderId.length < 8 ? orderId.length : 8;
        final shortOrderId = orderId.substring(0, maxLength);

        String statusText = 'En attente';
        Color statusColor = AppColors.warning;

        switch (order.status) {
          case entities.OrderStatus.pending:
            statusText = 'En attente';
            statusColor = AppColors.warning;
            break;
          case entities.OrderStatus.processing:
            statusText = 'En cours de traitement';
            statusColor = Colors.blue;
            break;
          case entities.OrderStatus.shipped:
            statusText = 'En cours de livraison';
            statusColor = Colors.blue;
            break;
          case entities.OrderStatus.delivered:
            statusText = 'Livrée';
            statusColor = AppColors.success;
            break;
          case entities.OrderStatus.cancelled:
            statusText = 'Annulée';
            statusColor = Colors.red;
            break;
        }

        final orderData = {
          'orderId': orderId,
          'orderDate':
              '${order.orderDate.day} ${_getMonthName(order.orderDate.month)} ${order.orderDate.year}',
          'status': statusText,
          'statusColor': statusColor,
          'estimatedDelivery':
              '${order.orderDate.add(const Duration(days: 3)).day} ${_getMonthName(order.orderDate.add(const Duration(days: 3)).month)} ${order.orderDate.add(const Duration(days: 3)).year}',
          'totalAmount': order.totalAmount,
          'items': order.items
              .map((item) => {
                    'name': item.product.name,
                    'quantity': item.quantity,
                    'price': item.product.price,
                  })
              .toList(),
          'trackingNumber': 'TRK${shortOrderId.toUpperCase()}',
          'carrier': 'DHL Express',
        };

        return Scaffold(
          appBar: AppBar(
            title: const Text('Suivi de commande'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/orders'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête de la commande
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Commande #$shortOrderId',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                orderData['status'] as String,
                                style: const TextStyle(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Commandé le ${orderData['orderDate']}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Livraison estimée: ${orderData['estimatedDelivery']}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Timeline de suivi
                Text(
                  'Suivi de livraison',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildTrackingTimeline(context),

                const SizedBox(height: 24),

                // Informations de livraison
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_shipping,
                                color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Informations de livraison',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(context, 'Transporteur',
                            orderData['carrier'] as String),
                        const SizedBox(height: 8),
                        _buildInfoRow(context, 'N° de suivi',
                            orderData['trackingNumber'] as String),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Articles commandés
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Articles commandés',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 24),
                        ...(orderData['items'] as List<Map<String, dynamic>>)
                            .map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item['name']} x${item['quantity']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                      Text(
                                        '${item['price']} DH',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '${orderData['totalAmount']} DH',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showCancelOrderDialog(context);
                        },
                        icon: const Icon(Icons.cancel, color: Colors.orange),
                        label: const Text('Annuler'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          foregroundColor: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showDeleteOrderDialog(context);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Supprimer'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.go('/contact-support');
                    },
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Contacter le support'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return months[month - 1];
  }

  Widget _buildTrackingTimeline(BuildContext context) {
    final steps = [
      {
        'title': 'Commande confirmée',
        'subtitle': '15 nov, 10:30',
        'completed': true
      },
      {
        'title': 'En préparation',
        'subtitle': '15 nov, 14:20',
        'completed': true
      },
      {'title': 'Expédiée', 'subtitle': '16 nov, 08:15', 'completed': true},
      {
        'title': 'En cours de livraison',
        'subtitle': '17 nov, 09:00',
        'completed': true
      },
      {'title': 'Livrée', 'subtitle': 'En attente', 'completed': false},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: step['completed'] as bool
                            ? AppColors.success
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                      ),
                      child: Icon(
                        step['completed'] as bool
                            ? Icons.check
                            : Icons.circle_outlined,
                        color: step['completed'] as bool
                            ? Colors.white
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                        size: 16,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: step['completed'] as bool
                            ? AppColors.success
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: step['completed'] as bool
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['subtitle'] as String,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  void _showCancelOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Annuler la commande'),
          content: const Text(
            'Êtes-vous sûr de vouloir annuler cette commande ? Cette action changera le statut de la commande à "Annulée".',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelOrder(context);
              },
              child: const Text(
                'Oui, annuler',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer la commande'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer définitivement cette commande ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteOrder(context);
              },
              child: const Text(
                'Oui, supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _cancelOrder(BuildContext context) async {
    final ordersProvider = context.read<OrdersProvider>();

    // Annuler la commande
    final success = await ordersProvider.cancelOrder(orderId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande annulée avec succès'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );

      // Retourner à la page des commandes après 1 seconde
      Future.delayed(const Duration(seconds: 1), () {
        if (context.mounted) {
          context.go('/orders');
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              ordersProvider.errorMessage ?? 'Erreur lors de l\'annulation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteOrder(BuildContext context) async {
    final ordersProvider = context.read<OrdersProvider>();

    // Supprimer la commande
    final success = await ordersProvider.deleteOrder(orderId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande supprimée avec succès'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      // Retourner à la page des commandes après 1 seconde
      Future.delayed(const Duration(seconds: 1), () {
        if (context.mounted) {
          context.go('/orders');
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              ordersProvider.errorMessage ?? 'Erreur lors de la suppression'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
