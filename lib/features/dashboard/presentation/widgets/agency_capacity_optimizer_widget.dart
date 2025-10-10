import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';

class AgencyCapacityOptimizerWidget extends StatefulWidget {
  const AgencyCapacityOptimizerWidget({super.key});

  @override
  State<AgencyCapacityOptimizerWidget> createState() => _AgencyCapacityOptimizerWidgetState();
}

class _AgencyCapacityOptimizerWidgetState extends State<AgencyCapacityOptimizerWidget> {
  String _selectedDistrict = 'All Districts';
  final List<String> _districts = ['All Districts', 'Central Delhi', 'East Delhi', 'North Delhi', 'South Delhi', 'West Delhi'];

  // Mock data - will be replaced with Supabase data
  final List<AgencyCapacityData> _agencies = [
    AgencyCapacityData('Delhi Development Agency', 85, 12, 8, 92),
    AgencyCapacityData('North Zone Implementation', 72, 18, 15, 78),
    AgencyCapacityData('South District Welfare', 68, 9, 7, 88),
    AgencyCapacityData('Central Projects Board', 90, 15, 10, 95),
    AgencyCapacityData('East Delhi Authority', 65, 20, 18, 72),
    AgencyCapacityData('West Zone Development', 78, 14, 11, 82),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildDistrictFilter(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildCapacityChart(),
                _buildAgencyList(),
                _buildOptimizationSuggestions(),
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
                'Agency Capacity Optimizer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'AI-driven workload balancing and resource allocation',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.auto_fix_high, size: 16),
                label: const Text('Auto-Optimize'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Running optimization algorithm...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryIndigo,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refreshing agency data...')),
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

  Widget _buildDistrictFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            'Filter by District:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _districts.map((district) {
                  final isSelected = _selectedDistrict == district;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(district),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedDistrict = district);
                      },
                      selectedColor: AppTheme.secondaryBlue.withOpacity(0.2),
                      checkmarkColor: AppTheme.secondaryBlue,
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

  Widget _buildCapacityChart() {
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
                'Agency Capacity Distribution',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final agency = _agencies[groupIndex];
                          return BarTooltipItem(
                            '${agency.name}\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: 'Capacity: ${agency.capacityScore}%\n',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              TextSpan(
                                text: 'Active: ${agency.activeProjects}\n',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              TextSpan(
                                text: 'Completed: ${agency.completedProjects}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          );
                        },
                      ),
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
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= _agencies.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _agencies[index].name.split(' ')[0],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
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
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _agencies.asMap().entries.map((entry) {
                      final index = entry.key;
                      final agency = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: agency.capacityScore.toDouble(),
                            width: 40,
                            color: _getCapacityColor(agency.capacityScore),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCapacityColor(int capacity) {
    if (capacity >= 80) return AppTheme.successGreen;
    if (capacity >= 60) return AppTheme.secondaryBlue;
    if (capacity >= 40) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  Widget _buildAgencyList() {
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
                    'Agency Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exporting agency data...')),
                      );
                    },
                    tooltip: 'Export Data',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _agencies.length,
              itemBuilder: (context, index) {
                final agency = _agencies[index];
                return _buildAgencyListItem(agency);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgencyListItem(AgencyCapacityData agency) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getCapacityColor(agency.capacityScore),
          child: Text(
            '${agency.capacityScore}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          agency.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${agency.activeProjects} active projects'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Capacity Score',
                        '${agency.capacityScore}%',
                        Icons.speed,
                        _getCapacityColor(agency.capacityScore),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Active Projects',
                        '${agency.activeProjects}',
                        Icons.work,
                        AppTheme.secondaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Completed',
                        '${agency.completedProjects}',
                        Icons.check_circle,
                        AppTheme.successGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Performance',
                        '${agency.performanceScore}%',
                        Icons.trending_up,
                        AppTheme.primaryIndigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.assignment_add),
                      label: const Text('Assign Project'),
                      onPressed: () {},
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.analytics),
                      label: const Text('View Analytics'),
                      onPressed: () {},
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Details'),
                      onPressed: () {},
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

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationSuggestions() {
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
                  Icon(Icons.psychology, color: AppTheme.primaryIndigo),
                  const SizedBox(width: 8),
                  Text(
                    'AI Optimization Suggestions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSuggestionItem(
                'Redistribute workload from East Delhi Authority',
                'This agency is at 65% capacity with 20 active projects. Consider redistributing 3-4 projects to underutilized agencies.',
                Icons.swap_horiz,
                AppTheme.warningOrange,
              ),
              const Divider(height: 24),
              _buildSuggestionItem(
                'Assign new projects to Central Projects Board',
                'This high-performing agency (90% capacity, 95% performance) can handle 2-3 additional projects efficiently.',
                Icons.add_task,
                AppTheme.successGreen,
              ),
              const Divider(height: 24),
              _buildSuggestionItem(
                'Capacity building needed for North Zone Implementation',
                'Performance at 78% with moderate capacity (72%). Training programs could improve throughput by 15-20%.',
                Icons.school,
                AppTheme.secondaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String title, String description, IconData icon, Color color) {
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
}

class AgencyCapacityData {
  final String name;
  final int capacityScore;
  final int activeProjects;
  final int completedProjects;
  final int performanceScore;

  AgencyCapacityData(
    this.name,
    this.capacityScore,
    this.activeProjects,
    this.completedProjects,
    this.performanceScore,
  );
}