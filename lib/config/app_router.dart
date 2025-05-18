// lib/config/app_router.dart
import 'package:auto_route/auto_route.dart';
import 'package:ecommerce_assignment/views/auth/login_screen.dart';
import 'package:ecommerce_assignment/views/auth/register_screen.dart';
import 'package:ecommerce_assignment/views/user/home_screen.dart';
import 'package:ecommerce_assignment/views/admin/admin_screen.dart';
import 'package:ecommerce_assignment/views/admin/price_settings_screen.dart';
import 'package:ecommerce_assignment/views/admin/orders_process_screen.dart';
import 'package:ecommerce_assignment/views/admin/admin_profile_screen.dart';
// Import semua halaman lainnya...

part 'app_router.gr.dart'; // File akan digenerate

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, initial: true),
        AutoRoute(page: RegisterRoute.page, path: '/register'),
        AutoRoute(page: HomeRoute.page, path: '/home'),
        AutoRoute(page: AdminRoute.page, path: '/admin'),
        AutoRoute(page: PriceSettingRoute.page, path: '/price-setting'),
        AutoRoute(page: OrderProcessRoute.page, path: '/order-process'),
        AutoRoute(page: ProfileRoute.page, path: '/profile'),

        // Tambahkan semua route lainnya di sini user route terutama
      ];
}
