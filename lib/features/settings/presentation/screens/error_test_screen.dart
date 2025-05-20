import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/error_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_button.dart';

class ErrorTestScreen extends ConsumerStatefulWidget {
  const ErrorTestScreen({super.key});

  @override
  ConsumerState<ErrorTestScreen> createState() => _ErrorTestScreenState();
}

class _ErrorTestScreenState extends ConsumerState<ErrorTestScreen> {
  final _errorService = getIt<ErrorService>();
  final _navigationService = getIt<NavigationService>();

  String? _statusMessage;
  bool _isLoading = false;

  Future<void> _triggerSyncError() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // Déclencher une erreur synchrone
      throw Exception('This is a test synchronous exception');
    } catch (e, stackTrace) {
      // Enregistrer l'erreur
      await _errorService.recordError(
        e,
        stackTrace,
        reason: 'Test synchronous error',
        fatal: false,
      );

      setState(() {
        _statusMessage = 'Synchronous error triggered and recorded';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _triggerAsyncError() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // Déclencher une erreur asynchrone
      await Future<void>.delayed(const Duration(milliseconds: 100));
      throw Exception('This is a test asynchronous exception');
    } catch (e, stackTrace) {
      // Enregistrer l'erreur
      await _errorService.recordError(
        e,
        stackTrace,
        reason: 'Test asynchronous error',
        fatal: false,
      );

      setState(() {
        _statusMessage = 'Asynchronous error triggered and recorded';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _triggerUncaughtError() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // Simuler une erreur non capturée
      Future<void>.microtask(() {
        throw Exception('This is a test uncaught exception');
      });

      await Future<void>.delayed(const Duration(milliseconds: 500));

      setState(() {
        _statusMessage = 'Uncaught error triggered (check logs)';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _triggerFatalError() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // Simuler une erreur fatale
      await _errorService.recordError(
        Exception('This is a test fatal exception'),
        StackTrace.current,
        reason: 'Test fatal error',
        fatal: true,
      );

      setState(() {
        _statusMessage = 'Fatal error recorded';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addCustomKeys() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // Ajouter des clés personnalisées
      await _errorService.setUserIdentifier('test_user_123');
      await _errorService.setCustomKey('test_key_1', 'test_value_1');
      await _errorService.setCustomKey('test_key_2', 123);
      await _errorService.setCustomKey('test_key_3', true);
      await _errorService.log('Test log message from error test screen');

      setState(() {
        _statusMessage = 'Custom keys and user identifier added';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addBreadcrumbs() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // Ajouter quelques breadcrumbs
      await _errorService.addBreadcrumb('User viewed product', data: {'product_id': '12345'});
      await _errorService.addBreadcrumb(
        'User added to cart',
        data: {'product_id': '12345', 'quantity': 2},
      );
      await _errorService.addBreadcrumb('User started checkout');

      setState(() {
        _statusMessage = 'Breadcrumbs added successfully';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setDeviceInfo() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // Définir les informations sur l'appareil
      await _errorService.setDeviceInfo();

      setState(() {
        _statusMessage = 'Device info set successfully';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _forceCrash() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Force Crash'),
            content: const Text(
              'This will crash the app. Are you sure you want to continue?\n\n'
              'Note: This only works in release mode, not in debug mode.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _errorService.forceCrash();
                },
                child: const Text('Crash'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Error Test',
        showBackButton: canPop,
        leading:
            !canPop
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _navigationService.navigateTo(context, '/settings'),
                )
                : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Error Handling',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use these buttons to test different types of error handling. '
              'Errors will be logged locally and sent to Firebase Crashlytics '
              'in production builds.',
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Trigger Synchronous Error',
              onPressed: _isLoading ? null : _triggerSyncError,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Trigger Asynchronous Error',
              onPressed: _isLoading ? null : _triggerAsyncError,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Trigger Uncaught Error',
              onPressed: _isLoading ? null : _triggerUncaughtError,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Trigger Fatal Error',
              onPressed: _isLoading ? null : _triggerFatalError,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Add Custom Keys',
              onPressed: _isLoading ? null : _addCustomKeys,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Add Breadcrumbs',
              onPressed: _isLoading ? null : _addBreadcrumbs,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Set Device Info',
              onPressed: _isLoading ? null : _setDeviceInfo,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Force Crash',
              onPressed: _isLoading ? null : _forceCrash,
              isLoading: _isLoading,
              type: AppButtonType.outline,
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_statusMessage!),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Testing Instructions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Use the buttons above to trigger different types of errors\n'
              '2. Check the logs to see the errors being recorded\n'
              '3. In production builds, the errors will be sent to Firebase Crashlytics\n'
              '4. You can view the errors in the Firebase console under Crashlytics\n'
              '5. The "Force Crash" button will only work in release mode',
            ),
          ],
        ),
      ),
    );
  }
}
