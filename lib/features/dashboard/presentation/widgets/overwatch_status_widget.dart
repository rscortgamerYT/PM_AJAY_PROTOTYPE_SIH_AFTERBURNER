import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';

/// Overwatch Status Widget
/// 
/// Displays audit-marked projects and overall overwatch monitoring activities
/// showing what actions the overwatch system is taking across all projects.
class OverwatchStatusWidget extends StatefulWidget {
  const OverwatchStatusWidget({super.key});

  @override
  State<OverwatchStatusWidget> createState() => _OverwatchStatusWidgetState();
}

class _OverwatchStatusWidgetState extends State<OverwatchStatusWidget> {
  String _selectedTab = 'audit'; // 'audit', 'monitoring', 'actions'

  final List<AuditProject> _auditProjects = [
    AuditProject(
      projectId: 'PMAJAY-MH-045',
      projectName: 'Maharashtra Healthcare Infrastructure',
      auditType: AuditType.financial,
      auditStatus: AuditStatus.inProgress,
      auditReason: 'Irregular fund disbursement patterns detected',
      auditor: 'Central Financial Audit Team',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      expectedCompletionDate: DateTime.now().add(const Duration(days: 10)),
      findings: 'Preliminary review shows discrepancies in equipment procurement',
      priority: AuditPriority.high,
    ),
    AuditProject(
      projectId: 'PMAJAY-UP-134',
      projectName: 'Uttar Pradesh Emergency Services',
      auditType: AuditType.compliance,
      auditStatus: AuditStatus.scheduled,
      auditReason: 'Tampered evidence detected in milestone claim',
      auditor: 'Document Verification Unit',
      startDate: DateTime.now().add(const Duration(days: 2)),
      expectedCompletionDate: DateTime.now().add(const Duration(days: 17)),
      findings: 'Awaiting audit commencement',
      priority: AuditPriority.critical,
    ),
    AuditProject(
      projectId: 'PMAJAY-KA-056',
      projectName: 'Karnataka Telemedicine Network',
      auditType: AuditType.procurement,
      auditStatus: AuditStatus.inProgress,
      auditReason: 'Budget overrun and vendor pricing concerns',
      auditor: 'Procurement Compliance Team',
      startDate: DateTime.now().subtract(const Duration(days: 3)),
      expectedCompletionDate: DateTime.now().add(const Duration(days: 12)),
      findings: 'Equipment costs 18% above market average',
      priority: AuditPriority.high,
    ),
    AuditProject(
      projectId: 'PMAJAY-RJ-078',
      projectName: 'Rajasthan Primary Health Network',
      auditType: AuditType.quality,
      auditStatus: AuditStatus.completed,
      auditReason: 'Construction quality below standards',
      auditor: 'Technical Quality Assurance',
      startDate: DateTime.now().subtract(const Duration(days: 20)),
      expectedCompletionDate: DateTime.now().subtract(const Duration(days: 5)),
      findings: 'Substandard materials used - corrective action plan implemented',
      priority: AuditPriority.medium,
    ),
  ];

  final List<MonitoringActivity> _monitoringActivities = [
    MonitoringActivity(
      activityType: 'Real-time Fund Tracking',
      projectsMonitored: 342,
      status: 'Active',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
      description: 'Continuous monitoring of all fund transfers and disbursements',
      alertsGenerated: 8,
    ),
    MonitoringActivity(
      activityType: 'Document Verification',
      projectsMonitored: 267,
      status: 'Active',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 15)),
      description: 'AI-powered blockchain verification of submitted evidence',
      alertsGenerated: 3,
    ),
    MonitoringActivity(
      activityType: 'Timeline Compliance',
      projectsMonitored: 342,
      status: 'Active',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 30)),
      description: 'Automated tracking of milestone deadlines and project progress',
      alertsGenerated: 12,
    ),
    MonitoringActivity(
      activityType: 'Quality Assurance',
      projectsMonitored: 198,
      status: 'Active',
      lastUpdate: DateTime.now().subtract(const Duration(hours: 1)),
      description: 'Site inspection report analysis and construction quality monitoring',
      alertsGenerated: 5,
    ),
    MonitoringActivity(
      activityType: 'Expense Analysis',
      projectsMonitored: 342,
      status: 'Active',
      lastUpdate: DateTime.now().subtract(const Duration(hours: 2)),
      description: 'Budget utilization tracking and anomaly detection',
      alertsGenerated: 6,
    ),
    MonitoringActivity(
      activityType: 'Compliance Tracking',
      projectsMonitored: 342,
      status: 'Active',
      lastUpdate: DateTime.now().subtract(const Duration(hours: 3)),
      description: 'Regulatory compliance and mandatory documentation verification',
      alertsGenerated: 4,
    ),
  ];

  final List<OverwatchAction> _overwatchActions = [
    OverwatchAction(
      actionType: 'Fund Transfer Suspension',
      projectId: 'PMAJAY-MH-045',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      reason: 'Irregular fund disbursement patterns detected',
      status: 'Active',
      initiatedBy: 'AI Fraud Detection System',
    ),
    OverwatchAction(
      actionType: 'Audit Initiated',
      projectId: 'PMAJAY-UP-134',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      reason: 'Evidence tampering detected',
      status: 'In Progress',
      initiatedBy: 'Document Verification AI',
    ),
    OverwatchAction(
      actionType: 'Claim Rejection',
      projectId: 'PMAJAY-UP-134',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      reason: 'Failed blockchain verification',
      status: 'Completed',
      initiatedBy: 'Smart Contract System',
    ),
    OverwatchAction(
      actionType: 'Agency Review Required',
      projectId: 'PMAJAY-GJ-089',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      reason: 'Milestone delay exceeding acceptable threshold',
      status: 'Pending',
      initiatedBy: 'Timeline Monitoring System',
    ),
    OverwatchAction(
      actionType: 'Procurement Investigation',
      projectId: 'PMAJAY-KA-056',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      reason: 'Equipment costs significantly above market rates',
      status: 'In Progress',
      initiatedBy: 'Expense Analysis System',
    ),
    OverwatchAction(
      actionType: 'Quality Inspection Ordered',
      projectId: 'PMAJAY-RJ-078',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      reason: 'Construction quality concerns',
      status: 'Scheduled',
      initiatedBy: 'Quality Assessment AI',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: ResponsiveLayout.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) * 2),
          _buildTabBar(),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) * 2),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: ResponsiveLayout.getResponsiveCardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, size: ResponsiveLayout.getResponsiveIconSize(context) * 1.5),
                SizedBox(width: ResponsiveLayout.getResponsiveSpacing(context)),
                ResponsiveLayout.responsiveText(
                  'Overwatch Status & Monitoring',
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
              'Comprehensive view of ongoing audits, monitoring activities, and automated actions',
              context: context,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Card(
      child: Padding(
        padding: ResponsiveLayout.getResponsiveCardPadding(context),
        child: ResponsiveLayout.responsiveFlex(
          context: context,
          children: [
            Expanded(
              child: _buildTabButton(
                'Audit Projects',
                'audit',
                Icons.fact_check,
                _auditProjects.length,
              ),
            ),
            Expanded(
              child: _buildTabButton(
                'Monitoring',
                'monitoring',
                Icons.monitor_heart,
                _monitoringActivities.length,
              ),
            ),
            Expanded(
              child: _buildTabButton(
                'Actions Taken',
                'actions',
                Icons.bolt,
                _overwatchActions.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, String value, IconData icon, int count) {
    final isSelected = _selectedTab == value;
    return InkWell(
      onTap: () => setState(() => _selectedTab = value),
      borderRadius: ResponsiveLayout.getResponsiveBorderRadius(context),
      child: Container(
        padding: ResponsiveLayout.getResponsiveCardPadding(context),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryIndigo.withOpacity(0.1) : Colors.transparent,
          borderRadius: ResponsiveLayout.getResponsiveBorderRadius(context),
          border: Border.all(
            color: isSelected ? AppTheme.primaryIndigo : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryIndigo : Colors.grey.shade600,
              size: ResponsiveLayout.getResponsiveIconSize(context) * 1.5,
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
            ResponsiveLayout.responsiveText(
              label,
              context: context,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryIndigo : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryIndigo : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ResponsiveLayout.responsiveText(
                count.toString(),
                context: context,
                style: TextStyle(
                  fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'audit':
        return _buildAuditProjects();
      case 'monitoring':
        return _buildMonitoringActivities();
      case 'actions':
        return _buildOverwatchActions();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAuditProjects() {
    return Column(
      children: _auditProjects.map((audit) => _buildAuditCard(audit)).toList(),
    );
  }

  Widget _buildAuditCard(AuditProject audit) {
    Color getPriorityColor() {
      switch (audit.priority) {
        case AuditPriority.critical:
          return AppTheme.errorRed;
        case AuditPriority.high:
          return AppTheme.warningOrange;
        case AuditPriority.medium:
          return Colors.yellow.shade700;
        case AuditPriority.low:
          return Colors.blue.shade600;
      }
    }

    Color getStatusColor() {
      switch (audit.auditStatus) {
        case AuditStatus.scheduled:
          return Colors.blue;
        case AuditStatus.inProgress:
          return Colors.orange;
        case AuditStatus.completed:
          return AppTheme.successGreen;
        case AuditStatus.onHold:
          return Colors.grey;
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveLayout.getResponsiveSpacing(context)),
      elevation: 3,
      child: Padding(
        padding: ResponsiveLayout.getResponsiveCardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getPriorityColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: getPriorityColor()),
                  ),
                  child: ResponsiveLayout.responsiveText(
                    audit.priority.name.toUpperCase(),
                    context: context,
                    style: TextStyle(
                      fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                      fontWeight: FontWeight.bold,
                      color: getPriorityColor(),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveLayout.getResponsiveSpacing(context)),
                Chip(
                  label: ResponsiveLayout.responsiveText(
                    audit.auditType.name.toUpperCase(),
                    context: context,
                    style: TextStyle(fontSize: ResponsiveLayout.getResponsiveCaptionSize(context)),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: getStatusColor()),
                  ),
                  child: ResponsiveLayout.responsiveText(
                    audit.auditStatus.name.toUpperCase(),
                    context: context,
                    style: TextStyle(
                      fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
            ResponsiveLayout.responsiveText(
              audit.projectName,
              context: context,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveTitleSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
            ResponsiveLayout.responsiveText(
              'Project ID: ${audit.projectId}',
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
                    'Audit Reason',
                    context: context,
                    style: TextStyle(
                      fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
                  ResponsiveLayout.responsiveText(
                    audit.auditReason,
                    context: context,
                    style: TextStyle(
                      fontSize: ResponsiveLayout.getResponsiveBodySize(context),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
            ResponsiveLayout.responsiveFlex(
              context: context,
              children: [
                Expanded(
                  child: _buildInfoRow(Icons.person_outline, 'Auditor', audit.auditor),
                ),
              ],
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
            ResponsiveLayout.responsiveFlex(
              context: context,
              children: [
                Expanded(
                  child: _buildInfoRow(Icons.calendar_today, 'Start', _formatDate(audit.startDate)),
                ),
                Expanded(
                  child: _buildInfoRow(Icons.event, 'Expected End', _formatDate(audit.expectedCompletionDate)),
                ),
              ],
            ),
            if (audit.findings.isNotEmpty) ...[
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
                      'Findings',
                      context: context,
                      style: TextStyle(
                        fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
                    ResponsiveLayout.responsiveText(
                      audit.findings,
                      context: context,
                      style: TextStyle(
                        fontSize: ResponsiveLayout.getResponsiveBodySize(context),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringActivities() {
    return Column(
      children: _monitoringActivities.map((activity) => _buildMonitoringCard(activity)).toList(),
    );
  }

  Widget _buildMonitoringCard(MonitoringActivity activity) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveLayout.getResponsiveSpacing(context)),
      elevation: 3,
      child: Padding(
        padding: ResponsiveLayout.getResponsiveCardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.monitor_heart,
                    color: AppTheme.successGreen,
                    size: ResponsiveLayout.getResponsiveIconSize(context) * 1.5,
                  ),
                ),
                SizedBox(width: ResponsiveLayout.getResponsiveSpacing(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveLayout.responsiveText(
                        activity.activityType,
                        context: context,
                        style: TextStyle(
                          fontSize: ResponsiveLayout.getResponsiveTitleSize(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 4),
                      ResponsiveLayout.responsiveText(
                        activity.status,
                        context: context,
                        style: TextStyle(
                          fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
            ResponsiveLayout.responsiveText(
              activity.description,
              context: context,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveBodySize(context),
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
            ResponsiveLayout.responsiveFlex(
              context: context,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ResponsiveLayout.responsiveText(
                          activity.projectsMonitored.toString(),
                          context: context,
                          style: TextStyle(
                            fontSize: ResponsiveLayout.getResponsiveHeadingSize(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        ResponsiveLayout.responsiveText(
                          'Projects',
                          context: context,
                          style: TextStyle(
                            fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ResponsiveLayout.responsiveText(
                          activity.alertsGenerated.toString(),
                          context: context,
                          style: TextStyle(
                            fontSize: ResponsiveLayout.getResponsiveHeadingSize(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        ResponsiveLayout.responsiveText(
                          'Alerts',
                          context: context,
                          style: TextStyle(
                            fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                ResponsiveLayout.responsiveText(
                  'Last updated: ${_formatTimeAgo(activity.lastUpdate)}',
                  context: context,
                  style: TextStyle(
                    fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverwatchActions() {
    return Column(
      children: _overwatchActions.map((action) => _buildActionCard(action)).toList(),
    );
  }

  Widget _buildActionCard(OverwatchAction action) {
    Color getStatusColor() {
      switch (action.status) {
        case 'Active':
          return AppTheme.errorRed;
        case 'In Progress':
          return Colors.orange;
        case 'Completed':
          return AppTheme.successGreen;
        case 'Pending':
          return Colors.blue;
        case 'Scheduled':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    }

    IconData getActionIcon() {
      if (action.actionType.contains('Suspension')) return Icons.block;
      if (action.actionType.contains('Audit')) return Icons.fact_check;
      if (action.actionType.contains('Rejection')) return Icons.cancel;
      if (action.actionType.contains('Review')) return Icons.rate_review;
      if (action.actionType.contains('Investigation')) return Icons.search;
      if (action.actionType.contains('Inspection')) return Icons.visibility;
      return Icons.bolt;
    }

    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveLayout.getResponsiveSpacing(context)),
      elevation: 3,
      child: Padding(
        padding: ResponsiveLayout.getResponsiveCardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    getActionIcon(),
                    color: getStatusColor(),
                    size: ResponsiveLayout.getResponsiveIconSize(context) * 1.5,
                  ),
                ),
                SizedBox(width: ResponsiveLayout.getResponsiveSpacing(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveLayout.responsiveText(
                        action.actionType,
                        context: context,
                        style: TextStyle(
                          fontSize: ResponsiveLayout.getResponsiveTitleSize(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 4),
                      ResponsiveLayout.responsiveText(
                        action.projectId,
                        context: context,
                        style: TextStyle(
                          fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: getStatusColor()),
                  ),
                  child: ResponsiveLayout.responsiveText(
                    action.status,
                    context: context,
                    style: TextStyle(
                      fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ResponsiveLayout.responsiveText(
                action.reason,
                context: context,
                style: TextStyle(
                  fontSize: ResponsiveLayout.getResponsiveBodySize(context),
                ),
              ),
            ),
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
            Row(
              children: [
                Icon(Icons.smart_toy, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: ResponsiveLayout.responsiveText(
                    'Initiated by: ${action.initiatedBy}',
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
                  _formatTimeAgo(action.timestamp),
                  context: context,
                  style: TextStyle(
                    fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: ResponsiveLayout.responsiveText(
            '$label: $value',
            context: context,
            style: TextStyle(
              fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
}

enum AuditType { financial, compliance, procurement, quality, timeline }
enum AuditStatus { scheduled, inProgress, completed, onHold }
enum AuditPriority { critical, high, medium, low }

class AuditProject {
  final String projectId;
  final String projectName;
  final AuditType auditType;
  final AuditStatus auditStatus;
  final String auditReason;
  final String auditor;
  final DateTime startDate;
  final DateTime expectedCompletionDate;
  final String findings;
  final AuditPriority priority;

  AuditProject({
    required this.projectId,
    required this.projectName,
    required this.auditType,
    required this.auditStatus,
    required this.auditReason,
    required this.auditor,
    required this.startDate,
    required this.expectedCompletionDate,
    required this.findings,
    required this.priority,
  });
}

class MonitoringActivity {
  final String activityType;
  final int projectsMonitored;
  final String status;
  final DateTime lastUpdate;
  final String description;
  final int alertsGenerated;

  MonitoringActivity({
    required this.activityType,
    required this.projectsMonitored,
    required this.status,
    required this.lastUpdate,
    required this.description,
    required this.alertsGenerated,
  });
}

class OverwatchAction {
  final String actionType;
  final String projectId;
  final DateTime timestamp;
  final String reason;
  final String status;
  final String initiatedBy;

  OverwatchAction({
    required this.actionType,
    required this.projectId,
    required this.timestamp,
    required this.reason,
    required this.status,
    required this.initiatedBy,
  });
}