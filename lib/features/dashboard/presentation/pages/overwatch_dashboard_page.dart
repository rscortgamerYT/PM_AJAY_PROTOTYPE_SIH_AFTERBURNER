import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/evidence_management_widget.dart';
import '../widgets/project_intelligence_widget.dart';
import '../widgets/alerts_monitoring_widget.dart';
import '../widgets/compliance_monitoring_widget.dart';
import '../widgets/reports_analytics_widget.dart';
import '../../../fund_flow/widgets/dual_entry_reconciliation_widget.dart';
import '../../../fund_flow/widgets/project_fund_flow_widget.dart';
import '../../../../core/widgets/calendar_widget.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/widgets/dashboard_components.dart';
import '../../../../core/widgets/event_calendar_widget.dart';
import '../../../../core/widgets/notification_panel_widget.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/dashboard_switcher_widget.dart';

class OverwatchDashboardPage extends ConsumerStatefulWidget {
  const OverwatchDashboardPage({super.key});

  @override
  ConsumerState<OverwatchDashboardPage> createState() => _OverwatchDashboardPageState();
}

class _OverwatchDashboardPageState extends ConsumerState<OverwatchDashboardPage> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  int _selectedIndex = 0;
  List<NotificationItem> _notifications = [];
  
  // Mock KPI data
  final Map<String, dynamic> _kpiData = {
    'totalStates': 28,
    'activeAlerts': 3,
    'fundsInTransit': 1250.0,
    'complianceScore': 94.5,
  };

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final now = DateTime.now();
    _notifications = [
      NotificationItem(
        id: '1',
        title: 'Critical Fund Discrepancy',
        message: 'State ABC has reported a fund allocation discrepancy of ₹50Cr that requires immediate attention.',
        type: NotificationType.alert,
        priority: NotificationPriority.high,
        timestamp: now.subtract(const Duration(minutes: 15)),
        actionRoute: '/alerts',
      ),
      NotificationItem(
        id: '2',
        title: 'Compliance Deadline Approaching',
        message: 'Q4 compliance reports are due in 3 days. 5 states have not submitted yet.',
        type: NotificationType.deadline,
        priority: NotificationPriority.high,
        timestamp: now.subtract(const Duration(hours: 2)),
        actionRoute: '/compliance',
      ),
      NotificationItem(
        id: '3',
        title: 'Fund Transfer Completed',
        message: '₹250Cr successfully transferred to 8 states for infrastructure projects.',
        type: NotificationType.success,
        priority: NotificationPriority.medium,
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: 'Audit Meeting Scheduled',
        message: 'Quarterly audit meeting with all stakeholders scheduled for tomorrow at 10:00 AM.',
        type: NotificationType.info,
        priority: NotificationPriority.medium,
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      NotificationItem(
        id: '5',
        title: 'System Maintenance',
        message: 'Scheduled system maintenance on Saturday from 2:00 AM to 4:00 AM.',
        type: NotificationType.system,
        priority: NotificationPriority.low,
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }

  void _showNotificationPanel() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        alignment: Alignment.topRight,
        insetPadding: EdgeInsets.only(
          top: ResponsiveLayout.valueByDevice(
            context: context,
            mobile: 0,
            mobileWide: 60,
            tablet: 80,
            desktop: 80,
          ),
          right: ResponsiveLayout.valueByDevice(
            context: context,
            mobile: 0,
            mobileWide: 16,
            tablet: 16,
            desktop: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        child: NotificationPanelWidget(
          notifications: _notifications,
          onNotificationTap: (notification) {
            if (notification.actionRoute != null) {
              Navigator.pop(context);
              // Navigate to the action route
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Navigate to: ${notification.actionRoute}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          onMarkAsRead: (id) {
            setState(() {
              final index = _notifications.indexWhere((n) => n.id == id);
              if (index != -1) {
                _notifications[index] = _notifications[index].copyWith(isRead: true);
              }
            });
          },
          onMarkAllAsRead: () {
            setState(() {
              _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
            });
          },
          onDeleteNotification: (id) {
            setState(() {
              _notifications.removeWhere((n) => n.id == id);
            });
          },
          onClearAll: () {
            setState(() {
              _notifications.clear();
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  
  List<CalendarEvent> _getSampleEvents() {
    final now = DateTime.now();
    return [
      CalendarEvent(
        id: '1',
        title: 'Critical Fund Review',
        date: now,
        type: EventType.review,
        description: 'Emergency review of fund allocation discrepancies',
      ),
      CalendarEvent(
        id: '2',
        title: 'Compliance Deadline',
        date: now.add(const Duration(days: 1)),
        type: EventType.deadline,
        description: 'Final compliance report submission',
      ),
      CalendarEvent(
        id: '3',
        title: 'Audit Meeting',
        date: now.add(const Duration(days: 3)),
        type: EventType.meeting,
        description: 'Quarterly audit with all stakeholders',
      ),
      CalendarEvent(
        id: '4',
        title: 'Fund Transfer',
        date: now.add(const Duration(days: 5)),
        type: EventType.funds,
        description: 'Multi-state fund transfer execution',
      ),
      CalendarEvent(
        id: '5',
        title: 'Major Milestone',
        date: now.add(const Duration(days: 7)),
        type: EventType.milestone,
        description: 'National project phase completion',
      ),
    ];
  }

  Widget _buildKpiSection() {
    return Padding(
      padding: ResponsiveLayout.getResponsivePadding(context),
      child: GridView.count(
        crossAxisCount: ResponsiveLayout.getKpiGridColumns(context),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: ResponsiveLayout.getResponsiveSpacing(context),
        crossAxisSpacing: ResponsiveLayout.getResponsiveSpacing(context),
        childAspectRatio: ResponsiveLayout.getKpiAspectRatio(context),
        children: [
          DashboardKpiCard(
            label: 'Total States',
            value: '${_kpiData['totalStates']}',
            icon: Icons.location_city,
            color: AppDesignSystem.deepIndigo,
          ),
          DashboardKpiCard(
            label: 'Active Alerts',
            value: '${_kpiData['activeAlerts']}',
            icon: Icons.warning_amber,
            color: AppDesignSystem.sunsetOrange,
            onTap: () {
              setState(() => _selectedIndex = 1);
            },
          ),
          DashboardKpiCard(
            label: 'Funds In Transit',
            value: '₹${(_kpiData['fundsInTransit'] as double).toStringAsFixed(0)}Cr',
            icon: Icons.swap_horiz,
            color: AppDesignSystem.vibrantTeal,
          ),
          DashboardKpiCard(
            label: 'Compliance Score',
            value: '${(_kpiData['complianceScore'] as double).toStringAsFixed(1)}%',
            icon: Icons.verified,
            color: AppDesignSystem.forestGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewPage() {
    return SingleChildScrollView(
      padding: ResponsiveLayout.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiSection(),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) * 2),
          const DashboardSectionHeader(
            title: 'Fund Flow Monitoring',
            subtitle: 'Real-time tracking of fund movements across states',
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
          SizedBox(
            height: ResponsiveLayout.getChartHeight(context),
            child: const ProjectFundFlowWidget(
              title: 'Step-by-Step Fund Flow Tracker',
            ),
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) * 2),
          const DashboardSectionHeader(
            title: 'Dual-Entry Reconciliation Ledger',
            subtitle: 'Instant reconciliation of PFMS vs Bank statements',
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
          SizedBox(
            height: ResponsiveLayout.getChartHeight(context),
            child: const DualEntryReconciliationWidget(
              showDetailsPanel: false, // Compact view for dashboard integration
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPage() {
    return const AlertsMonitoringWidget();
  }

  Widget _buildCompliancePage() {
    return const ComplianceMonitoringWidget();
  }

  Widget _buildEvidencePage() {
    return const EvidenceManagementWidget();
  }

  Widget _buildIntelligencePage() {
    return const ProjectIntelligenceWidget();
  }

  Widget _buildReportsPage() {
    return const ReportsAnalyticsWidget();
  }

  Widget _buildHorizontalCalendarStrip() {
    final events = _getSampleEvents();
    final startDate = DateTime.now().subtract(const Duration(days: 3));
    
    return Container(
      height: ResponsiveLayout.valueByDevice(
        context: context,
        mobile: 100,
        mobileWide: 110,
        tablet: 120,
        desktop: 120,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppDesignSystem.deepIndigo.withValues(alpha: 0.1),
            AppDesignSystem.vibrantTeal.withValues(alpha: 0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: const Border(
          bottom: BorderSide(
            color: AppDesignSystem.neutral300,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final isToday = DateTime.now().day == date.day &&
              DateTime.now().month == date.month &&
              DateTime.now().year == date.year;
          final isSelected = _selectedDate.day == date.day &&
              _selectedDate.month == date.month &&
              _selectedDate.year == date.year;
          final dayEvents = events.where((e) =>
              e.date.day == date.day &&
              e.date.month == date.month &&
              e.date.year == date.year).toList();
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppDesignSystem.vibrantTeal
                    : isToday
                        ? AppDesignSystem.deepIndigo.withValues(alpha: 0.1)
                        : Colors.transparent,
                borderRadius: AppDesignSystem.radiusMedium,
                border: Border.all(
                  color: isToday
                      ? AppDesignSystem.deepIndigo
                      : AppDesignSystem.neutral300,
                  width: isToday ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7],
                    style: AppDesignSystem.labelSmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppDesignSystem.neutral600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: AppDesignSystem.headlineMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? AppDesignSystem.deepIndigo
                              : AppDesignSystem.neutral900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (dayEvents.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: dayEvents.take(3).map((event) {
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: _getEventColor(event.type),
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.funds:
        return AppDesignSystem.info;
      case EventType.milestone:
        return AppDesignSystem.success;
      case EventType.deadline:
        return AppDesignSystem.error;
      case EventType.review:
        return AppDesignSystem.warning;
      case EventType.meeting:
        return AppDesignSystem.vibrantTeal;
      case EventType.other:
        return AppDesignSystem.neutral500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildOverviewPage(),
      _buildAlertsPage(),
      _buildCompliancePage(),
      _buildEvidencePage(),
      _buildIntelligencePage(),
      _buildReportsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppDesignSystem.sunsetOrange,
                AppDesignSystem.error,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Overwatch Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: _showNotificationPanel,
              ),
              if (_notifications.where((n) => !n.isRead).isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppDesignSystem.error, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        '${_notifications.where((n) => !n.isRead).length}',
                        style: const TextStyle(
                          color: AppDesignSystem.error,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          pages[_selectedIndex],
          const EventCalendarWidget(),
          const DashboardSwitcherWidget(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning_amber),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_outlined),
            selectedIcon: Icon(Icons.verified),
            label: 'Compliance',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: 'Evidence',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: 'Intelligence',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}