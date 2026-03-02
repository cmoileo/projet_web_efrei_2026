import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';

final _authRoutes = {'/login', '/register', '/forgot-password'};

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);
  return GoRouter(
    refreshListenable: router,
    redirect: router._redirect,
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => null,
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const DashboardScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page introuvable : ${state.uri}')),
    ),
  );
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen(authStateChangesProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? _redirect(BuildContext context, GoRouterState state) {
    final authAsync = _ref.read(authStateChangesProvider);
    debugPrint(
        '[Router] redirect called — location=${state.matchedLocation} authAsync=${authAsync.runtimeType} isLoading=${authAsync.isLoading} user=${authAsync.valueOrNull?.uid ?? "null"}');
    if (authAsync.isLoading) return null;
    final isAuthenticated = authAsync.valueOrNull != null;
    final location = state.matchedLocation;
    final isOnAuthRoute = _authRoutes.contains(location);

    if (location == '/') {
      return isAuthenticated ? '/dashboard' : '/login';
    }
    if (!isAuthenticated && !isOnAuthRoute) {
      debugPrint('[Router] Not authenticated, redirecting to /login');
      return '/login';
    }
    if (isAuthenticated && isOnAuthRoute) {
      debugPrint(
          '[Router] Authenticated on auth route, redirecting to /dashboard');
      return '/dashboard';
    }
    return null;
  }
}
