// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:ecommerce_assignment/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../controllers/product_controller.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String _baseUrl = 'https://backend-ecommerce-udhh.onrender.com';
  late final AuthService _authService;

  // POST: Login
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Add this
        },
        body: jsonEncode({
          'email': email.trim(), // Add trim()
          'password': password,
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Handle case where token might be in different field
        final token = responseBody['token'] ?? responseBody['access_token'];

        if (token == null) {
          throw Exception('Token not found in response');
        }

        return User.fromJson({
          ...responseBody['user'],
          'token': token,
        });
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on FormatException {
      throw Exception('Bad response format');
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  Future<String> _refreshToken() async {
    final refreshToken = await _authService.getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final newToken = json.decode(response.body)['token'];
      await _authService.saveToken(newToken);
      return newToken;
    } else {
      await _authService.logout();
      throw UnauthorizedException('Session expired. Please login again.');
    }
  }

  Future<http.Response> _authRequest(
      Future<http.Response> Function() request) async {
    try {
      final response = await request();
      if (response.statusCode == 401) {
        // Try refreshing token
        final newToken = await _refreshToken();
        // Retry with new token
        final retryResponse = await request();
        return retryResponse;
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST: Register
  Future<User> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // Note: Your backend returns 201 for successful registration
      return User.fromJson(responseBody['user']);
    } else {
      throw Exception(responseBody['message'] ?? 'Registration failed');
    }
  }

  // GET: User Profile (Contoh tambahan)
  Future<User> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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

  // section product
  Future<List<Product>> getProducts() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/products'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((i) => Product.fromJson(i))
          .toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Invalid or expired token');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('Insufficient permissions');
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> createProduct(Product product) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/products'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Invalid or expired token');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('Insufficient permissions');
    } else {
      throw Exception('Failed to create product');
    }
  }

  Future<Product> updateProduct(Product product) async {
    final token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/products/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Invalid or expired token');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('Insufficient permissions');
    } else {
      throw Exception('Failed to create product');
    }
  }

  Future<Product> deleteProduct(int id) async {
    final token = await _authService.getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/products/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Invalid or expired token');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('Insufficient permissions');
    } else {
      throw Exception('Failed to create product');
    }
  }
}
