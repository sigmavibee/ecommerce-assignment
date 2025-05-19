import 'dart:io';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';

class ProductDialog extends StatefulWidget {
  final Product? product;
  const ProductDialog({super.key, this.product});

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _stockController;
  late final TextEditingController _priceController;
  late bool _active;
  File? _imageFile; // Untuk menyimpan file gambar yang dipilih

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _active = widget.product?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final productController = context.read<ProductController>();
    await productController.pickImage();
    if (productController.pickedImage != null) {
      setState(() {
        _imageFile = productController.pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productController = context.watch<ProductController>();
    final errorMessage = productController.errorMessage;

    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
        productController.resetError();
      });
    }

    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 320,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_nameController, 'Product Name',
                    validator: _validateRequired),
                const SizedBox(height: 12),
                _buildTextField(_descriptionController, 'Description',
                    validator: _validateRequired, maxLines: 2),
                const SizedBox(height: 12),
                _buildTextField(_stockController, 'Stock',
                    keyboardType: TextInputType.number,
                    validator: _validateStock),
                const SizedBox(height: 12),
                _buildTextField(_priceController, 'Price',
                    keyboardType: TextInputType.number,
                    validator: _validatePrice),
                const SizedBox(height: 12),
                _buildImageUploadSection(productController),
                const SizedBox(height: 12),
                _buildActiveSwitch(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: productController.isLoading ? null : _submitForm,
          child: productController.isLoading
              ? const CircularProgressIndicator()
              : Text(widget.product == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection(ProductController productController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Product Image', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _imageFile != null
              ? Image.file(_imageFile!, fit: BoxFit.cover)
              : widget.product?.imageUrl != null
                  ? Image.network(widget.product!.imageUrl, fit: BoxFit.cover)
                  : const Center(child: Text('No image selected')),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: productController.isLoading ? null : _pickImage,
          child: const Text('Select Image'),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildActiveSwitch() {
    return Row(
      children: [
        const Text('Active:', style: TextStyle(fontSize: 15)),
        Switch(
          value: _active,
          onChanged: (val) => setState(() => _active = val),
        ),
      ],
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Enter price';
    final price = double.tryParse(value);
    if (price == null || price < 0) return 'Enter valid price';
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.isEmpty) return 'Enter stock';
    final stock = int.tryParse(value);
    if (stock == null || stock < 0) return 'Enter valid stock';
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final productController = context.read<ProductController>();
      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text,
        description: _descriptionController.text,
        stock: int.parse(_stockController.text),
        imageFile: productController.pickedImage,
        price: double.tryParse(_priceController.text) ?? 0.0,
        isActive: _active,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrl: widget.product?.imageUrl ?? '',
      );

      try {
        if (widget.product == null) {
          await productController.addProductWithImage(product);
        } else {
          if (_imageFile != null) {
            final imageUrl = await productController.uploadImage(_imageFile!);
            await productController
                .updateProduct(product.copyWith(imageUrl: imageUrl));
          } else {
            await productController.updateProduct(product);
          }
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
