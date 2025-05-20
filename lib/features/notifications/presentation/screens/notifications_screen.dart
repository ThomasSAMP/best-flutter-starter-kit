import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../shared/widgets/app_bar.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationService = getIt<NavigationService>();

    // Sample notifications data
    final notifications = [
      {
        'title': 'New message',
        'body': 'You have a new message from John Doe',
        'time': DateTime.now().subtract(const Duration(minutes: 5)),
        'read': false,
        'type': 'message',
      },
      {
        'title': 'Account update',
        'body': 'Your account information has been updated',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'read': true,
        'type': 'account',
      },
      {
        'title': 'New feature available',
        'body': 'Check out our new features in the latest update',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'read': false,
        'type': 'update',
      },
      {
        'title': 'Weekly summary',
        'body': 'Here\'s a summary of your activity this week',
        'time': DateTime.now().subtract(const Duration(days: 3)),
        'read': true,
        'type': 'summary',
      },
    ];

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Notifications',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              // Mark all as read
              navigationService.showSnackBar(context, message: 'All notifications marked as read');
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body:
          notifications.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You\'ll be notified when something important happens',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final IconData iconData;
                  final Color iconColor;

                  switch (notification['type']) {
                    case 'message':
                      iconData = Icons.message_outlined;
                      iconColor = Colors.blue;
                      break;
                    case 'account':
                      iconData = Icons.account_circle_outlined;
                      iconColor = Colors.orange;
                      break;
                    case 'update':
                      iconData = Icons.update_outlined;
                      iconColor = Colors.green;
                      break;
                    case 'summary':
                      iconData = Icons.summarize_outlined;
                      iconColor = Colors.purple;
                      break;
                    default:
                      iconData = Icons.notifications_outlined;
                      iconColor = Colors.grey;
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: iconColor.withOpacity(0.2),
                      child: Icon(iconData, color: iconColor),
                    ),
                    title: Text(
                      notification['title'] as String,
                      style: TextStyle(
                        fontWeight:
                            notification['read'] as bool ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['body'] as String),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(notification['time'] as DateTime),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing:
                        notification['read'] as bool
                            ? null
                            : Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                    onTap: () {
                      // Mark as read and handle notification
                      navigationService.showSnackBar(
                        context,
                        message: 'Notification: ${notification['title']}',
                      );
                    },
                  );
                },
              ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
