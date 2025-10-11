import 'package:flutter/material.dart';
import '../theme/app_design_system.dart';
import '../utils/responsive_layout.dart';
import 'calendar_widget.dart';

class FloatingCalendarWidget extends StatefulWidget {
  final List<CalendarEvent> events;
  final String title;
  final Color primaryColor;
  final Color secondaryColor;
  final VoidCallback? onEventTap;

  const FloatingCalendarWidget({
    super.key,
    required this.events,
    this.title = 'Calendar',
    this.primaryColor = const Color(0xFF4F46E5),
    this.secondaryColor = const Color(0xFF06B6D4),
    this.onEventTap,
  });

  @override
  State<FloatingCalendarWidget> createState() => _FloatingCalendarWidgetState();
}

class _FloatingCalendarWidgetState extends State<FloatingCalendarWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppDesignSystem.durationNormal,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppDesignSystem.curveStandard,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppDesignSystem.curveStandard,
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop overlay
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleCalendar,
            child: AnimatedOpacity(
              opacity: _isExpanded ? 1.0 : 0.0,
              duration: AppDesignSystem.durationNormal,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),

        // Floating calendar button
        Positioned(
          right: ResponsiveLayout.valueByDevice(
            context: context,
            mobile: 12,
            mobileWide: 16,
            tablet: 20,
            desktop: 20,
          ),
          bottom: ResponsiveLayout.valueByDevice(
            context: context,
            mobile: 70,
            mobileWide: 75,
            tablet: 80,
            desktop: 80,
          ),
          child: AnimatedScale(
            scale: _isExpanded ? 0.0 : 1.0,
            duration: AppDesignSystem.durationFast,
            child: FloatingActionButton(
              onPressed: _toggleCalendar,
              backgroundColor: widget.primaryColor,
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
              mobileWide: 12,
              tablet: 20,
              desktop: 20,
            ),
            bottom: ResponsiveLayout.valueByDevice(
              context: context,
              mobile: 0,
              mobileWide: 12,
              tablet: 20,
              desktop: 20,
            ),
            left: ResponsiveLayout.isMobile(context) ? 0 : null,
            top: ResponsiveLayout.isMobile(context) ? 0 : null,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: ResponsiveLayout.isMobile(context)
                  ? Alignment.center
                  : Alignment.bottomRight,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Material(
                    elevation: 16,
                    borderRadius: ResponsiveLayout.isMobile(context)
                        ? BorderRadius.zero
                        : AppDesignSystem.radiusLarge,
                    shadowColor: Colors.black.withValues(alpha: 0.3),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                        maxHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Container(
                        width: ResponsiveLayout.getCalendarWidth(context),
                        height: ResponsiveLayout.getCalendarHeight(context),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: ResponsiveLayout.isMobile(context)
                              ? BorderRadius.zero
                              : AppDesignSystem.radiusLarge,
                          border: ResponsiveLayout.isMobile(context)
                              ? null
                              : Border.all(
                                  color: AppDesignSystem.neutral300,
                                  width: 1,
                                ),
                        ),
                        child: Column(
                          children: [
                            // Header
                            Container(
                              padding: EdgeInsets.all(
                                ResponsiveLayout.valueByDevice(
                                  context: context,
                                  mobile: 12,
                                  mobileWide: 14,
                                  tablet: 16,
                                  desktop: 16,
                                ),
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    widget.primaryColor,
                                    widget.secondaryColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: ResponsiveLayout.isMobile(context)
                                    ? BorderRadius.zero
                                    : const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                      ResponsiveLayout.valueByDevice(
                                        context: context,
                                        mobile: 6,
                                        mobileWide: 7,
                                        tablet: 8,
                                        desktop: 8,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.event_note,
                                      color: Colors.white,
                                      size: ResponsiveLayout.valueByDevice(
                                        context: context,
                                        mobile: 20,
                                        mobileWide: 22,
                                        tablet: 24,
                                        desktop: 24,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: ResponsiveLayout.getResponsiveSpacing(context)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          widget.title,
                                          style: ResponsiveLayout.getResponsiveTitle(context).copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${widget.events.length} events',
                                          style: AppDesignSystem.labelSmall.copyWith(
                                            color: Colors.white.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    iconSize: ResponsiveLayout.valueByDevice(
                                      context: context,
                                      mobile: 20,
                                      mobileWide: 22,
                                      tablet: 24,
                                      desktop: 24,
                                    ),
                                    onPressed: _toggleCalendar,
                                    tooltip: 'Close Calendar',
                                  ),
                                ],
                              ),
                            ),

                            // Calendar content
                            Expanded(
                              child: PMCalendarWidget(
                              events: widget.events,
                              onEventTap: (event) {
                                widget.onEventTap?.call();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          _getEventIcon(event.type),
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(event.title),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: _getEventColor(event.type),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.funds:
        return Icons.account_balance_wallet;
      case EventType.milestone:
        return Icons.flag;
      case EventType.deadline:
        return Icons.access_time;
      case EventType.review:
        return Icons.rate_review;
      case EventType.meeting:
        return Icons.people;
      case EventType.other:
        return Icons.event;
    }
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
}