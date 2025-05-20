import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../shared/models/tab_item.dart';
import '../shared/providers/auth_provider.dart';
import '../shared/widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final tabsProvider = Provider<List<TabItem>>((ref) {
  return [
    TabItem(
      initialLocation: '/home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    TabItem(
      initialLocation: '/profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
    TabItem(
      initialLocation: '/notifications',
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      label: 'Notifications',
    ),
    TabItem(
      initialLocation: '/settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];
});

final routerProvider = Provider<GoRouter>((ref) {
  final tabs = ref.watch(tabsProvider);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/home',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Vérifier si l'utilisateur tente d'accéder à une route protégée
      final isGoingToProtectedRoute =
          state.matchedLocation.startsWith('/profile') ||
          state.matchedLocation.startsWith('/settings');

      // Si non authentifié et tentative d'accès à une route protégée
      if (!isAuthenticated && isGoingToProtectedRoute) {
        return '/login?redirect=${state.matchedLocation}';
      }

      // Si authentifié et tentative d'accès à une route d'auth
      if (isAuthenticated &&
          (state.matchedLocation.startsWith('/login') ||
              state.matchedLocation.startsWith('/register'))) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),

      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppScaffold(tabs: tabs, currentPath: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => const NoTransitionPage(child: NotificationsScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
  );
});
