import 'package:flutter/material.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/utils/responsive_layout.dart';

/// Alert severity levels
enum AlertSeverity {
  critical,
  high,
  medium,
  low,
}

extension AlertSeverityExtension on AlertSeverity {
  Color get color {
    switch (this) {
      case AlertSeverity.critical:
        return AppDesignSystem.error;
      case AlertSeverity.high:
        return AppDesignSystem.sunsetOrange;
      case AlertSeverity.medium:
        return AppDesignSystem.warning;
      case AlertSeverity.low:
        return AppDesignSystem.info;
    }
  }

  String get label {
    switch (this) {
      case AlertSeverity.critical:
        return 'Critical';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.low:
        return 'Low';
    }
  }

  IconData get icon {
    switch (this) {
      case AlertSeverity.critical:
        return Icons.error;
      case AlertSeverity.high:
        return Icons.warning;
      case AlertSeverity.medium:
        return Icons.info;
      case AlertSeverity.low:
        return Icons.notifications;
    }
  }
}

/// Alert type categories
enum AlertType {
  fundDiscrepancy,
  complianceIssue,
  delayedTransfer,
  missingDocument,
  budgetOverrun,
  systemAlert,
}

extension AlertTypeExtension on AlertType {
  String get label {
    switch (this) {
      case AlertType.fundDiscrepancy:
        return 'Fund Discrepancy';
      case AlertType.complianceIssue:
        return 'Compliance Issue';
      case AlertType.delayedTransfer:
        return 'Delayed Transfer';
      case AlertType.missingDocument:
        return 'Missing Document';
      case AlertType.budgetOverrun:
        return 'Budget Overrun';
      case AlertType.systemAlert:
        return 'System Alert';
    }
  }

  IconData get icon {
    switch (this) {
      case AlertType.fundDiscrepancy:
        return Icons.attach_money;
      case AlertType.complianceIssue:
        return Icons.policy;
      case AlertType.delayedTransfer:
        return Icons.access_time;
      case AlertType.missingDocument:
        return Icons.file_present;
      case AlertType.budgetOverrun:
        return Icons.trending_up;
      case AlertType.systemAlert:
        return Icons.computer;
    }
  }
}

/// Alert model
class Alert {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final AlertType type;
  final DateTime createdAt;
  final String affectedEntity;
  final String? affectedState;
  final double? amount;
  final bool isAcknowledged;
  final bool isResolved;
  final String? assignedTo;
  final DateTime? dueDate;
  final List<String> actions;

  Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.type,
    required this.createdAt,
    required this.affectedEntity,
    this.affectedState,
    this.amount,
    this.isAcknowledged = false,
    this.isResolved = false,
    this.assignedTo,
    this.dueDate,
    this.actions = const [],
  });
}

/// Alerts Monitoring Widget
class AlertsMonitoringWidget extends StatefulWidget {
  const AlertsMonitoringWidget({super.key});

  @override
  State<AlertsMonitoringWidget> createState() => _AlertsMonitoringWidgetState();
}

class _AlertsMonitoringWidgetState extends State<AlertsMonitoringWidget> {
  List<Alert> _alerts = [];
  AlertSeverity? _selectedSeverity;
  AlertType? _selectedType;
  bool _showResolved = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    final now = DateTime.now();
    _alerts = [
      Alert(
        id: '1',
        title: 'Critical Fund Discrepancy Detected',
        description: 'Maharashtra reported a ₹50Cr discrepancy between allocated and received funds for Q4 2024.',
        severity: AlertSeverity.critical,
        type: AlertType.fundDiscrepancy,
        createdAt: now.subtract(const Duration(minutes: 15)),
        affectedEntity: 'Maharashtra State',
        affectedState: 'Maharashtra',
        amount: 500000000,
        assignedTo: 'Finance Team Lead',
        dueDate: now.add(const Duration(hours: 24)),
        actions: ['Verify PFMS records', 'Contact state finance dept', 'Initiate audit'],
      ),
      Alert(
        id: '2',
        title: 'Compliance Report Overdue',
        description: 'Karnataka has not submitted Q4 compliance reports. Deadline exceeded by 5 days.',
        severity: AlertSeverity.high,
        type: AlertType.complianceIssue,
        createdAt: now.subtract(const Duration(hours: 2)),
        affectedEntity: 'Karnataka State',
        affectedState: 'Karnataka',
        isAcknowledged: true,
        assignedTo: 'Compliance Officer',
        dueDate: now.subtract(const Duration(days: 5)),
        actions: ['Send reminder', 'Escalate to state commissioner', 'Initiate penalty process'],
      ),
      Alert(
        id: '3',
        title: 'Fund Transfer Delayed',
        description: 'Transfer to Rajasthan delayed by 12 days. Processing stuck at intermediary bank.',
        severity: AlertSeverity.high,
        type: AlertType.delayedTransfer,
        createdAt: now.subtract(const Duration(hours: 5)),
        affectedEntity: 'Rajasthan State',
        affectedState: 'Rajasthan',
        amount: 400000000,
        assignedTo: 'Banking Coordinator',
        actions: ['Contact intermediary bank', 'Check PFMS status', 'Notify state'],
      ),
      Alert(
        id: '4',
        title: 'Missing Utilization Certificate',
        description: 'Punjab Agency has not submitted UC for ₹15Cr disbursed in January 2024.',
        severity: AlertSeverity.medium,
        type: AlertType.missingDocument,
        createdAt: now.subtract(const Duration(days: 1)),
        affectedEntity: 'Punjab Development Agency',
        affectedState: 'Punjab',
        amount: 150000000,
        isAcknowledged: true,
        assignedTo: 'Documentation Team',
        dueDate: now.add(const Duration(days: 7)),
        actions: ['Request UC from agency', 'Send deadline notice', 'Suspend further disbursements'],
      ),
      Alert(
        id: '5',
        title: 'Budget Overrun Warning',
        description: 'Tamil Nadu infrastructure project exceeding allocated budget by 15%.',
        severity: AlertSeverity.medium,
        type: AlertType.budgetOverrun,
        createdAt: now.subtract(const Duration(days: 2)),
        affectedEntity: 'Chennai Metro Phase 2',
        affectedState: 'Tamil Nadu',
        amount: 300000000,
        actions: ['Review budget allocation', 'Request revised estimates', 'Conduct financial audit'],
      ),
      Alert(
        id: '6',
        title: 'System Maintenance Scheduled',
        description: 'PFMS integration will undergo maintenance this Saturday 2:00 AM - 4:00 AM.',
        severity: AlertSeverity.low,
        type: AlertType.systemAlert,
        createdAt: now.subtract(const Duration(days: 3)),
        affectedEntity: 'Central System',
        isAcknowledged: true,
        actions: ['Notify all users', 'Prepare backup systems', 'Schedule support team'],
      ),
    ];
  }

  List<Alert> get _filteredAlerts {
    return _alerts.where((alert) {
      if (_selectedSeverity != null && alert.severity != _selectedSeverity) return false;
      if (_selectedType != null && alert.type != _selectedType) return false;
      if (!_showResolved && alert.isResolved) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return alert.title.toLowerCase().contains(query) ||
            alert.description.toLowerCase().contains(query) ||
            alert.affectedEntity.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  Map<AlertSeverity, int> get _severityCount {
    return {
      for (var severity in AlertSeverity.values)
        severity: _alerts.where((a) => a.severity == severity && !a.isResolved).length
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSummaryCards(),
        SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
        _buildFilterBar(),
        SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
        Expanded(child: _buildAlertsList()),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: ResponsiveLayout.getResponsivePadding(context),
      child: GridView.count(
        crossAxisCount: ResponsiveLayout.getKpiGridColumns(context),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: ResponsiveLayout.getResponsiveSpacing(context),
        crossAxisSpacing: ResponsiveLayout.getResponsiveSpacing(context),
        childAspectRatio: ResponsiveLayout.getKpiAspectRatio(context),
        children: [
          _buildSummaryCard(
            'Critical',
            _severityCount[AlertSeverity.critical] ?? 0,
            AlertSeverity.critical.color,
            AlertSeverity.critical.icon,
          ),
          _buildSummaryCard(
            'High Priority',
            _severityCount[AlertSeverity.high] ?? 0,
            AlertSeverity.high.color,
            AlertSeverity.high.icon,
          ),
          _buildSummaryCard(
            'Medium',
            _severityCount[AlertSeverity.medium] ?? 0,
            AlertSeverity.medium.color,
            AlertSeverity.medium.icon,
          ),
          _buildSummaryCard(
            'Low Priority',
            _severityCount[AlertSeverity.low] ?? 0,
            AlertSeverity.low.color,
            AlertSeverity.low.icon,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, int count, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppDesignSystem.radiusMedium,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: AppDesignSystem.displaySmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: AppDesignSystem.labelMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: ResponsiveLayout.getResponsivePadding(context),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search alerts...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: AppDesignSystem.radiusMedium),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<AlertSeverity>(
                  initialValue: _selectedSeverity,
                  decoration: const InputDecoration(
                    labelText: 'Severity',
                    border: OutlineInputBorder(borderRadius: AppDesignSystem.radiusMedium),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Severities')),
                    ...AlertSeverity.values.map((s) => DropdownMenuItem(
                      value: s,
                      child: Row(
                        children: [
                          Icon(s.icon, size: 16, color: s.color),
                          const SizedBox(width: 8),
                          Text(s.label),
                        ],
                      ),
                    )),
                  ],
                  onChanged: (value) => setState(() => _selectedSeverity = value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<AlertType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(borderRadius: AppDesignSystem.radiusMedium),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Types')),
                    ...AlertType.values.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.label),
                    )),
                  ],
                  onChanged: (value) => setState(() => _selectedType = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _showResolved,
                onChanged: (value) => setState(() => _showResolved = value ?? false),
              ),
              const Text('Show resolved alerts'),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedSeverity = null;
                    _selectedType = null;
                    _showResolved = false;
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    final alerts = _filteredAlerts;

    if (alerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: AppDesignSystem.success),
            SizedBox(height: 16),
            Text('No alerts found', style: AppDesignSystem.headlineMedium),
            SizedBox(height: 8),
            Text('All systems operational', style: AppDesignSystem.bodyLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: ResponsiveLayout.getResponsivePadding(context),
      itemCount: alerts.length,
      itemBuilder: (context, index) => _buildAlertCard(alerts[index]),
    );
  }

  Widget _buildAlertCard(Alert alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _showAlertDetails(alert),
        borderRadius: AppDesignSystem.radiusMedium,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: alert.severity.color.withOpacity(0.1),
                      borderRadius: AppDesignSystem.radiusSmall,
                    ),
                    child: Icon(alert.severity.icon, color: alert.severity.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(alert.title, style: AppDesignSystem.titleMedium),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: alert.severity.color,
                                borderRadius: AppDesignSystem.radiusSmall,
                              ),
                              child: Text(
                                alert.severity.label,
                                style: AppDesignSystem.labelSmall.copyWith(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(alert.type.icon, size: 14, color: AppDesignSystem.neutral600),
                            const SizedBox(width: 4),
                            Text(alert.type.label, style: AppDesignSystem.labelSmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (alert.isAcknowledged)
                    Chip(
                      label: const Text('Acknowledged'),
                      backgroundColor: AppDesignSystem.info.withOpacity(0.1),
                      labelStyle: const TextStyle(color: AppDesignSystem.info, fontSize: 11),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(alert.description, style: AppDesignSystem.bodyMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.business, alert.affectedEntity),
                  if (alert.affectedState != null)
                    _buildInfoChip(Icons.location_on, alert.affectedState!),
                  if (alert.amount != null)
                    _buildInfoChip(Icons.currency_rupee, '₹${(alert.amount! / 10000000).toStringAsFixed(2)}Cr'),
                  _buildInfoChip(Icons.access_time, _formatTimeAgo(alert.createdAt)),
                  if (alert.assignedTo != null)
                    _buildInfoChip(Icons.person, alert.assignedTo!),
                ],
              ),
              if (alert.dueDate != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: alert.dueDate!.isBefore(DateTime.now())
                        ? AppDesignSystem.error.withOpacity(0.1)
                        : AppDesignSystem.warning.withOpacity(0.1),
                    borderRadius: AppDesignSystem.radiusSmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: alert.dueDate!.isBefore(DateTime.now())
                            ? AppDesignSystem.error
                            : AppDesignSystem.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${_formatDate(alert.dueDate!)}',
                        style: AppDesignSystem.labelSmall.copyWith(
                          color: alert.dueDate!.isBefore(DateTime.now())
                              ? AppDesignSystem.error
                              : AppDesignSystem.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppDesignSystem.neutral600),
        const SizedBox(width: 4),
        Text(label, style: AppDesignSystem.labelSmall),
      ],
    );
  }

  void _showAlertDetails(Alert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(alert.severity.icon, color: alert.severity.color),
            const SizedBox(width: 8),
            Expanded(child: Text(alert.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(alert.description),
              const SizedBox(height: 16),
              if (alert.actions.isNotEmpty) ...[
                const Text('Recommended Actions:', style: AppDesignSystem.titleSmall),
                const SizedBox(height: 8),
                ...alert.actions.map((action) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right, size: 16, color: AppDesignSystem.deepIndigo),
                      const SizedBox(width: 4),
                      Expanded(child: Text(action)),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          if (!alert.isAcknowledged)
            TextButton(
              onPressed: () {
                setState(() {
                  final index = _alerts.indexWhere((a) => a.id == alert.id);
                  if (index != -1) {
                    _alerts[index] = Alert(
                      id: alert.id,
                      title: alert.title,
                      description: alert.description,
                      severity: alert.severity,
                      type: alert.type,
                      createdAt: alert.createdAt,
                      affectedEntity: alert.affectedEntity,
                      affectedState: alert.affectedState,
                      amount: alert.amount,
                      isAcknowledged: true,
                      isResolved: alert.isResolved,
                      assignedTo: alert.assignedTo,
                      dueDate: alert.dueDate,
                      actions: alert.actions,
                    );
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Acknowledge'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final index = _alerts.indexWhere((a) => a.id == alert.id);
                if (index != -1) {
                  _alerts[index] = Alert(
                    id: alert.id,
                    title: alert.title,
                    description: alert.description,
                    severity: alert.severity,
                    type: alert.type,
                    createdAt: alert.createdAt,
                    affectedEntity: alert.affectedEntity,
                    affectedState: alert.affectedState,
                    amount: alert.amount,
                    isAcknowledged: true,
                    isResolved: true,
                    assignedTo: alert.assignedTo,
                    dueDate: alert.dueDate,
                    actions: alert.actions,
                  );
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Mark Resolved'),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 0) return '${duration.inDays}d ago';
    if (duration.inHours > 0) return '${duration.inHours}h ago';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m ago';
    return 'Just now';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}