import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';

class PredictiveAnalyticsWidget extends StatefulWidget {
  const PredictiveAnalyticsWidget({super.key});

  @override
  State<PredictiveAnalyticsWidget> createState() => _PredictiveAnalyticsWidgetState();
}

class _PredictiveAnalyticsWidgetState extends State<PredictiveAnalyticsWidget> {
  int _selectedMetric = 0;
  final List<String> _metrics = ['Budget Utilization', 'Project Completion', 'Beneficiary Impact', 'Agency Performance'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildMetricSelector(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildPredictionChart(),
                _buildInsightsCards(),
                _buildRecommendations(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Predictive Analytics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'AI-powered insights and predictions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          Row(
            children: [
              Chip(
                avatar: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('ML Model Active'),
                backgroundColor: AppTheme.successGreen.withOpacity(0.2),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {},
                tooltip: 'Configure Models',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_metrics.length, (index) {
            final isSelected = _selectedMetric == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(_metrics[index]),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedMetric = index);
                },
                selectedColor: AppTheme.primaryIndigo.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryIndigo,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPredictionChart() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trend Analysis & Forecast',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.trending_up, size: 16, color: AppTheme.successGreen),
                        SizedBox(width: 4),
                        Text(
                          'Confidence: 87%',
                          style: TextStyle(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 20,
                      verticalInterval: 1,
                    ),
                    titlesData: FlTitlesData(
                      show: true,
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
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            if (value.toInt() >= 0 && value.toInt() < months.length) {
                              return Text(
                                months[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 20,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 11,
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      // Actual data
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 45),
                          const FlSpot(1, 52),
                          const FlSpot(2, 48),
                          const FlSpot(3, 58),
                          const FlSpot(4, 62),
                          const FlSpot(5, 65),
                          const FlSpot(6, 68),
                          const FlSpot(7, 72),
                        ],
                        isCurved: true,
                        color: AppTheme.primaryIndigo,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppTheme.primaryIndigo,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primaryIndigo.withOpacity(0.1),
                        ),
                      ),
                      // Predicted data
                      LineChartBarData(
                        spots: [
                          const FlSpot(7, 72),
                          const FlSpot(8, 76),
                          const FlSpot(9, 79),
                          const FlSpot(10, 82),
                          const FlSpot(11, 85),
                        ],
                        isCurved: true,
                        color: AppTheme.successGreen,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dashArray: [5, 5],
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppTheme.successGreen,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.successGreen.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildChartLegend('Actual Data', AppTheme.primaryIndigo, false),
                  const SizedBox(width: 24),
                  _buildChartLegend('Predicted', AppTheme.successGreen, true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color, bool isDashed) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: isDashed
              ? CustomPaint(
                  painter: DashedLinePainter(color: color),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildInsightsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Insights',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  'Expected by Dec 2025',
                  '85%',
                  'Utilization Rate',
                  Icons.trending_up,
                  AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightCard(
                  'Optimal Timeline',
                  '120 Days',
                  'Avg. Completion',
                  Icons.schedule,
                  AppTheme.secondaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightCard(
                  'Risk Assessment',
                  'Low',
                  'Delay Probability',
                  Icons.shield,
                  AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightCard(
                  'Improvement',
                  '+12%',
                  'vs Last Quarter',
                  Icons.show_chart,
                  AppTheme.successGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb, color: AppTheme.warningOrange),
                  const SizedBox(width: 8),
                  Text(
                    'AI Recommendations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRecommendationItem(
                'Increase fund release to high-performing states',
                'Model predicts 15% better utilization in Maharashtra and Gujarat',
                Icons.trending_up,
                AppTheme.successGreen,
                'High Impact',
              ),
              const Divider(height: 24),
              _buildRecommendationItem(
                'Early intervention needed for delayed projects',
                '23 projects show signs of potential delays based on historical patterns',
                Icons.warning,
                AppTheme.warningOrange,
                'Attention Required',
              ),
              const Divider(height: 24),
              _buildRecommendationItem(
                'Optimize agency workload distribution',
                'Current allocation could be improved by 18% using capacity scoring',
                Icons.balance,
                AppTheme.secondaryBlue,
                'Efficiency Gain',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String description, IconData icon, Color color, String badge) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}