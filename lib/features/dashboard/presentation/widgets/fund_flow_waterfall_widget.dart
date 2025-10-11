import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';

class FundFlowWaterfallWidget extends StatefulWidget {
  const FundFlowWaterfallWidget({super.key});

  @override
  State<FundFlowWaterfallWidget> createState() => _FundFlowWaterfallWidgetState();
}

class _FundFlowWaterfallWidgetState extends State<FundFlowWaterfallWidget> {
  int _selectedTimeRange = 0;
  final List<String> _timeRanges = ['This Month', 'This Quarter', 'This Year', 'All Time'];

  // Mock data - will be replaced with Supabase data
  final List<FundFlowItem> _fundFlowData = [
    FundFlowItem('Allocated Budget', 10000.0, true),
    FundFlowItem('Released to States', -7500.0, false),
    FundFlowItem('State to Agencies', -6000.0, false),
    FundFlowItem('Utilized Amount', -5200.0, false),
    FundFlowItem('Pending Release', 800.0, false),
    FundFlowItem('Balance', 4800.0, true),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTimeRangeSelector(),
        Expanded(child: _buildWaterfallChart()),
        _buildSummaryCards(),
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
                'Fund Flow Waterfall',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time fund tracking across hierarchy',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exporting fund flow data...')),
                  );
                },
                tooltip: 'Export Data',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refreshing fund flow data...')),
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

  Widget _buildTimeRangeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: List.generate(_timeRanges.length, (index) {
          final isSelected = _selectedTimeRange == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(_timeRanges[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedTimeRange = index);
              },
              selectedColor: AppTheme.primaryIndigo.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryIndigo,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWaterfallChart() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 12000,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final item = _fundFlowData[groupIndex];
                          return BarTooltipItem(
                            '${item.label}\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '₹${item.amount.abs().toStringAsFixed(2)} Cr',
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
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
                            if (index < 0 || index >= _fundFlowData.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _fundFlowData[index].label,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                          reservedSize: 60,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '₹${(value / 1000).toStringAsFixed(0)}K',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                          reservedSize: 50,
                        ),
                      ),
                    ),
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 2000,
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _buildBarGroups(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLegend(),
            ],
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    double cumulative = 0;
    return List.generate(_fundFlowData.length, (index) {
      final item = _fundFlowData[index];
      final isPositive = item.amount > 0;
      final barHeight = item.amount.abs();
      
      final fromY = cumulative;
      cumulative += item.amount;
      final toY = cumulative;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            fromY: item.isStart ? 0 : fromY.abs(),
            toY: toY.abs(),
            width: 40,
            color: item.isStart 
                ? AppTheme.primaryIndigo
                : isPositive 
                    ? AppTheme.successGreen
                    : AppTheme.errorRed,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Allocation', AppTheme.primaryIndigo),
        const SizedBox(width: 24),
        _buildLegendItem('Addition', AppTheme.successGreen),
        const SizedBox(width: 24),
        _buildLegendItem('Deduction', AppTheme.errorRed),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Allocated',
              '₹10,000 Cr',
              Icons.account_balance,
              AppTheme.primaryIndigo,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Total Utilized',
              '₹5,200 Cr',
              Icons.check_circle,
              AppTheme.successGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Utilization Rate',
              '52%',
              Icons.trending_up,
              AppTheme.secondaryBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Balance',
              '₹4,800 Cr',
              Icons.account_balance_wallet,
              AppTheme.warningOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
    );
  }
}

class FundFlowItem {
  final String label;
  final double amount;
  final bool isStart;

  FundFlowItem(this.label, this.amount, this.isStart);
}