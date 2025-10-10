import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/fund_transaction_model.dart';

/// Drill-Down Modal for detailed fund flow analysis
class FundFlowDrillDownModal extends StatefulWidget {
  final DrillDownContext context;
  final Function(String)? onEntityTap;

  const FundFlowDrillDownModal({
    Key? key,
    required this.context,
    this.onEntityTap,
  }) : super(key: key);

  @override
  State<FundFlowDrillDownModal> createState() => _FundFlowDrillDownModalState();

  static Future<void> show(
    BuildContext context,
    DrillDownContext drillDownContext,
  ) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: FundFlowDrillDownModal(context: drillDownContext),
        ),
      ),
    );
  }
}

class _FundFlowDrillDownModalState extends State<FundFlowDrillDownModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildTransactionsTab(),
              _buildTimelineTab(),
              _buildDocumentsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getEntityIcon(widget.context.entityType),
            size: 32,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.context.entityName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.context.entityType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const [
          Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
          Tab(icon: Icon(Icons.account_balance_wallet), text: 'Transactions'),
          Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
          Tab(icon: Icon(Icons.folder), text: 'Documents'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricsGrid(),
          const SizedBox(height: 24),
          _buildFundFlowSummary(),
          const SizedBox(height: 24),
          _buildRelatedEntities(),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = widget.context.metrics;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Metrics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2,
              children: [
                _buildMetricCard(
                  'Total Allocated',
                  '₹${_formatAmount(metrics.totalAllocated)}',
                  Icons.account_balance,
                  Colors.blue,
                ),
                _buildMetricCard(
                  'Total Utilized',
                  '₹${_formatAmount(metrics.totalUtilized)}',
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildMetricCard(
                  'Balance',
                  '₹${_formatAmount(metrics.balance)}',
                  Icons.account_balance_wallet,
                  Colors.orange,
                ),
                _buildMetricCard(
                  'Utilization Rate',
                  '${metrics.utilizationRate.toStringAsFixed(1)}%',
                  Icons.pie_chart,
                  Colors.purple,
                ),
                _buildMetricCard(
                  'Total Transactions',
                  '${metrics.transactionCount}',
                  Icons.receipt_long,
                  Colors.teal,
                ),
                _buildMetricCard(
                  'Avg Transfer Time',
                  '${metrics.avgTransferDays.toStringAsFixed(1)} days',
                  Icons.access_time,
                  Colors.indigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const Spacer(),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFundFlowSummary() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fund Flow Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...widget.context.flowSummary.map((flow) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStageColor(flow.stage).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          _getStageIcon(flow.stage),
                          size: 20,
                          color: _getStageColor(flow.stage),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flow.stage.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${flow.transactionCount} transactions',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${_formatAmount(flow.amount)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getStageColor(flow.stage),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedEntities() {
    if (widget.context.relatedEntities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Related Entities',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...widget.context.relatedEntities.map((entity) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    _getEntityIcon(entity.type),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(entity.name),
                subtitle: Text(entity.type.toUpperCase()),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => widget.onEntityTap?.call(entity.id),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.context.transactions.length,
      itemBuilder: (context, index) {
        final transaction = widget.context.transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStageColor(transaction.stage).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getStageIcon(transaction.stage),
                  color: _getStageColor(transaction.stage),
                ),
              ),
            ),
            title: Text(transaction.pfmsId),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${transaction.fromEntity} → ${transaction.toEntity}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(transaction.transactionDate),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${_formatAmount(transaction.amount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(
                    transaction.status.label,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getStatusColor(transaction.status),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            onTap: () {
              // Show transaction details
            },
          ),
        );
      },
    );
  }

  Widget _buildTimelineTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.context.timelineEvents.length,
      itemBuilder: (context, index) {
        final event = widget.context.timelineEvents[index];
        final isLast = index == widget.context.timelineEvents.length - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: event.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    event.icon,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 48,
                    color: Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yy').format(event.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.context.documents.length,
      itemBuilder: (context, index) {
        final document = widget.context.documents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getDocumentColor(document.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getDocumentIcon(document.type),
                color: _getDocumentColor(document.type),
              ),
            ),
            title: Text(document.name),
            subtitle: Text(
              '${document.type} • ${_formatFileSize(document.size)}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 20),
                  onPressed: () {
                    // Preview document
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download, size: 20),
                  onPressed: () {
                    // Download document
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getEntityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'centre':
        return Icons.account_balance;
      case 'state':
        return Icons.location_city;
      case 'agency':
        return Icons.business;
      case 'project':
        return Icons.work;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStageColor(FundFlowStage stage) {
    switch (stage) {
      case FundFlowStage.centreAllocation:
        return Colors.blue;
      case FundFlowStage.stateTransfer:
        return Colors.green;
      case FundFlowStage.agencyDisbursement:
        return Colors.orange;
      case FundFlowStage.projectSpend:
        return Colors.purple;
      case FundFlowStage.beneficiaryPayment:
        return Colors.teal;
    }
  }

  IconData _getStageIcon(FundFlowStage stage) {
    switch (stage) {
      case FundFlowStage.centreAllocation:
        return Icons.account_balance;
      case FundFlowStage.stateTransfer:
        return Icons.send;
      case FundFlowStage.agencyDisbursement:
        return Icons.business;
      case FundFlowStage.projectSpend:
        return Icons.construction;
      case FundFlowStage.beneficiaryPayment:
        return Icons.people;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange.shade100;
      case TransactionStatus.processing:
        return Colors.blue.shade100;
      case TransactionStatus.completed:
        return Colors.green.shade100;
      case TransactionStatus.failed:
        return Colors.red.shade100;
      case TransactionStatus.onHold:
        return Colors.grey.shade300;
      case TransactionStatus.cancelled:
        return Colors.red.shade200;
    }
  }

  Color _getDocumentColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'excel':
      case 'xlsx':
        return Colors.green;
      case 'word':
      case 'docx':
        return Colors.blue;
      case 'image':
      case 'jpg':
      case 'png':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'excel':
      case 'xlsx':
        return Icons.table_chart;
      case 'word':
      case 'docx':
        return Icons.description;
      case 'image':
      case 'jpg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
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

  String _formatFileSize(int bytes) {
    if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes bytes';
  }
}

/// Drill-Down Context containing all data for modal
class DrillDownContext {
  final String entityId;
  final String entityName;
  final String entityType;
  final EntityMetrics metrics;
  final List<FlowSummary> flowSummary;
  final List<FundTransaction> transactions;
  final List<TimelineEvent> timelineEvents;
  final List<DocumentInfo> documents;
  final List<RelatedEntity> relatedEntities;

  DrillDownContext({
    required this.entityId,
    required this.entityName,
    required this.entityType,
    required this.metrics,
    required this.flowSummary,
    required this.transactions,
    required this.timelineEvents,
    required this.documents,
    required this.relatedEntities,
  });
}

/// Entity metrics for overview
class EntityMetrics {
  final double totalAllocated;
  final double totalUtilized;
  final double balance;
  final double utilizationRate;
  final int transactionCount;
  final double avgTransferDays;

  EntityMetrics({
    required this.totalAllocated,
    required this.totalUtilized,
    required this.balance,
    required this.utilizationRate,
    required this.transactionCount,
    required this.avgTransferDays,
  });
}

/// Flow summary by stage
class FlowSummary {
  final FundFlowStage stage;
  final double amount;
  final int transactionCount;

  FlowSummary({
    required this.stage,
    required this.amount,
    required this.transactionCount,
  });
}

/// Timeline event for history
class TimelineEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  TimelineEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.color,
  });
}

/// Document information
class DocumentInfo {
  final String id;
  final String name;
  final String type;
  final int size;
  final String url;

  DocumentInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.url,
  });
}

/// Related entity reference
class RelatedEntity {
  final String id;
  final String name;
  final String type;

  RelatedEntity({
    required this.id,
    required this.name,
    required this.type,
  });
}