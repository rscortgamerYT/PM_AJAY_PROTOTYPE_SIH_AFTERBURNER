import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

enum FundStatus {
  allocated,
  transferred,
  utilized,
  pendingUC,
  completed;

  String get displayName {
    switch (this) {
      case FundStatus.allocated:
        return 'Allocated';
      case FundStatus.transferred:
        return 'Transferred';
      case FundStatus.utilized:
        return 'Utilized';
      case FundStatus.pendingUC:
        return 'Pending UC';
      case FundStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case FundStatus.allocated:
        return Colors.blue;
      case FundStatus.transferred:
        return Colors.orange;
      case FundStatus.utilized:
        return Colors.purple;
      case FundStatus.pendingUC:
        return Colors.amber;
      case FundStatus.completed:
        return AppTheme.successGreen;
    }
  }
}

class FundFlowTransaction {
  final String id;
  final String fromEntity;
  final String toEntity;
  final double amount;
  final FundStatus status;
  final DateTime transactionDate;
  final String component;

  FundFlowTransaction({
    required this.id,
    required this.fromEntity,
    required this.toEntity,
    required this.amount,
    required this.status,
    required this.transactionDate,
    required this.component,
  });
}

class FundFlowVisualizer extends StatefulWidget {
  final List<FundFlowTransaction> transactions;
  final String? selectedComponent;

  const FundFlowVisualizer({
    super.key,
    required this.transactions,
    this.selectedComponent,
  });

  @override
  State<FundFlowVisualizer> createState() => _FundFlowVisualizerState();
}

class _FundFlowVisualizerState extends State<FundFlowVisualizer> {
  int touchedIndex = -1;

  List<FundFlowTransaction> get _filteredTransactions {
    if (widget.selectedComponent == null) {
      return widget.transactions;
    }
    return widget.transactions
        .where((t) => t.component == widget.selectedComponent)
        .toList();
  }

  Map<FundStatus, double> _calculateStatusDistribution() {
    final Map<FundStatus, double> distribution = {};
    
    for (var transaction in _filteredTransactions) {
      distribution[transaction.status] = 
          (distribution[transaction.status] ?? 0) + transaction.amount;
    }
    
    return distribution;
  }

  Widget _buildWaterfallChart() {
    final distribution = _calculateStatusDistribution();
    final total = distribution.values.fold(0.0, (sum, val) => sum + val);

    return Column(
      children: [
        Text(
          'Fund Flow Waterfall',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: total * 1.2,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final status = FundStatus.values[group.x.toInt()];
                    return BarTooltipItem(
                      '${status.displayName}\n₹${rod.toY.toStringAsFixed(2)}L',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
                      if (value.toInt() >= FundStatus.values.length) {
                        return const SizedBox.shrink();
                      }
                      final status = FundStatus.values[value.toInt()];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          status.displayName,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '₹${value.toStringAsFixed(0)}L',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: total / 5,
              ),
              borderData: FlBorderData(show: false),
              barGroups: distribution.entries.map((entry) {
                final index = FundStatus.values.indexOf(entry.key);
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: entry.key.color,
                      width: 40,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    final distribution = _calculateStatusDistribution();
    
    return Column(
      children: [
        Text(
          'Status Distribution',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: distribution.entries.map((entry) {
                final index = distribution.keys.toList().indexOf(entry.key);
                final isTouched = index == touchedIndex;
                final radius = isTouched ? 70.0 : 60.0;
                
                return PieChartSectionData(
                  color: entry.key.color,
                  value: entry.value,
                  title: '₹${entry.value.toStringAsFixed(1)}L',
                  radius: radius,
                  titleStyle: TextStyle(
                    fontSize: isTouched ? 16 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: distribution.keys.map((status) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  status.displayName,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredTransactions.take(10).length,
          itemBuilder: (context, index) {
            final transaction = _filteredTransactions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.grey[800],
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: transaction.status.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: transaction.status.color,
                  ),
                ),
                title: Text(
                  '${transaction.fromEntity} → ${transaction.toEntity}',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${transaction.component} • ${transaction.status.displayName}',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${transaction.amount.toStringAsFixed(2)}L',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: transaction.status.color,
                          ),
                    ),
                    Text(
                      '${transaction.transactionDate.day}/${transaction.transactionDate.month}/${transaction.transactionDate.year}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildWaterfallChart(),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildPieChart(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: _buildTransactionList(),
          ),
        ],
      ),
    );
  }
}