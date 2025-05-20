import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../shared/widgets/app_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = getIt<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_rounded, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text('Welcome Home!', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                user != null ? 'You are signed in as ${user.email}' : 'You are not signed in',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (user == null)
                AppButton(
                  text: 'Sign In',
                  onPressed: () => context.go('/login'),
                  icon: Icons.login,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
