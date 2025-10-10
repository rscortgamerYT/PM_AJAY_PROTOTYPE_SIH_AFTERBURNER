import 'package:flutter/material.dart' hide Badge;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/dashboard_analytics_service.dart';
import '../../../../core/services/mock_dashboard_data_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Enhanced Performance Analytics & Benchmarking Widget
/// 
/// Comprehensive performance tracking with peer comparisons,
/// skill gap analysis, and achievement badges.
class PerformanceAnalyticsWidget extends ConsumerStatefulWidget {
  final String agencyId;
  
  const PerformanceAnalyticsWidget({
    super.key,
    required this.agencyId,
  });

  @override
  ConsumerState<PerformanceAnalyticsWidget> createState() => _PerformanceAnalyticsWidgetState();
}

class _PerformanceAnalyticsWidgetState extends ConsumerState<PerformanceAnalyticsWidget> {
  final DashboardAnalyticsService _analyticsService = DashboardAnalyticsService();
  String _selectedMetric = 'overall';

  @override
  Widget build(BuildContext context) {
    // Use mock data for now since backend is not connected
    final performanceData = MockDashboardDataService.getMockPerformanceData(widget.agencyId);

    return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Performance score card
              _buildPerformanceScoreCard(performanceData),
              const SizedBox(height: 16),
              
              // Performance trend chart
              _buildPerformanceTrendChart(performanceData),
              const SizedBox(height: 16),
              
              // Metrics comparison
              _buildMetricsComparison(performanceData),
              const SizedBox(height: 16),
              
              // Badges section
              _buildBadgesSection(performanceData),
              const SizedBox(height: 16),
              
              // Skill gaps
              _buildSkillGapsSection(performanceData),
              const SizedBox(height: 16),
              
              // Recommendations
              _buildRecommendationsSection(performanceData),
            ],
          ),
    );
  }

  Widget _buildPerformanceScoreCard(PerformanceData data) {
    final scoreDelta = data.overallScore - data.previousScore;
    final isImproving = scoreDelta > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Performance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.neutralGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          data.overallScore.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(data.overallScore),
                          ),
                        ),
                        Text(
                          '/100',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.neutralGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isImproving
                        ? AppTheme.successGreen.withOpacity(0.1)
                        : AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isImproving ? Icons.trending_up : Icons.trending_down,
                        color: isImproving ? AppTheme.successGreen : AppTheme.errorRed,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isImproving ? '+' : ''}${scoreDelta.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isImproving ? AppTheme.successGreen : AppTheme.errorRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: data.overallScore / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(data.overallScore)),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('State Rank', '#${data.stateRanking}', Icons.leaderboard),
                _buildStatItem('Total Agencies', '${data.totalAgencies}', Icons.business),
                _buildStatItem(
                  'Percentile',
                  '${(100 - (data.stateRanking / data.totalAgencies * 100)).toStringAsFixed(0)}th',
                  Icons.show_chart,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryIndigo, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.neutralGray,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return AppTheme.successGreen;
    if (score >= 70) return Colors.yellow.shade700;
    if (score >= 50) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  Widget _buildPerformanceTrendChart(PerformanceData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < data.performanceHistory.length) {
                            final date = data.performanceHistory[value.toInt()].date;
                            return Text(
                              '${date.month}/${date.day}',
                              style: Theme.of(context).textTheme.bodySmall,
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
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.performanceHistory
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.score))
                          .toList(),
                      isCurved: true,
                      color: AppTheme.primaryIndigo,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryIndigo.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsComparison(PerformanceData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...data.agencyMetrics.entries.map((entry) {
              final peerAverage = data.peerAverages[entry.key] ?? 0;
              return _buildMetricBar(
                entry.key,
                entry.value,
                peerAverage,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBar(String metric, double value, double peerAverage) {
    final isAboveAverage = value > peerAverage;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric.replaceAll('_', ' ').toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    value.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isAboveAverage ? AppTheme.successGreen : AppTheme.warningOrange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isAboveAverage ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: isAboveAverage ? AppTheme.successGreen : AppTheme.warningOrange,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: isAboveAverage ? AppTheme.successGreen : AppTheme.warningOrange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Positioned(
                left: (peerAverage / 100) * MediaQuery.of(context).size.width * 0.8,
                child: Container(
                  width: 2,
                  height: 12,
                  color: AppTheme.neutralGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Peer Average: ${peerAverage.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.neutralGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(PerformanceData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Achievement Badges',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${data.earnedBadges.length}/${data.availableBadges.length}'),
                  backgroundColor: AppTheme.primaryIndigo.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...data.earnedBadges.map((badge) => _buildBadge(badge, true)),
                ...data.availableBadges
                    .where((b) => !data.earnedBadges.any((e) => e.id == b.id))
                    .map((badge) => _buildBadge(badge, false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(Badge badge, bool isEarned) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isEarned
            ? AppTheme.successGreen.withOpacity(0.1)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEarned ? AppTheme.successGreen : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            badge.icon,
            style: TextStyle(
              fontSize: 32,
              color: isEarned ? null : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isEarned ? null : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillGapsSection(PerformanceData data) {
    if (data.skillGaps.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: AppTheme.warningOrange),
                const SizedBox(width: 8),
                Text(
                  'Skill Gaps',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...data.skillGaps.map((gap) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: AppTheme.warningOrange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      gap.skillName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to training resources
                    },
                    child: const Text('Learn'),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(PerformanceData data) {
    if (data.recommendations.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppTheme.accentTeal),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...data.recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accentTeal.withOpacity(0.2)),
                ),
                child: Text(
                  rec.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}