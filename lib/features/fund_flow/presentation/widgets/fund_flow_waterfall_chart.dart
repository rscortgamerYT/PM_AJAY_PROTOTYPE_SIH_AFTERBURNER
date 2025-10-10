import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/models/fund_transaction_model.dart';

/// Waterfall bar data for fund flow stages
class WaterfallBarData {
  final String label;
  final double value;
  final bool isIncrease;
  final bool isTotal;
  final Color color;
  final double? plannedValue;
  final List<FundTransaction>? transactions;

  WaterfallBarData({
    required this.label,
    required this.value,
    this.isIncrease = true,
    this.isTotal = false,
    required this.color,
    this.plannedValue,
    this.transactions,
  });

  double get variance => plannedValue != null ? value - plannedValue! : 0;
  double get variancePercentage => 
      plannedValue != null && plannedValue! > 0 
          ? (variance / plannedValue!) * 100 
          : 0;
  bool get isUnderUtilized => variancePercentage < -10;
  bool get isOverUtilized => variancePercentage > 10;
}

/// Interactive Waterfall Chart showing cumulative fund allocation and utilization
class FundFlowWaterfallChart extends StatefulWidget {
  final List<FundTransaction> transactions;
  final Map<String, double>? plannedAllocations;
  final Function(WaterfallBarData)? onBarClick;
  final String? selectedStateId;

  const FundFlowWaterfallChart({
    super.key,
    required this.transactions,
    this.plannedAllocations,
    this.onBarClick,
    this.selectedStateId,
  });

  @override
  State<FundFlowWaterfallChart> createState() => _FundFlowWaterfallChartState();
}

class _FundFlowWaterfallChartState extends State<FundFlowWaterfallChart> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<WaterfallBarData> _barData = [];
  int? _hoveredIndex;
  WaterfallBarData? _selectedBar;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _calculateWaterfallData();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(FundFlowWaterfallChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions ||
        oldWidget.selectedStateId != widget.selectedStateId) {
      _calculateWaterfallData();
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateWaterfallData() {
    final centreAllocated = widget.transactions
        .where((tx) => tx.stage == FundFlowStage.centreAllocation)
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final stateTransferred = widget.transactions
        .where((tx) => tx.stage == FundFlowStage.stateTransfer)
        .where((tx) => widget.selectedStateId == null || tx.stateId == widget.selectedStateId)
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final agencyDisbursed = widget.transactions
        .where((tx) => tx.stage == FundFlowStage.agencyDisbursement)
        .where((tx) => widget.selectedStateId == null || tx.stateId == widget.selectedStateId)
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final projectSpent = widget.transactions
        .where((tx) => tx.stage == FundFlowStage.projectSpend)
        .where((tx) => widget.selectedStateId == null || tx.stateId == widget.selectedStateId)
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final remaining = centreAllocated - projectSpent;

    _barData = [
      WaterfallBarData(
        label: 'Centre\nAllocated',
        value: centreAllocated,
        isTotal: true,
        color: Colors.blue,
        plannedValue: widget.plannedAllocations?['centre'],
        transactions: widget.transactions
            .where((tx) => tx.stage == FundFlowStage.centreAllocation)
            .toList(),
      ),
      WaterfallBarData(
        label: 'Transferred\nto States',
        value: stateTransferred,
        color: Colors.green,
        plannedValue: widget.plannedAllocations?['state'],
        transactions: widget.transactions
            .where((tx) => tx.stage == FundFlowStage.stateTransfer)
            .toList(),
      ),
      WaterfallBarData(
        label: 'Disbursed\nto Agencies',
        value: agencyDisbursed,
        color: Colors.orange,
        plannedValue: widget.plannedAllocations?['agency'],
        transactions: widget.transactions
            .where((tx) => tx.stage == FundFlowStage.agencyDisbursement)
            .toList(),
      ),
      WaterfallBarData(
        label: 'Spent by\nProjects',
        value: projectSpent,
        color: Colors.purple,
        plannedValue: widget.plannedAllocations?['project'],
        transactions: widget.transactions
            .where((tx) => tx.stage == FundFlowStage.projectSpend)
            .toList(),
      ),
      WaterfallBarData(
        label: 'Remaining\nBalance',
        value: remaining,
        isIncrease: false,
        isTotal: true,
        color: remaining > 0 ? Colors.teal : Colors.red,
        transactions: null,
      ),
    ];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildWaterfallChart(),
                  ),
                  if (_selectedBar != null) ...[
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 300,
                      child: _buildDetailPanel(_selectedBar!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fund Flow Waterfall',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.selectedStateId != null 
                  ? 'State-level breakdown' 
                  : 'Cumulative allocation & utilization',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildLegendItem('Under-utilized', Colors.red),
            const SizedBox(width: 16),
            _buildLegendItem('On track', Colors.grey),
            const SizedBox(width: 16),
            _buildLegendItem('Over-utilized', Colors.green),
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _showExportOptions,
              tooltip: 'Export',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildWaterfallChart() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth / (_barData.length * 2);
            
            return Stack(
              children: [
                _buildGridLines(constraints),
                _buildBars(constraints, barWidth),
                _buildConnectorLines(constraints, barWidth),
                if (_hoveredIndex != null)
                  _buildTooltip(constraints, barWidth),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGridLines(BoxConstraints constraints) {
    return CustomPaint(
      size: Size(constraints.maxWidth, constraints.maxHeight),
      painter: GridLinesPainter(),
    );
  }

  Widget _buildBars(BoxConstraints constraints, double barWidth) {
    final maxValue = _barData.fold<double>(
      0,
      (max, bar) => bar.value > max ? bar.value : max,
    );

    double cumulativeY = 0;

    return Stack(
      children: _barData.asMap().entries.map((entry) {
        final index = entry.key;
        final bar = entry.value;
        final animatedValue = bar.value * _animation.value;
        final barHeight = (animatedValue / maxValue) * (constraints.maxHeight - 100);
        
        final x = (index * 2 + 1) * barWidth;
        final y = constraints.maxHeight - 50 - barHeight;

        final barWidget = Positioned(
          left: x - barWidth / 2,
          top: y,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedBar = bar);
                widget.onBarClick?.call(bar);
              },
              child: Column(
                children: [
                  _buildVarianceIndicator(bar),
                  const SizedBox(height: 4),
                  Container(
                    width: barWidth * 1.5,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: _hoveredIndex == index 
                          ? bar.color 
                          : bar.color.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedBar == bar ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: _hoveredIndex == index
                          ? [
                              BoxShadow(
                                color: bar.color.withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '₹${_formatAmount(animatedValue)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: barWidth * 1.8,
                    child: Text(
                      bar.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        cumulativeY += barHeight;
        return barWidget;
      }).toList(),
    );
  }

  Widget _buildVarianceIndicator(WaterfallBarData bar) {
    if (bar.plannedValue == null) return const SizedBox.shrink();

    final variance = bar.variancePercentage;
    final isNegative = variance < 0;
    final color = bar.isUnderUtilized 
        ? Colors.red 
        : bar.isOverUtilized 
            ? Colors.green 
            : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNegative ? Icons.arrow_downward : Icons.arrow_upward,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${variance.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorLines(BoxConstraints constraints, double barWidth) {
    return CustomPaint(
      size: Size(constraints.maxWidth, constraints.maxHeight),
      painter: ConnectorLinesPainter(
        barData: _barData,
        barWidth: barWidth,
        animation: _animation.value,
      ),
    );
  }

  Widget _buildTooltip(BoxConstraints constraints, double barWidth) {
    if (_hoveredIndex == null || _hoveredIndex! >= _barData.length) {
      return const SizedBox.shrink();
    }

    final bar = _barData[_hoveredIndex!];
    final x = (_hoveredIndex! * 2 + 1) * barWidth;

    return Positioned(
      left: x,
      top: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bar.label.replaceAll('\n', ' '),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Amount: ₹${_formatAmount(bar.value)}',
              style: const TextStyle(fontSize: 12),
            ),
            if (bar.plannedValue != null) ...[
              Text(
                'Planned: ₹${_formatAmount(bar.plannedValue!)}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Variance: ${bar.variancePercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: bar.isUnderUtilized 
                      ? Colors.red 
                      : bar.isOverUtilized 
                          ? Colors.green 
                          : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (bar.transactions != null) ...[
              const Divider(height: 12),
              Text(
                'Transactions: ${bar.transactions!.length}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPanel(WaterfallBarData bar) {
    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bar.label.replaceAll('\n', ' '),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedBar = null),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            _buildDetailRow('Amount', '₹${_formatAmount(bar.value)}'),
            if (bar.plannedValue != null) ...[
              _buildDetailRow('Planned', '₹${_formatAmount(bar.plannedValue!)}'),
              _buildDetailRow(
                'Variance',
                '${bar.variancePercentage.toStringAsFixed(1)}%',
                valueColor: bar.isUnderUtilized 
                    ? Colors.red 
                    : bar.isOverUtilized 
                        ? Colors.green 
                        : null,
              ),
            ],
            if (bar.transactions != null && bar.transactions!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Recent Transactions (${bar.transactions!.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: bar.transactions!.take(5).length,
                  itemBuilder: (context, index) {
                    final tx = bar.transactions![index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.account_balance_wallet,
                        size: 20,
                        color: bar.color,
                      ),
                      title: Text(
                        tx.pfmsId,
                        style: const TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        _formatDate(tx.transactionDate),
                        style: const TextStyle(fontSize: 10),
                      ),
                      trailing: Text(
                        '₹${_formatAmount(tx.amount)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (bar.transactions!.length > 5)
                TextButton(
                  onPressed: () {
                    // TODO: Show all transactions
                  },
                  child: const Text('View all transactions'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Waterfall Chart'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Export as PNG'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement PNG export
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement PDF export
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement CSV export
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    }
    return amount.toStringAsFixed(2);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Custom painter for grid lines
class GridLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = (size.height - 50) * i / 5;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridLinesPainter oldDelegate) => false;
}

/// Custom painter for connector lines between bars
class ConnectorLinesPainter extends CustomPainter {
  final List<WaterfallBarData> barData;
  final double barWidth;
  final double animation;

  ConnectorLinesPainter({
    required this.barData,
    required this.barWidth,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw dashed lines connecting bars
    for (int i = 0; i < barData.length - 1; i++) {
      final x1 = (i * 2 + 1) * barWidth + barWidth * 0.75;
      final x2 = ((i + 1) * 2 + 1) * barWidth - barWidth * 0.75;
      final y = size.height - 50;

      _drawDashedLine(
        canvas,
        Offset(x1 * animation, y),
        Offset(x2 * animation, y),
        paint,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5;
    const dashSpace = 3;
    final distance = (end - start).distance;
    final normalizedDistance = Offset(
      (end.dx - start.dx) / distance,
      (end.dy - start.dy) / distance,
    );

    var currentDistance = 0.0;
    while (currentDistance < distance) {
      final dashEnd = currentDistance + dashWidth;
      canvas.drawLine(
        Offset(
          start.dx + normalizedDistance.dx * currentDistance,
          start.dy + normalizedDistance.dy * currentDistance,
        ),
        Offset(
          start.dx + normalizedDistance.dx * dashEnd.clamp(0, distance),
          start.dy + normalizedDistance.dy * dashEnd.clamp(0, distance),
        ),
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(ConnectorLinesPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}