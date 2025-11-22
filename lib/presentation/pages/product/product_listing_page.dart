import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../domain/entities/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/skeleton_loader.dart';

class ProductListingPage extends StatefulWidget {
  const ProductListingPage({super.key});

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  String _sortBy = 'default';
  List<String> _selectedCategories = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final cartProvider = context.read<CartProvider>();

      if (authProvider.user != null) {
        cartProvider.setUserId(authProvider.user!.id);
      }

      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshProducts() async {
    await context.read<ProductProvider>().loadProducts();
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trier par'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Par défaut'),
              value: 'default',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Prix croissant'),
              value: 'price_asc',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Prix décroissant'),
              value: 'price_desc',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Nom A-Z'),
              value: 'name_asc',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Meilleures notes'),
              value: 'rating',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer par catégorie'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('📱 Électronique'),
                value: _selectedCategories.contains('electronique'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedCategories.add('electronique');
                    } else {
                      _selectedCategories.remove('electronique');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('👕 Mode'),
                value: _selectedCategories.contains('mode'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedCategories.add('mode');
                    } else {
                      _selectedCategories.remove('mode');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('🏠 Maison'),
                value: _selectedCategories.contains('maison'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedCategories.add('maison');
                    } else {
                      _selectedCategories.remove('maison');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('⚽ Sports'),
                value: _selectedCategories.contains('sports'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedCategories.add('sports');
                    } else {
                      _selectedCategories.remove('sports');
                    }
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selectedCategories.clear());
              Navigator.pop(context);
            },
            child: const Text('Réinitialiser'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nos Produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort_outlined),
            onPressed: _showSortDialog,
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.status == ProductStatus.loading) {
            return const ProductListSkeleton(itemCount: 6);
          }

          if (productProvider.status == ProductStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${productProvider.errorMessage}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productProvider.loadProducts(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          var products = productProvider.products;

          // Filtrage par catégorie
          if (_selectedCategories.isNotEmpty) {
            products = products
                .where((p) => _selectedCategories.contains(p.categoryId))
                .toList();
          }

          // Tri
          var sortedProducts = List<Product>.from(products);
          switch (_sortBy) {
            case 'price_asc':
              sortedProducts.sort((a, b) => a.price.compareTo(b.price));
              break;
            case 'price_desc':
              sortedProducts.sort((a, b) => b.price.compareTo(a.price));
              break;
            case 'name_asc':
              sortedProducts.sort((a, b) => a.name.compareTo(b.name));
              break;
            case 'rating':
              sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
              break;
          }

          if (sortedProducts.isEmpty) {
            return const Center(child: Text('Aucun produit disponible'));
          }

          return RefreshIndicator(
            onRefresh: _refreshProducts,
            child: AnimationLimiter(
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: sortedProducts.length,
                itemBuilder: (context, index) {
                  final product = sortedProducts[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: InkWell(
                onTap: () => context.go('/product/${product.id}'),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: Icon(Icons.image_not_supported,
                                    size: 50,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.3)),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: Theme.of(context).textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(product.discountPrice ?? product.price).toStringAsFixed(2)} DH',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon: const Icon(
                                    Icons.add_shopping_cart_outlined),
                                color: Theme.of(context).colorScheme.secondary,
                                onPressed: () {
                                  context
                                      .read<CartProvider>()
                                      .addToCart(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${product.name} ajouté au panier')),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
