import 'dart:io';

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/upload_service.dart';
import '../utils/exceptions.dart' as exceptions;
import 'package:image_picker/image_picker.dart';

class ProductController with ChangeNotifier {
  final ApiService _apiService;
  final UploadService _uploadService;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  File? _pickedImage; // Changed from XFile to File

  File? get pickedImage => _pickedImage;

  ProductController(this._apiService, this._uploadService);

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    debugPrint('ProductController Error: $error');

    if (error is exceptions.UnauthorizedException) {
      _errorMessage = 'Session expired. Please login again.';
    } else if (error is exceptions.ForbiddenException) {
      _errorMessage = 'You don\'t have permission for this action.';
    } else if (error is exceptions.ApiException) {
      _errorMessage = error.message;
    } else {
      _errorMessage = error.toString();
    }

    notifyListeners();
  }

  Future<void> fetchProducts() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      _products = await _apiService.getProducts();
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct(Product product) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final newProduct = await _apiService.createProduct(product);
      _products.add(newProduct);
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final updatedProduct = await _apiService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(int id) async {
    // Changed from int to String
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      await _apiService.deleteProduct(id);
      _products.removeWhere((product) => product.id == id);
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _pickedImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _errorMessage = 'Failed to pick image';
      notifyListeners();
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      _isLoading = true;
      notifyListeners();

      final imageUrl = await _uploadService.uploadImage(XFile(imageFile.path));
      return imageUrl;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProductWithImage(Product product) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      if (_pickedImage != null) {
        final imageUrl =
            await _uploadService.uploadImage(XFile(_pickedImage!.path));
        product = product.copyWith(imageUrl: imageUrl);
      }

      final newProduct = await _apiService.createProduct(product);
      _products.add(newProduct);
      _pickedImage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProducts() {
    _products.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
