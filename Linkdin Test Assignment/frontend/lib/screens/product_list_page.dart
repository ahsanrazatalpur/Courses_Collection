import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> productsFuture;

  @override
  void initState() {
    super.initState();
    productsFuture = ApiService.fetchProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      productsFuture = ApiService.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: FutureBuilder<List<Product>>(
          future: productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Failed to load products",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _refreshProducts,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              );
            }

            final products = snapshot.data ?? [];

            if (products.isEmpty) {
              return const Center(
                child: Text(
                  "No products available",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 300 + index * 100),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Card(
                    elevation: 6,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: product.image.isNotEmpty
                              ? Image.network(
                                  product.image,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 180,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                product.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Rs. ${product.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    product.stock > 0
                                        ? "In Stock: ${product.stock}"
                                        : "Out of Stock",
                                    style: TextStyle(
                                      color: product.stock > 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (product.stock > 0)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // TODO: Integrate cart functionality
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              "${product.name} added to cart!"),
                                          duration:
                                              const Duration(seconds: 1),
                                        ));
                                      },
                                      icon: const Icon(Icons.add_shopping_cart),
                                      label: const Text("Add"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
