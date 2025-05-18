import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_router.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'services/api_service.dart';
import 'services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final apiService = ApiService(authService: authService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ProductController(apiService)),
        Provider<AuthService>(create: (_) => authService),
        Provider<ApiService>(create: (_) => apiService),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ecommerce App',
      routerConfig: appRouter.config(),
    );
  }
}
