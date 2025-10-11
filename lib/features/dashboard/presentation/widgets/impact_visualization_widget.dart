import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';

class ImpactVisualizationWidget extends StatefulWidget {
  const ImpactVisualizationWidget({super.key});

  @override
  State<ImpactVisualizationWidget> createState() => _ImpactVisualizationWidgetState();
}

class _ImpactVisualizationWidgetState extends State<ImpactVisualizationWidget> {
  String _selectedTimeRange = '1y';
  String _selectedMetric = 'Beneficiaries';
  
  final List<String> _timeRanges = ['6m', '1y', '3y', 'All'];
  final List<String> _metrics = ['Beneficiaries', 'Investment', 'Projects', 'Employment'];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildControlBar(),
            const SizedBox(height: 24),
            _buildImpactMetrics(),
            const SizedBox(height: 24),
            _buildImpactTrend(),
            const SizedBox(height: 24),
            _buildSectorDistribution(),
            const SizedBox(height: 24),
            _buildGeographicImpact(),
          ],
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
            color: AppTheme.publicColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.insights, color: AppTheme.publicColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Impact Visualization',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Visual representation of project outcomes and societal impact',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Export Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.publicColor,
            foregroundColor: Colors.white,
          ),
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
                selectedColor: AppTheme.publicColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.publicColor : Colors.grey[700],
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
            value: _selectedMetric,
            underline: const SizedBox(),
            items: _metrics.map((metric) {
              return DropdownMenuItem(
                value: metric,
                child: Text(metric),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedMetric = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImpactMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Beneficiaries',
            '2.4M',
            '+18%',
            Icons.people,
            AppTheme.publicColor,
            'Citizens',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Total Investment',
            '₹8,450 Cr',
            '+23%',
            Icons.account_balance,
            AppTheme.secondaryBlue,
            'Allocated',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Active Projects',
            '1,847',
            '+145',
            Icons.construction,
            AppTheme.warningOrange,
            'Ongoing',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Jobs Created',
            '847K',
            '+12%',
            Icons.work,
            AppTheme.successGreen,
            'Employment',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String change, IconData icon, Color color, String subtitle) {
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
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactTrend() {
    final data = _getImpactTrendData();
    
    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Impact Trend - $_selectedMetric',
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
                  horizontalInterval: 500000,
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
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000000).toStringAsFixed(1)}M',
                          style: TextStyle(color: Colors.grey[600], fontSize: 11),
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
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        final index = value.toInt();
                        if (index >= 0 && index < months.length) {
                          return Text(
                            months[index],
                            style: TextStyle(color: Colors.grey[600], fontSize: 11),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 11,
                minY: 1500000,
                maxY: 2500000,
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    color: AppTheme.publicColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.publicColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.publicColor.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${(spot.y / 1000000).toStringAsFixed(2)}M',
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

  List<FlSpot> _getImpactTrendData() {
    return [
      const FlSpot(0, 1800000),
      const FlSpot(1, 1850000),
      const FlSpot(2, 1920000),
      const FlSpot(3, 1980000),
      const FlSpot(4, 2050000),
      const FlSpot(5, 2100000),
      const FlSpot(6, 2180000),
      const FlSpot(7, 2240000),
      const FlSpot(8, 2290000),
      const FlSpot(9, 2350000),
      const FlSpot(10, 2380000),
      const FlSpot(11, 2400000),
    ];
  }

  Widget _buildSectorDistribution() {
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
            'Impact by Sector',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(
                          value: 32,
                          title: '32%',
                          color: AppTheme.secondaryBlue,
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: 28,
                          title: '28%',
                          color: AppTheme.publicColor,
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: 22,
                          title: '22%',
                          color: AppTheme.warningOrange,
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: 18,
                          title: '18%',
                          color: AppTheme.accentTeal,
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectorItem('Infrastructure', '768K', 32, AppTheme.secondaryBlue),
                    const SizedBox(height: 12),
                    _buildSectorItem('Social Welfare', '672K', 28, AppTheme.publicColor),
                    const SizedBox(height: 12),
                    _buildSectorItem('Education', '528K', 22, AppTheme.warningOrange),
                    const SizedBox(height: 12),
                    _buildSectorItem('Healthcare', '432K', 18, AppTheme.accentTeal),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectorItem(String label, String beneficiaries, int percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Text(
          '$beneficiaries ($percentage%)',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildGeographicImpact() {
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
            'Top States by Impact',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildStateImpact('Uttar Pradesh', 387, 100),
          const SizedBox(height: 12),
          _buildStateImpact('Maharashtra', 342, 88),
          const SizedBox(height: 12),
          _buildStateImpact('Bihar', 298, 77),
          const SizedBox(height: 12),
          _buildStateImpact('West Bengal', 265, 68),
          const SizedBox(height: 12),
          _buildStateImpact('Madhya Pradesh', 234, 60),
        ],
      ),
    );
  }

  Widget _buildStateImpact(String state, int beneficiaries, int percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              '${beneficiaries}K beneficiaries',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.publicColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}