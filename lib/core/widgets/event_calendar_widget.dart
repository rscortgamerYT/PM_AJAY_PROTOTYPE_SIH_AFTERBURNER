import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_design_system.dart';
import '../utils/responsive_layout.dart';

/// Event model for calendar
class Event {
  final String id;
  final String name;
  final int date; // Day of month (1-31)
  final String icon; // URL or asset path
  final Color color;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.icon,
    required this.color,
  });
}

/// Event Calendar Widget with floating button
class EventCalendarWidget extends StatefulWidget {
  const EventCalendarWidget({super.key});

  @override
  State<EventCalendarWidget> createState() => _EventCalendarWidgetState();
}

class _EventCalendarWidgetState extends State<EventCalendarWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  DateTime _currentMonth = DateTime.now();
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppDesignSystem.durationNormal,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCalendar() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
      );
    });
  }

  void _showAddEventDialog() {
    final nameController = TextEditingController();
    final dateController = TextEditingController();
    final iconController = TextEditingController();
    Color selectedColor = AppDesignSystem.deepIndigo;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add New Event',
            style: AppDesignSystem.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Event Name', style: AppDesignSystem.labelMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Event Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Enter Only Date', style: AppDesignSystem.labelMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: dateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Ex - 12',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Icon (emoji or text)', style: AppDesignSystem.labelMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: iconController,
                  decoration: const InputDecoration(
                    hintText: '📅',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Color', style: AppDesignSystem.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    AppDesignSystem.deepIndigo,
                    AppDesignSystem.vibrantTeal,
                    AppDesignSystem.success,
                    AppDesignSystem.error,
                    AppDesignSystem.warning,
                    AppDesignSystem.coral,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selectedColor == color
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    dateController.text.isNotEmpty &&
                    iconController.text.isNotEmpty) {
                  final date = int.tryParse(dateController.text);
                  if (date != null && date >= 1 && date <= 31) {
                    setState(() {
                      _events.add(Event(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        date: date,
                        icon: iconController.text,
                        color: selectedColor,
                      ));
                    });
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeEvent(String id) {
    setState(() {
      _events.removeWhere((event) => event.id == id);
    });
  }

  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    
    // Get the first day of the week containing the first day of the month
    final startDay = firstDay.subtract(Duration(days: firstDay.weekday % 7));
    
    // Get the last day of the week containing the last day of the month
    final endDay = lastDay.add(Duration(days: 6 - (lastDay.weekday % 7)));
    
    final days = <DateTime>[];
    for (var day = startDay; day.isBefore(endDay.add(const Duration(days: 1))); day = day.add(const Duration(days: 1))) {
      days.add(day);
    }
    
    return days;
  }

  bool _isSameMonth(DateTime date) {
    return date.year == _currentMonth.year && date.month == _currentMonth.month;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  List<Event> _getEventsForDay(DateTime date) {
    return _events.where((event) => event.date == date.day && _isSameMonth(date)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Backdrop overlay
          if (_isExpanded)
            IgnorePointer(
              ignoring: false,
              child: GestureDetector(
                onTap: _toggleCalendar,
                child: AnimatedOpacity(
                  opacity: _isExpanded ? 1.0 : 0.0,
                  duration: AppDesignSystem.durationNormal,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),

          // Floating calendar button (middle right)
          Positioned(
            right: ResponsiveLayout.valueByDevice(
              context: context,
              mobile: 16,
              mobileWide: 20,
              tablet: 24,
              desktop: 24,
            ),
            top: MediaQuery.of(context).size.height / 2 - 28,
            child: AnimatedScale(
              scale: _isExpanded ? 0.0 : 1.0,
              duration: AppDesignSystem.durationFast,
              child: FloatingActionButton(
                onPressed: _toggleCalendar,
                backgroundColor: AppDesignSystem.deepIndigo,
                elevation: 8,
                child: const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Expanded calendar panel
          if (_isExpanded)
            Positioned(
              right: ResponsiveLayout.valueByDevice(
                context: context,
                mobile: 0,
                mobileWide: 20,
                tablet: 40,
                desktop: 40,
              ),
              top: ResponsiveLayout.valueByDevice(
                context: context,
                mobile: 0,
                mobileWide: 20,
                tablet: 40,
                desktop: 40,
              ),
              bottom: ResponsiveLayout.valueByDevice(
                context: context,
                mobile: 0,
                mobileWide: 20,
                tablet: 40,
                desktop: 40,
              ),
              left: ResponsiveLayout.isMobile(context) ? 0 : null,
              child: ScaleTransition(
                scale: _scaleAnimation,
                alignment: Alignment.centerRight,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Material(
                    elevation: 16,
                    borderRadius: ResponsiveLayout.isMobile(context)
                        ? BorderRadius.zero
                        : AppDesignSystem.radiusLarge,
                    child: Container(
                      width: ResponsiveLayout.isMobile(context)
                          ? MediaQuery.of(context).size.width
                          : 600,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: ResponsiveLayout.isMobile(context)
                            ? BorderRadius.zero
                            : AppDesignSystem.radiusLarge,
                      ),
                      child: Column(
                        children: [
                          _buildHeader(),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: _buildCalendarGrid(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ResponsiveLayout.isMobile(context)
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
            tooltip: 'Previous Month',
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
            tooltip: 'Next Month',
          ),
          const SizedBox(width: 16),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: AppDesignSystem.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _showAddEventDialog,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Event'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.deepIndigo,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _toggleCalendar,
            tooltip: 'Close Calendar',
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final days = _getDaysInMonth();
    final weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Container(
      decoration: BoxDecoration(
        color: AppDesignSystem.neutral200.withValues(alpha: 0.3),
        borderRadius: AppDesignSystem.radiusMedium,
      ),
      child: Column(
        children: [
          // Week day headers
          Row(
            children: weekDays.map((day) {
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: AppDesignSystem.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppDesignSystem.neutral600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          // Calendar days grid
          ...List.generate((days.length / 7).ceil(), (weekIndex) {
            final weekStart = weekIndex * 7;
            final weekEnd = (weekStart + 7).clamp(0, days.length);
            final weekDays = days.sublist(weekStart, weekEnd);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: weekDays.map((day) {
                return Expanded(
                  child: _buildDayCell(day),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isCurrentMonth = _isSameMonth(date);
    final isToday = _isToday(date);
    final events = _getEventsForDay(date);

    return TweenAnimationBuilder<double>(
      duration: AppDesignSystem.durationFast,
      tween: Tween(begin: 0.95, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minHeight: 100),
        decoration: BoxDecoration(
          color: isToday
              ? AppDesignSystem.vibrantTeal.withValues(alpha: 0.1)
              : isCurrentMonth
                  ? Colors.white
                  : AppDesignSystem.neutral200.withValues(alpha: 0.3),
          borderRadius: AppDesignSystem.radiusSmall,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date.day}',
              style: AppDesignSystem.bodySmall.copyWith(
                color: isToday
                    ? AppDesignSystem.deepIndigo
                    : (isCurrentMonth
                        ? AppDesignSystem.neutral900
                        : AppDesignSystem.neutral400),
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            ...events.map((event) => _buildEventChip(event)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventChip(Event event) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppDesignSystem.radiusSmall,
            border: Border.all(color: event.color, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.icon,
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.name,
                  style: AppDesignSystem.labelSmall.copyWith(
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => _removeEvent(event.id),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: AppDesignSystem.neutral600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}