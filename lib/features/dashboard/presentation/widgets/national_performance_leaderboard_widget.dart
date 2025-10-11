import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// National Performance Leaderboard Widget
/// 
/// Shows top 5 States by on-time completion, fund utilization, and quality metrics
/// with achievement badges for exemplary performance.
class NationalPerformanceLeaderboardWidget extends StatefulWidget {
  const NationalPerformanceLeaderboardWidget({super.key});

  @override
  State<NationalPerformanceLeaderboardWidget> createState() => 
      _NationalPerformanceLeaderboardWidgetState();
}

class _NationalPerformanceLeaderboardWidgetState 
    extends State<NationalPerformanceLeaderboardWidget> 
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  String _selectedMetric = 'overall'; // 'overall', 'completion', 'utilization', 'quality'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<StatePerformance> _mockPerformanceData = [
    StatePerformance(
      rank: 1,
      stateName: 'Maharashtra',
      overallScore: 95.8,
      completionRate: 97.5,
      fundUtilization: 94.2,
      qualityScore: 95.7,
      badges: ['100_compliance', 'quality_excellence', 'innovation_leader'],
      trend: 2.5,
      totalProjects: 78,
      completedProjects: 76,
    ),
    StatePerformance(
      rank: 2,
      stateName: 'Karnataka',
      overallScore: 93.4,
      completionRate: 95.2,
      fundUtilization: 91.8,
      qualityScore: 93.2,
      badges: ['early_completion', 'best_practices'],
      trend: 1.8,
      totalProjects: 62,
      completedProjects: 59,
    ),
    StatePerformance(
      rank: 3,
      stateName: 'Tamil Nadu',
      overallScore: 91.2,
      completionRate: 92.8,
      fundUtilization: 89.5,
      qualityScore: 91.3,
      badges: ['quality_excellence'],
      trend: -0.5,
      totalProjects: 56,
      completedProjects: 52,
    ),
    StatePerformance(
      rank: 4,
      stateName: 'Gujarat',
      overallScore: 88.7,
      completionRate: 90.1,
      fundUtilization: 87.2,
      qualityScore: 88.9,
      badges: ['best_practices'],
      trend: 1.2,
      totalProjects: 45,
      completedProjects: 41,
    ),
    StatePerformance(
      rank: 5,
      stateName: 'Delhi',
      overallScore: 86.5,
      completionRate: 88.3,
      fundUtilization: 84.8,
      qualityScore: 86.4,
      badges: [],
      trend: 0.8,
      totalProjects: 45,
      completedProjects: 40,
    ),
  ];

  List<StatePerformance> get _sortedPerformanceData {
    var data = List<StatePerformance>.from(_mockPerformanceData);
    data.sort((a, b) {
      switch (_selectedMetric) {
        case 'completion':
          return b.completionRate.compareTo(a.completionRate);
        case 'utilization':
          return b.fundUtilization.compareTo(a.fundUtilization);
        case 'quality':
          return b.qualityScore.compareTo(a.qualityScore);
        default:
          return b.overallScore.compareTo(a.overallScore);
      }
    });
    
    // Update ranks based on current sorting
    for (int i = 0; i < data.length; i++) {
      data[i] = data[i].copyWith(rank: i + 1);
    }
    
    return data;
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey.shade400;
    }
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

  String _getBadgeName(String badge) {
    switch (badge) {
      case '100_compliance':
        return '100% Compliance';
      case 'early_completion':
        return 'Early Completion';
      case 'quality_excellence':
        return 'Quality Excellence';
      case 'innovation_leader':
        return 'Innovation Leader';
      case 'best_practices':
        return 'Best Practices';
      default:
        return badge;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildMetricTabs(),
        Expanded(
          child: _buildLeaderboard(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryIndigo, AppTheme.secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, size: 40, color: Colors.amber.shade300),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'National Performance Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Top 5 performing states across India',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            switch (index) {
              case 0:
                _selectedMetric = 'overall';
                break;
              case 1:
                _selectedMetric = 'completion';
                break;
              case 2:
                _selectedMetric = 'utilization';
                break;
              case 3:
                _selectedMetric = 'quality';
                break;
            }
          });
        },
        labelColor: AppTheme.primaryIndigo,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primaryIndigo,
        tabs: const [
          Tab(text: 'Overall', icon: Icon(Icons.star, size: 20)),
          Tab(text: 'Completion', icon: Icon(Icons.check_circle, size: 20)),
          Tab(text: 'Fund Usage', icon: Icon(Icons.account_balance, size: 20)),
          Tab(text: 'Quality', icon: Icon(Icons.diamond, size: 20)),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    final sortedData = _sortedPerformanceData;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedData.length,
      itemBuilder: (context, index) {
        return _buildLeaderboardCard(sortedData[index], index);
      },
    );
  }

  Widget _buildLeaderboardCard(StatePerformance state, int index) {
    final isTopThree = state.rank <= 3;
    final rankColor = _getRankColor(state.rank);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isTopThree ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isTopThree
            ? BorderSide(color: rankColor, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        decoration: isTopThree
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    rankColor.withOpacity(0.1),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Rank Badge
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: rankColor,
                      shape: BoxShape.circle,
                      boxShadow: isTopThree
                          ? [
                              BoxShadow(
                                color: rankColor.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '#${state.rank}',
                        style: TextStyle(
                          color: isTopThree ? Colors.white : Colors.grey.shade700,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // State Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              state.stateName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (state.trend != 0) ...[
                              const SizedBox(width: 8),
                              Icon(
                                state.trend > 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: state.trend > 0
                                    ? AppTheme.successGreen
                                    : AppTheme.errorRed,
                                size: 20,
                              ),
                              Text(
                                '${state.trend > 0 ? '+' : ''}${state.trend.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: state.trend > 0
                                      ? AppTheme.successGreen
                                      : AppTheme.errorRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.completedProjects}/${state.totalProjects} projects completed',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Score Display
                  _buildScoreDisplay(state),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              // Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      'Completion',
                      state.completionRate,
                      Icons.check_circle,
                      AppTheme.successGreen,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      'Fund Usage',
                      state.fundUtilization,
                      Icons.account_balance,
                      AppTheme.secondaryBlue,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      'Quality',
                      state.qualityScore,
                      Icons.diamond,
                      AppTheme.accentTeal,
                    ),
                  ),
                ],
              ),
              
              // Badges
              if (state.badges.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.badges.map((badge) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.accentTeal.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getBadgeIcon(badge),
                            size: 16,
                            color: AppTheme.accentTeal,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getBadgeName(badge),
                            style: const TextStyle(
                              color: AppTheme.accentTeal,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreDisplay(StatePerformance state) {
    double displayScore;
    switch (_selectedMetric) {
      case 'completion':
        displayScore = state.completionRate;
        break;
      case 'utilization':
        displayScore = state.fundUtilization;
        break;
      case 'quality':
        displayScore = state.qualityScore;
        break;
      default:
        displayScore = state.overallScore;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryIndigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            displayScore.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryIndigo,
            ),
          ),
          Text(
            'SCORE',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    double value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontSize: 10,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// State Performance Model
class StatePerformance {
  final int rank;
  final String stateName;
  final double overallScore;
  final double completionRate;
  final double fundUtilization;
  final double qualityScore;
  final List<String> badges;
  final double trend; // Positive for improvement, negative for decline
  final int totalProjects;
  final int completedProjects;

  StatePerformance({
    required this.rank,
    required this.stateName,
    required this.overallScore,
    required this.completionRate,
    required this.fundUtilization,
    required this.qualityScore,
    required this.badges,
    required this.trend,
    required this.totalProjects,
    required this.completedProjects,
  });

  StatePerformance copyWith({
    int? rank,
    String? stateName,
    double? overallScore,
    double? completionRate,
    double? fundUtilization,
    double? qualityScore,
    List<String>? badges,
    double? trend,
    int? totalProjects,
    int? completedProjects,
  }) {
    return StatePerformance(
      rank: rank ?? this.rank,
      stateName: stateName ?? this.stateName,
      overallScore: overallScore ?? this.overallScore,
      completionRate: completionRate ?? this.completionRate,
      fundUtilization: fundUtilization ?? this.fundUtilization,
      qualityScore: qualityScore ?? this.qualityScore,
      badges: badges ?? this.badges,
      trend: trend ?? this.trend,
      totalProjects: totalProjects ?? this.totalProjects,
      completedProjects: completedProjects ?? this.completedProjects,
    );
  }
}