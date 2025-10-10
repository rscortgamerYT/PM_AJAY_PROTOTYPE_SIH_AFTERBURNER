import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';

class OpenDataAnalyticsWidget extends StatefulWidget {
  const OpenDataAnalyticsWidget({super.key});

  @override
  State<OpenDataAnalyticsWidget> createState() => _OpenDataAnalyticsWidgetState();
}

class _OpenDataAnalyticsWidgetState extends State<OpenDataAnalyticsWidget> {
  String _selectedDataset = 'All';
  String _selectedTimeRange = '1y';
  
  final List<String> _datasets = ['All', 'Budget', 'Projects', 'Performance', 'Demographics'];
  final List<String> _timeRanges = ['1m', '3m', '6m', '1y', 'All'];

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
            _buildDatasetStats(),
            const SizedBox(height: 24),
            _buildDownloadTrends(),
            const SizedBox(height: 24),
            _buildPopularDatasets(),
            const SizedBox(height: 24),
            _buildDataQualityMetrics(),
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
            color: AppTheme.secondaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.analytics, color: AppTheme.secondaryBlue, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Open Data Analytics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Public access to government data and transparency metrics',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('Browse Data'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryBlue,
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
            value: _selectedDataset,
            underline: const SizedBox(),
            items: _datasets.map((dataset) {
              return DropdownMenuItem(
                value: dataset,
                child: Text(dataset),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedDataset = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDatasetStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Datasets',
            '487',
            '+23',
            Icons.dataset,
            AppTheme.secondaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Downloads',
            '2.8M',
            '+187K',
            Icons.download,
            AppTheme.publicColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'API Requests',
            '847K',
            '+45K',
            Icons.api,
            AppTheme.warningOrange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Active Users',
            '12.4K',
            '+342',
            Icons.people,
            AppTheme.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String change, IconData icon, Color color) {
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
        ],
      ),
    );
  }

  Widget _buildDownloadTrends() {
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
            'Download Trends',
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
                  horizontalInterval: 50000,
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
                          '${(value / 1000).toInt()}K',
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
                minY: 180000,
                maxY: 280000,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 180000),
                      const FlSpot(1, 195000),
                      const FlSpot(2, 210000),
                      const FlSpot(3, 205000),
                      const FlSpot(4, 225000),
                      const FlSpot(5, 235000),
                      const FlSpot(6, 245000),
                      const FlSpot(7, 250000),
                      const FlSpot(8, 260000),
                      const FlSpot(9, 265000),
                      const FlSpot(10, 270000),
                      const FlSpot(11, 280000),
                    ],
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
                          '${(spot.y / 1000).toStringAsFixed(0)}K',
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

  Widget _buildPopularDatasets() {
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
                'Most Downloaded Datasets',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDatasetItem(
            'Budget Allocation 2024-25',
            'Complete budget data across all departments',
            'CSV, JSON, XML',
            '487K',
            4.8,
            AppTheme.secondaryBlue,
          ),
          const Divider(height: 24),
          _buildDatasetItem(
            'Project Status Dashboard',
            'Real-time project progress and milestones',
            'JSON, API',
            '342K',
            4.6,
            AppTheme.publicColor,
          ),
          const Divider(height: 24),
          _buildDatasetItem(
            'Beneficiary Demographics',
            'Demographic data of program beneficiaries',
            'CSV, JSON',
            '298K',
            4.7,
            AppTheme.warningOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildDatasetItem(String title, String description, String formats, String downloads, double rating, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.description, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.file_download, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    downloads,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.star, size: 14, color: AppTheme.warningOrange),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.code, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    formats,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Download', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildDataQualityMetrics() {
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
            'Data Quality Metrics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildQualityRow('Completeness', 94, AppTheme.successGreen),
          const SizedBox(height: 12),
          _buildQualityRow('Accuracy', 92, AppTheme.successGreen),
          const SizedBox(height: 12),
          _buildQualityRow('Timeliness', 88, AppTheme.warningOrange),
          const SizedBox(height: 12),
          _buildQualityRow('Consistency', 96, AppTheme.successGreen),
          const SizedBox(height: 12),
          _buildQualityRow('Accessibility', 90, AppTheme.successGreen),
        ],
      ),
    );
  }

  Widget _buildQualityRow(String metric, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              metric,
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