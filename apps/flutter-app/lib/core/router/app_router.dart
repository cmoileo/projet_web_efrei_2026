import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/chat/presentation/pages/conversation_detail_page.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/tasks/presentation/pages/task_detail_page.dart';
import '../../features/tasks/presentation/pages/task_form_page.dart';
import '../../features/tasks/screens/tasks_screen.dart';
import '../../shared/widgets/organisms/main_shell.dart';

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
      ShellRoute(
        builder: (context, state, child) => MainShell(
          currentLocation: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (_, __) => const TasksScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (_, __) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (_, __) => const ChatScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/tasks/new',
        builder: (_, __) => const TaskFormPage(),
      ),
      GoRoute(
        path: '/tasks/:id',
        builder: (_, state) => TaskDetailPage(
          taskId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) => ConversationDetailPage(
          conversationId: state.pathParameters['id']!,
        ),
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
