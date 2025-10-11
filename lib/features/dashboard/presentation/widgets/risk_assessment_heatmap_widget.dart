import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';

class RiskAssessmentHeatmapWidget extends StatefulWidget {
  const RiskAssessmentHeatmapWidget({super.key});

  @override
  State<RiskAssessmentHeatmapWidget> createState() => _RiskAssessmentHeatmapWidgetState();
}

class _RiskAssessmentHeatmapWidgetState extends State<RiskAssessmentHeatmapWidget> {
  String _selectedRiskType = 'All Risks';
  final List<String> _riskTypes = ['All Risks', 'Financial', 'Timeline', 'Quality', 'Compliance'];

  // Mock data - will be replaced with Supabase data
  final List<RiskData> _risks = [
    RiskData('PRJ001', 'Adarsh Gram - Village A', RiskLevel.high, 'Financial', 'Budget overrun detected', 85),
    RiskData('PRJ002', 'Hostel Construction', RiskLevel.medium, 'Timeline', 'Potential delay risk', 65),
    RiskData('PRJ003', 'Infrastructure GIA', RiskLevel.low, 'Quality', 'Minor quality concerns', 35),
    RiskData('PRJ004', 'Rural Development', RiskLevel.high, 'Compliance', 'Documentation gaps', 78),
    RiskData('PRJ005', 'Urban Planning', RiskLevel.medium, 'Financial', 'Fund utilization issues', 55),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildRiskTypeFilter(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildRiskOverview(),
                _buildRiskHeatmap(),
                _buildHighRiskProjects(),
                _buildMLPredictions(),
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
                'Risk Assessment Heat Map',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'ML-powered risk prediction and monitoring',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: AppTheme.errorRed),
                    SizedBox(width: 4),
                    Text(
                      '5 High Risk',
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refreshing risk assessment...')),
                  );
                },
                tooltip: 'Refresh',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskTypeFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            'Filter by Type:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _riskTypes.map((type) {
                  final isSelected = _selectedRiskType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedRiskType = type);
                      },
                      selectedColor: AppTheme.warningOrange.withOpacity(0.2),
                      checkmarkColor: AppTheme.warningOrange,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskOverview() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildRiskCard('Critical', '2', Icons.error, AppTheme.errorRed),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildRiskCard('High', '3', Icons.warning, AppTheme.warningOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildRiskCard('Medium', '8', Icons.info, AppTheme.secondaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildRiskCard('Low', '15', Icons.check_circle, AppTheme.successGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(String label, String count, IconData icon, Color color) {
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Projects',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskHeatmap() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Risk Distribution Matrix',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: ScatterChart(
                  ScatterChartData(
                    scatterSpots: [
                      ScatterSpot(2, 8, dotPainter: FlDotCirclePainter(color: AppTheme.errorRed, radius: 12)),
                      ScatterSpot(4, 7, dotPainter: FlDotCirclePainter(color: AppTheme.errorRed, radius: 10)),
                      ScatterSpot(3, 6, dotPainter: FlDotCirclePainter(color: AppTheme.warningOrange, radius: 10)),
                      ScatterSpot(5, 5, dotPainter: FlDotCirclePainter(color: AppTheme.warningOrange, radius: 8)),
                      ScatterSpot(6, 4, dotPainter: FlDotCirclePainter(color: AppTheme.secondaryBlue, radius: 8)),
                      ScatterSpot(7, 3, dotPainter: FlDotCirclePainter(color: AppTheme.secondaryBlue, radius: 6)),
                      ScatterSpot(8, 2, dotPainter: FlDotCirclePainter(color: AppTheme.successGreen, radius: 6)),
                      ScatterSpot(9, 1, dotPainter: FlDotCirclePainter(color: AppTheme.successGreen, radius: 4)),
                    ],
                    minX: 0,
                    maxX: 10,
                    minY: 0,
                    maxY: 10,
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        axisNameWidget: const Text('Likelihood →'),
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: const Text('Impact ↑'),
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      verticalInterval: 1,
                    ),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeatmapLegend('Critical', AppTheme.errorRed),
                  const SizedBox(width: 16),
                  _buildHeatmapLegend('High', AppTheme.warningOrange),
                  const SizedBox(width: 16),
                  _buildHeatmapLegend('Medium', AppTheme.secondaryBlue),
                  const SizedBox(width: 16),
                  _buildHeatmapLegend('Low', AppTheme.successGreen),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeatmapLegend(String label, Color color) {
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
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildHighRiskProjects() {
    final highRisks = _risks.where((r) => r.level == RiskLevel.high).toList();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'High Risk Projects Requiring Attention',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.notifications_active, size: 16),
                    label: const Text('Alert All'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sending alerts to stakeholders...')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRed,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: highRisks.length,
              itemBuilder: (context, index) {
                return _buildRiskItem(highRisks[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskItem(RiskData risk) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getRiskColor(risk.level).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getRiskIcon(risk.level),
            color: _getRiskColor(risk.level),
            size: 24,
          ),
        ),
        title: Text(
          risk.projectName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${risk.projectId}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(risk.category),
                  backgroundColor: _getRiskColor(risk.level).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _getRiskColor(risk.level),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Risk Score: ${risk.score}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: _getRiskColor(risk.level),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        risk.description,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Recommended Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildActionItem('Conduct immediate financial audit'),
                _buildActionItem('Schedule stakeholder meeting'),
                _buildActionItem('Review project timeline and milestones'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.flag),
                      label: const Text('Create Flag'),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warningOrange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.secondaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              action,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMLPredictions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        color: AppTheme.primaryIndigo.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: AppTheme.primaryIndigo),
                  const SizedBox(width: 8),
                  Text(
                    'ML Risk Predictions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified, size: 16, color: AppTheme.successGreen),
                        SizedBox(width: 4),
                        Text(
                          'Model Accuracy: 89%',
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
              const SizedBox(height: 16),
              _buildPredictionItem(
                'Projects at risk of budget overrun',
                '3 projects predicted to exceed budget by >10% in next quarter',
                Icons.account_balance,
                AppTheme.warningOrange,
              ),
              const Divider(height: 24),
              _buildPredictionItem(
                'Timeline delay probability',
                '5 projects show 75%+ probability of missing deadlines',
                Icons.schedule,
                AppTheme.errorRed,
              ),
              const Divider(height: 24),
              _buildPredictionItem(
                'Compliance risk forecast',
                '2 projects may face regulatory issues based on historical patterns',
                Icons.gavel,
                AppTheme.warningOrange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionItem(String title, String description, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return AppTheme.successGreen;
      case RiskLevel.medium:
        return AppTheme.secondaryBlue;
      case RiskLevel.high:
        return AppTheme.warningOrange;
      case RiskLevel.critical:
        return AppTheme.errorRed;
    }
  }

  IconData _getRiskIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.medium:
        return Icons.info;
      case RiskLevel.high:
        return Icons.warning;
      case RiskLevel.critical:
        return Icons.error;
    }
  }
}

enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

class RiskData {
  final String projectId;
  final String projectName;
  final RiskLevel level;
  final String category;
  final String description;
  final int score;

  RiskData(
    this.projectId,
    this.projectName,
    this.level,
    this.category,
    this.description,
    this.score,
  );
}