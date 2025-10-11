// Add this route to your main.dart file's routing configuration

import 'package:flutter/material.dart';
import 'features/dashboard/presentation/pages/new_overwatch_dashboard_page.dart';

// Example route configuration:
// In your MaterialApp or router configuration, add:

/*
'/new-overwatch-dashboard': (context) => const NewOverwatchDashboardPage(),
*/

// Or if using GoRouter or similar:
/*
GoRoute(
  path: '/new-overwatch-dashboard',
  builder: (context, state) => const NewOverwatchDashboardPage(),
),
*/

// The new Overwatch dashboard is now accessible at the route above.
// It includes:
// - Project selector with search and filtering
// - Interactive fund flow Sankey diagram with detailed node information
// - Project carousel with status indicators and progress tracking
// - Key metrics dashboard with real-time statistics
// - Tabbed navigation for different views (Fund Flow, Projects, Maps, Reports)
// - Flagging and reporting system for issue tracking

// All components use mock data from OverwatchMockData.
// To integrate with Supabase:
// 1. Create corresponding tables in Supabase for projects and fund flows
// 2. Replace mock data calls with Supabase queries
// 3. Add real-time subscriptions for live updates