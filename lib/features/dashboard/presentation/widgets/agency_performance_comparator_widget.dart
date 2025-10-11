import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Agency Performance Comparator Widget
/// 
/// Side-by-side comparison of agency performance metrics
/// with drill-down analytics and benchmark indicators.
class AgencyPerformanceComparatorWidget extends StatefulWidget {
  final String stateId;
  
  const AgencyPerformanceComparatorWidget({
    super.key,
    required this.stateId,
  });

  @override
  State<AgencyPerformanceComparatorWidget> createState() => 
      _AgencyPerformanceComparatorWidgetState();
}

class _AgencyPerformanceComparatorWidgetState 
    extends State<AgencyPerformanceComparatorWidget> {
  
  String _selectedMetric = 'overall'; // 'overall', 'completion', 'quality', 'speed'
  final List<String> _selectedAgencies = ['agency_001', 'agency_002'];

  final List<AgencyPerformance> _mockAgencies = [
    AgencyPerformance(
      id: 'agency_001',
      name: 'Alpha Construction',
      overallScore: 87.5,
      completionRate: 92.0,
      qualityScore: 88.0,
      avgCompletionTime: 145,
      activeProjects: 12,
      completedProjects: 48,
      totalBudget: 5000000,
      onTimeDelivery: 85.0,
      costEfficiency: 90.0,
    ),
    AgencyPerformance(
      id: 'agency_002',
      name: 'Beta Infrastructure',
      overallScore: 82.3,
      completionRate: 88.0,
      qualityScore: 85.0,
      avgCompletionTime: 160,
      activeProjects: 8,
      completedProjects: 35,
      totalBudget: 3500000,
      onTimeDelivery: 80.0,
      costEfficiency: 87.0,
    ),
    AgencyPerformance(
      id: 'agency_003',
      name: 'Gamma Developers',
      overallScore: 91.2,
      completionRate: 95.0,
      qualityScore: 92.0,
      avgCompletionTime: 130,
      activeProjects: 15,
      completedProjects: 62,
      totalBudget: 7500000,
      onTimeDelivery: 93.0,
      costEfficiency: 95.0,
    ),
    AgencyPerformance(
      id: 'agency_004',
      name: 'Delta Engineering',
      overallScore: 78.9,
      completionRate: 82.0,
      qualityScore: 80.0,
      avgCompletionTime: 175,
      activeProjects: 6,
      completedProjects: 28,
      totalBudget: 2800000,
      onTimeDelivery: 75.0,
      costEfficiency: 82.0,
    ),
  ];

  List<AgencyPerformance> get _availableAgencies {
    return _mockAgencies.where((a) => !_selectedAgencies.contains(a.id)).toList();
  }

  void _addAgency(String agencyId) {
    if (_selectedAgencies.length < 4) {
      setState(() => _selectedAgencies.add(agencyId));
    }
  }

  void _removeAgency(String agencyId) {
    if (_selectedAgencies.length > 2) {
      setState(() => _selectedAgencies.remove(agencyId));
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 85) return AppTheme.successGreen;
    if (score >= 70) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildControls(),
        Expanded(
          child: _buildComparisonView(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.stateOfficerColor, AppTheme.secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.leaderboard, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agency Performance Comparator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Side-by-side performance analysis with benchmarks',
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

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Metric View:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'overall',
                      label: Text('Overall'),
                      icon: Icon(Icons.star),
                    ),
                    ButtonSegment(
                      value: 'completion',
                      label: Text('Completion'),
                      icon: Icon(Icons.task_alt),
                    ),
                    ButtonSegment(
                      value: 'quality',
                      label: Text('Quality'),
                      icon: Icon(Icons.verified),
                    ),
                    ButtonSegment(
                      value: 'speed',
                      label: Text('Speed'),
                      icon: Icon(Icons.speed),
                    ),
                  ],
                  selected: {_selectedMetric},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() => _selectedMetric = newSelection.first);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              const Text('Compare:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._selectedAgencies.map((id) {
                final agency = _mockAgencies.firstWhere((a) => a.id == id);
                return Chip(
                  label: Text(agency.name),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: _selectedAgencies.length > 2 ? () => _removeAgency(id) : null,
                );
              }),
              if (_selectedAgencies.length < 4 && _availableAgencies.isNotEmpty)
                ActionChip(
                  label: const Text('+ Add Agency'),
                  onPressed: () => _showAgencySelector(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView() {
    final selectedData = _mockAgencies
        .where((a) => _selectedAgencies.contains(a.id))
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selectedData.map((agency) {
              return _buildAgencyColumn(agency);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAgencyColumn(AgencyPerformance agency) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agency Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getScoreColor(agency.overallScore).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agency.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: _getScoreColor(agency.overallScore),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        agency.overallScore.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(agency.overallScore),
                        ),
                      ),
                      const Text('/100'),
                    ],
                  ),
                ],
              ),
            ),
            
            // Metrics
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMetricRow(
                    'Completion Rate',
                    '${agency.completionRate.toStringAsFixed(1)}%',
                    agency.completionRate,
                    Icons.task_alt,
                  ),
                  const Divider(),
                  _buildMetricRow(
                    'Quality Score',
                    '${agency.qualityScore.toStringAsFixed(1)}%',
                    agency.qualityScore,
                    Icons.verified,
                  ),
                  const Divider(),
                  _buildMetricRow(
                    'Avg. Completion',
                    '${agency.avgCompletionTime} days',
                    (180 - agency.avgCompletionTime) / 180 * 100,
                    Icons.schedule,
                  ),
                  const Divider(),
                  _buildMetricRow(
                    'On-Time Delivery',
                    '${agency.onTimeDelivery.toStringAsFixed(1)}%',
                    agency.onTimeDelivery,
                    Icons.schedule_send,
                  ),
                  const Divider(),
                  _buildMetricRow(
                    'Cost Efficiency',
                    '${agency.costEfficiency.toStringAsFixed(1)}%',
                    agency.costEfficiency,
                    Icons.currency_rupee,
                  ),
                  const SizedBox(height: 16),
                  
                  // Project Stats
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Active Projects:'),
                            Text(
                              agency.activeProjects.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Completed:'),
                            Text(
                              agency.completedProjects.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Budget:'),
                            Text(
                              _formatCurrency(agency.totalBudget),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, double score, IconData icon) {
    final color = _getScoreColor(score);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Text(
                value,
                style: TextStyle(
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
              value: score / 100,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  void _showAgencySelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Agency to Compare',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._availableAgencies.map((agency) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getScoreColor(agency.overallScore),
                    child: Text(
                      agency.overallScore.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(agency.name),
                  subtitle: Text('${agency.activeProjects} active projects'),
                  trailing: const Icon(Icons.add),
                  onTap: () {
                    _addAgency(agency.id);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }
}

/// Agency Performance Model
class AgencyPerformance {
  final String id;
  final String name;
  final double overallScore;
  final double completionRate;
  final double qualityScore;
  final int avgCompletionTime;
  final int activeProjects;
  final int completedProjects;
  final double totalBudget;
  final double onTimeDelivery;
  final double costEfficiency;

  AgencyPerformance({
    required this.id,
    required this.name,
    required this.overallScore,
    required this.completionRate,
    required this.qualityScore,
    required this.avgCompletionTime,
    required this.activeProjects,
    required this.completedProjects,
    required this.totalBudget,
    required this.onTimeDelivery,
    required this.costEfficiency,
  });
}