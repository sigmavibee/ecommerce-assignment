import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../utils/exceptions.dart' as exceptions;

class ProductController with ChangeNotifier {
  final ApiService _apiService;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProductController(this._apiService);

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

  void clearProducts() {
    _products.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
