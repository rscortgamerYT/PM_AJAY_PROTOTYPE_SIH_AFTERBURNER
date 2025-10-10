import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/models/fund_transaction_model.dart';

/// Comparative Analytics Widget with peer benchmarking and heatmaps
class ComparativeAnalyticsWidget extends StatefulWidget {
  final List<EntityComparison> comparisons;
  final String currentEntityId;
  final String currentEntityName;
  final Function(String)? onEntityTap;

  const ComparativeAnalyticsWidget({
    Key? key,
    required this.comparisons,
    required this.currentEntityId,
    required this.currentEntityName,
    this.onEntityTap,
  }) : super(key: key);

  @override
  State<ComparativeAnalyticsWidget> createState() => _ComparativeAnalyticsWidgetState();
}

class _ComparativeAnalyticsWidgetState extends State<ComparativeAnalyticsWidget> {
  ComparisonMetric _selectedMetric = ComparisonMetric.utilizationRate;
  String _selectedPeriod = 'Q4 2024';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildMetricSelector(),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildComparisonChart(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildPerformanceHeatmap(),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildRankingList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Comparative Analytics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        DropdownButton<String>(
          value: _selectedPeriod,
          items: ['Q1 2024', 'Q2 2024', 'Q3 2024', 'Q4 2024', 'FY 2024']
              .map((period) => DropdownMenuItem(
                    value: period,
                    child: Text(period),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildMetricSelector() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ComparisonMetric.values.map((metric) {
            final isSelected = _selectedMetric == metric;
            return ChoiceChip(
              label: Text(_getMetricLabel(metric)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedMetric = metric;
                });
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildComparisonChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peer Benchmarking - ${_getMetricLabel(_selectedMetric)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final comparison = widget.comparisons[groupIndex];
                        return BarTooltipItem(
                          '${comparison.entityName}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: _formatValue(_getMetricValue(comparison)),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= widget.comparisons.length) {
                            return const SizedBox();
                          }
                          final comparison = widget.comparisons[value.toInt()];
                          final isCurrent = comparison.entityId == widget.currentEntityId;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              comparison.entityName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isCurrent ? Theme.of(context).primaryColor : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatValue(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getMaxValue() / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: widget.comparisons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final comparison = entry.value;
                    final isCurrent = comparison.entityId == widget.currentEntityId;
                    final value = _getMetricValue(comparison);
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          color: isCurrent
                              ? Theme.of(context).primaryColor
                              : _getPerformanceColor(value, _getMaxValue()),
                          width: 24,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceHeatmap() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Heatmap',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: widget.comparisons.length,
                itemBuilder: (context, index) {
                  final comparison = widget.comparisons[index];
                  final isCurrent = comparison.entityId == widget.currentEntityId;
                  final score = _calculateOverallScore(comparison);
                  
                  return InkWell(
                    onTap: () => widget.onEntityTap?.call(comparison.entityId),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getHeatmapColor(score),
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrent
                            ? Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            comparison.entityName.substring(0, 
                              comparison.entityName.length > 10 ? 10 : comparison.entityName.length),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: score > 70 ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${score.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: score > 70 ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeatmapLegendItem(Colors.red.shade200, '0-40%'),
                _buildHeatmapLegendItem(Colors.orange.shade200, '41-60%'),
                _buildHeatmapLegendItem(Colors.yellow.shade200, '61-80%'),
                _buildHeatmapLegendItem(Colors.green.shade600, '81-100%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingList() {
    final sortedComparisons = List<EntityComparison>.from(widget.comparisons)
      ..sort((a, b) => _getMetricValue(b).compareTo(_getMetricValue(a)));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rankings - ${_getMetricLabel(_selectedMetric)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: sortedComparisons.length,
                itemBuilder: (context, index) {
                  final comparison = sortedComparisons[index];
                  final isCurrent = comparison.entityId == widget.currentEntityId;
                  final rank = index + 1;
                  final value = _getMetricValue(comparison);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrent
                          ? Border.all(color: Theme.of(context).primaryColor)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getRankColor(rank),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comparison.entityName,
                                style: TextStyle(
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                comparison.entityType.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatValue(value),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getPerformanceColor(value, _getMaxValue()),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Theme.of(context).primaryColor, 'Current Entity'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.green, 'High Performance'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.orange, 'Medium Performance'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.red, 'Low Performance'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildHeatmapLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  String _getMetricLabel(ComparisonMetric metric) {
    switch (metric) {
      case ComparisonMetric.utilizationRate:
        return 'Utilization Rate';
      case ComparisonMetric.transferSpeed:
        return 'Transfer Speed';
      case ComparisonMetric.complianceScore:
        return 'Compliance Score';
      case ComparisonMetric.projectCompletion:
        return 'Project Completion';
      case ComparisonMetric.fundEfficiency:
        return 'Fund Efficiency';
    }
  }

  double _getMetricValue(EntityComparison comparison) {
    switch (_selectedMetric) {
      case ComparisonMetric.utilizationRate:
        return comparison.utilizationRate;
      case ComparisonMetric.transferSpeed:
        return comparison.avgTransferDays;
      case ComparisonMetric.complianceScore:
        return comparison.complianceScore;
      case ComparisonMetric.projectCompletion:
        return comparison.projectCompletionRate;
      case ComparisonMetric.fundEfficiency:
        return comparison.fundEfficiencyScore;
    }
  }

  double _getMaxValue() {
    switch (_selectedMetric) {
      case ComparisonMetric.utilizationRate:
      case ComparisonMetric.complianceScore:
      case ComparisonMetric.projectCompletion:
      case ComparisonMetric.fundEfficiency:
        return 100;
      case ComparisonMetric.transferSpeed:
        return 30; // Maximum 30 days
    }
  }

  String _formatValue(double value) {
    switch (_selectedMetric) {
      case ComparisonMetric.transferSpeed:
        return '${value.toStringAsFixed(1)}d';
      default:
        return '${value.toStringAsFixed(1)}%';
    }
  }

  Color _getPerformanceColor(double value, double maxValue) {
    final percentage = (value / maxValue) * 100;
    if (_selectedMetric == ComparisonMetric.transferSpeed) {
      // Lower is better for transfer speed
      if (value <= 7) return Colors.green;
      if (value <= 14) return Colors.orange;
      return Colors.red;
    } else {
      // Higher is better for other metrics
      if (percentage >= 80) return Colors.green;
      if (percentage >= 60) return Colors.orange;
      return Colors.red;
    }
  }

  Color _getHeatmapColor(double score) {
    if (score >= 81) return Colors.green.shade600;
    if (score >= 61) return Colors.yellow.shade200;
    if (score >= 41) return Colors.orange.shade200;
    return Colors.red.shade200;
  }

  double _calculateOverallScore(EntityComparison comparison) {
    return (comparison.utilizationRate +
            comparison.complianceScore +
            comparison.projectCompletionRate +
            comparison.fundEfficiencyScore) /
        4;
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade700;
      case 2:
        return Colors.grey.shade500;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.blue.shade400;
    }
  }
}

/// Entity comparison data model
class EntityComparison {
  final String entityId;
  final String entityName;
  final String entityType;
  final double utilizationRate;
  final double avgTransferDays;
  final double complianceScore;
  final double projectCompletionRate;
  final double fundEfficiencyScore;

  EntityComparison({
    required this.entityId,
    required this.entityName,
    required this.entityType,
    required this.utilizationRate,
    required this.avgTransferDays,
    required this.complianceScore,
    required this.projectCompletionRate,
    required this.fundEfficiencyScore,
  });
}

/// Comparison metrics enum
enum ComparisonMetric {
  utilizationRate,
  transferSpeed,
  complianceScore,
  projectCompletion,
  fundEfficiency,
}