import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/env_config.dart';
import 'core/di/injection.dart';
import 'core/services/firebase_service.dart';
import 'core/services/update_service.dart';
import 'routes/app_router.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/widgets/update_dialog.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize environment configuration
  EnvConfig.initialize(Environment.dev);

  // Initialize dependency injection
  await configureDependencies();

  // Initialize Firebase
  await getIt<FirebaseService>().initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check for Updates after the first render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    try {
      final updateService = getIt<UpdateService>();
      final updateInfo = await updateService.checkForUpdate();

      if (updateInfo != null && mounted) {
        // Show Update Dialog
        await showDialog(
          context: context,
          barrierDismissible: !updateInfo.forceUpdate,
          builder:
              (context) => UpdateDialog(
                updateInfo: updateInfo,
                onUpdate: () async {
                  Navigator.of(context).pop();
                  await updateService.openStore();
                },
                onLater: updateInfo.forceUpdate ? null : () => Navigator.of(context).pop(),
              ),
        );
      }
    } catch (e) {
      // Ignore errors during update checks
      // to avoid blocking application startup
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: EnvConfig.instance.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.toThemeMode(),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
    );
  }
}
