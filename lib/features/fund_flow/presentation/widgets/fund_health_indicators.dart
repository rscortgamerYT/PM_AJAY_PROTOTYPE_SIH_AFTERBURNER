import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/models/fund_transaction_model.dart';

/// Fund Health Indicators showing key metrics and alerts
class FundHealthIndicators extends StatelessWidget {
  final double utilizationRate;
  final double averageTransferDays;
  final int delayedTransactions;
  final int totalTransactions;
  final double complianceScore;
  final List<BottleneckAlert> bottlenecks;
  final Function()? onViewDetails;

  const FundHealthIndicators({
    Key? key,
    required this.utilizationRate,
    required this.averageTransferDays,
    required this.delayedTransactions,
    required this.totalTransactions,
    required this.complianceScore,
    required this.bottlenecks,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              'Fund Health Indicators',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (onViewDetails != null)
              TextButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Icons.info_outline, size: 16),
                label: const Text('View Details'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: UtilizationRateGauge(
                utilizationRate: utilizationRate,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AverageTransferTimeCard(
                averageTransferDays: averageTransferDays,
                delayedTransactions: delayedTransactions,
                totalTransactions: totalTransactions,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ComplianceScoreCard(
                complianceScore: complianceScore,
              ),
            ),
          ],
        ),
        if (bottlenecks.isNotEmpty) ...[
          const SizedBox(height: 16),
          BottleneckAlertsPanel(
            bottlenecks: bottlenecks,
          ),
        ],
      ],
    );
  }
}

/// Utilization Rate Gauge with animated circular progress
class UtilizationRateGauge extends StatefulWidget {
  final double utilizationRate;

  const UtilizationRateGauge({
    Key? key,
    required this.utilizationRate,
  }) : super(key: key);

  @override
  State<UtilizationRateGauge> createState() => _UtilizationRateGaugeState();
}

class _UtilizationRateGaugeState extends State<UtilizationRateGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.utilizationRate)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Utilization Rate',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              width: 150,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: GaugePainter(
                      value: _animation.value,
                      color: _getUtilizationColor(_animation.value),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_animation.value.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _getUtilizationColor(_animation.value),
                            ),
                          ),
                          Text(
                            _getUtilizationLabel(_animation.value),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.red, 'Low'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.orange, 'Medium'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.green, 'High'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Color _getUtilizationColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getUtilizationLabel(double rate) {
    if (rate >= 80) return 'Excellent';
    if (rate >= 60) return 'Good';
    if (rate >= 40) return 'Fair';
    return 'Poor';
  }
}

/// Custom painter for gauge visualization
class GaugePainter extends CustomPainter {
  final double value;
  final Color color;

  GaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      backgroundPaint,
    );

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (value / 100) * math.pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}

/// Average Transfer Time Card with trend indicator
class AverageTransferTimeCard extends StatelessWidget {
  final double averageTransferDays;
  final int delayedTransactions;
  final int totalTransactions;

  const AverageTransferTimeCard({
    Key? key,
    required this.averageTransferDays,
    required this.delayedTransactions,
    required this.totalTransactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final delayPercentage = totalTransactions > 0
        ? (delayedTransactions / totalTransactions * 100)
        : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transfer Efficiency',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  averageTransferDays.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _getTransferTimeColor(averageTransferDays),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'days',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Average Transfer Time',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  delayPercentage > 20
                      ? Icons.warning_amber
                      : Icons.check_circle,
                  size: 20,
                  color: delayPercentage > 20 ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$delayedTransactions delayed',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${delayPercentage.toStringAsFixed(1)}% of total',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTransferTimeColor(double days) {
    if (days <= 7) return Colors.green;
    if (days <= 14) return Colors.orange;
    return Colors.red;
  }
}

/// Compliance Score Card with progress bar
class ComplianceScoreCard extends StatelessWidget {
  final double complianceScore;

  const ComplianceScoreCard({
    Key? key,
    required this.complianceScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compliance Score',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  complianceScore.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _getComplianceColor(complianceScore),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/100',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: complianceScore / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getComplianceColor(complianceScore),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getComplianceLabel(complianceScore),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _getComplianceIcon(complianceScore),
                  size: 16,
                  color: _getComplianceColor(complianceScore),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _getComplianceDescription(complianceScore),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getComplianceColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getComplianceLabel(double score) {
    if (score >= 80) return 'Excellent Compliance';
    if (score >= 60) return 'Good Compliance';
    if (score >= 40) return 'Fair Compliance';
    return 'Poor Compliance';
  }

  IconData _getComplianceIcon(double score) {
    if (score >= 80) return Icons.verified;
    if (score >= 60) return Icons.check_circle_outline;
    return Icons.warning_amber;
  }

  String _getComplianceDescription(double score) {
    if (score >= 80) return 'All regulatory requirements met';
    if (score >= 60) return 'Minor compliance issues';
    return 'Attention required for compliance';
  }
}

/// Bottleneck Alert model
class BottleneckAlert {
  final String id;
  final String stage;
  final String description;
  final int affectedTransactions;
  final BottleneckSeverity severity;
  final DateTime detectedAt;

  BottleneckAlert({
    required this.id,
    required this.stage,
    required this.description,
    required this.affectedTransactions,
    required this.severity,
    required this.detectedAt,
  });
}

enum BottleneckSeverity { low, medium, high, critical }

/// Bottleneck Alerts Panel showing issues and delays
class BottleneckAlertsPanel extends StatelessWidget {
  final List<BottleneckAlert> bottlenecks;

  const BottleneckAlertsPanel({
    Key? key,
    required this.bottlenecks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Bottleneck Alerts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Chip(
                  label: Text('${bottlenecks.length}'),
                  backgroundColor: Colors.orange.shade100,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...bottlenecks.map((alert) => _buildAlertItem(alert)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(BottleneckAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: _getSeverityColor(alert.severity)),
        borderRadius: BorderRadius.circular(8),
        color: _getSeverityColor(alert.severity).withOpacity(0.1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSeverityColor(alert.severity),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              _getSeverityIcon(alert.severity),
              color: Colors.white,
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
                        alert.stage,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        _getSeverityLabel(alert.severity),
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: _getSeverityColor(alert.severity),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.description,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${alert.affectedTransactions} transactions affected',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, size: 18),
            onPressed: () {
              // Navigate to detailed view
            },
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(BottleneckSeverity severity) {
    switch (severity) {
      case BottleneckSeverity.low:
        return Colors.blue;
      case BottleneckSeverity.medium:
        return Colors.orange;
      case BottleneckSeverity.high:
        return Colors.deepOrange;
      case BottleneckSeverity.critical:
        return Colors.red;
    }
  }

  IconData _getSeverityIcon(BottleneckSeverity severity) {
    switch (severity) {
      case BottleneckSeverity.low:
        return Icons.info;
      case BottleneckSeverity.medium:
        return Icons.warning_amber;
      case BottleneckSeverity.high:
        return Icons.error;
      case BottleneckSeverity.critical:
        return Icons.dangerous;
    }
  }

  String _getSeverityLabel(BottleneckSeverity severity) {
    switch (severity) {
      case BottleneckSeverity.low:
        return 'LOW';
      case BottleneckSeverity.medium:
        return 'MEDIUM';
      case BottleneckSeverity.high:
        return 'HIGH';
      case BottleneckSeverity.critical:
        return 'CRITICAL';
    }
  }
}