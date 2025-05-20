import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class AnalyticsTestScreen extends ConsumerStatefulWidget {
  const AnalyticsTestScreen({super.key});

  @override
  ConsumerState<AnalyticsTestScreen> createState() => _AnalyticsTestScreenState();
}

class _AnalyticsTestScreenState extends ConsumerState<AnalyticsTestScreen> {
  final _analyticsService = getIt<AnalyticsService>();
  final _navigationService = getIt<NavigationService>();
  final _eventNameController = TextEditingController(text: 'test_event');
  final _paramNameController = TextEditingController(text: 'param_name');
  final _paramValueController = TextEditingController(text: 'param_value');
  final _searchTermController = TextEditingController(text: 'test search');
  String? _statusMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _eventNameController.dispose();
    _paramNameController.dispose();
    _paramValueController.dispose();
    _searchTermController.dispose();
    super.dispose();
  }

  Future<void> _logCustomEvent() async {
    if (_eventNameController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final params = <String, Object>{}; // Changé de dynamic à Object
      if (_paramNameController.text.isNotEmpty && _paramValueController.text.isNotEmpty) {
        params[_paramNameController.text] = _paramValueController.text;
      }

      await _analyticsService.logCustomEvent(
        name: _eventNameController.text,
        parameters: params.isNotEmpty ? params : null,
      );

      setState(() {
        _statusMessage = 'Custom event logged successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error logging custom event: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logSearchEvent() async {
    if (_searchTermController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await _analyticsService.logSearch(searchTerm: _searchTermController.text);

      setState(() {
        _statusMessage = 'Search event logged successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error logging search event: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logPurchaseEvent() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await _analyticsService.logPurchase(
        value: 9.99,
        currency: 'USD',
        itemId: 'premium_subscription',
        itemName: 'Premium Subscription',
      );

      setState(() {
        _statusMessage = 'Purchase event logged successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error logging purchase event: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setUserProperties() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await _analyticsService.setUserProperties(
        userId: 'test_user_123',
        userRole: 'tester',
        subscriptionType: 'premium',
      );

      setState(() {
        _statusMessage = 'User properties set successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error setting user properties: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Analytics Test',
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
            const Text('Custom Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            AppTextField(
              controller: _eventNameController,
              label: 'Event Name',
              hint: 'Enter event name',
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _paramNameController,
              label: 'Parameter Name (optional)',
              hint: 'Enter parameter name',
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _paramValueController,
              label: 'Parameter Value (optional)',
              hint: 'Enter parameter value',
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Log Custom Event',
              onPressed: _isLoading ? null : _logCustomEvent,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Predefined Events',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text('Search Event'),
            const SizedBox(height: 8),
            AppTextField(
              controller: _searchTermController,
              label: 'Search Term',
              hint: 'Enter search term',
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Log Search Event',
              onPressed: _isLoading ? null : _logSearchEvent,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            const Text('Purchase Event'),
            const SizedBox(height: 8),
            AppButton(
              text: 'Log Purchase Event',
              onPressed: _isLoading ? null : _logPurchaseEvent,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            const Text('User Properties'),
            const SizedBox(height: 8),
            AppButton(
              text: 'Set User Properties',
              onPressed: _isLoading ? null : _setUserProperties,
              isLoading: _isLoading,
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _statusMessage!.contains('Error')
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(context).colorScheme.primaryContainer,
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
              '1. Use the forms above to log different types of events\n'
              '2. Check the Firebase Analytics dashboard to see the events\n'
              '3. Note that events may take some time to appear in the dashboard\n'
              '4. You can also use the DebugView in Firebase Analytics to see events in real-time',
            ),
          ],
        ),
      ),
    );
  }
}
