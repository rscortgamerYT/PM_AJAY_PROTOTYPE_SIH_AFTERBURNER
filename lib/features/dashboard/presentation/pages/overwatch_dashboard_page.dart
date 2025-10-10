import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/fund_flow_explorer_widget.dart';
import '../../../../core/widgets/calendar_widget.dart';
import '../../../../core/theme/app_design_system.dart';

class OverwatchDashboardPage extends ConsumerStatefulWidget {
  const OverwatchDashboardPage({super.key});

  @override
  ConsumerState<OverwatchDashboardPage> createState() => _OverwatchDashboardPageState();
}

class _OverwatchDashboardPageState extends ConsumerState<OverwatchDashboardPage> {
  DateTime _selectedDate = DateTime.now();
  
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

  Widget _buildHorizontalCalendarStrip() {
    final events = _getSampleEvents();
    final startDate = DateTime.now().subtract(const Duration(days: 3));
    
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppDesignSystem.deepIndigo.withValues(alpha: 0.1),
            AppDesignSystem.vibrantTeal.withValues(alpha: 0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overwatch Dashboard - Enhanced Fund Flow Explorer v2.0'),
        backgroundColor: AppTheme.overwatchColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // AI-powered search to be implemented
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHorizontalCalendarStrip(),
          Expanded(
            child: const FundFlowExplorerWidget(userId: 'overwatch_user'),
          ),
        ],
      ),
    );
  }
}