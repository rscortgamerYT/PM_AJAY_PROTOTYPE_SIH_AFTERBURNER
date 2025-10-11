import 'package:flutter/material.dart';
import '../../../models/economic_event_model.dart';
import '../../../../../core/theme/app_design_system.dart';

/// Economic Calendar widget for displaying economic events
class EconomicCalendarWidget extends StatefulWidget {
  final String title;
  final List<EconomicEvent> events;

  const EconomicCalendarWidget({
    super.key,
    required this.title,
    required this.events,
  });

  @override
  State<EconomicCalendarWidget> createState() => _EconomicCalendarWidgetState();
}

class _EconomicCalendarWidgetState extends State<EconomicCalendarWidget>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollController.addListener(_updateScrollButtons);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollButtons();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (!mounted) return;
    setState(() {
      _canScrollLeft = _scrollController.hasClients && _scrollController.offset > 0;
      _canScrollRight = _scrollController.hasClients &&
          _scrollController.offset < _scrollController.position.maxScrollExtent - 1;
    });
  }

  void _scroll(bool left) {
    if (!_scrollController.hasClients) return;
    final scrollAmount = _scrollController.position.viewportDimension * 0.8;
    _scrollController.animateTo(
      _scrollController.offset + (left ? -scrollAmount : scrollAmount),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildEventsList(),
          const SizedBox(height: 12),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: AppDesignSystem.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: AppDesignSystem.neutral600,
              size: 20,
            ),
          ],
        ),
        Row(
          children: [
            if (_canScrollLeft)
              _buildScrollButton(Icons.chevron_left, () => _scroll(true)),
            if (_canScrollRight)
              _buildScrollButton(Icons.chevron_right, () => _scroll(false)),
            const SizedBox(width: 8),
            Icon(
              Icons.code,
              color: AppDesignSystem.neutral600,
              size: 24,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScrollButton(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: AppDesignSystem.neutral300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.events.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: _buildEventCard(widget.events[index]),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(EconomicEvent event) {
    return Container(
      width: 288,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppDesignSystem.neutral300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventHeader(event),
          const SizedBox(height: 12),
          _buildEventInfo(event),
          const SizedBox(height: 16),
          _buildEventMetrics(event),
        ],
      ),
    );
  }

  Widget _buildEventHeader(EconomicEvent event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Today',
              style: AppDesignSystem.labelSmall.copyWith(
                color: AppDesignSystem.neutral600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppDesignSystem.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                event.time,
                style: AppDesignSystem.labelSmall.copyWith(
                  color: AppDesignSystem.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        _buildVolatilityIcon(event.impact),
      ],
    );
  }

  Widget _buildVolatilityIcon(EventImpact impact) {
    final barCount = impact == EventImpact.high ? 3 : impact == EventImpact.medium ? 2 : 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (index) {
        final height = index == 0 ? 8.0 : index == 1 ? 12.0 : 16.0;
        final isActive = index < barCount;
        return Container(
          width: 4,
          height: height,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: isActive ? AppDesignSystem.neutral800 : AppDesignSystem.neutral300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildEventInfo(EconomicEvent event) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppDesignSystem.neutral200,
          ),
          child: ClipOval(
            child: Image.network(
              'https://flagcdn.com/w40/${event.countryCode.toLowerCase()}.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    event.countryCode,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            event.eventName,
            style: AppDesignSystem.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEventMetrics(EconomicEvent event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetric('Actual', event.actual ?? '—'),
        _buildMetric('Forecast', event.forecast ?? '—'),
        _buildMetric('Prior', event.prior ?? '—'),
      ],
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppDesignSystem.labelSmall.copyWith(
            color: AppDesignSystem.neutral600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppDesignSystem.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return InkWell(
      onTap: () {
        // Navigate to full calendar view
      },
      child: Text(
        'See all market events ›',
        style: AppDesignSystem.labelMedium.copyWith(
          color: AppDesignSystem.skyBlue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}