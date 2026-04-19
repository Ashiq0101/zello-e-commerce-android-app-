import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello/features/auth/application/auth_provider.dart';
import 'package:zello/features/auth/presentation/welcome_screen.dart';
import 'package:zello/features/auth/presentation/login_screen.dart';
import 'package:zello/features/auth/presentation/signup_screen.dart';
import 'package:zello/features/auth/presentation/otp_verification_screen.dart';
import 'package:zello/features/auth/presentation/forgot_password_screen.dart';
import 'package:zello/features/dashboard/presentation/dashboard_screen.dart';

import 'package:zello/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:zello/features/admin/presentation/category_management_screen.dart';
import 'package:zello/features/admin/presentation/product_management_screen.dart';
import 'package:zello/features/admin/presentation/add_edit_product_screen.dart';
import 'package:zello/features/admin/domain/product.dart';
import 'package:zello/features/admin/presentation/order_management_screen.dart';
import 'package:zello/features/admin/presentation/user_management_screen.dart';
import 'package:zello/features/dashboard/presentation/views/product_detail_screen.dart';
import 'package:zello/features/dashboard/presentation/views/checkout_screen.dart';
import 'package:zello/features/dashboard/presentation/views/user_order_history_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/signup' || 
                          state.matchedLocation == '/otp-verification' ||
                          state.matchedLocation == '/forgot-password' || 
                          state.matchedLocation == '/';
      
      final isAuth = authState != AuthState.unauthenticated;
      final isAdmin = authState == AuthState.admin;
      
      if (!isAuth && !isLoggingIn) return '/';
      if (isAuth && isLoggingIn) {
         return isAdmin ? '/admin/dashboard' : '/dashboard';
      }
      
      // Prevent ordinary user from accessing admin paths
      if (isAuth && !isAdmin && state.matchedLocation.startsWith('/admin')) {
         return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (context, state) => const CategoryManagementScreen(),
      ),
      GoRoute(
        path: '/admin/products',
        builder: (context, state) => const ProductManagementScreen(),
      ),
      GoRoute(
        path: '/admin/products/add',
        builder: (context, state) => const AddEditProductScreen(),
      ),
      GoRoute(
        path: '/admin/products/edit',
        builder: (context, state) {
          final product = state.extra as Product?;
          return AddEditProductScreen(product: product);
        },
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const OrderManagementScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/product-detail',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-history',
        builder: (context, state) => const UserOrderHistoryScreen(),
      ),
    ],
  );
});
