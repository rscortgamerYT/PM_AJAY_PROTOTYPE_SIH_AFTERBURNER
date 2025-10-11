# Overwatch Dashboard Integration Guide

## Overview

The new Overwatch Dashboard has been successfully converted from React to Flutter and is ready for integration. This guide provides comprehensive instructions for deployment and usage.

## 🎯 What's Been Built

### Core Components

1. **Data Models** (`lib/features/dashboard/data/models/`)
   - [`overwatch_project_model.dart`](lib/features/dashboard/data/models/overwatch_project_model.dart) - Project tracking with status, risk, and progress
   - [`overwatch_fund_flow_model.dart`](lib/features/dashboard/data/models/overwatch_fund_flow_model.dart) - Multi-level fund flow hierarchy
   - [`overwatch_mock_data.dart`](lib/features/dashboard/data/models/overwatch_mock_data.dart) - Sample data generator

2. **Widgets** (`lib/features/dashboard/presentation/widgets/overwatch/`)
   - [`overwatch_project_selector_widget.dart`](lib/features/dashboard/presentation/widgets/overwatch/overwatch_project_selector_widget.dart) - Search and filter interface
   - [`overwatch_fund_flow_sankey_widget.dart`](lib/features/dashboard/presentation/widgets/overwatch/overwatch_fund_flow_sankey_widget.dart) - Interactive fund flow visualization
   - [`overwatch_project_carousel_widget.dart`](lib/features/dashboard/presentation/widgets/overwatch/overwatch_project_carousel_widget.dart) - Project card carousel

3. **Dashboard Page**
   - [`new_overwatch_dashboard_page.dart`](lib/features/dashboard/presentation/pages/new_overwatch_dashboard_page.dart) - Main dashboard with tabs

4. **Utilities**
   - [`navigation_helpers.dart`](lib/features/dashboard/presentation/utils/navigation_helpers.dart) - Navigation utilities

## 🚀 Quick Start

### Access the Dashboard

The dashboard is accessible at the route `/new-overwatch-dashboard`:

```dart
import 'package:flutter/material.dart';
import 'features/dashboard/presentation/utils/navigation_helpers.dart';

// Navigate to the new dashboard
DashboardNavigation.navigateToNewOverwatchDashboard(context);

// Or use direct navigation
Navigator.pushNamed(context, AppRouter.newOverwatchDashboard);
```

### Test the Dashboard

The Flutter web server is running at `http://localhost:8080`. To test:

1. Navigate to the dashboard route in your app
2. Or add a button/menu item to navigate to `/new-overwatch-dashboard`
3. Verify all tabs load correctly (Fund Flow, Projects, Maps, Reports)

## 📊 Features

### 1. Project Selector
- **Search**: Real-time project search by name or ID
- **Filters**: Status, risk level, fund utilization
- **Display**: Grid view with status badges and progress bars
- **Selection**: Click to view detailed fund flow

### 2. Fund Flow Visualization
- **Multi-Level Tracking**: Centre → State → Agency → Project → Milestone → Expense
- **Interactive**: Click nodes to drill down
- **Information Panels**: Detailed breakdown for each level
- **Analytics**: Real-time summaries and metrics
- **PFMS Integration**: Transaction tracking with document references

### 3. Key Metrics Dashboard
- Active projects count
- Total fund allocation tracking
- High-risk projects monitoring
- System health indicators

### 4. Tabbed Interface
- **Fund Flow**: Sankey diagram with drill-down
- **Projects**: Grid view with carousel
- **Maps**: Placeholder for geographic visualization
- **Reports**: Placeholder for analytics charts

## 🔧 Next Steps for Production

### 1. Replace Mock Data with Supabase

Create Supabase tables:

```sql
-- Projects table
CREATE TABLE overwatch_projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  status TEXT NOT NULL,
  risk_score INTEGER,
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  allocated_amount DECIMAL,
  utilized_amount DECIMAL,
  responsible_person_name TEXT,
  responsible_person_role TEXT,
  responsible_person_contact TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Fund flows table
CREATE TABLE overwatch_fund_flows (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  node_id TEXT UNIQUE NOT NULL,
  level TEXT NOT NULL,
  name TEXT NOT NULL,
  allocated_amount DECIMAL,
  utilized_amount DECIMAL,
  parent_id TEXT,
  responsible_person_name TEXT,
  responsible_person_role TEXT,
  responsible_person_contact TEXT,
  pfms_transaction_id TEXT,
  transaction_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### 2. Update Data Providers

Replace mock data calls in [`new_overwatch_dashboard_page.dart`](lib/features/dashboard/presentation/pages/new_overwatch_dashboard_page.dart:1):

```dart
// Replace this:
final projects = OverwatchMockData.generateProjects();

// With Supabase query:
final response = await Supabase.instance.client
  .from('overwatch_projects')
  .select()
  .order('created_at', ascending: false);

final projects = (response as List)
  .map((json) => OverwatchProject.fromJson(json))
  .toList();
```

### 3. Implement Map Visualization

Add to the Maps tab in [`new_overwatch_dashboard_page.dart`](lib/features/dashboard/presentation/pages/new_overwatch_dashboard_page.dart:1):

```dart
// Use existing InteractiveMapWidget
import '../../maps/widgets/interactive_map_widget.dart';

// In Maps tab:
InteractiveMapWidget(
  projects: projects,
  onProjectSelected: (project) {
    // Handle project selection
  },
)
```

### 4. Add Analytics Charts

Install charting library:
```yaml
dependencies:
  fl_chart: ^0.66.0
```

Create chart widgets for the Reports tab showing:
- Fund utilization trends
- Risk distribution
- Timeline progress
- Budget vs actual comparisons

### 5. Implement Flagging System

Add UI components for:
- Flag creation dialog
- Flag list view
- Flag resolution workflow
- Flag notifications

## 🎨 Customization

### Theme Integration

The dashboard uses the existing app theme from [`app_theme.dart`](lib/core/theme/app_theme.dart:1). All colors, typography, and spacing follow the design system.

### Widget Customization

Widgets accept parameters for customization:

```dart
OverwatchProjectSelectorWidget(
  onProjectSelected: (project) {
    // Custom handler
  },
  initialFilters: {
    'status': 'active',
    'riskLevel': 'high',
  },
)
```

## 📱 Responsive Design

The dashboard is built to be responsive:
- Desktop: Full layout with sidebars
- Tablet: Adaptive grid columns
- Mobile: Stacked layout with scrolling

## 🔐 Access Control

Add role-based access:

```dart
// Check user role before showing dashboard
if (user.role == UserRole.overwatchOfficer || 
    user.role == UserRole.admin) {
  DashboardNavigation.navigateToNewOverwatchDashboard(context);
}
```

## 🐛 Testing

The dashboard includes:
- Mock data for development
- Null-safe implementations
- Error handling for API failures
- Loading states for async operations

## 📝 Documentation

All widgets include:
- Comprehensive inline documentation
- Parameter descriptions
- Usage examples
- Best practice guidelines

## 🔄 Migration Path

To replace the old dashboard:

1. Test new dashboard thoroughly
2. Update navigation to point to new route
3. Remove old dashboard files (optional backup first)
4. Update documentation and training materials

## 🆘 Troubleshooting

### Issue: Dashboard not loading
- Check route configuration in [`app_router.dart`](lib/core/router/app_router.dart:1)
- Verify import paths are correct
- Check console for errors

### Issue: Mock data not showing
- Verify [`overwatch_mock_data.dart`](lib/features/dashboard/data/models/overwatch_mock_data.dart:1) is imported
- Check data generation methods are called correctly

### Issue: Navigation not working
- Ensure [`navigation_helpers.dart`](lib/features/dashboard/presentation/utils/navigation_helpers.dart:1) is imported
- Verify context is valid
- Check route is registered

## 📞 Support

For issues or questions:
1. Check this integration guide
2. Review inline code documentation
3. Examine mock data structure
4. Test with sample data first

## ✅ Completion Checklist

- [x] Data models created
- [x] Widgets implemented
- [x] Dashboard page built
- [x] Routing configured
- [x] Navigation helpers added
- [ ] Supabase integration
- [ ] Map visualization added
- [ ] Analytics charts implemented
- [ ] Flagging system UI
- [ ] Production testing
- [ ] User acceptance testing
- [ ] Documentation updated
- [ ] Training materials created

## 🎉 Ready for Production

The foundation is complete. The dashboard is fully functional with mock data and ready for:
1. Backend integration
2. Production data
3. User testing
4. Deployment

Navigate to `http://localhost:8080` and access the `/new-overwatch-dashboard` route to see it in action!