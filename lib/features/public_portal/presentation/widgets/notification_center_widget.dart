import 'package:flutter/material.dart';
import '../../../../core/models/citizen_services_models.dart';

class NotificationCenterWidget extends StatefulWidget {
  const NotificationCenterWidget({super.key});

  @override
  State<NotificationCenterWidget> createState() => _NotificationCenterWidgetState();
}

class _NotificationCenterWidgetState extends State<NotificationCenterWidget> {
  NotificationPreferences _preferences = NotificationPreferences(
    sms: true,
    email: true,
    whatsapp: false,
    push: true,
    categories: NotificationCategories(
      deadlines: true,
      fundReleases: true,
      projectUpdates: true,
      newSchemes: true,
      localEvents: false,
    ),
  );

  final List<CitizenNotification> _notifications = [
    CitizenNotification(
      id: '1',
      type: NotificationType.deadline,
      title: 'Scholarship Application Deadline Approaching',
      message: 'The deadline for PM-AJAY Adarsh Gram Education Scholarship is in 5 days. Submit your application before March 31, 2025.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      priority: NotificationPriority.high,
      location: 'Wardha, Maharashtra',
      actionRequired: true,
      expiryDate: DateTime.now().add(const Duration(days: 5)),
    ),
    CitizenNotification(
      id: '2',
      type: NotificationType.fundRelease,
      title: 'New Fund Release for Hostel Construction',
      message: '₹2 Crore released for hostel construction in your district. Applications for hostel accommodation now open.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      priority: NotificationPriority.medium,
      location: 'Nagpur District, Maharashtra',
    ),
    CitizenNotification(
      id: '3',
      type: NotificationType.projectUpdate,
      title: 'Village Road Construction Completed',
      message: 'The 2km village connecting road in Wardha village has been completed under Adarsh Gram project.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      priority: NotificationPriority.low,
      location: 'Wardha Village, Maharashtra',
    ),
    CitizenNotification(
      id: '4',
      type: NotificationType.newScheme,
      title: 'New Skill Development Program Launched',
      message: 'GIA Digital Literacy Program now available. Free training for 3 months with job placement assistance.',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      priority: NotificationPriority.medium,
      location: 'Maharashtra State',
    ),
  ];

  void _savePreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification preferences saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Colors.red.shade50;
      case NotificationPriority.medium:
        return Colors.amber.shade50;
      case NotificationPriority.low:
        return Colors.green.shade50;
    }
  }

  Color _getPriorityBorderColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Colors.red.shade200;
      case NotificationPriority.medium:
        return Colors.amber.shade200;
      case NotificationPriority.low:
        return Colors.green.shade200;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.deadline:
        return Icons.calendar_today;
      case NotificationType.fundRelease:
        return Icons.notifications;
      case NotificationType.projectUpdate:
        return Icons.location_on;
      case NotificationType.newScheme:
        return Icons.message;
      case NotificationType.localEvent:
        return Icons.event;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Notification Preferences Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_active, 
                          color: Theme.of(context).primaryColor, 
                          size: 24
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notification Preferences',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Choose how you want to receive updates about PM-AJAY schemes and local development',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Delivery Methods',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildDeliveryMethodCard(
                          icon: Icons.smartphone,
                          label: 'SMS',
                          value: _preferences.sms,
                          onChanged: (val) => setState(() => 
                            _preferences = NotificationPreferences(
                              sms: val,
                              email: _preferences.email,
                              whatsapp: _preferences.whatsapp,
                              push: _preferences.push,
                              categories: _preferences.categories,
                            )
                          ),
                        ),
                        _buildDeliveryMethodCard(
                          icon: Icons.email,
                          label: 'Email',
                          value: _preferences.email,
                          onChanged: (val) => setState(() => 
                            _preferences = NotificationPreferences(
                              sms: _preferences.sms,
                              email: val,
                              whatsapp: _preferences.whatsapp,
                              push: _preferences.push,
                              categories: _preferences.categories,
                            )
                          ),
                        ),
                        _buildDeliveryMethodCard(
                          icon: Icons.message,
                          label: 'WhatsApp',
                          value: _preferences.whatsapp,
                          onChanged: (val) => setState(() => 
                            _preferences = NotificationPreferences(
                              sms: _preferences.sms,
                              email: _preferences.email,
                              whatsapp: val,
                              push: _preferences.push,
                              categories: _preferences.categories,
                            )
                          ),
                        ),
                        _buildDeliveryMethodCard(
                          icon: Icons.notifications,
                          label: 'Push',
                          value: _preferences.push,
                          onChanged: (val) => setState(() => 
                            _preferences = NotificationPreferences(
                              sms: _preferences.sms,
                              email: _preferences.email,
                              whatsapp: _preferences.whatsapp,
                              push: val,
                              categories: _preferences.categories,
                            )
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'What to notify about',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryTile(
                      title: 'Deadlines',
                      subtitle: 'Application deadlines and important dates',
                      value: _preferences.categories.deadlines,
                      onChanged: (val) => setState(() {
                        _preferences = NotificationPreferences(
                          sms: _preferences.sms,
                          email: _preferences.email,
                          whatsapp: _preferences.whatsapp,
                          push: _preferences.push,
                          categories: NotificationCategories(
                            deadlines: val,
                            fundReleases: _preferences.categories.fundReleases,
                            projectUpdates: _preferences.categories.projectUpdates,
                            newSchemes: _preferences.categories.newSchemes,
                            localEvents: _preferences.categories.localEvents,
                          ),
                        );
                      }),
                    ),
                    _buildCategoryTile(
                      title: 'Fund Releases',
                      subtitle: 'New fund allocations and budget announcements',
                      value: _preferences.categories.fundReleases,
                      onChanged: (val) => setState(() {
                        _preferences = NotificationPreferences(
                          sms: _preferences.sms,
                          email: _preferences.email,
                          whatsapp: _preferences.whatsapp,
                          push: _preferences.push,
                          categories: NotificationCategories(
                            deadlines: _preferences.categories.deadlines,
                            fundReleases: val,
                            projectUpdates: _preferences.categories.projectUpdates,
                            newSchemes: _preferences.categories.newSchemes,
                            localEvents: _preferences.categories.localEvents,
                          ),
                        );
                      }),
                    ),
                    _buildCategoryTile(
                      title: 'Project Updates',
                      subtitle: 'Construction and development progress',
                      value: _preferences.categories.projectUpdates,
                      onChanged: (val) => setState(() {
                        _preferences = NotificationPreferences(
                          sms: _preferences.sms,
                          email: _preferences.email,
                          whatsapp: _preferences.whatsapp,
                          push: _preferences.push,
                          categories: NotificationCategories(
                            deadlines: _preferences.categories.deadlines,
                            fundReleases: _preferences.categories.fundReleases,
                            projectUpdates: val,
                            newSchemes: _preferences.categories.newSchemes,
                            localEvents: _preferences.categories.localEvents,
                          ),
                        );
                      }),
                    ),
                    _buildCategoryTile(
                      title: 'New Schemes',
                      subtitle: 'New scheme launches and policy updates',
                      value: _preferences.categories.newSchemes,
                      onChanged: (val) => setState(() {
                        _preferences = NotificationPreferences(
                          sms: _preferences.sms,
                          email: _preferences.email,
                          whatsapp: _preferences.whatsapp,
                          push: _preferences.push,
                          categories: NotificationCategories(
                            deadlines: _preferences.categories.deadlines,
                            fundReleases: _preferences.categories.fundReleases,
                            projectUpdates: _preferences.categories.projectUpdates,
                            newSchemes: val,
                            localEvents: _preferences.categories.localEvents,
                          ),
                        );
                      }),
                    ),
                    _buildCategoryTile(
                      title: 'Local Events',
                      subtitle: 'Community events and meetings',
                      value: _preferences.categories.localEvents,
                      onChanged: (val) => setState(() {
                        _preferences = NotificationPreferences(
                          sms: _preferences.sms,
                          email: _preferences.email,
                          whatsapp: _preferences.whatsapp,
                          push: _preferences.push,
                          categories: NotificationCategories(
                            deadlines: _preferences.categories.deadlines,
                            fundReleases: _preferences.categories.fundReleases,
                            projectUpdates: _preferences.categories.projectUpdates,
                            newSchemes: _preferences.categories.newSchemes,
                            localEvents: val,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _savePreferences,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save Preferences'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Recent Notifications Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Notifications',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Latest updates relevant to your location and interests',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(notification.priority),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getPriorityBorderColor(notification.priority),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    _getNotificationIcon(notification.type),
                                    size: 20,
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
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            if (notification.actionRequired)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Action Required',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification.message,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 16,
                                          children: [
                                            Text(
                                              _formatDate(notification.timestamp),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (notification.location != null)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    notification.location!,
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (notification.expiryDate != null)
                                              Text(
                                                'Expires: ${notification.expiryDate!.day}/${notification.expiryDate!.month}/${notification.expiryDate!.year}',
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (notification.actionRequired)
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text('Take Action'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryMethodCard({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}