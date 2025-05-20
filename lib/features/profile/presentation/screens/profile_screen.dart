import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _authService = getIt<AuthService>();
  final _navigationService = getIt<NavigationService>();
  bool _isLoading = false;

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signOut();
      if (mounted) {
        _navigationService.navigateTo(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        _navigationService.showSnackBar(context, message: 'Error signing out: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: const AppBarWidget(title: 'Profile'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You need to be signed in to view your profile'),
              const SizedBox(height: 16),
              AppButton(
                text: 'Sign In',
                onPressed: () => _navigationService.navigateTo(context, '/login'),
                icon: Icons.login,
                fullWidth: false,
              ),
            ],
          ),
        ),
      );
    }

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Signing out...',
      child: Scaffold(
        appBar: AppBarWidget(
          title: 'Profile',
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _isLoading ? null : _signOut,
              tooltip: 'Sign Out',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.email?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(user.email ?? 'No email', style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('User ID: ${user.uid}', style: Theme.of(context).textTheme.bodySmall),
            ),
            const SizedBox(height: 32),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _navigationService.showSnackBar(
                  context,
                  message: 'Edit profile functionality will be implemented soon.',
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _navigationService.showSnackBar(
                  context,
                  message: 'Change password functionality will be implemented soon.',
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: _isLoading ? null : _signOut,
            ),
          ],
        ),
      ),
    );
  }
}
