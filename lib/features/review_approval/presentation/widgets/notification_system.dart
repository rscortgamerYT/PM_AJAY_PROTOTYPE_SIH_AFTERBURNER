import 'package:flutter/material.dart';

/// Notification types for Review & Approval workflows
enum NotificationType {
  newRequest('New Request', Icons.notification_add, Colors.blue),
  requestApproved('Request Approved', Icons.check_circle, Colors.green),
  requestRejected('Request Rejected', Icons.cancel, Colors.red),
  infoRequested('Information Requested', Icons.info, Colors.orange),
  slaWarning('SLA Warning', Icons.warning, Colors.orange),
  slaViolation('SLA Violation', Icons.error, Colors.red),
  taskAssigned('Task Assigned', Icons.assignment, Colors.purple),
  statusUpdate('Status Update', Icons.update, Colors.blue),
  escalation('Escalation', Icons.priority_high, Colors.red);

  final String label;
  final IconData icon;
  final Color color;
  
  const NotificationType(this.label, this.icon, this.color);
}

/// Notification model
class ReviewNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? requestId;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  ReviewNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.requestId,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  ReviewNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    String? requestId,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return ReviewNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      requestId: requestId ?? this.requestId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Notification panel widget displaying all notifications
class NotificationPanel extends StatefulWidget {
  final String userId;
  final VoidCallback? onNotificationRead;

  const NotificationPanel({
    super.key,
    required this.userId,
    this.onNotificationRead,
  });

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  List<ReviewNotification> _notifications = [];
  NotificationType? _filterType;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    // Mock notifications - replace with actual Supabase queries
    setState(() {
      _notifications = [
        ReviewNotification(
          id: 'notif-001',
          type: NotificationType.newRequest,
          title: 'New State Participation Request',
          message: 'Maharashtra has submitted a request for PM-AJAY Adarsha Gram scheme',
          requestId: 'req-001',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        ReviewNotification(
          id: 'notif-002',
          type: NotificationType.slaWarning,
          title: 'SLA Warning',
          message: 'Request REQ-045 is approaching the 48-hour SLA deadline',
          requestId: 'req-045',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ReviewNotification(
          id: 'notif-003',
          type: NotificationType.requestApproved,
          title: 'Request Approved',
          message: 'Your agency onboarding request has been approved',
          requestId: 'req-023',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: true,
        ),
        ReviewNotification(
          id: 'notif-004',
          type: NotificationType.infoRequested,
          title: 'Additional Information Required',
          message: 'Centre has requested additional documentation for REQ-034',
          requestId: 'req-034',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ReviewNotification(
          id: 'notif-005',
          type: NotificationType.escalation,
          title: 'Request Escalated',
          message: 'REQ-012 has been escalated to senior management due to SLA violation',
          requestId: 'req-012',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
        ),
      ];
    });
  }

  List<ReviewNotification> get _filteredNotifications {
    var filtered = _notifications;
    
    if (_showUnreadOnly) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }
    
    if (_filterType != null) {
      filtered = filtered.where((n) => n.type == _filterType).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(unreadCount),
        const SizedBox(height: 16),
        _buildFilters(),
        const SizedBox(height: 16),
        Expanded(
          child: _filteredNotifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = _filteredNotifications[index];
                    return _buildNotificationCard(notification);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(int unreadCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount new',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        Row(
          children: [
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all),
              label: const Text('Mark all as read'),
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
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        FilterChip(
          label: const Text('Unread only'),
          selected: _showUnreadOnly,
          onSelected: (selected) {
            setState(() {
              _showUnreadOnly = selected;
            });
          },
          selectedColor: Colors.blue.withOpacity(0.2),
          checkmarkColor: Colors.blue,
        ),
        const SizedBox(width: 8),
        const Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        _buildTypeFilter(null, 'All'),
        _buildTypeFilter(NotificationType.newRequest, 'New'),
        _buildTypeFilter(NotificationType.slaWarning, 'SLA'),
        _buildTypeFilter(NotificationType.escalation, 'Escalated'),
      ],
    );
  }

  Widget _buildTypeFilter(NotificationType? type, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filterType == type,
        onSelected: (selected) {
          setState(() {
            _filterType = selected ? type : null;
          });
        },
        selectedColor: Colors.blue,
        labelStyle: TextStyle(
          color: _filterType == type ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(ReviewNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notification.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification.type.icon,
                  color: notification.type.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (notification.requestId != null) ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              notification.requestId!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.visibility, size: 18),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                    onTap: () => _viewNotificationDetails(notification),
                  ),
                  if (!notification.isRead)
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.done, size: 18),
                          SizedBox(width: 8),
                          Text('Mark as read'),
                        ],
                      ),
                      onTap: () => _markAsRead(notification),
                    ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 18),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                    onTap: () => _deleteNotification(notification),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _handleNotificationTap(ReviewNotification notification) {
    if (!notification.isRead) {
      _markAsRead(notification);
    }
    
    if (notification.requestId != null) {
      // TODO: Navigate to request details page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening request ${notification.requestId}')),
      );
    }
  }

  void _markAsRead(ReviewNotification notification) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    });
    widget.onNotificationRead?.call();
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    widget.onNotificationRead?.call();
  }

  void _viewNotificationDetails(ReviewNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(notification.type.icon, color: notification.type.color),
            const SizedBox(width: 12),
            Expanded(child: Text(notification.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            Text(
              'Time: ${_formatTimestamp(notification.timestamp)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (notification.requestId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Request ID: ${notification.requestId}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
          if (notification.requestId != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleNotificationTap(notification);
              },
              child: const Text('View Request'),
            ),
        ],
      ),
    );
  }

  void _deleteNotification(ReviewNotification notification) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => const NotificationSettingsDialog(),
    );
  }
}

/// Notification settings dialog
class NotificationSettingsDialog extends StatefulWidget {
  const NotificationSettingsDialog({super.key});

  @override
  State<NotificationSettingsDialog> createState() => _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState extends State<NotificationSettingsDialog> {
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _newRequestNotif = true;
  bool _statusUpdateNotif = true;
  bool _slaWarningNotif = true;
  bool _escalationNotif = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Notification Settings'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Delivery Methods',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SwitchListTile(
                title: const Text('Email Notifications'),
                subtitle: const Text('Receive notifications via email'),
                value: _emailNotifications,
                onChanged: (value) => setState(() => _emailNotifications = value),
              ),
              SwitchListTile(
                title: const Text('SMS Notifications'),
                subtitle: const Text('Receive notifications via SMS'),
                value: _smsNotifications,
                onChanged: (value) => setState(() => _smsNotifications = value),
              ),
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive in-app push notifications'),
                value: _pushNotifications,
                onChanged: (value) => setState(() => _pushNotifications = value),
              ),
              const Divider(height: 32),
              const Text(
                'Notification Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SwitchListTile(
                title: const Text('New Requests'),
                value: _newRequestNotif,
                onChanged: (value) => setState(() => _newRequestNotif = value),
              ),
              SwitchListTile(
                title: const Text('Status Updates'),
                value: _statusUpdateNotif,
                onChanged: (value) => setState(() => _statusUpdateNotif = value),
              ),
              SwitchListTile(
                title: const Text('SLA Warnings'),
                value: _slaWarningNotif,
                onChanged: (value) => setState(() => _slaWarningNotif = value),
              ),
              SwitchListTile(
                title: const Text('Escalations'),
                value: _escalationNotif,
                onChanged: (value) => setState(() => _escalationNotif = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Save notification preferences
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification settings saved')),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}