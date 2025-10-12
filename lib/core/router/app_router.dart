import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

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
        return _createAuthGuardedRoute(const CentreDashboardPage(), 'centre');
      case stateDashboard:
        return _createAuthGuardedRoute(const StateDashboardPage(), 'state');
      case agencyDashboard:
        return _createAuthGuardedRoute(const AgencyDashboardPage(), 'agency');
      case overwatchDashboard:
        return _createAuthGuardedRoute(const OverwatchDashboardPage(), 'overwatch');
      case newOverwatchDashboard:
        return _createAuthGuardedRoute(const NewOverwatchDashboardPage(), 'overwatch');
      case publicDashboard:
        return _createAuthGuardedRoute(const PublicDashboardPage(), 'public');
      case communicationHub:
        return _createAuthGuardedRoute(const CommunicationHubPage(), null);
      case publicPortal:
        return MaterialPageRoute(builder: (_) => const PublicPortalPage());
      case reviewApproval:
        return _createAuthGuardedRoute(const ReviewApprovalPage(), null);
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

  static MaterialPageRoute _createAuthGuardedRoute(Widget page, String? requiredRole) {
    return MaterialPageRoute(
      builder: (context) => AuthGuard(
        child: page,
        requiredRole: requiredRole,
      ),
    );
  }
}

class AuthGuard extends ConsumerWidget {
  final Widget child;
  final String? requiredRole;

  const AuthGuard({
    Key? key,
    required this.child,
    this.requiredRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    if (!authState.isAuthenticated || authState.user == null) {
      // Not authenticated, redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Check role if required
    if (requiredRole != null) {
      final userRole = _mapUserRoleToString(authState.user!.role);
      
      if (userRole != requiredRole) {
        // Wrong role, redirect to appropriate dashboard based on user's actual role
        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (authState.user!.role) {
            case UserRole.centreAdmin:
              Navigator.of(context).pushReplacementNamed(AppRouter.centreDashboard);
              break;
            case UserRole.stateOfficer:
              Navigator.of(context).pushReplacementNamed(AppRouter.stateDashboard);
              break;
            case UserRole.agencyUser:
              Navigator.of(context).pushReplacementNamed(AppRouter.agencyDashboard);
              break;
            case UserRole.overwatch:
              Navigator.of(context).pushReplacementNamed(AppRouter.newOverwatchDashboard);
              break;
            case UserRole.public:
              Navigator.of(context).pushReplacementNamed(AppRouter.publicDashboard);
              break;
            default:
              Navigator.of(context).pushReplacementNamed(AppRouter.login);
          }
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    }

    // Authenticated and authorized, show the page
    return child;
  }

  String _mapUserRoleToString(UserRole role) {
    switch (role) {
      case UserRole.centreAdmin:
        return 'centre';
      case UserRole.stateOfficer:
        return 'state';
      case UserRole.agencyUser:
        return 'agency';
      case UserRole.overwatch:
        return 'overwatch';
      case UserRole.public:
        return 'public';
      default:
        return '';
    }
  }
}