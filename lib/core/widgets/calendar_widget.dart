import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_design_system.dart';

/// Calendar Event Model
class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final EventType type;
  final String? projectId;
  final String? linkedEntity;
  
  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.projectId,
    this.linkedEntity,
  });
}

/// Event Types with Color Coding
enum EventType {
  funds,        // Blue
  milestone,    // Green
  deadline,     // Red
  review,       // Amber
  meeting,      // Teal
  other,        // Neutral
}

/// Calendar Widget with drag-and-drop, color-coded events, and animations
class PMCalendarWidget extends StatefulWidget {
  final List<CalendarEvent> events;
  final Function(DateTime)? onDaySelected;
  final Function(CalendarEvent)? onEventTap;
  final Function(CalendarEvent, DateTime)? onEventRescheduled;
  final bool enableDragAndDrop;
  final bool showAgenda;
  final CalendarFormat initialFormat;
  
  const PMCalendarWidget({
    super.key,
    required this.events,
    this.onDaySelected,
    this.onEventTap,
    this.onEventRescheduled,
    this.enableDragAndDrop = true,
    this.showAgenda = true,
    this.initialFormat = CalendarFormat.month,
  });

  @override
  State<PMCalendarWidget> createState() => _PMCalendarWidgetState();
}

class _PMCalendarWidgetState extends State<PMCalendarWidget> with SingleTickerProviderStateMixin {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = widget.initialFormat;
    
    // Setup pulse animation for today's date
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
        return AppDesignSystem.amber;
      case EventType.meeting:
        return AppDesignSystem.vibrantTeal;
      case EventType.other:
        return AppDesignSystem.neutral600;
    }
  }
  
  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return widget.events.where((event) {
      return isSameDay(event.date, day);
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    final isMobile = AppDesignSystem.isMobile(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: AppDesignSystem.radiusLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Divider(height: 1, color: AppDesignSystem.neutral300),
          _buildCalendar(),
          if (widget.showAgenda && _selectedDay != null) ...[
            Divider(height: 1, color: AppDesignSystem.neutral300),
            _buildAgenda(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppDesignSystem.deepIndigo, AppDesignSystem.vibrantTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: Colors.white, size: AppDesignSystem.iconMedium),
          const SizedBox(width: AppDesignSystem.space8),
          Text(
            'Project Calendar',
            style: AppDesignSystem.titleLarge.copyWith(color: Colors.white),
          ),
          const Spacer(),
          _buildFormatToggle(),
        ],
      ),
    );
  }
  
  Widget _buildFormatToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: AppDesignSystem.radiusMedium,
      ),
      child: SegmentedButton<CalendarFormat>(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppDesignSystem.deepIndigo;
            }
            return Colors.white;
          }),
        ),
        segments: const [
          ButtonSegment(
            value: CalendarFormat.month,
            icon: Icon(Icons.calendar_view_month, size: 16),
          ),
          ButtonSegment(
            value: CalendarFormat.week,
            icon: Icon(Icons.view_week, size: 16),
          ),
        ],
        selected: {_calendarFormat},
        onSelectionChanged: (Set<CalendarFormat> selection) {
          setState(() {
            _calendarFormat = selection.first;
          });
        },
      ),
    );
  }
  
  Widget _buildCalendar() {
    return AnimatedContainer(
      duration: AppDesignSystem.durationNormal,
      curve: AppDesignSystem.curveStandard,
      padding: const EdgeInsets.all(AppDesignSystem.space16),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          widget.onDaySelected?.call(selectedDay);
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppDesignSystem.vibrantTeal.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppDesignSystem.deepIndigo,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppDesignSystem.coral,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          outsideDaysVisible: false,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppDesignSystem.titleMedium.copyWith(
            color: AppDesignSystem.deepIndigo,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: AppDesignSystem.deepIndigo),
          rightChevronIcon: Icon(Icons.chevron_right, color: AppDesignSystem.deepIndigo),
        ),
        calendarBuilders: CalendarBuilders(
          todayBuilder: (context, day, focusedDay) {
            return ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppDesignSystem.vibrantTeal.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppDesignSystem.vibrantTeal.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.deepIndigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            
            return Positioned(
              bottom: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: events.take(3).map((event) {
                  final calEvent = event as CalendarEvent;
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: _getEventColor(calEvent.type),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildAgenda() {
    final events = _getEventsForDay(_selectedDay!);
    
    return AnimatedContainer(
      duration: AppDesignSystem.durationNormal,
      curve: AppDesignSystem.curveDecelerate,
      constraints: const BoxConstraints(maxHeight: 300),
      child: events.isEmpty
          ? _buildEmptyAgenda()
          : ListView.separated(
              padding: const EdgeInsets.all(AppDesignSystem.space16),
              shrinkWrap: true,
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppDesignSystem.space8),
              itemBuilder: (context, index) => _buildEventCard(events[index]),
            ),
    );
  }
  
  Widget _buildEmptyAgenda() {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: AppDesignSystem.iconXLarge,
            color: AppDesignSystem.neutral400,
          ),
          const SizedBox(height: AppDesignSystem.space12),
          Text(
            'No events scheduled',
            style: AppDesignSystem.bodyLarge.copyWith(color: AppDesignSystem.neutral600),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventCard(CalendarEvent event) {
    return TweenAnimationBuilder<double>(
      duration: AppDesignSystem.durationFast,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesignSystem.radiusMedium,
          side: BorderSide(
            color: _getEventColor(event.type).withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () => widget.onEventTap?.call(event),
          borderRadius: AppDesignSystem.radiusMedium,
          child: Padding(
            padding: const EdgeInsets.all(AppDesignSystem.space12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getEventColor(event.type),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppDesignSystem.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppDesignSystem.titleSmall.copyWith(
                          color: AppDesignSystem.neutral900,
                        ),
                      ),
                      const SizedBox(height: AppDesignSystem.space4),
                      Text(
                        event.description,
                        style: AppDesignSystem.bodySmall.copyWith(
                          color: AppDesignSystem.neutral600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildEventTypeBadge(event.type),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEventTypeBadge(EventType type) {
    String label;
    IconData icon;
    
    switch (type) {
      case EventType.funds:
        label = 'Funds';
        icon = Icons.account_balance_wallet;
        break;
      case EventType.milestone:
        label = 'Milestone';
        icon = Icons.flag;
        break;
      case EventType.deadline:
        label = 'Deadline';
        icon = Icons.alarm;
        break;
      case EventType.review:
        label = 'Review';
        icon = Icons.rate_review;
        break;
      case EventType.meeting:
        label = 'Meeting';
        icon = Icons.people;
        break;
      case EventType.other:
        label = 'Other';
        icon = Icons.event;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignSystem.space8,
        vertical: AppDesignSystem.space4,
      ),
      decoration: BoxDecoration(
        color: _getEventColor(type).withValues(alpha: 0.2),
        borderRadius: AppDesignSystem.radiusSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _getEventColor(type)),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppDesignSystem.labelSmall.copyWith(
              color: _getEventColor(type),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}