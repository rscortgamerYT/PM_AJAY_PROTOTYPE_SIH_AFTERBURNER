import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/utils/responsive_layout.dart';

/// Report type
enum ReportType {
  financial,
  performance,
  compliance,
  utilization,
  audit,
}

extension ReportTypeExtension on ReportType {
  String get label {
    switch (this) {
      case ReportType.financial:
        return 'Financial Report';
      case ReportType.performance:
        return 'Performance Report';
      case ReportType.compliance:
        return 'Compliance Report';
      case ReportType.utilization:
        return 'Utilization Report';
      case ReportType.audit:
        return 'Audit Report';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportType.financial:
        return Icons.account_balance_wallet;
      case ReportType.performance:
        return Icons.analytics;
      case ReportType.compliance:
        return Icons.verified;
      case ReportType.utilization:
        return Icons.pie_chart;
      case ReportType.audit:
        return Icons.fact_check;
    }
  }

  Color get color {
    switch (this) {
      case ReportType.financial:
        return AppDesignSystem.deepIndigo;
      case ReportType.performance:
        return AppDesignSystem.vibrantTeal;
      case ReportType.compliance:
        return AppDesignSystem.forestGreen;
      case ReportType.utilization:
        return AppDesignSystem.royalPurple;
      case ReportType.audit:
        return AppDesignSystem.sunsetOrange;
    }
  }
}

/// Analytics metric
class AnalyticsMetric {
  final String label;
  final double value;
  final double previousValue;
  final String unit;
  final IconData icon;
  final Color color;

  AnalyticsMetric({
    required this.label,
    required this.value,
    required this.previousValue,
    required this.unit,
    required this.icon,
    required this.color,
  });

  double get change => value - previousValue;
  double get changePercentage => previousValue > 0 ? (change / previousValue) * 100 : 0;
  bool get isPositive => change >= 0;
}

/// Trend data point
class TrendDataPoint {
  final String label;
  final double value;
  final DateTime date;

  TrendDataPoint({
    required this.label,
    required this.value,
    required this.date,
  });
}

/// Reports and Analytics Widget
class ReportsAnalyticsWidget extends StatefulWidget {
  const ReportsAnalyticsWidget({super.key});

  @override
  State<ReportsAnalyticsWidget> createState() => _ReportsAnalyticsWidgetState();
}

class _ReportsAnalyticsWidgetState extends State<ReportsAnalyticsWidget> {
  ReportType _selectedReportType = ReportType.financial;
  String _selectedPeriod = 'monthly';

  List<AnalyticsMetric> get _currentMetrics {
    switch (_selectedReportType) {
      case ReportType.financial:
        return [
          AnalyticsMetric(
            label: 'Total Allocated',
            value: 10000,
            previousValue: 9500,
            unit: 'Cr',
            icon: Icons.account_balance,
            color: AppDesignSystem.deepIndigo,
          ),
          AnalyticsMetric(
            label: 'Total Utilized',
            value: 7500,
            previousValue: 7000,
            unit: 'Cr',
            icon: Icons.trending_up,
            color: AppDesignSystem.success,
          ),
          AnalyticsMetric(
            label: 'Funds in Transit',
            value: 1250,
            previousValue: 1400,
            unit: 'Cr',
            icon: Icons.swap_horiz,
            color: AppDesignSystem.warning,
          ),
          AnalyticsMetric(
            label: 'Remaining',
            value: 2500,
            previousValue: 2500,
            unit: 'Cr',
            icon: Icons.account_balance_wallet,
            color: AppDesignSystem.vibrantTeal,
          ),
        ];
      case ReportType.performance:
        return [
          AnalyticsMetric(
            label: 'Avg Processing Time',
            value: 5.2,
            previousValue: 6.5,
            unit: 'days',
            icon: Icons.timer,
            color: AppDesignSystem.success,
          ),
          AnalyticsMetric(
            label: 'Completion Rate',
            value: 87.5,
            previousValue: 82.0,
            unit: '%',
            icon: Icons.check_circle,
            color: AppDesignSystem.deepIndigo,
          ),
          AnalyticsMetric(
            label: 'Delayed Projects',
            value: 12,
            previousValue: 18,
            unit: '',
            icon: Icons.warning,
            color: AppDesignSystem.warning,
          ),
          AnalyticsMetric(
            label: 'Efficiency Score',
            value: 92.3,
            previousValue: 88.5,
            unit: '%',
            icon: Icons.trending_up,
            color: AppDesignSystem.vibrantTeal,
          ),
        ];
      case ReportType.compliance:
        return [
          AnalyticsMetric(
            label: 'Compliance Rate',
            value: 94.5,
            previousValue: 91.0,
            unit: '%',
            icon: Icons.verified,
            color: AppDesignSystem.success,
          ),
          AnalyticsMetric(
            label: 'Pending Reports',
            value: 8,
            previousValue: 12,
            unit: '',
            icon: Icons.pending_actions,
            color: AppDesignSystem.warning,
          ),
          AnalyticsMetric(
            label: 'Overdue Items',
            value: 3,
            previousValue: 5,
            unit: '',
            icon: Icons.error,
            color: AppDesignSystem.error,
          ),
          AnalyticsMetric(
            label: 'Audit Score',
            value: 89.5,
            previousValue: 87.0,
            unit: '%',
            icon: Icons.fact_check,
            color: AppDesignSystem.deepIndigo,
          ),
        ];
      case ReportType.utilization:
        return [
          AnalyticsMetric(
            label: 'Overall Utilization',
            value: 75.0,
            previousValue: 73.7,
            unit: '%',
            icon: Icons.pie_chart,
            color: AppDesignSystem.vibrantTeal,
          ),
          AnalyticsMetric(
            label: 'Active Projects',
            value: 342,
            previousValue: 325,
            unit: '',
            icon: Icons.work,
            color: AppDesignSystem.deepIndigo,
          ),
          AnalyticsMetric(
            label: 'UC Submitted',
            value: 156,
            previousValue: 148,
            unit: '',
            icon: Icons.file_present,
            color: AppDesignSystem.success,
          ),
          AnalyticsMetric(
            label: 'Beneficiaries',
            value: 12500,
            previousValue: 11800,
            unit: '',
            icon: Icons.people,
            color: AppDesignSystem.royalPurple,
          ),
        ];
      case ReportType.audit:
        return [
          AnalyticsMetric(
            label: 'Audits Completed',
            value: 24,
            previousValue: 20,
            unit: '',
            icon: Icons.fact_check,
            color: AppDesignSystem.success,
          ),
          AnalyticsMetric(
            label: 'Findings',
            value: 45,
            previousValue: 52,
            unit: '',
            icon: Icons.find_in_page,
            color: AppDesignSystem.warning,
          ),
          AnalyticsMetric(
            label: 'Resolved',
            value: 38,
            previousValue: 35,
            unit: '',
            icon: Icons.check_circle,
            color: AppDesignSystem.deepIndigo,
          ),
          AnalyticsMetric(
            label: 'Avg Resolution Time',
            value: 12.5,
            previousValue: 15.2,
            unit: 'days',
            icon: Icons.timer,
            color: AppDesignSystem.vibrantTeal,
          ),
        ];
    }
  }

  List<TrendDataPoint> get _trendData {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final month = now.subtract(Duration(days: 30 * (5 - index)));
      return TrendDataPoint(
        label: '${month.month}/${month.year}',
        value: 70 + (index * 3) + (index % 2 == 0 ? 5 : -2),
        date: month,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildReportTypeSelector(),
        SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
        _buildMetricsGrid(),
        SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildTrendChart(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightsPanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportTypeSelector() {
    return Container(
      padding: ResponsiveLayout.getResponsivePadding(context),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ReportType.values.map((type) {
                  final isSelected = _selectedReportType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(type.icon, size: 16, color: isSelected ? Colors.white : type.color),
                          const SizedBox(width: 8),
                          Text(type.label),
                        ],
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedReportType = type);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: type.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppDesignSystem.neutral900,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _selectedPeriod,
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Daily')),
              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
              DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
            ],
            onChanged: (value) => setState(() => _selectedPeriod = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Padding(
      padding: ResponsiveLayout.getResponsivePadding(context),
      child: GridView.count(
        crossAxisCount: ResponsiveLayout.getKpiGridColumns(context),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: ResponsiveLayout.getResponsiveSpacing(context),
        crossAxisSpacing: ResponsiveLayout.getResponsiveSpacing(context),
        childAspectRatio: ResponsiveLayout.getKpiAspectRatio(context),
        children: _currentMetrics.map(_buildMetricCard).toList(),
      ),
    );
  }

  Widget _buildMetricCard(AnalyticsMetric metric) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(metric.icon, color: metric.color, size: 24),
                const Spacer(),
                if (metric.changePercentage.abs() > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: metric.isPositive 
                          ? AppDesignSystem.success.withOpacity(0.1)
                          : AppDesignSystem.error.withOpacity(0.1),
                      borderRadius: AppDesignSystem.radiusSmall,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          metric.isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 12,
                          color: metric.isPositive ? AppDesignSystem.success : AppDesignSystem.error,
                        ),
                        Text(
                          '${metric.changePercentage.abs().toStringAsFixed(1)}%',
                          style: AppDesignSystem.labelSmall.copyWith(
                            color: metric.isPositive ? AppDesignSystem.success : AppDesignSystem.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${metric.value.toStringAsFixed(metric.unit == '%' || metric.unit == 'days' ? 1 : 0)}${metric.unit}',
              style: AppDesignSystem.displaySmall.copyWith(
                color: metric.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(metric.label, style: AppDesignSystem.labelMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    return Card(
      margin: ResponsiveLayout.getResponsivePadding(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trend Analysis', style: AppDesignSystem.headlineSmall),
            const SizedBox(height: 24),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%', style: AppDesignSystem.labelSmall);
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < _trendData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _trendData[value.toInt()].label,
                                style: AppDesignSystem.labelSmall,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _trendData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value);
                      }).toList(),
                      isCurved: true,
                      color: _selectedReportType.color,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _selectedReportType.color.withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: 60,
                  maxY: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsPanel() {
    return Card(
      margin: ResponsiveLayout.getResponsivePadding(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Key Insights', style: AppDesignSystem.headlineSmall),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildInsightCard(
                    icon: Icons.trending_up,
                    color: AppDesignSystem.success,
                    title: 'Positive Trend',
                    description: 'Overall performance has improved by 12.5% compared to last quarter.',
                  ),
                  _buildInsightCard(
                    icon: Icons.warning,
                    color: AppDesignSystem.warning,
                    title: 'Attention Required',
                    description: '3 states need immediate follow-up for pending compliance reports.',
                  ),
                  _buildInsightCard(
                    icon: Icons.lightbulb,
                    color: AppDesignSystem.deepIndigo,
                    title: 'Recommendation',
                    description: 'Consider increasing budget allocation for high-performing states.',
                  ),
                  _buildInsightCard(
                    icon: Icons.check_circle,
                    color: AppDesignSystem.success,
                    title: 'Achievement',
                    description: 'Fund utilization rate reached 75%, exceeding the 70% target.',
                  ),
                ],
              ),
            ),
            const Divider(),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generating detailed report...')),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Export Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedReportType.color,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: AppDesignSystem.radiusSmall,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppDesignSystem.titleSmall),
                  const SizedBox(height: 4),
                  Text(description, style: AppDesignSystem.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}