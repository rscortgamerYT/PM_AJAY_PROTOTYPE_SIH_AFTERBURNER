import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/national_heatmap_widget.dart';
import '../widgets/collaboration_network_widget.dart';
import '../widgets/compliance_scoreboard_widget.dart';
import '../widgets/national_performance_leaderboard_widget.dart';
import '../widgets/fund_flow_waterfall_widget.dart';
import '../widgets/predictive_analytics_widget.dart';
import '../widgets/request_review_panel_widget.dart';
import '../../../communication/presentation/pages/communication_hub_page.dart';
import '../../../../core/widgets/calendar_widget.dart';
import '../../../../core/theme/app_design_system.dart';

class CentreDashboardPage extends ConsumerStatefulWidget {
  const CentreDashboardPage({super.key});

  @override
  ConsumerState<CentreDashboardPage> createState() => _CentreDashboardPageState();
}

class _CentreDashboardPageState extends ConsumerState<CentreDashboardPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isCalendarExpanded = false;
  late AnimationController _calendarAnimationController;
  late Animation<double> _calendarAnimation;

  @override
  void initState() {
    super.initState();
    _calendarAnimationController = AnimationController(
      vsync: this,
      duration: AppDesignSystem.durationNormal,
    );
    _calendarAnimation = CurvedAnimation(
      parent: _calendarAnimationController,
      curve: AppDesignSystem.curveStandard,
    );
  }

  @override
  void dispose() {
    _calendarAnimationController.dispose();
    super.dispose();
  }

  void _toggleCalendar() {
    setState(() {
      _isCalendarExpanded = !_isCalendarExpanded;
      if (_isCalendarExpanded) {
        _calendarAnimationController.forward();
      } else {
        _calendarAnimationController.reverse();
      }
    });
  }

  List<CalendarEvent> _getSampleEvents() {
    final now = DateTime.now();
    return [
      CalendarEvent(
        id: '1',
        title: 'Budget Review Meeting',
        date: now,
        type: EventType.meeting,
        description: 'Quarterly budget review with finance team',
      ),
      CalendarEvent(
        id: '2',
        title: 'Fund Transfer Deadline',
        date: now.add(const Duration(days: 2)),
        type: EventType.deadline,
        description: 'Final date for Q4 fund transfers',
      ),
      CalendarEvent(
        id: '3',
        title: 'Project Milestone - Phase 2',
        date: now.add(const Duration(days: 5)),
        type: EventType.milestone,
        description: 'Infrastructure development phase 2 completion',
      ),
      CalendarEvent(
        id: '4',
        title: 'Compliance Audit',
        date: now.add(const Duration(days: 7)),
        type: EventType.review,
        description: 'Annual compliance audit scheduled',
      ),
      CalendarEvent(
        id: '5',
        title: 'New Fund Allocation',
        date: now.add(const Duration(days: 10)),
        type: EventType.funds,
        description: 'Allocation of new central funds to states',
      ),
    ];
  }

  Widget _buildNationalHeatmap() {
    return const NationalHeatmapWidget();
  }

  Widget _buildCollaborationNetwork() {
    return const CollaborationNetworkWidget();
  }

  Widget _buildComplianceScoreboard() {
    return const ComplianceScoreboardWidget();
  }

  Widget _buildPerformanceLeaderboard() {
    return const NationalPerformanceLeaderboardWidget();
  }

  Widget _buildFundFlowView() {
    return const FundFlowWaterfallWidget();
  }

  Widget _buildAnalyticsView() {
    return const PredictiveAnalyticsWidget();
  }

  Widget _buildCommunicationHub() {
    return const CommunicationHubPage();
  }

  Widget _buildRequestReviewPanel() {
    return const RequestReviewPanelWidget();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildNationalHeatmap(),
      _buildRequestReviewPanel(),
      _buildCollaborationNetwork(),
      _buildPerformanceLeaderboard(),
      _buildComplianceScoreboard(),
      _buildFundFlowView(),
      _buildAnalyticsView(),
      _buildCommunicationHub(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centre Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: AnimatedRotation(
              turns: _isCalendarExpanded ? 0.5 : 0,
              duration: AppDesignSystem.durationNormal,
              child: Icon(
                _isCalendarExpanded ? Icons.close : Icons.calendar_today,
                color: _isCalendarExpanded ? AppDesignSystem.vibrantTeal : null,
              ),
            ),
            onPressed: _toggleCalendar,
            tooltip: _isCalendarExpanded ? 'Close Calendar' : 'Open Calendar',
          ),
        ],
      ),
      body: Stack(
        children: [
          pages[_selectedIndex],
          // Expandable Calendar Overlay
          Positioned(
            top: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _calendarAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    MediaQuery.of(context).size.width * 0.35 * (1 - _calendarAnimation.value),
                    0,
                  ),
                  child: Opacity(
                    opacity: _calendarAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: AppDesignSystem.elevation4,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: _isCalendarExpanded
                    ? Column(
                        children: [
                          Container(
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
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.event_available,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Schedule',
                                  style: AppDesignSystem.headlineSmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: PMCalendarWidget(
                              events: _getSampleEvents(),
                              onEventTap: (event) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Selected: ${event.title}'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.approval_outlined),
            selectedIcon: Icon(Icons.approval),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            selectedIcon: Icon(Icons.hub),
            label: 'Network',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Leaderboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.rule_outlined),
            selectedIcon: Icon(Icons.rule),
            label: 'Compliance',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Funds',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}