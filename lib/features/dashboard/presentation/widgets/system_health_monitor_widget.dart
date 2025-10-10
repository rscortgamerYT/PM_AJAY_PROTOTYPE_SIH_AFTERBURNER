import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';

class SystemHealthMonitorWidget extends StatefulWidget {
  const SystemHealthMonitorWidget({super.key});

  @override
  State<SystemHealthMonitorWidget> createState() => _SystemHealthMonitorWidgetState();
}

class _SystemHealthMonitorWidgetState extends State<SystemHealthMonitorWidget> {
  String _selectedTimeRange = '1h';
  
  final List<String> _timeRanges = ['1h', '6h', '24h', '7d'];

  // Mock data for system metrics
  final Map<String, List<FlSpot>> _cpuData = {
    '1h': List.generate(12, (i) => FlSpot(i.toDouble(), 45 + (i % 3) * 10)),
    '6h': List.generate(12, (i) => FlSpot(i.toDouble(), 50 + (i % 4) * 8)),
    '24h': List.generate(12, (i) => FlSpot(i.toDouble(), 48 + (i % 5) * 7)),
    '7d': List.generate(12, (i) => FlSpot(i.toDouble(), 52 + (i % 3) * 6)),
  };

  final Map<String, List<FlSpot>> _memoryData = {
    '1h': List.generate(12, (i) => FlSpot(i.toDouble(), 65 + (i % 4) * 8)),
    '6h': List.generate(12, (i) => FlSpot(i.toDouble(), 68 + (i % 3) * 7)),
    '24h': List.generate(12, (i) => FlSpot(i.toDouble(), 70 + (i % 5) * 6)),
    '7d': List.generate(12, (i) => FlSpot(i.toDouble(), 67 + (i % 4) * 5)),
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildTimeRangeSelector(),
            const SizedBox(height: 24),
            _buildSystemStatus(),
            const SizedBox(height: 24),
            _buildPerformanceMetrics(),
            const SizedBox(height: 24),
            _buildActiveServices(),
            const SizedBox(height: 24),
            _buildRecentAlerts(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.monitor_heart, color: AppTheme.successGreen, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Health Monitor',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time platform monitoring and diagnostics',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.successGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'All Systems Operational',
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
    );
  }

  Widget _buildTimeRangeSelector() {
    return Wrap(
      spacing: 8,
      children: _timeRanges.map((range) {
        final isSelected = range == _selectedTimeRange;
        return ChoiceChip(
          label: Text(range),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedTimeRange = range);
            }
          },
          selectedColor: AppTheme.secondaryBlue.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.secondaryBlue : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSystemStatus() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Uptime',
            '99.98%',
            '45d 12h',
            Icons.timer,
            AppTheme.successGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Response Time',
            '124ms',
            'Avg',
            Icons.speed,
            AppTheme.secondaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'API Calls',
            '2.4M',
            'Today',
            Icons.api,
            AppTheme.warningOrange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Error Rate',
            '0.02%',
            'Last 24h',
            Icons.error_outline,
            AppTheme.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildPerformanceChart(
            'CPU Usage',
            _cpuData[_selectedTimeRange]!,
            AppTheme.secondaryBlue,
            '52%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPerformanceChart(
            'Memory Usage',
            _memoryData[_selectedTimeRange]!,
            AppTheme.warningOrange,
            '68%',
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart(String title, List<FlSpot> data, Color color, String current) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                current,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(color: Colors.grey[600], fontSize: 10),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveServices() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Services',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildServiceStatus('Database', 'Healthy', AppTheme.successGreen, '23ms'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServiceStatus('API Gateway', 'Healthy', AppTheme.successGreen, '45ms'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServiceStatus('Cache', 'Healthy', AppTheme.successGreen, '8ms'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServiceStatus('File Storage', 'Healthy', AppTheme.successGreen, '12ms'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildServiceStatus('Authentication', 'Healthy', AppTheme.successGreen, '34ms'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServiceStatus('Email Service', 'Degraded', AppTheme.warningOrange, '156ms'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServiceStatus('Analytics', 'Healthy', AppTheme.successGreen, '67ms'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServiceStatus('Notifications', 'Healthy', AppTheme.successGreen, '89ms'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatus(String name, String status, Color statusColor, String latency) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            latency,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAlerts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Alerts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAlertItem(
            'Email Service Latency',
            'High latency detected in email service (156ms)',
            'Warning',
            AppTheme.warningOrange,
            '5 min ago',
          ),
          const Divider(height: 24),
          _buildAlertItem(
            'Database Connection Pool',
            'Connection pool usage at 85%',
            'Info',
            AppTheme.secondaryBlue,
            '32 min ago',
          ),
          const Divider(height: 24),
          _buildAlertItem(
            'SSL Certificate',
            'SSL certificate renewal in 30 days',
            'Info',
            AppTheme.secondaryBlue,
            '2 hours ago',
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String description, String severity, Color color, String time) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            severity == 'Warning' ? Icons.warning : Icons.info,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      severity,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}