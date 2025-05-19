import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/product_controller.dart';

@RoutePage()
class PriceSettingPage extends StatelessWidget {
  const PriceSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = context.watch<ProductController>();

    if (productController.isLoading && productController.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: () => productController.fetchProducts(),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: productController.products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = productController.products[index];
            final controller = TextEditingController(
              text: product.price.toStringAsFixed(2),
            );
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                        size: 56, color: Colors.grey),
                  ),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Row(
                  children: [
                    const Text('Price: '),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                        child: TextField(
                          controller: controller,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            prefixText: '\Rp ',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                          ),
                          style: const TextStyle(fontSize: 16),
                          onSubmitted: (value) {
                            final newPrice = double.tryParse(value);
                            if (newPrice != null && newPrice != product.price) {
                              productController.updateProduct(
                                product.copyWith(price: newPrice),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Price for ${product.name} updated!'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.save, color: Colors.deepPurple),
                  tooltip: 'Save Price',
                  onPressed: () {
                    final newPrice = double.tryParse(controller.text);
                    if (newPrice != null && newPrice != product.price) {
                      productController.updateProduct(
                        product.copyWith(price: newPrice),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Price for ${product.name} updated!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
