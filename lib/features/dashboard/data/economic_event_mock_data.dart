import '../models/economic_event_model.dart';

/// Mock data generator for economic events
class EconomicEventMockData {
  static List<EconomicEvent> generateMockEvents() {
    return [
      const EconomicEvent(
        countryCode: "US",
        time: "21:30",
        eventName: "15-Year Mortgage Rate",
        actual: "10:59",
        forecast: null,
        prior: "5.49%",
        impact: EventImpact.medium,
      ),
      const EconomicEvent(
        countryCode: "US",
        time: "21:30",
        eventName: "30-Year Mortgage Rate",
        actual: "10:59",
        forecast: null,
        prior: "6.3%",
        impact: EventImpact.high,
      ),
      const EconomicEvent(
        countryCode: "EU",
        time: "22:30",
        eventName: "ECB Guindos Speech",
        actual: null,
        forecast: null,
        prior: null,
        impact: EventImpact.low,
      ),
      const EconomicEvent(
        countryCode: "CA",
        time: "23:10",
        eventName: "BoC Mendes Speech",
        actual: null,
        forecast: null,
        prior: null,
        impact: EventImpact.low,
      ),
      const EconomicEvent(
        countryCode: "JP",
        time: "23:50",
        eventName: "BoJ Core CPI y/y",
        actual: "2.8%",
        forecast: "2.9%",
        prior: "3.1%",
        impact: EventImpact.high,
      ),
      const EconomicEvent(
        countryCode: "AU",
        time: "01:00",
        eventName: "RBA Financial Stability Review",
        actual: null,
        forecast: null,
        prior: null,
        impact: EventImpact.medium,
      ),
      const EconomicEvent(
        countryCode: "IN",
        time: "09:30",
        eventName: "RBI Interest Rate Decision",
        actual: "6.5%",
        forecast: "6.5%",
        prior: "6.5%",
        impact: EventImpact.high,
      ),
      const EconomicEvent(
        countryCode: "GB",
        time: "14:00",
        eventName: "BoE Governor Bailey Speech",
        actual: null,
        forecast: null,
        prior: null,
        impact: EventImpact.medium,
      ),
    ];
  }
}