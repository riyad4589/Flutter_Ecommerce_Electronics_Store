import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';

class DatabaseViewerPage extends StatelessWidget {
  const DatabaseViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualiseur de Base de Données'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Vider toutes les tables',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Vider la base de données'),
                  content: const Text(
                      'Êtes-vous sûr de vouloir supprimer toutes les données ? Cette action est irréversible.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await DatabaseHelper.instance.clearDatabase();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toutes les tables ont été vidées'),
                    backgroundColor: Colors.green,
                  ),
                );
                (context as Element).markNeedsBuild();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force rebuild
              (context as Element).markNeedsBuild();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHiveSection(context),
          const SizedBox(height: 24),
          _buildAuthSection(context),
        ],
      ),
    );
  }

  Widget _buildHiveSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Base de données Hive (Panier)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FutureBuilder(
              future: _getHiveData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                }

                final data = snapshot.data as Map<String, dynamic>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Box ouvert', data['isOpen'].toString()),
                    _buildInfoRow('Nombre d\'items', data['length'].toString()),
                    const Divider(height: 32),
                    Text(
                      'Données du panier:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (data['items'].isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Aucun item dans le panier'),
                      )
                    else
                      ...data['items'].map<Widget>((item) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Clé: ${item['key']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Produit ID: ${item['productId']}'),
                                Text('Nom: ${item['productName']}'),
                                Text('Prix: ${item['price']} DH'),
                                Text('Quantité: ${item['quantity']}'),
                                Text(
                                  'Total: ${item['price'] * item['quantity']} DH',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Base de données Hive (Auth)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FutureBuilder(
              future: _getAuthData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                }

                final data = snapshot.data as Map<String, dynamic>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                        'Token stocké', data['hasToken'] ? 'Oui' : 'Non'),
                    if (data['hasToken']) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Token: ${data['token']}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getHiveData() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final results = await db.query('cart_items');

      final items = results.map((row) {
        return {
          'key': '${row['user_id']}_${row['product_id']}',
          'productId': row['product_id'],
          'productName': row['product_name'],
          'price': row['price'],
          'quantity': row['quantity'],
          'imageUrl': row['image_url'],
        };
      }).toList();

      return {
        'isOpen': true,
        'length': items.length,
        'items': items,
      };
    } catch (e) {
      return {
        'isOpen': false,
        'length': 0,
        'items': [],
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> _getAuthData() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final results =
          await db.query('auth_tokens', orderBy: 'id DESC', limit: 1);

      if (results.isEmpty) {
        return {
          'hasToken': false,
          'token': 'Aucun token',
        };
      }

      final token = results.first['token'] as String;
      return {
        'hasToken': true,
        'token': token,
      };
    } catch (e) {
      return {
        'hasToken': false,
        'token': 'Erreur: ${e.toString()}',
      };
    }
  }
}
