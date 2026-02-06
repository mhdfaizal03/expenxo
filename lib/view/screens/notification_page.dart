import 'package:expenxo/models/notification_model.dart';
import 'package:expenxo/services/firestore_service.dart';
import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/view/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notifications",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () =>
                _showClearAllConfirmDialog(context, firestoreService),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: firestoreService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const ShimmerList();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No notifications yet",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.color?.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              return Dismissible(
                key: Key(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  // No-op
                },
                confirmDismiss: (_) async => false,
                child: _buildNotificationItem(
                  context,
                  n,
                  firestoreService,
                ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1),
              );
            },
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     firestoreService.addNotification(
      //       NotificationModel(
      //         id: '',
      //         title: "Test Notification",
      //         body:
      //             "This is a test alert generated at ${DateFormat('h:mm:ss a').format(DateTime.now())}",
      //         timestamp: DateTime.now(),
      //         type: 'alert',
      //       ),
      //     );
      //   },
      //   backgroundColor: AppColors.mainColor,
      //   child: const Icon(Icons.add_alert, color: Colors.white),
      // ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel n,
    FirestoreService service,
  ) {
    if (!n.isRead) {
      service.markNotificationAsRead(n.id);
    }

    Color iconColor;
    IconData iconData;

    switch (n.type) {
      case 'alert':
        iconColor = AppColors.error;
        iconData = Icons.warning_amber_rounded;
        break;
      case 'success':
        iconColor = const Color(0xFF00C9A7);
        iconData = Icons.check_circle_outline;
        break;
      default:
        iconColor = AppColors.mainColor;
        iconData = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: n.isRead
              ? Theme.of(context).dividerColor.withOpacity(0.1)
              : iconColor.withOpacity(0.3),
        ),
        boxShadow: n.isRead
            ? []
            : [
                BoxShadow(
                  color: iconColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        n.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    Text(
                      _formatTimestamp(n.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n.body,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (difference.inDays < 7) {
      return DateFormat('E, h:mm a').format(timestamp);
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  void _showClearAllConfirmDialog(
    BuildContext context,
    FirestoreService service,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          "Clear All?",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        content: Text(
          "Are you sure you want to delete all notifications?",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text(
              "Clear",
              style: TextStyle(color: AppColors.error),
            ),
            onPressed: () {
              service.clearAllNotifications();
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
