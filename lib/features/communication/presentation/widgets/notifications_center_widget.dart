import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/communication_service.dart';
import '../../../../core/models/communication_models.dart';
import '../../../../core/theme/app_theme.dart';

/// Notifications Center Widget
/// 
/// Unified notification center for all communication activities
class NotificationsCenterWidget extends ConsumerStatefulWidget {
  const NotificationsCenterWidget({super.key});

  @override
  ConsumerState<NotificationsCenterWidget> createState() => _NotificationsCenterWidgetState();
}

class _NotificationsCenterWidgetState extends ConsumerState<NotificationsCenterWidget> {
  final CommunicationService _commService = CommunicationService();
  
  bool _showUnreadOnly = false;
  NotificationType? _selectedType;

  @override
  Widget build(BuildContext context) {
    const userId = 'current-user-id'; // TODO: Get from auth

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _markAllAsRead(userId),
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Mark all read'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _showNotificationSettings,
                    tooltip: 'Notification Settings',
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread Filter
              Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: !_showUnreadOnly,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _showUnreadOnly = false);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Unread'),
                    selected: _showUnreadOnly,
                    onSelected: (selected) {
                      setState(() => _showUnreadOnly = selected);
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Type Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Types'),
                      selected: _selectedType == null,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedType = null);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ...NotificationType.values.map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(_getTypeLabel(type)),
                          selected: _selectedType == type,
                          avatar: Icon(
                            _getNotificationIcon(type),
                            size: 16,
                          ),
                          onSelected: (selected) {
                            setState(() => _selectedType = selected ? type : null);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Notifications List
        Expanded(
          child: StreamBuilder<List<CommunicationNotification>>(
            stream: _commService.getNotificationsStream(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var notifications = snapshot.data ?? [];
              
              // Apply filters
              if (_showUnreadOnly) {
                notifications = notifications.where((n) => !n.isRead).toList();
              }
              
              if (_selectedType != null) {
                notifications = notifications.where((n) => n.type == _selectedType).toList();
              }

              if (notifications.isEmpty) {
                return _buildEmptyState();
              }

              // Group notifications by date
              final groupedNotifications = _groupNotificationsByDate(notifications);

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedNotifications.length,
                itemBuilder: (context, index) {
                  final group = groupedNotifications[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          group['date'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neutralGray,
                          ),
                        ),
                      ),
                      // Notifications in this group
                      ...(group['notifications'] as List<CommunicationNotification>).map(
                        (notification) => _buildNotificationTile(notification),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTile(CommunicationNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : AppTheme.primaryIndigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: notification.isRead ? Colors.grey.shade300 : AppTheme.primaryIndigo.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
            size: 24,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.timestamp),
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.neutralGray,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Text('Mark as read'),
              ),
            const PopupMenuItem(
              value: 'view',
              child: Text('View details'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) {
            if (value == 'mark_read') {
              _commService.markNotificationAsRead(notification.id);
            } else if (value == 'view') {
              _viewNotificationDetails(notification);
            } else if (value == 'delete') {
              _deleteNotification(notification.id);
            }
          },
        ),
        onTap: () {
          if (!notification.isRead) {
            _commService.markNotificationAsRead(notification.id);
          }
          _viewNotificationDetails(notification);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showUnreadOnly ? Icons.notifications_off : Icons.notifications_none,
            size: 64,
            color: AppTheme.neutralGray,
          ),
          const SizedBox(height: 16),
          Text(
            _showUnreadOnly ? 'No unread notifications' : 'No notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.neutralGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showUnreadOnly 
                ? 'You\'re all caught up!'
                : 'Notifications will appear here',
            style: const TextStyle(
              color: AppTheme.neutralGray,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupNotificationsByDate(
    List<CommunicationNotification> notifications,
  ) {
    final groups = <String, List<CommunicationNotification>>{};
    
    for (final notification in notifications) {
      final dateKey = _getDateKey(notification.timestamp);
      groups.putIfAbsent(dateKey, () => []).add(notification);
    }
    
    return groups.entries.map((entry) {
      return {
        'date': entry.key,
        'notifications': entry.value,
      };
    }).toList();
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);
    
    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return '${now.difference(date).inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newMessage:
        return Icons.message;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.ticketAssigned:
        return Icons.assignment;
      case NotificationType.ticketUpdated:
        return Icons.update;
      case NotificationType.ticketEscalated:
        return Icons.priority_high;
      case NotificationType.tagAdded:
        return Icons.label;
      case NotificationType.general:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newMessage:
        return Colors.blue;
      case NotificationType.mention:
        return Colors.purple;
      case NotificationType.ticketAssigned:
        return Colors.orange;
      case NotificationType.ticketUpdated:
        return Colors.amber;
      case NotificationType.ticketEscalated:
        return AppTheme.errorRed;
      case NotificationType.tagAdded:
        return Colors.teal;
      case NotificationType.general:
        return AppTheme.neutralGray;
    }
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.newMessage:
        return 'Messages';
      case NotificationType.mention:
        return 'Mentions';
      case NotificationType.ticketAssigned:
        return 'Assigned';
      case NotificationType.ticketUpdated:
        return 'Updates';
      case NotificationType.ticketEscalated:
        return 'Escalated';
      case NotificationType.tagAdded:
        return 'Tags';
      case NotificationType.general:
        return 'General';
    }
  }

  void _markAllAsRead(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark all as read'),
        content: const Text('Are you sure you want to mark all notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementation would mark all notifications as read
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
    );
  }

  void _viewNotificationDetails(CommunicationNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(notification.title),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 16),
            Text(
              _formatTimestamp(notification.timestamp),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.neutralGray,
              ),
            ),
            if (notification.data.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Additional Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...notification.data.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (notification.data.containsKey('ticket_id') ||
              notification.data.containsKey('channel_id'))
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to the related item
              },
              child: const Text('Go to item'),
            ),
        ],
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementation would delete the notification
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive push notifications'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: const Text('Email Notifications'),
                subtitle: const Text('Receive email notifications'),
                value: true,
                onChanged: (value) {},
              ),
              const Divider(),
              ...NotificationType.values.map((type) {
                return SwitchListTile(
                  title: Text(_getTypeLabel(type)),
                  value: true,
                  onChanged: (value) {},
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}