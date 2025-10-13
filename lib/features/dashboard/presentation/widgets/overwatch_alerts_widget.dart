import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';

/// Overwatch Alerts Widget
/// 
/// Displays all projects flagged by the overwatch system with
/// severity levels, reasons, and recommended actions.
class OverwatchAlertsWidget extends StatefulWidget {
  const OverwatchAlertsWidget({super.key});

  @override
  State<OverwatchAlertsWidget> createState() => _OverwatchAlertsWidgetState();
}

class _OverwatchAlertsWidgetState extends State<OverwatchAlertsWidget> {
  String _filterSeverity = 'ALL';
  String _filterCategory = 'ALL';

  final List<OverwatchAlert> _alerts = [
    OverwatchAlert(
      projectId: 'PMAJAY-MH-045',
      projectName: 'Maharashtra Healthcare Infrastructure',
      severity: AlertSeverity.critical,
      category: AlertCategory.financial,
      flaggedBy: 'AI Fraud Detection System',
      reason: 'Irregular fund disbursement pattern detected',
      details: 'Multiple high-value transactions flagged for unusual timing and amounts. Requires immediate verification.',
      flaggedDate: DateTime.now().subtract(const Duration(hours: 2)),
      recommendedAction: 'Initiate financial audit and suspend fund transfers',
      status: AlertStatus.pending,
    ),
    OverwatchAlert(
      projectId: 'PMAJAY-GJ-089',
      projectName: 'Gujarat Urban Health Centers',
      severity: AlertSeverity.high,
      category: AlertCategory.timeline,
      flaggedBy: 'Timeline Monitoring System',
      reason: 'Milestone M4 delayed by 45 days',
      details: 'Project timeline significantly behind schedule. Agency has not provided valid justification.',
      flaggedDate: DateTime.now().subtract(const Duration(hours: 6)),
      recommendedAction: 'Review project timeline and agency capacity',
      status: AlertStatus.underReview,
    ),
    OverwatchAlert(
      projectId: 'PMAJAY-UP-134',
      projectName: 'Uttar Pradesh Emergency Services',
      severity: AlertSeverity.critical,
      category: AlertCategory.compliance,
      flaggedBy: 'Document Verification AI',
      reason: 'Tampered evidence detected in milestone claim',
      details: 'Blockchain verification failed for submitted construction photos. Metadata analysis shows possible manipulation.',
      flaggedDate: DateTime.now().subtract(const Duration(hours: 12)),
      recommendedAction: 'Reject claim and initiate investigation',
      status: AlertStatus.escalated,
    ),
    OverwatchAlert(
      projectId: 'PMAJAY-RJ-078',
      projectName: 'Rajasthan Primary Health Network',
      severity: AlertSeverity.medium,
      category: AlertCategory.quality,
      flaggedBy: 'Quality Assessment AI',
      reason: 'Construction quality below standards',
      details: 'Site inspection reports indicate substandard materials used in 3 out of 5 facilities.',
      flaggedDate: DateTime.now().subtract(const Duration(days: 1)),
      recommendedAction: 'Schedule quality audit and corrective action plan',
      status: AlertStatus.pending,
    ),
    OverwatchAlert(
      projectId: 'PMAJAY-KA-056',
      projectName: 'Karnataka Telemedicine Network',
      severity: AlertSeverity.high,
      category: AlertCategory.financial,
      flaggedBy: 'Expense Analysis System',
      reason: 'Budget overrun detected - 15% above approved',
      details: 'Equipment procurement costs significantly higher than market rates. Possible vendor collusion.',
      flaggedDate: DateTime.now().subtract(const Duration(days: 2)),
      recommendedAction: 'Review procurement process and vendor agreements',
      status: AlertStatus.underReview,
    ),
    OverwatchAlert(
      projectId: 'PMAJAY-TN-092',
      projectName: 'Tamil Nadu Medical Equipment Supply',
      severity: AlertSeverity.low,
      category: AlertCategory.documentation,
      flaggedBy: 'Document Completeness Check',
      reason: 'Missing mandatory compliance certificates',
      details: 'Environmental clearance and safety compliance documents pending submission.',
      flaggedDate: DateTime.now().subtract(const Duration(days: 3)),
      recommendedAction: 'Request missing documents within 7 days',
      status: AlertStatus.pending,
    ),
  ];

  List<OverwatchAlert> get filteredAlerts {
    return _alerts.where((alert) {
      final severityMatch = _filterSeverity == 'ALL' || alert.severity.name.toUpperCase() == _filterSeverity;
      final categoryMatch = _filterCategory == 'ALL' || alert.category.name.toUpperCase() == _filterCategory;
      return severityMatch && categoryMatch;
    }).toList();
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppTheme.errorRed;
      case AlertSeverity.high:
        return AppTheme.warningOrange;
      case AlertSeverity.medium:
        return Colors.yellow.shade700;
      case AlertSeverity.low:
        return Colors.blue.shade600;
    }
  }

  IconData _getCategoryIcon(AlertCategory category) {
    switch (category) {
      case AlertCategory.financial:
        return Icons.account_balance_wallet;
      case AlertCategory.timeline:
        return Icons.schedule;
      case AlertCategory.compliance:
        return Icons.gavel;
      case AlertCategory.quality:
        return Icons.verified;
      case AlertCategory.documentation:
        return Icons.description;
    }
  }

  IconData _getStatusIcon(AlertStatus status) {
    switch (status) {
      case AlertStatus.pending:
        return Icons.pending;
      case AlertStatus.underReview:
        return Icons.rate_review;
      case AlertStatus.escalated:
        return Icons.error_outline;
      case AlertStatus.resolved:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: ResponsiveLayout.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stats
          _buildHeaderStats(),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) * 2),
          
          // Filters
          _buildFilters(),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) * 2),
          
          // Alerts list
          _buildAlertsList(),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    final criticalCount = _alerts.where((a) => a.severity == AlertSeverity.critical).length;
    final highCount = _alerts.where((a) => a.severity == AlertSeverity.high).length;
    final pendingCount = _alerts.where((a) => a.status == AlertStatus.pending).length;
    final escalatedCount = _alerts.where((a) => a.status == AlertStatus.escalated).length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: ResponsiveLayout.getResponsiveCardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: ResponsiveLayout.getResponsiveIconSize(context) * 1.5),
                SizedBox(width: ResponsiveLayout.getResponsiveSpacing(context)),
                ResponsiveLayout.responsiveText(
                  'Overwatch Alert Dashboard',
                  context: context,
                  style: TextStyle(
                    fontSize: ResponsiveLayout.getResponsiveHeadingSize(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
            ResponsiveLayout.responsiveText(
              'Real-time monitoring and flagging of projects requiring immediate attention',
              context: context,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) * 2),
            ResponsiveLayout.responsiveFlex(
              context: context,
              children: [
                Expanded(child: _buildStatCard('Critical Alerts', criticalCount, AppTheme.errorRed, Icons.error)),
                Expanded(child: _buildStatCard('High Priority', highCount, AppTheme.warningOrange, Icons.warning)),
                Expanded(child: _buildStatCard('Pending Review', pendingCount, Colors.blue, Icons.pending_actions)),
                Expanded(child: _buildStatCard('Escalated', escalatedCount, Colors.purple, Icons.trending_up)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: ResponsiveLayout.getResponsiveCardPadding(context),
        child: Column(
          children: [
            Icon(icon, color: color, size: ResponsiveLayout.getResponsiveIconSize(context) * 1.5),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
            ResponsiveLayout.responsiveText(
              value.toString(),
              context: context,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveHeadingSize(context),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
            ResponsiveLayout.responsiveText(
              label,
              context: context,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: ResponsiveLayout.getResponsiveCardPadding(context),
        child: ResponsiveLayout.responsiveFlex(
          context: context,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveLayout.responsiveText(
                    'Filter by Severity',
                    context: context,
                    style: TextStyle(fontSize: ResponsiveLayout.getResponsiveCaptionSize(context)),
                  ),
                  SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
                  DropdownButton<String>(
                    value: _filterSeverity,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Severities')),
                      DropdownMenuItem(value: 'CRITICAL', child: Text('Critical')),
                      DropdownMenuItem(value: 'HIGH', child: Text('High')),
                      DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                      DropdownMenuItem(value: 'LOW', child: Text('Low')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _filterSeverity = value);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveLayout.responsiveText(
                    'Filter by Category',
                    context: context,
                    style: TextStyle(fontSize: ResponsiveLayout.getResponsiveCaptionSize(context)),
                  ),
                  SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
                  DropdownButton<String>(
                    value: _filterCategory,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Categories')),
                      DropdownMenuItem(value: 'FINANCIAL', child: Text('Financial')),
                      DropdownMenuItem(value: 'TIMELINE', child: Text('Timeline')),
                      DropdownMenuItem(value: 'COMPLIANCE', child: Text('Compliance')),
                      DropdownMenuItem(value: 'QUALITY', child: Text('Quality')),
                      DropdownMenuItem(value: 'DOCUMENTATION', child: Text('Documentation')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _filterCategory = value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsList() {
    final alerts = filteredAlerts;
    
    if (alerts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: AppTheme.successGreen),
                const SizedBox(height: 16),
                Text(
                  'No alerts match the selected filters',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: alerts.map((alert) => _buildAlertCard(alert)).toList(),
    );
  }

  Widget _buildAlertCard(OverwatchAlert alert) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveLayout.getResponsiveSpacing(context)),
      elevation: 3,
      child: InkWell(
        onTap: () => _showAlertDetails(alert),
        borderRadius: ResponsiveLayout.getResponsiveBorderRadius(context),
        child: Padding(
          padding: ResponsiveLayout.getResponsiveCardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Severity indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(alert.severity).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getSeverityColor(alert.severity)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: _getSeverityColor(alert.severity),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          alert.severity.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                            fontWeight: FontWeight.bold,
                            color: _getSeverityColor(alert.severity),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: ResponsiveLayout.getResponsiveSpacing(context)),
                  // Category
                  Chip(
                    avatar: Icon(_getCategoryIcon(alert.category), size: 16),
                    label: Text(
                      alert.category.name.toUpperCase(),
                      style: TextStyle(fontSize: ResponsiveLayout.getResponsiveCaptionSize(context)),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Spacer(),
                  // Status
                  Icon(_getStatusIcon(alert.status), size: 20, color: Colors.grey.shade600),
                ],
              ),
              SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
              ResponsiveLayout.responsiveText(
                alert.projectName,
                context: context,
                style: TextStyle(
                  fontSize: ResponsiveLayout.getResponsiveTitleSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
              ResponsiveLayout.responsiveText(
                'Project ID: ${alert.projectId}',
                context: context,
                style: TextStyle(
                  fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveLayout.responsiveText(
                      alert.reason,
                      context: context,
                      style: TextStyle(
                        fontSize: ResponsiveLayout.getResponsiveBodySize(context),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
                    ResponsiveLayout.responsiveText(
                      alert.details,
                      context: context,
                      style: TextStyle(
                        fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                        color: Colors.white,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ResponsiveLayout.responsiveText(
                      'Flagged by: ${alert.flaggedBy}',
                      context: context,
                      style: TextStyle(
                        fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  ResponsiveLayout.responsiveText(
                    _formatTimeAgo(alert.flaggedDate),
                    context: context,
                    style: TextStyle(
                      fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAlertDetails(alert),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('View Details'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(0, ResponsiveLayout.getResponsiveButtonHeight(context)),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveLayout.getResponsiveSpacing(context)),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _takeAction(alert),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Take Action'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(0, ResponsiveLayout.getResponsiveButtonHeight(context)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  void _showAlertDetails(OverwatchAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert.projectName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Project ID: ${alert.projectId}'),
              const SizedBox(height: 16),
              Text('Severity: ${alert.severity.name.toUpperCase()}'),
              Text('Category: ${alert.category.name.toUpperCase()}'),
              Text('Status: ${alert.status.name.toUpperCase()}'),
              const SizedBox(height: 16),
              const Text('Reason:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(alert.reason),
              const SizedBox(height: 16),
              const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(alert.details),
              const SizedBox(height: 16),
              const Text('Recommended Action:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(alert.recommendedAction),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _takeAction(OverwatchAlert alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action initiated for ${alert.projectId}'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }
}

enum AlertSeverity { critical, high, medium, low }
enum AlertCategory { financial, timeline, compliance, quality, documentation }
enum AlertStatus { pending, underReview, escalated, resolved }

class OverwatchAlert {
  final String projectId;
  final String projectName;
  final AlertSeverity severity;
  final AlertCategory category;
  final String flaggedBy;
  final String reason;
  final String details;
  final DateTime flaggedDate;
  final String recommendedAction;
  final AlertStatus status;

  OverwatchAlert({
    required this.projectId,
    required this.projectName,
    required this.severity,
    required this.category,
    required this.flaggedBy,
    required this.reason,
    required this.details,
    required this.flaggedDate,
    required this.recommendedAction,
    required this.status,
  });
}