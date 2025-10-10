import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';

class QualityAssuranceWidget extends StatefulWidget {
  const QualityAssuranceWidget({super.key});

  @override
  State<QualityAssuranceWidget> createState() => _QualityAssuranceWidgetState();
}

class _QualityAssuranceWidgetState extends State<QualityAssuranceWidget> {
  String _selectedTimeRange = '30d';
  String _selectedCategory = 'All';

  final List<String> _timeRanges = ['7d', '30d', '90d', '1y'];
  final List<String> _categories = ['All', 'Infrastructure', 'Social Welfare', 'Education', 'Healthcare'];

  // Mock data for quality scores
  final Map<String, List<FlSpot>> _qualityTrendData = {
    '7d': [
      const FlSpot(0, 85),
      const FlSpot(1, 87),
      const FlSpot(2, 86),
      const FlSpot(3, 88),
      const FlSpot(4, 90),
      const FlSpot(5, 89),
      const FlSpot(6, 91),
    ],
    '30d': [
      const FlSpot(0, 82),
      const FlSpot(5, 84),
      const FlSpot(10, 86),
      const FlSpot(15, 85),
      const FlSpot(20, 88),
      const FlSpot(25, 90),
      const FlSpot(29, 91),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildControlBar(),
            const SizedBox(height: 24),
            _buildQualityMetrics(),
            const SizedBox(height: 24),
            _buildQualityTrendChart(),
            const SizedBox(height: 24),
            _buildAuditResults(),
            const SizedBox(height: 24),
            _buildComplianceMatrix(),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.verified_user, color: AppTheme.secondaryBlue, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quality Assurance Command Center',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'AI-powered quality monitoring and compliance tracking',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildControlBar() {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeRanges.map((range) {
              final isSelected = range == _selectedTimeRange;
              return ChoiceChip(
                label: Text(range),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedTimeRange = range);
                  }
                },
                selectedColor: AppTheme.secondaryBlue.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.secondaryBlue : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            underline: const SizedBox(),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQualityMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Overall Quality Score',
            '91',
            '+5%',
            Icons.grade,
            AppTheme.successGreen,
            '%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Compliance Rate',
            '96',
            '+2%',
            Icons.check_circle,
            AppTheme.secondaryBlue,
            '%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Audits Completed',
            '847',
            '+23',
            Icons.assignment_turned_in,
            AppTheme.warningOrange,
            '',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Issues Resolved',
            '1,234',
            '+89',
            Icons.build,
            AppTheme.successGreen,
            '',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String change, IconData icon, Color color, String suffix) {
    final isPositive = change.startsWith('+');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? AppTheme.successGreen : AppTheme.errorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              if (suffix.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    suffix,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityTrendChart() {
    final data = _qualityTrendData[_selectedTimeRange] ?? _qualityTrendData['30d']!;
    
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quality Score Trend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (_selectedTimeRange == '7d') {
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final index = value.toInt();
                          if (index >= 0 && index < days.length) {
                            return Text(
                              days[index],
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            );
                          }
                        } else if (_selectedTimeRange == '30d') {
                          if (value % 5 == 0) {
                            return Text(
                              'Day ${value.toInt()}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            );
                          }
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: data.first.x,
                maxX: data.last.x,
                minY: 75,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    color: AppTheme.secondaryBlue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.secondaryBlue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.secondaryBlue.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Audit Results',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filter'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAuditItem(
            'Highway Construction Project - Phase 2',
            'Passed',
            '95/100',
            'Infrastructure',
            AppTheme.successGreen,
            '2 hours ago',
          ),
          const Divider(height: 24),
          _buildAuditItem(
            'Rural Water Supply Initiative',
            'Passed',
            '88/100',
            'Social Welfare',
            AppTheme.successGreen,
            '5 hours ago',
          ),
          const Divider(height: 24),
          _buildAuditItem(
            'Primary School Building Construction',
            'Under Review',
            '72/100',
            'Education',
            AppTheme.warningOrange,
            '1 day ago',
          ),
          const Divider(height: 24),
          _buildAuditItem(
            'Community Health Center Upgrade',
            'Action Required',
            '68/100',
            'Healthcare',
            AppTheme.errorRed,
            '2 days ago',
          ),
        ],
      ),
    );
  }

  Widget _buildAuditItem(String project, String status, String score, String category, Color statusColor, String time) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 60,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.category, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.grade, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    score,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildComplianceMatrix() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compliance Matrix',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildComplianceRow('Documentation', 98, AppTheme.successGreen),
          const SizedBox(height: 12),
          _buildComplianceRow('Safety Standards', 95, AppTheme.successGreen),
          const SizedBox(height: 12),
          _buildComplianceRow('Environmental', 92, AppTheme.successGreen),
          const SizedBox(height: 12),
          _buildComplianceRow('Financial Controls', 88, AppTheme.warningOrange),
          const SizedBox(height: 12),
          _buildComplianceRow('Timeline Adherence', 85, AppTheme.warningOrange),
        ],
      ),
    );
  }

  Widget _buildComplianceRow(String category, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}