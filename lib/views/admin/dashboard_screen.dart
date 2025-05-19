import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../widgets/product_dialog.dart';
import 'product_list.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _showAddProductDialog(context),
                  child: const Text('Add Product'),
                ),
              ],
            ),
          ),
          const Expanded(child: ProductList()),
        ],
      ),
    );
  }

  Future<void> _showAddProductDialog(BuildContext context) async {
    final productController = context.read<ProductController>();
    final result = await showDialog<Product>(
      context: context,
      builder: (context) => const ProductDialog(),
    );

    if (result != null) {
      await productController.createProduct(result);
    }
  }
}
