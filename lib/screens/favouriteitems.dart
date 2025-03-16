import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sole_mate/models/shoes.dart';
import 'package:sole_mate/provider/favouritized.dart';

class FavoritedProductsScreen extends StatefulWidget {
  @override
  _FavoritedProductsScreenState createState() => _FavoritedProductsScreenState();
}

class _FavoritedProductsScreenState extends State<FavoritedProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavouriteProvider>(context, listen: false).fetchFavoritedProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 12, right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Favorited Products',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Consumer<FavouriteProvider>(
                  builder: (context, productProvider, _) {
                    if (!productProvider.hasInternet) {
                      return const Center(
                        child: Text(
                          'No internet connection',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    if (productProvider.favoritedProducts.isEmpty) {
                      return const Center(
                        child: Text(
                          'No favorited products found',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    final reversedProducts = productProvider.favoritedProducts.reversed.toList();

                    return ListView.builder(
                      itemCount: reversedProducts.length,
                      itemBuilder: (context, index) {
                        final product = reversedProducts[index];
                        return Dismissible(
                          key: Key(product.id),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            productProvider.removeFavoritedProduct(product.id);
                           
                          },
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm"),
                                  content: const Text("Are you sure you want to remove this item from favorites?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text("CANCEL"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text("DELETE"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: ProductCard(
                            product: product,
                            onDelete: () {
                              productProvider.removeFavoritedProduct(product.id);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;

  const ProductCard({required this.product, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product.thumbnail,
                        width: 113,
                        height: 101,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brand,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        product.shoeName,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '\$${product.retailPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 20, color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm"),
                      content: const Text("Are you sure you want to remove this item from favorites?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("CANCEL"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onDelete();
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(content: Text('${product.shoeName} removed from favorites')),
                            // );
                          },
                          child: const Text("DELETE"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}