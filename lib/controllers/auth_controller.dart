import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_services.dart';
import '../utils/shared_prefs.dart';

class AuthController with ChangeNotifier {
  final ApiService _apiService = ApiService(
    authService: AuthService(),
  );
  User? _currentUser;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get obsecurePasswordConfirmation => _obscurePasswordConfirmation;

  void toggleObscure() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmation() {
    _obscurePasswordConfirmation = !_obscurePasswordConfirmation;
    notifyListeners();
  }

  // Login
  Future<void> login(String email, String password, BuildContext context,
      GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      try {
        _isLoading = true;
        notifyListeners();

        debugPrint('Attempting login with email: $email');
        debugPrint('token: ${await SharedPrefs.getToken()}');

        final user = await _apiService.login(email, password);

        if (user.token == null) {
          throw Exception('No token received from server');
        }

        _currentUser = user;
        await SharedPrefs.saveToken(user.token!);
        debugPrint('Token saved: ${await SharedPrefs.getToken()}');
        debugPrint('Login successful for user: ${user.email}');

        // Navigate based on role
        if (user.role == 'admin') {
          context.router.replaceNamed('/admin');
        } else {
          context.router.replaceNamed('/home');
        }
      } catch (e) {
        debugPrint('Login error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Login failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Register
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register(
      String name, String email, String password, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.register(name, email, password);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login')),
      );

      // Navigate back to login after successful registration
      context.router.maybePop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // get user data
  Future<void> getUserData(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await SharedPrefs.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      _currentUser = await _apiService.getUserProfile(token);
      notifyListeners();

      debugPrint('Current user: ${_currentUser?.name}');
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user data: ${e.toString()}')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout(BuildContext context) async {
    await SharedPrefs.removeToken();
    _currentUser = null;
    context.router.pushNamed('/');
  }
}
