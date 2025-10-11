import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../theme/app_design_system.dart';

/// A floating widget that allows quick switching between different dashboards
/// for testing and development purposes.
class DashboardSwitcherWidget extends StatelessWidget {
  const DashboardSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton.extended(
        onPressed: () => _showDashboardSwitcher(context),
        backgroundColor: AppDesignSystem.deepIndigo,
        icon: const Icon(Icons.dashboard, color: Colors.white),
        label: const Text(
          'Switch Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showDashboardSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, color: AppDesignSystem.deepIndigo, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Switch Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppDesignSystem.deepIndigo,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildDashboardTile(
                      context,
                      icon: Icons.visibility,
                      title: 'Overwatch Dashboard',
                      subtitle: 'Comprehensive monitoring and analytics',
                      route: AppRouter.newOverwatchDashboard,
                      color: Colors.blue,
                    ),
                    _buildDashboardTile(
                      context,
                      icon: Icons.account_balance,
                      title: 'Centre Dashboard',
                      subtitle: 'Central government view',
                      route: AppRouter.centreDashboard,
                      color: Colors.purple,
                    ),
                    _buildDashboardTile(
                      context,
                      icon: Icons.location_city,
                      title: 'State Dashboard',
                      subtitle: 'State-level project monitoring',
                      route: AppRouter.stateDashboard,
                      color: Colors.green,
                    ),
                    _buildDashboardTile(
                      context,
                      icon: Icons.business,
                      title: 'Agency Dashboard',
                      subtitle: 'Agency-specific project tracking',
                      route: AppRouter.agencyDashboard,
                      color: Colors.orange,
                    ),
                    _buildDashboardTile(
                      context,
                      icon: Icons.public,
                      title: 'Public Dashboard',
                      subtitle: 'Citizen-facing information portal',
                      route: AppRouter.publicDashboard,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Color color,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isActive = currentRoute == route;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isActive ? color : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: isActive
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: isActive
            ? null
            : () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, route);
              },
      ),
    );
  }
}

/// A wrapper widget that adds the dashboard switcher to any page.
/// Use this to wrap your dashboard scaffold content.
class DashboardWithSwitcher extends StatelessWidget {
  final Widget child;
  final bool showSwitcher;

  const DashboardWithSwitcher({
    super.key,
    required this.child,
    this.showSwitcher = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showSwitcher) {
      return child;
    }

    return Stack(
      children: [
        child,
        const DashboardSwitcherWidget(),
      ],
    );
  }
}