import 'package:flutter/material.dart';
import '../../../../core/services/dashboard_analytics_service.dart';
import '../../../../core/services/mock_dashboard_data_service.dart';
import '../../../../core/theme/app_theme.dart';

/// National Compliance Scoreboard Widget
/// 
/// Gamified compliance tracking system showing state and agency rankings
/// with achievement badges and real-time compliance scores.
class ComplianceScoreboardWidget extends StatefulWidget {
  const ComplianceScoreboardWidget({super.key});

  @override
  State<ComplianceScoreboardWidget> createState() => _ComplianceScoreboardWidgetState();
}

class _ComplianceScoreboardWidgetState extends State<ComplianceScoreboardWidget> {
  final DashboardAnalyticsService _analyticsService = DashboardAnalyticsService();
  
  String _sortBy = 'overall'; // 'overall', 'financial', 'timeline', 'quality'
  bool _ascending = false;

  Color _getScoreColor(double score) {
    if (score >= 90) return AppTheme.successGreen;
    if (score >= 70) return Colors.yellow.shade700;
    if (score >= 50) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  IconData _getBadgeIcon(String badge) {
    switch (badge) {
      case '100_compliance':
        return Icons.verified;
      case 'early_completion':
        return Icons.rocket_launch;
      case 'quality_excellence':
        return Icons.diamond;
      case 'innovation_leader':
        return Icons.lightbulb;
      case 'best_practices':
        return Icons.stars;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use mock data for now since backend is not connected
    final data = MockDashboardDataService.getMockComplianceData();

    // Sort rankings
    final sortedRankings = List<ComplianceRanking>.from(data.rankings);
    sortedRankings.sort((a, b) {
      late double scoreA, scoreB;
      
      switch (_sortBy) {
        case 'financial':
          scoreA = a.financialScore;
          scoreB = b.financialScore;
          break;
        case 'timeline':
          scoreA = a.timelineScore;
          scoreB = b.timelineScore;
          break;
        case 'quality':
          scoreA = a.qualityScore;
          scoreB = b.qualityScore;
          break;
        default:
          scoreA = a.overallScore;
          scoreB = b.overallScore;
      }
      
      return _ascending
          ? scoreA.compareTo(scoreB)
          : scoreB.compareTo(scoreA);
    });

    return Column(
      children: [
        // Top performers carousel
        _buildTopPerformersCarousel(data.topPerformers),
        
        const SizedBox(height: 16),
        
        // Sort controls
        _buildSortControls(),
        
        const SizedBox(height: 16),
        
        // Rankings table
        Expanded(
          child: _buildRankingsTable(sortedRankings),
        ),
      ],
    );
  }

  Widget _buildTopPerformersCarousel(List<CompliancePerformer> performers) {
    if (performers.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Performers',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: performers.length,
              itemBuilder: (context, index) {
                final performer = performers[index];
                return _buildPerformerCard(performer, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformerCard(CompliancePerformer performer, int rank) {
    Color getRankColor() {
      if (rank == 1) return Colors.amber;
      if (rank == 2) return Colors.grey.shade400;
      if (rank == 3) return Colors.brown.shade300;
      return AppTheme.primaryIndigo;
    }

    return Card(
      margin: const EdgeInsets.only(right: 12),
      elevation: 4,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: getRankColor(),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    rank <= 3 ? Icons.emoji_events : Icons.star,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: getRankColor(), width: 2),
                    ),
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: getRankColor(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              performer.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${performer.score.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _getScoreColor(performer.score),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Text('Sort by:'),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: _sortBy,
              items: const [
                DropdownMenuItem(value: 'overall', child: Text('Overall Score')),
                DropdownMenuItem(value: 'financial', child: Text('Financial')),
                DropdownMenuItem(value: 'timeline', child: Text('Timeline')),
                DropdownMenuItem(value: 'quality', child: Text('Quality')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortBy = value);
                }
              },
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
              onPressed: () {
                setState(() => _ascending = !_ascending);
              },
              tooltip: _ascending ? 'Ascending' : 'Descending',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingsTable(List<ComplianceRanking> rankings) {
    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(
              label: Text(
                'Rank',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'State/Agency',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Overall',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Financial',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Timeline',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Quality',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Badges',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          rows: rankings.asMap().entries.map((entry) {
            final index = entry.key;
            final ranking = entry.value;
            
            return DataRow(
              cells: [
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: index < 3 
                          ? (index == 0 ? Colors.amber : index == 1 ? Colors.grey.shade400 : Colors.brown.shade300).withOpacity(0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: index < 3 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    ranking.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(_buildScoreWidget(ranking.overallScore)),
                DataCell(_buildScoreIndicator(ranking.financialScore)),
                DataCell(_buildScoreIndicator(ranking.timelineScore)),
                DataCell(_buildScoreIndicator(ranking.qualityScore)),
                DataCell(_buildBadgeDisplay(ranking.badges)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildScoreWidget(double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getScoreColor(score).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getScoreColor(score)),
      ),
      child: Text(
        '${score.toStringAsFixed(1)}%',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _getScoreColor(score),
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(double score) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: score / 100,
            child: Container(
              decoration: BoxDecoration(
                color: _getScoreColor(score),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          score.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 12,
            color: _getScoreColor(score),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeDisplay(List<String> badges) {
    if (badges.isEmpty) {
      return const Text('-', style: TextStyle(color: Colors.grey));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...badges.take(3).map((badge) {
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Tooltip(
              message: badge.replaceAll('_', ' ').toUpperCase(),
              child: Icon(
                _getBadgeIcon(badge),
                size: 20,
                color: AppTheme.accentTeal,
              ),
            ),
          );
        }),
        if (badges.length > 3)
          Text(
            '+${badges.length - 3}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}