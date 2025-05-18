import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

// Define UnauthorizedException if not already defined elsewhere
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized']);
  @override
  String toString() => 'UnauthorizedException: $message';
}

// Define ForbiddenException if not already defined elsewhere
class ForbiddenException implements Exception {
  final String message;
  ForbiddenException([this.message = 'Forbidden']);
  @override
  String toString() => 'ForbiddenException: $message';
}

class ProductController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    try {
      _resetError();
      _isLoading = true;
      notifyListeners();

      _products = await _apiService.getProducts();
    } catch (e) {
      _handleError(e, 'Error fetching products');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProduct(Product product) async {
    try {
      _resetError();
      _isLoading = true;
      notifyListeners();

      final newProduct = await _apiService.createProduct(product);
      _products.add(newProduct);
    } catch (e) {
      _handleError(e, 'Error creating product');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      _resetError();
      _isLoading = true;
      notifyListeners();

      final updatedProduct = await _apiService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
    } catch (e) {
      _handleError(e, 'Error updating product');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      _resetError();
      _isLoading = true;
      notifyListeners();

      await _apiService.deleteProduct(id);
      _products.removeWhere((product) => product.id == id);
    } catch (e) {
      _handleError(e, 'Error deleting product');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _handleError(dynamic error, String defaultMessage) {
    if (error is UnauthorizedException) {
      _errorMessage = 'Session expired. Please login again.';
    } else if (error is ForbiddenException) {
      _errorMessage = 'You don\'t have permission to perform this action.';
    } else {
      _errorMessage = defaultMessage;
    }
    debugPrint('Error: $_errorMessage');
  }

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}
