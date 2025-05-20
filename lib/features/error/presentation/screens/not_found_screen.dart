import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_button.dart';

class NotFoundScreen extends StatelessWidget {
  final String? path;

  const NotFoundScreen({super.key, this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Page Not Found', showBackButton: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              Text('Page Not Found', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              Text(
                path != null
                    ? 'The page "$path" could not be found.'
                    : 'The requested page could not be found.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Go Home',
                onPressed: () => context.go('/home'),
                icon: Icons.home,
                fullWidth: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
