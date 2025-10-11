import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/centre_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/state_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/agency_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/overwatch_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/new_overwatch_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/public_dashboard_page.dart';
import '../../features/communication/presentation/pages/communication_hub_page.dart';
import '../../features/public_portal/presentation/pages/public_portal_page.dart';
import '../../features/review_approval/presentation/pages/review_approval_page.dart';
import '../../features/dashboard/presentation/pages/widget_test_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String centreDashboard = '/centre-dashboard';
  static const String stateDashboard = '/state-dashboard';
  static const String agencyDashboard = '/agency-dashboard';
  static const String overwatchDashboard = '/overwatch-dashboard';
  static const String newOverwatchDashboard = '/new-overwatch-dashboard';
  static const String publicDashboard = '/public-dashboard';
  static const String communicationHub = '/communication-hub';
  static const String publicPortal = '/public-portal';
  static const String reviewApproval = '/review-approval';
  static const String widgetTest = '/widget-test';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case centreDashboard:
        return MaterialPageRoute(builder: (_) => const CentreDashboardPage());
      case stateDashboard:
        return MaterialPageRoute(builder: (_) => const StateDashboardPage());
      case agencyDashboard:
        return MaterialPageRoute(builder: (_) => const AgencyDashboardPage());
      case overwatchDashboard:
        return MaterialPageRoute(builder: (_) => const OverwatchDashboardPage());
      case newOverwatchDashboard:
        return MaterialPageRoute(builder: (_) => const NewOverwatchDashboardPage());
      case publicDashboard:
        return MaterialPageRoute(builder: (_) => const PublicDashboardPage());
      case communicationHub:
        return MaterialPageRoute(builder: (_) => const CommunicationHubPage());
      case publicPortal:
        return MaterialPageRoute(builder: (_) => const PublicPortalPage());
      case reviewApproval:
        return MaterialPageRoute(builder: (_) => const ReviewApprovalPage());
      case widgetTest:
        return MaterialPageRoute(builder: (_) => const WidgetTestPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}