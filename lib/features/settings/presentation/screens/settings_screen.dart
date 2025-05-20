import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/app_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  PackageInfo? _packageInfo;
  bool _isLoading = true;
  final _navigationService = getIt<NavigationService>();

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = packageInfo;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: const AppBarWidget(title: 'Settings', showBackButton: false),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                children: [
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Appearance',
                    children: [
                      ListTile(
                        title: const Text('Theme'),
                        subtitle: Text(themeMode.name),
                        leading: Icon(themeMode.icon),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showThemeDialog(context),
                      ),
                    ],
                  ),
                  _buildSection(
                    title: 'Notifications',
                    children: [
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        subtitle: const Text('Receive push notifications'),
                        value: true,
                        onChanged: (value) {
                          // Toggle push notifications
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Email Notifications'),
                        subtitle: const Text('Receive email notifications'),
                        value: false,
                        onChanged: (value) {
                          // Toggle email notifications
                        },
                      ),
                    ],
                  ),
                  _buildSection(
                    title: 'Developer Tools',
                    children: [
                      ListTile(
                        title: const Text('Test Notifications'),
                        subtitle: const Text('Send and receive test notifications'),
                        leading: const Icon(Icons.notifications_active),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _navigationService.navigateTo(context, '/notification-test'),
                      ),
                      ListTile(
                        title: const Text('Test Analytics'),
                        subtitle: const Text('Log and view analytics events'),
                        leading: const Icon(Icons.analytics_outlined),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _navigationService.navigateTo(context, '/analytics-test'),
                      ),
                      ListTile(
                        title: const Text('Test Error Handling'),
                        subtitle: const Text('Trigger and record errors'),
                        leading: const Icon(Icons.error_outline),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _navigationService.navigateTo(context, '/error-test'),
                      ),
                      ListTile(
                        title: const Text('Test App Updates'),
                        subtitle: const Text('Check for app updates'),
                        leading: const Icon(Icons.system_update_outlined),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _navigationService.navigateTo(context, '/update-test'),
                      ),
                      ListTile(
                        title: const Text('Test Offline Mode'),
                        subtitle: const Text('Create and sync data offline'),
                        leading: const Icon(Icons.wifi_off_outlined),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _navigationService.navigateTo(context, '/offline-test'),
                      ),
                      ListTile(
                        title: const Text('Test Cache d\'Images'),
                        subtitle: const Text('Gérer le cache d\'images'),
                        leading: const Icon(Icons.image_outlined),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _navigationService.navigateTo(context, '/image-cache-test'),
                      ),
                      ListTile(
                        title: const Text('Test Haptique'),
                        subtitle: const Text('Tester les retours haptiques'),
                        leading: const Icon(Icons.vibration),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _navigationService.navigateTo(context, '/haptic-test'),
                      ),
                    ],
                  ),
                  _buildSection(
                    title: 'Privacy',
                    children: [
                      ListTile(
                        title: const Text('Privacy Policy'),
                        leading: const Icon(Icons.privacy_tip_outlined),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () {
                          // Open privacy policy
                        },
                      ),
                      ListTile(
                        title: const Text('Terms of Service'),
                        leading: const Icon(Icons.description_outlined),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () {
                          // Open terms of service
                        },
                      ),
                      ListTile(
                        title: const Text('Delete Account'),
                        leading: const Icon(Icons.delete_outline, color: Colors.red),
                        onTap: () {
                          _navigationService
                              .showConfirmationDialog(
                                context,
                                title: 'Delete Account',
                                message:
                                    'Are you sure you want to delete your account? This action cannot be undone.',
                                confirmText: 'Delete',
                                cancelText: 'Cancel',
                              )
                              .then((confirmed) {
                                if (confirmed == true) {
                                  // Delete account
                                  _navigationService.showSnackBar(
                                    context,
                                    message:
                                        'Account deletion functionality will be implemented soon.',
                                  );
                                }
                              });
                        },
                      ),
                    ],
                  ),
                  _buildSection(
                    title: 'About',
                    children: [
                      ListTile(
                        title: const Text('Version'),
                        subtitle: Text('${_packageInfo?.version} (${_packageInfo?.buildNumber})'),
                        leading: const Icon(Icons.info_outline),
                      ),
                      ListTile(
                        title: const Text('Licenses'),
                        leading: const Icon(Icons.article_outlined),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          showLicensePage(
                            context: context,
                            applicationName: _packageInfo?.appName,
                            applicationVersion: _packageInfo?.version,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                AppThemeMode.values.map((mode) {
                  return RadioListTile<AppThemeMode>(
                    title: Text(mode.name),
                    value: mode,
                    groupValue: ref.read(themeProvider),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(themeProvider.notifier).setThemeMode(value);
                        Navigator.pop(context);
                      }
                    },
                    secondary: Icon(mode.icon),
                  );
                }).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        );
      },
    );
  }
}
