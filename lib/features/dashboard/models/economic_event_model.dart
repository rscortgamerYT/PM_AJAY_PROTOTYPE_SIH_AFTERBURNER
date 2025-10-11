import 'package:flutter/material.dart';

/// Impact level for economic events
enum EventImpact {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case EventImpact.low:
        return 'Low';
      case EventImpact.medium:
        return 'Medium';
      case EventImpact.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case EventImpact.low:
        return const Color(0xFF10B981);
      case EventImpact.medium:
        return const Color(0xFFF59E0B);
      case EventImpact.high:
        return const Color(0xFFEF4444);
    }
  }
}

/// Economic event model for calendar widget
class EconomicEvent {
  final String countryCode;
  final String time;
  final String eventName;
  final String? actual;
  final String? forecast;
  final String? prior;
  final EventImpact impact;

  const EconomicEvent({
    required this.countryCode,
    required this.time,
    required this.eventName,
    this.actual,
    this.forecast,
    this.prior,
    required this.impact,
  });

  factory EconomicEvent.fromJson(Map<String, dynamic> json) {
    return EconomicEvent(
      countryCode: json['country_code'] as String,
      time: json['time'] as String,
      eventName: json['event_name'] as String,
      actual: json['actual'] as String?,
      forecast: json['forecast'] as String?,
      prior: json['prior'] as String?,
      impact: EventImpact.values.firstWhere(
        (e) => e.name == json['impact'],
        orElse: () => EventImpact.medium,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country_code': countryCode,
      'time': time,
      'event_name': eventName,
      'actual': actual,
      'forecast': forecast,
      'prior': prior,
      'impact': impact.name,
    };
  }
}