import 'package:flutter/material.dart';
import '../../../models/overwatch_project_model.dart';
import '../../../../../core/theme/app_design_system.dart';
import 'interactive_pie_chart_widget.dart';

/// Analytics charts widget for Overwatch dashboard
class OverwatchAnalyticsCharts extends StatelessWidget {
  final List<OverwatchProject> projects;

  const OverwatchAnalyticsCharts({
    super.key,
    required this.projects,
  });

  Map<String, int> _getStatusDistribution() {
    final distribution = <String, int>{};
    for (final status in OverwatchProjectStatus.values) {
      distribution[status.label] = projects.where((p) => p.status == status).length;
    }
    return distribution;
  }

  Map<String, int> _getRiskDistribution() {
    final distribution = <String, int>{};
    for (final risk in RiskLevel.values) {
      distribution[risk.label] = projects.where((p) => p.riskLevel == risk).length;
    }
    return distribution;
  }

  Map<String, double> _getFundUtilization() {
    final utilization = <String, double>{};
    for (final component in ProjectComponentType.values) {
      final componentProjects = projects.where((p) => p.component == component).toList();
      if (componentProjects.isNotEmpty) {
        final totalFunds = componentProjects.fold<double>(0, (sum, p) => sum + p.totalFunds);
        final utilizedFunds = componentProjects.fold<double>(0, (sum, p) => sum + p.utilizedFunds);
        utilization[component.label] = totalFunds > 0 ? (utilizedFunds / totalFunds * 100) : 0;
      }
    }
    return utilization;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildStatusChart(context),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRiskChart(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFundUtilizationChart(context),
        ],
      ),
    );
  }

  Widget _buildStatusChart(BuildContext context) {
    final distribution = _getStatusDistribution();
    final total = distribution.values.fold<int>(0, (sum, count) => sum + count);

    final segments = distribution.entries.map((entry) {
      final index = distribution.keys.toList().indexOf(entry.key);
      return PieChartSegment(
        label: entry.key,
        value: total > 0 ? entry.value / total : 0,
        color: OverwatchProjectStatus.values[index].color,
        count: entry.value,
      );
    }).toList();

    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppDesignSystem.radiusLarge,
        border: Border.all(
          color: AppDesignSystem.neutral300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Status Distribution',
            style: AppDesignSystem.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Interactive - Hover and click for details',
            style: AppDesignSystem.bodySmall.copyWith(
              color: AppDesignSystem.neutral600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: InteractivePieChartWidget(
              segments: segments,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskChart(BuildContext context) {
    final distribution = _getRiskDistribution();
    final total = distribution.values.fold<int>(0, (sum, count) => sum + count);

    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppDesignSystem.radiusLarge,
        border: Border.all(
          color: AppDesignSystem.neutral300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Risk Level Distribution',
            style: AppDesignSystem.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildBarChart(
                    distribution,
                    RiskLevel.values.map((r) => r.color).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildLegend(
                    distribution,
                    RiskLevel.values.map((r) => r.color).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundUtilizationChart(BuildContext context) {
    final utilization = _getFundUtilization();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppDesignSystem.radiusLarge,
        border: Border.all(
          color: AppDesignSystem.neutral300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fund Utilization by Component',
            style: AppDesignSystem.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: utilization.length,
              itemBuilder: (context, index) {
                final entry = utilization.entries.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildProgressBar(
                    entry.key,
                    entry.value,
                    ProjectComponentType.values[index].value == 'adarsh_gram'
                        ? AppDesignSystem.deepIndigo
                        : ProjectComponentType.values[index].value == 'gia'
                            ? AppDesignSystem.skyBlue
                            : AppDesignSystem.sunsetOrange,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data, List<Color> colors) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CustomPaint(
          painter: _PieChartPainter(data, colors),
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data, List<Color> colors) {
    final maxValue = data.values.fold<int>(0, (max, value) => value > max ? value : max);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.entries.map((entry) {
        final index = data.keys.toList().indexOf(entry.key);
        final height = maxValue > 0 ? (entry.value / maxValue * 150) : 0;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${entry.value}',
              style: AppDesignSystem.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: height.toDouble(),
              decoration: BoxDecoration(
                color: colors[index],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildProgressBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppDesignSystem.labelMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: AppDesignSystem.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppDesignSystem.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(Map<String, dynamic> data, List<Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: data.entries.map((entry) {
        final index = data.keys.toList().indexOf(entry.key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  entry.key,
                  style: AppDesignSystem.labelSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;

  _PieChartPainter(this.data, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width < size.height ? size.width : size.height) * 0.35;
    
    double startAngle = -90 * 3.14159 / 180; // Start at top
    
    int colorIndex = 0;
    for (final entry in data.entries) {
      final sweepAngle = entry.value * 2 * 3.14159;
      
      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
      colorIndex++;
    }
    
    // Draw center circle for donut effect
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}