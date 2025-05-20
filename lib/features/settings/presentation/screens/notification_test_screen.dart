import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class NotificationTestScreen extends ConsumerStatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  ConsumerState<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends ConsumerState<NotificationTestScreen> {
  final _notificationService = getIt<NotificationService>();
  final _navigationService = getIt<NavigationService>();
  final _topicController = TextEditingController(text: 'all_users');
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  String? _fcmToken;
  String? _statusMessage;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    setState(() {
      _fcmToken = _notificationService.token;
    });
  }

  Future<void> _subscribeToTopic() async {
    if (_topicController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await _notificationService.subscribeToTopic(_topicController.text);
      setState(() {
        _statusMessage = 'Successfully subscribed to ${_topicController.text}';
        _isSubscribed = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error subscribing to topic: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _unsubscribeFromTopic() async {
    if (_topicController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await _notificationService.unsubscribeFromTopic(_topicController.text);
      setState(() {
        _statusMessage = 'Successfully unsubscribed from ${_topicController.text}';
        _isSubscribed = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error unsubscribing from topic: $e';
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
        title: 'Notification Test',
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
            const Text('FCM Token', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _fcmToken ?? 'Loading token...',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed:
                        _fcmToken == null
                            ? null
                            : () {
                              Clipboard.setData(ClipboardData(text: _fcmToken!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Token copied to clipboard')),
                              );
                            },
                    tooltip: 'Copy token',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Topic Subscription',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _topicController,
              label: 'Topic Name',
              hint: 'Enter topic name',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Subscribe',
                    onPressed: _isLoading || _isSubscribed ? null : _subscribeToTopic,
                    isLoading: _isLoading && !_isSubscribed,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    text: 'Unsubscribe',
                    onPressed: _isLoading || !_isSubscribed ? null : _unsubscribeFromTopic,
                    isLoading: _isLoading && _isSubscribed,
                    type: AppButtonType.outline,
                  ),
                ),
              ],
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
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
              '1. Subscribe to a topic (e.g., "all_users")\n'
              '2. Use Firebase Console to send a notification to this topic\n'
              '3. Or use the FCM REST API with the token above to send a direct notification\n'
              '4. Check how the app handles the notification in foreground and background',
            ),
            const SizedBox(height: 16),
            const Text('Firebase Console Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              '1. Go to Firebase Console > Messaging\n'
              '2. Click "Create your first campaign" or "New campaign"\n'
              '3. Select "Notifications" as campaign type\n'
              '4. Fill in the notification details\n'
              '5. In targeting, select "Topic" and enter your topic name\n'
              '6. Schedule for "Now" and send the notification',
            ),
          ],
        ),
      ),
    );
  }
}
