import 'package:flutter/material.dart';
import '../widgets/national_heatmap_widget.dart';
import '../widgets/fund_flow_waterfall_widget.dart';
import '../widgets/agency_capacity_optimizer_widget.dart';
import '../widgets/smart_milestone_claims_widget.dart';
import '../../../fund_flow/presentation/pages/fund_flow_demo_page.dart';

/// Widget Test Page - Diagnostic page to test all dashboard widgets
class WidgetTestPage extends StatefulWidget {
  const WidgetTestPage({Key? key}) : super(key: key);

  @override
  State<WidgetTestPage> createState() => _WidgetTestPageState();
}

class _WidgetTestPageState extends State<WidgetTestPage> {
  int _selectedIndex = 0;

  final List<WidgetTestItem> _widgets = [
    WidgetTestItem('National Heatmap', Icons.map, () => const NationalHeatmapWidget()),
    WidgetTestItem('Fund Flow Waterfall', Icons.waterfall_chart, () => const FundFlowWaterfallWidget()),
    WidgetTestItem('Agency Optimizer', Icons.psychology, () => const AgencyCapacityOptimizerWidget()),
    WidgetTestItem('Milestone Claims', Icons.flag, () => const SmartMilestoneClaimsWidget()),
    WidgetTestItem('Fund Flow Demo', Icons.account_tree, () => const FundFlowDemoPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Test Page'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: _widgets.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                label: Text(item.name),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Icon(_widgets[_selectedIndex].icon, size: 32),
                      const SizedBox(width: 16),
                      Text(
                        _widgets[_selectedIndex].name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Chip(
                        label: const Text('TESTING'),
                        backgroundColor: Colors.orange.shade100,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildWidgetWithErrorBoundary(_widgets[_selectedIndex]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetWithErrorBoundary(WidgetTestItem item) {
    return ErrorBoundary(
      child: item.builder(),
    );
  }
}

class WidgetTestItem {
  final String name;
  final IconData icon;
  final Widget Function() builder;

  WidgetTestItem(this.name, this.icon, this.builder);
}

/// Error Boundary widget to catch and display errors gracefully
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({Key? key, required this.child}) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? error;
  StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        color: Colors.red.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade700, size: 32),
                const SizedBox(width: 16),
                const Text(
                  'Widget Error Detected',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.red.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Error Message:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    error.toString(),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  if (stackTrace != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Stack Trace:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          stackTrace.toString(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  error = null;
                  stackTrace = null;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (e, st) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              error = e;
              stackTrace = st;
            });
          });
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}