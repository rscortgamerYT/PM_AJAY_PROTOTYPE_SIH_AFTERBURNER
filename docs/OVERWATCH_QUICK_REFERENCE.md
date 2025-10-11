# Overwatch Dashboard - Quick Reference

## 🚀 Quick Start

### Navigate to Dashboard
```dart
import 'package:your_app/features/dashboard/presentation/utils/navigation_helpers.dart';

// In your widget
DashboardNavigation.navigateToNewOverwatchDashboard(context);
```

### Direct Route
```dart
Navigator.pushNamed(context, '/new-overwatch-dashboard');
```

## 📁 File Structure

```
lib/features/dashboard/
├── data/models/
│   ├── overwatch_project_model.dart      # Project data model
│   ├── overwatch_fund_flow_model.dart    # Fund flow data model
│   └── overwatch_mock_data.dart          # Mock data generator
├── presentation/
│   ├── pages/
│   │   └── new_overwatch_dashboard_page.dart  # Main dashboard
│   ├── widgets/overwatch/
│   │   ├── overwatch_project_selector_widget.dart     # Project search/filter
│   │   ├── overwatch_fund_flow_sankey_widget.dart     # Fund flow viz
│   │   └── overwatch_project_carousel_widget.dart     # Project cards
│   └── utils/
│       └── navigation_helpers.dart       # Navigation utilities
```

## 🔧 Common Tasks

### Load Projects
```dart
final projects = OverwatchMockData.generateProjects();
// Or from Supabase:
final response = await Supabase.instance.client
  .from('overwatch_projects')
  .select();
```

### Load Fund Flow
```dart
final fundFlow = OverwatchMockData.generateFundFlow();
// Or from Supabase:
final response = await Supabase.instance.client
  .from('overwatch_fund_flows')
  .select();
```

### Filter Projects
```dart
final filteredProjects = projects.where((p) {
  if (statusFilter != null && p.status != statusFilter) return false;
  if (riskFilter != null && p.riskLevel != riskFilter) return false;
  if (searchQuery.isNotEmpty && 
      !p.name.toLowerCase().contains(searchQuery.toLowerCase())) {
    return false;
  }
  return true;
}).toList();
```

### Handle Project Selection
```dart
OverwatchProjectSelectorWidget(
  onProjectSelected: (project) {
    setState(() {
      selectedProject = project;
      // Load fund flow for selected project
      fundFlow = _loadFundFlowForProject(project.projectId);
    });
  },
)
```

## 🎨 Widget Usage

### Project Selector
```dart
OverwatchProjectSelectorWidget(
  onProjectSelected: (project) {
    // Handle selection
  },
)
```

### Fund Flow Sankey
```dart
OverwatchFundFlowSankeyWidget(
  fundFlowData: fundFlow,
  projectName: selectedProject.name,
)
```

### Project Carousel
```dart
OverwatchProjectCarouselWidget(
  projects: projects,
  onProjectTap: (project) {
    // Handle tap
  },
)
```

## 📊 Data Models

### OverwatchProject
```dart
OverwatchProject(
  projectId: 'PM-2024-001',
  name: 'Solar Installation',
  status: ProjectStatus.active,
  riskScore: 45,
  riskLevel: RiskLevel.medium,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 180)),
  allocatedAmount: 5000000,
  utilizedAmount: 3250000,
  responsiblePerson: ResponsiblePerson(...),
)
```

### OverwatchFundFlow
```dart
OverwatchFundFlow(
  nodeId: 'centre-001',
  level: FundFlowLevel.centre,
  name: 'Ministry of New and Renewable Energy',
  allocatedAmount: 500000000,
  utilizedAmount: 350000000,
  children: [...],
  responsiblePerson: ResponsiblePerson(...),
  pfmsDetails: PFMSTransactionDetails(...),
)
```

## 🔍 Enums

### ProjectStatus
- `active` - Project is ongoing
- `completed` - Project finished
- `delayed` - Behind schedule
- `onHold` - Temporarily paused

### RiskLevel
- `low` - Risk score 0-33
- `medium` - Risk score 34-66
- `high` - Risk score 67-100

### FundFlowLevel
- `centre` - Central government
- `state` - State government
- `agency` - Implementing agency
- `project` - Specific project
- `milestone` - Project milestone
- `expense` - Individual expense

## 🎯 Key Metrics

### Calculate Fund Utilization
```dart
double utilizationPercentage = 
  (project.utilizedAmount / project.allocatedAmount) * 100;
```

### Get Risk Color
```dart
Color getRiskColor(RiskLevel risk) {
  switch (risk) {
    case RiskLevel.low: return Colors.green;
    case RiskLevel.medium: return Colors.orange;
    case RiskLevel.high: return Colors.red;
  }
}
```

### Format Currency
```dart
String formatAmount(double amount) {
  return '₹${(amount / 10000000).toStringAsFixed(2)}Cr';
}
```

## 🔄 State Management

### Using setState
```dart
class _DashboardState extends State<NewOverwatchDashboardPage> {
  List<OverwatchProject> projects = [];
  OverwatchProject? selectedProject;
  OverwatchFundFlow? fundFlow;

  void _loadData() {
    setState(() {
      projects = OverwatchMockData.generateProjects();
    });
  }
}
```

## 🧪 Testing

### Generate Test Data
```dart
// 10 projects
final projects = OverwatchMockData.generateProjects(count: 10);

// Complete fund flow
final fundFlow = OverwatchMockData.generateFundFlow();

// Specific project fund flow
final projectFundFlow = OverwatchMockData.generateProjectFundFlow(
  'PM-2024-001',
  'Solar Installation',
);
```

## 📱 Responsive Design

### Check Screen Size
```dart
final isDesktop = MediaQuery.of(context).size.width > 1024;
final isTablet = MediaQuery.of(context).size.width > 768;
final isMobile = MediaQuery.of(context).size.width <= 768;
```

### Adaptive Grid
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
    childAspectRatio: 1.5,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
)
```

## 🎨 Theme Usage

```dart
// Colors from theme
final primaryColor = Theme.of(context).colorScheme.primary;
final surfaceColor = Theme.of(context).colorScheme.surface;

// Text styles
final headlineStyle = Theme.of(context).textTheme.headlineMedium;
final bodyStyle = Theme.of(context).textTheme.bodyLarge;
```

## 🐛 Common Issues

### Issue: Projects not loading
```dart
// Check mock data is being called
print('Projects count: ${projects.length}');
```

### Issue: Fund flow not displaying
```dart
// Verify data structure
print('Fund flow children: ${fundFlow?.children.length}');
```

### Issue: Navigation not working
```dart
// Check context is valid
if (!mounted) return;
Navigator.pushNamed(context, '/new-overwatch-dashboard');
```

## 🔗 Related Documentation

- [Full Integration Guide](OVERWATCH_DASHBOARD_INTEGRATION.md)
- [Data Models](../lib/features/dashboard/data/models/)
- [Widgets](../lib/features/dashboard/presentation/widgets/overwatch/)

## ⚡ Performance Tips

1. Use `const` constructors where possible
2. Implement `ListView.builder` for large lists
3. Cache computed values
4. Use `RepaintBoundary` for complex widgets
5. Profile with Flutter DevTools

## 📞 Quick Help

**Can't find the dashboard?**
- Check route: `/new-overwatch-dashboard`
- Verify import: `navigation_helpers.dart`

**No data showing?**
- Use `OverwatchMockData.generateProjects()`
- Check console for errors

**Widget not updating?**
- Call `setState(() {...})`
- Check if widget is mounted

**Need more info?**
- See [Integration Guide](OVERWATCH_DASHBOARD_INTEGRATION.md)
- Check inline code documentation