import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_design_system.dart';
import '../utils/responsive_layout.dart';

/// Notification types for different dashboards
enum NotificationType {
  alert,
  warning,
  info,
  success,
  deadline,
  approval,
  message,
  system,
}

/// Notification priority levels
enum NotificationPriority {
  high,
  medium,
  low,
}

/// Notification model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;
  final Map<String, dynamic>? actionData;
  final String? avatarUrl;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
    this.actionData,
    this.avatarUrl,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? timestamp,
    bool? isRead,
    String? actionRoute,
    Map<String, dynamic>? actionData,
    String? avatarUrl,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      actionData: actionData ?? this.actionData,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

/// Notification Panel Widget
class NotificationPanelWidget extends StatefulWidget {
  final List<NotificationItem> notifications;
  final Function(NotificationItem)? onNotificationTap;
  final Function(String)? onMarkAsRead;
  final Function()? onMarkAllAsRead;
  final Function(String)? onDeleteNotification;
  final Function()? onClearAll;

  const NotificationPanelWidget({
    super.key,
    required this.notifications,
    this.onNotificationTap,
    this.onMarkAsRead,
    this.onMarkAllAsRead,
    this.onDeleteNotification,
    this.onClearAll,
  });

  @override
  State<NotificationPanelWidget> createState() => _NotificationPanelWidgetState();
}

class _NotificationPanelWidgetState extends State<NotificationPanelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  NotificationType? _filterType;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppDesignSystem.durationNormal,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.alert:
        return AppDesignSystem.error;
      case NotificationType.warning:
        return AppDesignSystem.warning;
      case NotificationType.info:
        return AppDesignSystem.info;
      case NotificationType.success:
        return AppDesignSystem.success;
      case NotificationType.deadline:
        return AppDesignSystem.sunsetOrange;
      case NotificationType.approval:
        return AppDesignSystem.vibrantTeal;
      case NotificationType.message:
        return AppDesignSystem.deepIndigo;
      case NotificationType.system:
        return AppDesignSystem.neutral600;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.alert:
        return Icons.warning_amber_rounded;
      case NotificationType.warning:
        return Icons.error_outline;
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.deadline:
        return Icons.access_time;
      case NotificationType.approval:
        return Icons.approval;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.system:
        return Icons.settings;
    }
  }

  List<NotificationItem> _getFilteredNotifications() {
    var filtered = widget.notifications;

    if (_showUnreadOnly) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }

    if (_filterType != null) {
      filtered = filtered.where((n) => n.type == _filterType).toList();
    }

    return filtered..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _getFilteredNotifications();
    final unreadCount = widget.notifications.where((n) => !n.isRead).length;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          elevation: 16,
          borderRadius: AppDesignSystem.radiusLarge,
          child: Container(
            width: ResponsiveLayout.valueByDevice(
              context: context,
              mobile: MediaQuery.of(context).size.width,
              mobileWide: 400,
              tablet: 450,
              desktop: 500,
            ),
            height: ResponsiveLayout.valueByDevice(
              context: context,
              mobile: MediaQuery.of(context).size.height,
              mobileWide: 600,
              tablet: 700,
              desktop: 800,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: AppDesignSystem.radiusLarge,
            ),
            child: Column(
              children: [
                _buildHeader(unreadCount),
                _buildFilters(),
                Divider(height: 1, color: AppDesignSystem.neutral300),
                Expanded(
                  child: filteredNotifications.isEmpty
                      ? _buildEmptyState()
                      : _buildNotificationList(filteredNotifications),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int unreadCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppDesignSystem.deepIndigo,
            AppDesignSystem.vibrantTeal,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: AppDesignSystem.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (unreadCount > 0)
                  Text(
                    '$unreadCount unread',
                    style: AppDesignSystem.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: widget.onMarkAllAsRead,
              icon: const Icon(Icons.done_all, size: 16, color: Colors.white),
              label: Text(
                'Mark all read',
                style: AppDesignSystem.labelSmall.copyWith(color: Colors.white),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _filterType == null,
                        onSelected: (selected) {
                          setState(() {
                            _filterType = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...NotificationType.values.map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            avatar: Icon(
                              _getTypeIcon(type),
                              size: 16,
                              color: _filterType == type
                                  ? Colors.white
                                  : _getTypeColor(type),
                            ),
                            label: Text(
                              type.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                color: _filterType == type
                                    ? Colors.white
                                    : _getTypeColor(type),
                              ),
                            ),
                            selected: _filterType == type,
                            selectedColor: _getTypeColor(type),
                            onSelected: (selected) {
                              setState(() {
                                _filterType = selected ? type : null;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilterChip(
                label: const Text('Unread only'),
                selected: _showUnreadOnly,
                onSelected: (selected) {
                  setState(() {
                    _showUnreadOnly = selected;
                  });
                },
              ),
              const Spacer(),
              if (widget.notifications.isNotEmpty)
                TextButton.icon(
                  onPressed: widget.onClearAll,
                  icon: const Icon(Icons.delete_sweep, size: 16),
                  label: const Text('Clear all'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppDesignSystem.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationItem> notifications) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    final color = _getTypeColor(notification.type);
    final icon = _getTypeIcon(notification.type);

    return TweenAnimationBuilder<double>(
      duration: AppDesignSystem.durationFast,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: notification.isRead ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesignSystem.radiusMedium,
          side: BorderSide(
            color: notification.isRead
                ? AppDesignSystem.neutral300
                : color.withValues(alpha: 0.3),
            width: notification.isRead ? 1 : 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              widget.onMarkAsRead?.call(notification.id);
            }
            widget.onNotificationTap?.call(notification);
          },
          borderRadius: AppDesignSystem.radiusMedium,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppDesignSystem.titleSmall.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppDesignSystem.bodySmall.copyWith(
                          color: AppDesignSystem.neutral600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppDesignSystem.neutral500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style: AppDesignSystem.labelSmall.copyWith(
                              color: AppDesignSystem.neutral500,
                            ),
                          ),
                          if (notification.priority == NotificationPriority.high) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppDesignSystem.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'HIGH',
                                style: AppDesignSystem.labelSmall.copyWith(
                                  color: AppDesignSystem.error,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: AppDesignSystem.neutral500,
                            ),
                            onPressed: () {
                              widget.onDeleteNotification?.call(notification.id);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            Icons.notifications_none,
            size: 64,
            color: AppDesignSystem.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: AppDesignSystem.titleMedium.copyWith(
              color: AppDesignSystem.neutral600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filterType != null || _showUnreadOnly
                ? 'Try adjusting your filters'
                : 'You\'re all caught up!',
            style: AppDesignSystem.bodySmall.copyWith(
              color: AppDesignSystem.neutral500,
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
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}