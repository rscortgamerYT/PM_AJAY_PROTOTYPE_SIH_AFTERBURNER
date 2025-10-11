import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';

class DashboardNavigation {
  /// Navigate to the new Overwatch Dashboard
  static void navigateToNewOverwatchDashboard(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.newOverwatchDashboard);
  }

  /// Navigate to the original Overwatch Dashboard
  static void navigateToOverwatchDashboard(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.overwatchDashboard);
  }

  /// Navigate to Centre Dashboard
  static void navigateToCentreDashboard(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.centreDashboard);
  }

  /// Navigate to State Dashboard
  static void navigateToStateDashboard(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.stateDashboard);
  }

  /// Navigate to Agency Dashboard
  static void navigateToAgencyDashboard(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.agencyDashboard);
  }

  /// Navigate to Public Dashboard
  static void navigateToPublicDashboard(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.publicDashboard);
  }
}