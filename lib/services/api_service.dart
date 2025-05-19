// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:ecommerce_assignment/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../models/user_model.dart';

class ApiService {
  final AuthService authService;
  static const String _baseUrl = 'https://backend-ecommerce-udhh.onrender.com';

  ApiService({required this.authService});

  // Helper method for making authenticated requests
  Future<dynamic> _makeAuthenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await authService.getToken();
      debugPrint('Current Token: $token');
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final uri = Uri.parse('$_baseUrl/$endpoint');
      final headers = {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      };

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      debugPrint('API Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 403) {
        throw ForbiddenException();
      } else if (response.statusCode >= 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Request failed');
      }

      // Return either Map or List based on response
      final decoded = jsonDecode(response.body);
      return decoded;
    } on SocketException {
      throw Exception('No Internet connection');
    } on FormatException {
      throw Exception('Bad response format');
    } catch (e) {
      debugPrint('API Error: $e');
      rethrow;
    }
  }

  //refresh token
  Future<String> refreshToken() async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final newToken = responseBody['token'];
        if (newToken == null)
          throw Exception('New token not found in response');

        await authService.saveTokens(newToken, await refreshToken());
        return newToken;
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      debugPrint('Error in refreshToken: $e');
      rethrow;
    }
  }

  Future<User> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return User.fromJson(responseBody);
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to fetch user profile');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on FormatException {
      throw Exception('Bad response format');
    } catch (e) {
      throw Exception('Get user profile error: ${e.toString()}');
    }
  }

  // Product Endpoints
  Future<List<Product>> getProducts() async {
    try {
      final response = await _makeAuthenticatedRequest('GET', 'products');

      // Handle both List and Map responses
      if (response is List) {
        return response.map((product) => Product.fromJson(product)).toList();
      } else if (response is Map && response.containsKey('data')) {
        return (response['data'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      debugPrint('Error in getProducts: $e');
      rethrow;
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      // Validate required fields
      if (product.name.isEmpty ||
          product.price <= 0 ||
          product.stock < 0 ||
          product.description.isEmpty ||
          product.imageUrl.isEmpty) {
        throw Exception('All fields are required');
      }

      final token = await authService.getToken();
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }
      final response = await http.post(
        Uri.parse('$_baseUrl/products'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(product.toJson()),
      );
      debugPrint(
          'Create Product Response (${response.statusCode}): ${response.body}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody is Map &&
            responseBody.containsKey('data') &&
            responseBody['data'] != null) {
          return Product.fromJson(responseBody['data']);
        } else {
          // Fallback: try to parse the response body directly as the product
          return Product.fromJson(responseBody);
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create product');
      }
    } catch (e) {
      debugPrint('Error in createProduct: $e');
      rethrow;
    }
  }

  Future<Product> updateProduct(Product product) async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }
      final response = await http.put(
        Uri.parse('$_baseUrl/products/${product.id}'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(product.toJson()),
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody is Map &&
            responseBody.containsKey('data') &&
            responseBody['data'] != null) {
          return Product.fromJson(responseBody['data']);
        } else {
          // Fallback: try to parse the response body directly as the product
          return Product.fromJson(responseBody);
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update product');
      }
    } catch (e) {
      debugPrint('Error in updateProduct: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }
      final response = await http.delete(
        Uri.parse('$_baseUrl/products/$id'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete product');
      }
    } catch (e) {
      debugPrint('Error in deleteProduct: $e');
      rethrow;
    }
  }

  //upload image
  Future<String> uploadImage(File imageFile) async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload'),
      );
      request.headers['Authorization'] = '$token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody.body);
        return responseData['imageUrl'];
      } else {
        final error = jsonDecode(responseBody.body);
        throw Exception(error['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      debugPrint('Error in uploadImage: $e');
      rethrow;
    }
  }

  // User Endpoints
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'];
        final refreshToken =
            responseBody['refreshToken']; // Optional, if your API provides it
        if (token == null) throw Exception('Token not found in response');

        await authService.saveTokens(token, refreshToken);

        // Create user object with the token and user data
        final userData = responseBody['user'];
        return User.fromJson({
          ...userData,
          'token': token, // Include the token in the user object
          'refreshToken': refreshToken // Optional
        });
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('Error in login: $e');
      rethrow;
    }
  }

  Future<User> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return User.fromJson(responseBody['user']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      debugPrint('Error in register: $e');
      rethrow;
    }
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = "Unauthorized access"]);
  @override
  String toString() => 'UnauthorizedException: $message';
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException([this.message = "Forbidden access"]);
  @override
  String toString() => 'ForbiddenException: $message';
}
