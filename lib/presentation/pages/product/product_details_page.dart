import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/product.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final authProvider = context.read<AuthProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();

    if (authProvider.user != null) {
      final isFav = await favoritesProvider.isFavorite(widget.productId);
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Map<String, dynamic> get mockProduct => {
        'id': widget.productId,
        'name': 'Smartphone Ultra X (ID: ${widget.productId})',
        'description':
            'Le Smartphone Ultra X est un appareil de pointe doté d\'un écran OLED Super Retina XDR, d\'une puce A16 Bionic ultra-rapide et d\'un système de caméra Pro avancé.',
        'price': 999.99,
        'discountPrice': 899.99,
        'imageUrl':
            'https://via.placeholder.com/600x400/1E88E5/FFFFFF?text=Smartphone',
        'category': 'Smartphones',
        'brand': 'TechBrand',
        'rating': 4.5,
        'reviewCount': 250,
        'images': [
          'https://via.placeholder.com/600x400/1E88E5/FFFFFF?text=Vue1',
          'https://via.placeholder.com/600x400/1E88E5/FFFFFF?text=Vue2',
        ],
      };

  @override
  Widget build(BuildContext context) {
    final product = mockProduct;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(product['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: product['images'].length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: product['images'][index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (product['discountPrice'] != null)
                        Text(
                          '${product['price'].toStringAsFixed(2)} DH',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        '${(product['discountPrice'] ?? product['price']).toStringAsFixed(2)} DH',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: AppColors.accent, size: 20),
                      Text(
                        '${product['rating']} (${product['reviewCount']} avis)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['description'],
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Ajouter au Panier',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${product['name']} ajouté au panier !')),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: _isFavorite
                        ? 'Retirer des Favoris'
                        : 'Ajouter aux Favoris',
                    onPressed: () async {
                      final authProvider = context.read<AuthProvider>();
                      final favoritesProvider =
                          context.read<FavoritesProvider>();

                      if (authProvider.user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Connectez-vous pour gérer vos favoris'),
                          ),
                        );
                        return;
                      }

                      final productEntity = Product(
                        id: product['id'],
                        name: product['name'],
                        description: product['description'],
                        price: (product['price'] as num).toDouble(),
                        discountPrice:
                            (product['discountPrice'] as num?)?.toDouble(),
                        imageUrl: product['imageUrl'],
                        categoryId: product['category'],
                        brand: product['brand'],
                        rating: (product['rating'] as num).toDouble(),
                        reviewCount: product['reviewCount'] as int,
                      );

                      final success =
                          await favoritesProvider.toggleFavorite(productEntity);

                      if (success) {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isFavorite
                                ? '${product['name']} ajouté aux favoris !'
                                : '${product['name']} retiré des favoris !'),
                          ),
                        );
                      }
                    },
                    backgroundColor:
                        _isFavorite ? AppColors.error : AppColors.primaryLight,
                    icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
