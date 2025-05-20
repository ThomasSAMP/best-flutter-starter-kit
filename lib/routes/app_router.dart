import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection.dart';
import '../core/services/analytics_service.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/error/presentation/screens/not_found_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/analytics_test_screen.dart';
import '../features/settings/presentation/screens/error_test_screen.dart';
import '../features/settings/presentation/screens/haptic_test_screen.dart';
import '../features/settings/presentation/screens/image_cache_test_screen.dart';
import '../features/settings/presentation/screens/notification_test_screen.dart';
import '../features/settings/presentation/screens/offline_test_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/update_test_screen.dart';
import '../shared/models/tab_item.dart';
import '../shared/providers/auth_provider.dart';
import '../shared/widgets/app_scaffold.dart';
import 'navigation_observer.dart';
import 'page_transitions.dart';

export 'package:flutter/material.dart' show GlobalKey, NavigatorState;

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellNavigator');

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
  final observer = getIt<AppNavigationObserver>();
  final analyticsObserver = getIt<AnalyticsService>().observer;

  final router = GoRouter(
    initialLocation: '/home',
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    observers: [observer, analyticsObserver],
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
    errorBuilder: (context, state) => NotFoundScreen(path: state.uri.toString()),
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder:
            (context, state) => FadeTransitionPage(child: const LoginScreen(), name: 'LoginScreen'),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder:
            (context, state) =>
                SlideTransitionPage(child: const RegisterScreen(), name: 'RegisterScreen'),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder:
            (context, state) => SlideTransitionPage(
              child: const ForgotPasswordScreen(),
              name: 'ForgotPasswordScreen',
            ),
      ),
      GoRoute(
        path: '/notification-test',
        name: 'notification-test',
        pageBuilder:
            (context, state) => const NoTransitionPage(
              child: NotificationTestScreen(),
              name: 'NotificationTestScreen',
            ),
      ),
      GoRoute(
        path: '/analytics-test',
        name: 'analytics-test',
        pageBuilder:
            (context, state) =>
                const NoTransitionPage(child: AnalyticsTestScreen(), name: 'AnalyticsTestScreen'),
      ),
      GoRoute(
        path: '/error-test',
        name: 'error-test',
        pageBuilder:
            (context, state) =>
                const NoTransitionPage(child: ErrorTestScreen(), name: 'ErrorTestScreen'),
      ),
      GoRoute(
        path: '/update-test',
        name: 'update-test',
        pageBuilder:
            (context, state) =>
                const NoTransitionPage(child: UpdateTestScreen(), name: 'UpdateTestScreen'),
      ),
      GoRoute(
        path: '/offline-test',
        name: 'offline-test',
        pageBuilder:
            (context, state) =>
                const NoTransitionPage(child: OfflineTestScreen(), name: 'OfflineTestScreen'),
      ),
      GoRoute(
        path: '/image-cache-test',
        name: 'image-cache-test',
        pageBuilder:
            (context, state) =>
                const NoTransitionPage(child: ImageCacheTestScreen(), name: 'ImageCacheTestScreen'),
      ),
      GoRoute(
        path: '/haptic-test',
        name: 'haptic-test',
        pageBuilder:
            (context, state) =>
                const NoTransitionPage(child: HapticTestScreen(), name: 'HapticTestScreen'),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppScaffold(tabs: tabs, currentPath: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder:
                (context, state) => const NoTransitionPage(child: HomeScreen(), name: 'HomeScreen'),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: ProfileScreen(), name: 'ProfileScreen'),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: NotificationsScreen(),
                  name: 'NotificationsScreen',
                ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: SettingsScreen(), name: 'SettingsScreen'),
          ),
        ],
      ),
    ],
  );

  // Enregistrer le router dans GetIt
  if (!getIt.isRegistered<GoRouter>()) {
    getIt.registerSingleton<GoRouter>(router);
  }

  return router;
});
