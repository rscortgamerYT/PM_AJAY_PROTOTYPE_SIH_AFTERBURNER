import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Fund Allocation Simulator Widget
/// 
/// Drag-and-drop budgeting interface with real-time impact modeling
/// for testing "what-if" scenarios before committing funds.
class FundAllocationSimulatorWidget extends StatefulWidget {
  final String stateId;
  
  const FundAllocationSimulatorWidget({
    super.key,
    required this.stateId,
  });

  @override
  State<FundAllocationSimulatorWidget> createState() => 
      _FundAllocationSimulatorWidgetState();
}

class _FundAllocationSimulatorWidgetState 
    extends State<FundAllocationSimulatorWidget> {
  
  double _totalBudget = 10000000; // 1 crore
  
  final List<BudgetCategory> _categories = [
    BudgetCategory(
      name: 'Water Supply Infrastructure',
      allocated: 3500000,
      color: AppTheme.secondaryBlue,
      icon: Icons.water_drop,
      impactMetrics: ImpactMetrics(
        householdsServed: 15000,
        completionTime: 180,
        qualityScore: 85,
      ),
    ),
    BudgetCategory(
      name: 'Toilet Construction',
      allocated: 2500000,
      color: AppTheme.accentTeal,
      icon: Icons.wc,
      impactMetrics: ImpactMetrics(
        householdsServed: 10000,
        completionTime: 150,
        qualityScore: 90,
      ),
    ),
    BudgetCategory(
      name: 'Maintenance & Operations',
      allocated: 1500000,
      color: AppTheme.warningOrange,
      icon: Icons.build,
      impactMetrics: ImpactMetrics(
        householdsServed: 25000,
        completionTime: 365,
        qualityScore: 75,
      ),
    ),
    BudgetCategory(
      name: 'Training & Capacity Building',
      allocated: 1000000,
      color: AppTheme.successGreen,
      icon: Icons.school,
      impactMetrics: ImpactMetrics(
        householdsServed: 5000,
        completionTime: 120,
        qualityScore: 80,
      ),
    ),
    BudgetCategory(
      name: 'IEC Activities',
      allocated: 1500000,
      color: Colors.purple,
      icon: Icons.campaign,
      impactMetrics: ImpactMetrics(
        householdsServed: 30000,
        completionTime: 365,
        qualityScore: 70,
      ),
    ),
  ];

  List<ScenarioComparison> _scenarios = [];
  int _activeScenarioIndex = 0;

  @override
  void initState() {
    super.initState();
    _saveCurrentScenario('Current Allocation');
  }

  double get _allocatedTotal => _categories.fold(
    0, 
    (sum, cat) => sum + cat.allocated,
  );

  double get _unallocated => _totalBudget - _allocatedTotal;

  void _updateAllocation(int index, double newValue) {
    setState(() {
      _categories[index].allocated = newValue;
    });
  }

  void _saveCurrentScenario(String name) {
    final scenario = ScenarioComparison(
      name: name,
      timestamp: DateTime.now(),
      allocations: Map.fromEntries(
        _categories.map((cat) => MapEntry(cat.name, cat.allocated)),
      ),
      totalImpact: _calculateTotalImpact(),
    );
    
    setState(() {
      _scenarios.add(scenario);
      _activeScenarioIndex = _scenarios.length - 1;
    });
  }

  TotalImpact _calculateTotalImpact() {
    return TotalImpact(
      totalHouseholdsServed: _categories.fold(
        0,
        (sum, cat) => sum + cat.impactMetrics.householdsServed,
      ),
      avgCompletionTime: _categories.fold(
        0.0,
        (sum, cat) => sum + cat.impactMetrics.completionTime,
      ) / _categories.length,
      avgQualityScore: _categories.fold(
        0.0,
        (sum, cat) => sum + cat.impactMetrics.qualityScore,
      ) / _categories.length,
    );
  }

  void _resetToScenario(int index) {
    if (index >= 0 && index < _scenarios.length) {
      final scenario = _scenarios[index];
      setState(() {
        for (var category in _categories) {
          category.allocated = scenario.allocations[category.name] ?? 0;
        }
        _activeScenarioIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildBudgetOverview(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildAllocationPanel(),
              ),
              Expanded(
                flex: 2,
                child: _buildImpactPanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.stateOfficerColor, AppTheme.secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calculate, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fund Allocation Simulator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Test "what-if" scenarios before committing funds',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showSaveScenarioDialog(),
            icon: const Icon(Icons.save),
            label: const Text('Save Scenario'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.stateOfficerColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetOverview() {
    final utilizationRate = (_allocatedTotal / _totalBudget) * 100;
    final isOverBudget = _allocatedTotal > _totalBudget;

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildBudgetCard(
                  'Total Budget',
                  _formatCurrency(_totalBudget),
                  Icons.account_balance_wallet,
                  AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBudgetCard(
                  'Allocated',
                  _formatCurrency(_allocatedTotal),
                  Icons.payments,
                  AppTheme.secondaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBudgetCard(
                  'Remaining',
                  _formatCurrency(_unallocated),
                  isOverBudget ? Icons.warning : Icons.savings,
                  isOverBudget ? AppTheme.errorRed : AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBudgetCard(
                  'Utilization',
                  '${utilizationRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  isOverBudget ? AppTheme.errorRed : AppTheme.accentTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: utilizationRate / 100,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                isOverBudget ? AppTheme.errorRed : AppTheme.successGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationPanel() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Budget Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_scenarios.isNotEmpty)
                  DropdownButton<int>(
                    value: _activeScenarioIndex,
                    items: _scenarios.asMap().entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) _resetToScenario(value);
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryCard(_categories[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BudgetCategory category, int index) {
    final percentage = (_totalBudget > 0) 
        ? (category.allocated / _totalBudget * 100) 
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(category.icon, color: category.color, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${percentage.toStringAsFixed(1)}% of total budget',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: category.allocated,
                    min: 0,
                    max: _totalBudget,
                    divisions: 100,
                    activeColor: category.color,
                    onChanged: (value) => _updateAllocation(index, value),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: Text(
                    _formatCurrency(category.allocated),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                  ),
                ),
              ],
            ),
            
            const Divider(),
            
            Row(
              children: [
                _buildImpactMetric(
                  'Households',
                  category.impactMetrics.householdsServed.toString(),
                  Icons.home,
                ),
                const SizedBox(width: 24),
                _buildImpactMetric(
                  'Timeline',
                  '${category.impactMetrics.completionTime} days',
                  Icons.schedule,
                ),
                const SizedBox(width: 24),
                _buildImpactMetric(
                  'Quality',
                  '${category.impactMetrics.qualityScore}%',
                  Icons.star,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactMetric(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImpactPanel() {
    final impact = _calculateTotalImpact();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.insights, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Projected Impact',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildImpactCard(
                    'Total Households Served',
                    impact.totalHouseholdsServed.toString(),
                    Icons.home_work,
                    AppTheme.successGreen,
                  ),
                  const SizedBox(height: 16),
                  _buildImpactCard(
                    'Average Completion Time',
                    '${impact.avgCompletionTime.toStringAsFixed(0)} days',
                    Icons.timer,
                    AppTheme.secondaryBlue,
                  ),
                  const SizedBox(height: 16),
                  _buildImpactCard(
                    'Average Quality Score',
                    '${impact.avgQualityScore.toStringAsFixed(1)}%',
                    Icons.verified,
                    AppTheme.accentTeal,
                  ),
                  
                  if (_scenarios.length > 1) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Scenario Comparison',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._scenarios.asMap().entries.map((entry) {
                      return _buildScenarioCard(entry.key, entry.value);
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioCard(int index, ScenarioComparison scenario) {
    final isActive = index == _activeScenarioIndex;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isActive ? AppTheme.accentTeal.withOpacity(0.1) : null,
      child: ListTile(
        leading: Icon(
          isActive ? Icons.check_circle : Icons.circle_outlined,
          color: isActive ? AppTheme.accentTeal : Colors.grey,
        ),
        title: Text(
          scenario.name,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          '${scenario.totalImpact.totalHouseholdsServed} households • ${scenario.totalImpact.avgQualityScore.toStringAsFixed(1)}% quality',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () {
            setState(() {
              _scenarios.removeAt(index);
              if (_activeScenarioIndex >= _scenarios.length) {
                _activeScenarioIndex = _scenarios.length - 1;
              }
            });
          },
        ),
        onTap: () => _resetToScenario(index),
      ),
    );
  }

  void _showSaveScenarioDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Scenario'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Scenario Name',
              hintText: 'e.g., High Water Focus',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _saveCurrentScenario(controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
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

/// Budget Category Model
class BudgetCategory {
  final String name;
  double allocated;
  final Color color;
  final IconData icon;
  final ImpactMetrics impactMetrics;

  BudgetCategory({
    required this.name,
    required this.allocated,
    required this.color,
    required this.icon,
    required this.impactMetrics,
  });
}

/// Impact Metrics Model
class ImpactMetrics {
  final int householdsServed;
  final int completionTime;
  final int qualityScore;

  ImpactMetrics({
    required this.householdsServed,
    required this.completionTime,
    required this.qualityScore,
  });
}

/// Scenario Comparison Model
class ScenarioComparison {
  final String name;
  final DateTime timestamp;
  final Map<String, double> allocations;
  final TotalImpact totalImpact;

  ScenarioComparison({
    required this.name,
    required this.timestamp,
    required this.allocations,
    required this.totalImpact,
  });
}

/// Total Impact Model
class TotalImpact {
  final int totalHouseholdsServed;
  final double avgCompletionTime;
  final double avgQualityScore;

  TotalImpact({
    required this.totalHouseholdsServed,
    required this.avgCompletionTime,
    required this.avgQualityScore,
  });
}