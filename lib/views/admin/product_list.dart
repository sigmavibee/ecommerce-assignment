import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../widgets/product_dialog.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = context.watch<ProductController>();

    if (productController.isLoading && productController.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => productController.fetchProducts(),
      child: ListView.separated(
        itemCount: productController.products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildProductCard(
          context,
          productController.products[index],
          productController,
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
    ProductController controller,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: _buildProductImage(product.imageUrl),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: _buildProductSubtitle(product),
        trailing: _buildActionButtons(context, product, controller),
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    return imageUrl != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 56, color: Colors.grey),
            ),
          )
        : const Icon(Icons.image, size: 56, color: Colors.grey);
  }

  Widget _buildProductSubtitle(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock: ${product.stock}',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Text('Active:', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Icon(
              product.isActive ? Icons.check_circle : Icons.cancel,
              color: product.isActive ? Colors.green : Colors.red,
              size: 18,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Product product,
    ProductController controller,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blueAccent),
          onPressed: () => _showEditDialog(context, product, controller),
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _showDeleteDialog(context, product.id, controller),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    Product product,
    ProductController controller,
  ) async {
    final result = await showDialog<Product>(
      context: context,
      builder: (context) => ProductDialog(product: product),
    );

    if (result != null) {
      await controller.updateProduct(result);
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    int productId,
    ProductController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteProduct(productId);
    }
  }
}
