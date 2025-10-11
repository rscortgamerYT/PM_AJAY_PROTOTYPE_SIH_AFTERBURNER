import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// District Capacity Planner Widget
/// 
/// Visual capacity heatmap of agencies versus district demand
/// with AI suggestions for workload balancing.
class DistrictCapacityPlannerWidget extends StatefulWidget {
  final String stateId;
  
  const DistrictCapacityPlannerWidget({
    super.key,
    required this.stateId,
  });

  @override
  State<DistrictCapacityPlannerWidget> createState() => 
      _DistrictCapacityPlannerWidgetState();
}

class _DistrictCapacityPlannerWidgetState 
    extends State<DistrictCapacityPlannerWidget> {
  
  String _selectedView = 'heatmap'; // 'heatmap', 'table', 'recommendations'

  final List<DistrictCapacity> _mockCapacityData = [
    DistrictCapacity(
      districtName: 'Mumbai',
      totalDemand: 25,
      availableAgencies: 8,
      allocatedProjects: 22,
      capacityUtilization: 88.0,
      status: 'optimal',
      agencies: ['Agency A', 'Agency B', 'Agency C'],
    ),
    DistrictCapacity(
      districtName: 'Pune',
      totalDemand: 18,
      availableAgencies: 4,
      allocatedProjects: 18,
      capacityUtilization: 100.0,
      status: 'overloaded',
      agencies: ['Agency D', 'Agency E'],
    ),
    DistrictCapacity(
      districtName: 'Nashik',
      totalDemand: 12,
      availableAgencies: 6,
      allocatedProjects: 8,
      capacityUtilization: 66.7,
      status: 'underutilized',
      agencies: ['Agency F', 'Agency G', 'Agency H'],
    ),
    DistrictCapacity(
      districtName: 'Nagpur',
      totalDemand: 15,
      availableAgencies: 5,
      allocatedProjects: 14,
      capacityUtilization: 93.3,
      status: 'optimal',
      agencies: ['Agency I', 'Agency J'],
    ),
    DistrictCapacity(
      districtName: 'Aurangabad',
      totalDemand: 10,
      availableAgencies: 3,
      allocatedProjects: 10,
      capacityUtilization: 100.0,
      status: 'overloaded',
      agencies: ['Agency K'],
    ),
  ];

  final List<AIRecommendation> _mockRecommendations = [
    AIRecommendation(
      priority: 'High',
      district: 'Pune',
      recommendation: 'Reassign 3 projects to Nashik district to balance workload',
      impact: 'Will reduce Pune utilization to 83% and increase Nashik to 92%',
      estimatedCost: 0,
    ),
    AIRecommendation(
      priority: 'High',
      district: 'Aurangabad',
      recommendation: 'Onboard 2 additional agencies to handle current demand',
      impact: 'Will reduce capacity pressure and improve delivery timelines',
      estimatedCost: 50000,
    ),
    AIRecommendation(
      priority: 'Medium',
      district: 'Nashik',
      recommendation: 'Allocate 4 additional projects to maximize capacity',
      impact: 'Will improve utilization from 67% to 100%',
      estimatedCost: 0,
    ),
  ];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'optimal':
        return AppTheme.successGreen;
      case 'overloaded':
        return AppTheme.errorRed;
      case 'underutilized':
        return AppTheme.warningOrange;
      default:
        return Colors.grey;
    }
  }

  Color _getUtilizationColor(double utilization) {
    if (utilization >= 85 && utilization <= 95) {
      return AppTheme.successGreen;
    } else if (utilization > 95) {
      return AppTheme.errorRed;
    } else {
      return AppTheme.warningOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildViewSelector(),
        Expanded(
          child: _buildContent(),
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
          const Icon(Icons.analytics, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'District Capacity Planner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-powered workload optimization across districts',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalDemand = _mockCapacityData.fold<int>(
      0, 
      (sum, d) => sum + d.totalDemand,
    );
    final totalAllocated = _mockCapacityData.fold<int>(
      0,
      (sum, d) => sum + d.allocatedProjects,
    );
    final avgUtilization = _mockCapacityData.fold<double>(
      0,
      (sum, d) => sum + d.capacityUtilization,
    ) / _mockCapacityData.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSummaryItem('Total Demand', totalDemand.toString()),
          const SizedBox(width: 20),
          _buildSummaryItem('Allocated', totalAllocated.toString()),
          const SizedBox(width: 20),
          _buildSummaryItem('Avg. Utilization', '${avgUtilization.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'heatmap',
            label: Text('Heatmap'),
            icon: Icon(Icons.grid_on),
          ),
          ButtonSegment(
            value: 'table',
            label: Text('Table View'),
            icon: Icon(Icons.table_chart),
          ),
          ButtonSegment(
            value: 'recommendations',
            label: Text('AI Suggestions'),
            icon: Icon(Icons.psychology),
          ),
        ],
        selected: {_selectedView},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() => _selectedView = newSelection.first);
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedView) {
      case 'table':
        return _buildTableView();
      case 'recommendations':
        return _buildRecommendationsView();
      default:
        return _buildHeatmapView();
    }
  }

  Widget _buildHeatmapView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _mockCapacityData.map((district) {
          return _buildHeatmapCard(district);
        }).toList(),
      ),
    );
  }

  Widget _buildHeatmapCard(DistrictCapacity district) {
    final statusColor = _getStatusColor(district.status);
    final utilizationColor = _getUtilizationColor(district.capacityUtilization);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    district.districtName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    district.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Capacity Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Capacity Utilization',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${district.capacityUtilization.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: utilizationColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: district.capacityUtilization / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(utilizationColor),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Total Demand',
                    district.totalDemand.toString(),
                    Icons.assignment,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Agencies',
                    district.availableAgencies.toString(),
                    Icons.business,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Allocated',
                    district.allocatedProjects.toString(),
                    Icons.task_alt,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Agency List
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: district.agencies.map((agency) {
                return Chip(
                  label: Text(agency),
                  backgroundColor: AppTheme.secondaryBlue.withOpacity(0.1),
                  labelStyle: const TextStyle(fontSize: 11),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.secondaryBlue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTableView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('District')),
            DataColumn(label: Text('Demand')),
            DataColumn(label: Text('Agencies')),
            DataColumn(label: Text('Allocated')),
            DataColumn(label: Text('Utilization')),
            DataColumn(label: Text('Status')),
          ],
          rows: _mockCapacityData.map((district) {
            return DataRow(
              cells: [
                DataCell(Text(district.districtName)),
                DataCell(Text(district.totalDemand.toString())),
                DataCell(Text(district.availableAgencies.toString())),
                DataCell(Text(district.allocatedProjects.toString())),
                DataCell(
                  Text(
                    '${district.capacityUtilization.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getUtilizationColor(district.capacityUtilization),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(district.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      district.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(district.status),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecommendationsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockRecommendations.length,
      itemBuilder: (context, index) {
        return _buildRecommendationCard(_mockRecommendations[index]);
      },
    );
  }

  Widget _buildRecommendationCard(AIRecommendation recommendation) {
    final priorityColor = recommendation.priority == 'High'
        ? AppTheme.errorRed
        : AppTheme.warningOrange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: AppTheme.accentTeal),
                const SizedBox(width: 8),
                const Text(
                  'AI Recommendation',
                  style: TextStyle(
                    color: AppTheme.accentTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${recommendation.priority} Priority',
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              recommendation.district,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            
            Text(
              recommendation.recommendation,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, size: 20, color: AppTheme.successGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation.impact,
                      style: const TextStyle(
                        color: AppTheme.successGreen,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (recommendation.estimatedCost > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.currency_rupee, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Estimated Cost: ₹${recommendation.estimatedCost.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check),
                    label: const Text('Implement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// District Capacity Model
class DistrictCapacity {
  final String districtName;
  final int totalDemand;
  final int availableAgencies;
  final int allocatedProjects;
  final double capacityUtilization;
  final String status;
  final List<String> agencies;

  DistrictCapacity({
    required this.districtName,
    required this.totalDemand,
    required this.availableAgencies,
    required this.allocatedProjects,
    required this.capacityUtilization,
    required this.status,
    required this.agencies,
  });
}

/// AI Recommendation Model
class AIRecommendation {
  final String priority;
  final String district;
  final String recommendation;
  final String impact;
  final double estimatedCost;

  AIRecommendation({
    required this.priority,
    required this.district,
    required this.recommendation,
    required this.impact,
    required this.estimatedCost,
  });
}