import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/utils/responsive_layout.dart';

/// Compliance status
enum ComplianceStatus {
  compliant,
  partiallyCompliant,
  nonCompliant,
  pending,
}

extension ComplianceStatusExtension on ComplianceStatus {
  Color get color {
    switch (this) {
      case ComplianceStatus.compliant:
        return AppDesignSystem.success;
      case ComplianceStatus.partiallyCompliant:
        return AppDesignSystem.warning;
      case ComplianceStatus.nonCompliant:
        return AppDesignSystem.error;
      case ComplianceStatus.pending:
        return AppDesignSystem.neutral500;
    }
  }

  String get label {
    switch (this) {
      case ComplianceStatus.compliant:
        return 'Compliant';
      case ComplianceStatus.partiallyCompliant:
        return 'Partially Compliant';
      case ComplianceStatus.nonCompliant:
        return 'Non-Compliant';
      case ComplianceStatus.pending:
        return 'Pending Review';
    }
  }

  IconData get icon {
    switch (this) {
      case ComplianceStatus.compliant:
        return Icons.check_circle;
      case ComplianceStatus.partiallyCompliant:
        return Icons.warning;
      case ComplianceStatus.nonCompliant:
        return Icons.error;
      case ComplianceStatus.pending:
        return Icons.pending;
    }
  }
}

/// Compliance requirement types
enum ComplianceRequirement {
  ucSubmission,
  quarterlyReport,
  auditReport,
  financialStatement,
  projectUpdate,
  documentVerification,
}

extension ComplianceRequirementExtension on ComplianceRequirement {
  String get label {
    switch (this) {
      case ComplianceRequirement.ucSubmission:
        return 'UC Submission';
      case ComplianceRequirement.quarterlyReport:
        return 'Quarterly Report';
      case ComplianceRequirement.auditReport:
        return 'Audit Report';
      case ComplianceRequirement.financialStatement:
        return 'Financial Statement';
      case ComplianceRequirement.projectUpdate:
        return 'Project Update';
      case ComplianceRequirement.documentVerification:
        return 'Document Verification';
    }
  }
}

/// State compliance data
class StateCompliance {
  final String stateId;
  final String stateName;
  final double complianceScore;
  final ComplianceStatus status;
  final int totalRequirements;
  final int completedRequirements;
  final int pendingRequirements;
  final int overdueRequirements;
  final DateTime lastUpdated;
  final List<ComplianceIssue> issues;

  StateCompliance({
    required this.stateId,
    required this.stateName,
    required this.complianceScore,
    required this.status,
    required this.totalRequirements,
    required this.completedRequirements,
    required this.pendingRequirements,
    required this.overdueRequirements,
    required this.lastUpdated,
    this.issues = const [],
  });
}

/// Compliance issue
class ComplianceIssue {
  final String id;
  final ComplianceRequirement requirement;
  final String description;
  final DateTime dueDate;
  final bool isOverdue;
  final String? assignedTo;

  ComplianceIssue({
    required this.id,
    required this.requirement,
    required this.description,
    required this.dueDate,
    required this.isOverdue,
    this.assignedTo,
  });
}

/// Compliance Monitoring Widget
class ComplianceMonitoringWidget extends StatefulWidget {
  const ComplianceMonitoringWidget({super.key});

  @override
  State<ComplianceMonitoringWidget> createState() => _ComplianceMonitoringWidgetState();
}

class _ComplianceMonitoringWidgetState extends State<ComplianceMonitoringWidget> {
  List<StateCompliance> _stateCompliance = [];
  String _searchQuery = '';
  ComplianceStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadComplianceData();
  }

  void _loadComplianceData() {
    final now = DateTime.now();
    _stateCompliance = [
      StateCompliance(
        stateId: 'MH',
        stateName: 'Maharashtra',
        complianceScore: 95.5,
        status: ComplianceStatus.compliant,
        totalRequirements: 12,
        completedRequirements: 11,
        pendingRequirements: 1,
        overdueRequirements: 0,
        lastUpdated: now.subtract(const Duration(days: 2)),
        issues: [],
      ),
      StateCompliance(
        stateId: 'KA',
        stateName: 'Karnataka',
        complianceScore: 72.0,
        status: ComplianceStatus.partiallyCompliant,
        totalRequirements: 12,
        completedRequirements: 8,
        pendingRequirements: 2,
        overdueRequirements: 2,
        lastUpdated: now.subtract(const Duration(days: 5)),
        issues: [
          ComplianceIssue(
            id: '1',
            requirement: ComplianceRequirement.quarterlyReport,
            description: 'Q4 2024 quarterly report not submitted',
            dueDate: now.subtract(const Duration(days: 5)),
            isOverdue: true,
            assignedTo: 'State Commissioner',
          ),
          ComplianceIssue(
            id: '2',
            requirement: ComplianceRequirement.ucSubmission,
            description: 'UC for ₹10Cr pending submission',
            dueDate: now.add(const Duration(days: 3)),
            isOverdue: false,
            assignedTo: 'Finance Officer',
          ),
        ],
      ),
      StateCompliance(
        stateId: 'RJ',
        stateName: 'Rajasthan',
        complianceScore: 88.0,
        status: ComplianceStatus.compliant,
        totalRequirements: 12,
        completedRequirements: 10,
        pendingRequirements: 2,
        overdueRequirements: 0,
        lastUpdated: now.subtract(const Duration(days: 1)),
        issues: [],
      ),
      StateCompliance(
        stateId: 'TN',
        stateName: 'Tamil Nadu',
        complianceScore: 91.5,
        status: ComplianceStatus.compliant,
        totalRequirements: 12,
        completedRequirements: 11,
        pendingRequirements: 1,
        overdueRequirements: 0,
        lastUpdated: now.subtract(const Duration(hours: 12)),
        issues: [],
      ),
      StateCompliance(
        stateId: 'UP',
        stateName: 'Uttar Pradesh',
        complianceScore: 65.0,
        status: ComplianceStatus.partiallyCompliant,
        totalRequirements: 12,
        completedRequirements: 7,
        pendingRequirements: 3,
        overdueRequirements: 2,
        lastUpdated: now.subtract(const Duration(days: 7)),
        issues: [
          ComplianceIssue(
            id: '3',
            requirement: ComplianceRequirement.auditReport,
            description: 'Annual audit report overdue by 7 days',
            dueDate: now.subtract(const Duration(days: 7)),
            isOverdue: true,
            assignedTo: 'Audit Team',
          ),
        ],
      ),
      StateCompliance(
        stateId: 'PB',
        stateName: 'Punjab',
        complianceScore: 45.0,
        status: ComplianceStatus.nonCompliant,
        totalRequirements: 12,
        completedRequirements: 5,
        pendingRequirements: 4,
        overdueRequirements: 3,
        lastUpdated: now.subtract(const Duration(days: 10)),
        issues: [
          ComplianceIssue(
            id: '4',
            requirement: ComplianceRequirement.quarterlyReport,
            description: 'Multiple quarterly reports missing',
            dueDate: now.subtract(const Duration(days: 10)),
            isOverdue: true,
            assignedTo: 'State Commissioner',
          ),
          ComplianceIssue(
            id: '5',
            requirement: ComplianceRequirement.financialStatement,
            description: 'Financial statements not updated',
            dueDate: now.subtract(const Duration(days: 8)),
            isOverdue: true,
            assignedTo: 'Finance Director',
          ),
        ],
      ),
    ];
  }

  List<StateCompliance> get _filteredStates {
    return _stateCompliance.where((state) {
      if (_selectedStatus != null && state.status != _selectedStatus) return false;
      if (_searchQuery.isNotEmpty) {
        return state.stateName.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();
  }

  double get _averageComplianceScore {
    if (_stateCompliance.isEmpty) return 0;
    return _stateCompliance.fold(0.0, (sum, state) => sum + state.complianceScore) / _stateCompliance.length;
  }

  int get _totalOverdueRequirements {
    return _stateCompliance.fold(0, (sum, state) => sum + state.overdueRequirements);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSummarySection(),
        SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
        _buildFilterBar(),
        SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildStatesList(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComplianceChart(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
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
            'Avg Score',
            '${_averageComplianceScore.toStringAsFixed(1)}%',
            AppDesignSystem.deepIndigo,
            Icons.analytics,
          ),
          _buildSummaryCard(
            'Compliant',
            _stateCompliance.where((s) => s.status == ComplianceStatus.compliant).length.toString(),
            AppDesignSystem.success,
            Icons.check_circle,
          ),
          _buildSummaryCard(
            'Issues',
            _stateCompliance.where((s) => s.status == ComplianceStatus.partiallyCompliant || s.status == ComplianceStatus.nonCompliant).length.toString(),
            AppDesignSystem.warning,
            Icons.warning,
          ),
          _buildSummaryCard(
            'Overdue',
            _totalOverdueRequirements.toString(),
            AppDesignSystem.error,
            Icons.error,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color, IconData icon) {
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
              value,
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
    return Padding(
      padding: ResponsiveLayout.getResponsivePadding(context),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search states...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: AppDesignSystem.radiusMedium),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<ComplianceStatus>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status Filter',
                border: OutlineInputBorder(borderRadius: AppDesignSystem.radiusMedium),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Status')),
                ...ComplianceStatus.values.map((s) => DropdownMenuItem(
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
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatesList() {
    final states = _filteredStates..sort((a, b) => b.complianceScore.compareTo(a.complianceScore));

    return Card(
      margin: ResponsiveLayout.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('State Compliance Status', style: AppDesignSystem.headlineSmall),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: states.length,
              itemBuilder: (context, index) => _buildStateCard(states[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateCard(StateCompliance state) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showStateDetails(state),
        borderRadius: AppDesignSystem.radiusMedium,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.stateName, style: AppDesignSystem.titleMedium),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: state.status.color,
                                borderRadius: AppDesignSystem.radiusSmall,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(state.status.icon, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    state.status.label,
                                    style: AppDesignSystem.labelSmall.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${state.complianceScore.toStringAsFixed(1)}%',
                        style: AppDesignSystem.headlineMedium.copyWith(
                          color: state.status.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Score', style: AppDesignSystem.labelSmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: state.complianceScore / 100,
                backgroundColor: AppDesignSystem.neutral200,
                valueColor: AlwaysStoppedAnimation<Color>(state.status.color),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildStatChip(Icons.check_circle, '${state.completedRequirements}/${state.totalRequirements} Completed', AppDesignSystem.success),
                  _buildStatChip(Icons.pending, '${state.pendingRequirements} Pending', AppDesignSystem.warning),
                  if (state.overdueRequirements > 0)
                    _buildStatChip(Icons.error, '${state.overdueRequirements} Overdue', AppDesignSystem.error),
                ],
              ),
              if (state.issues.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('${state.issues.length} active issues', 
                  style: AppDesignSystem.labelSmall.copyWith(color: AppDesignSystem.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: AppDesignSystem.labelSmall.copyWith(color: color)),
      ],
    );
  }

  Widget _buildComplianceChart() {
    return Card(
      margin: ResponsiveLayout.getResponsivePadding(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compliance Distribution', style: AppDesignSystem.headlineSmall),
            const SizedBox(height: 24),
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      color: ComplianceStatus.compliant.color,
                      value: _stateCompliance.where((s) => s.status == ComplianceStatus.compliant).length.toDouble(),
                      title: 'Compliant',
                      titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      radius: 80,
                    ),
                    PieChartSectionData(
                      color: ComplianceStatus.partiallyCompliant.color,
                      value: _stateCompliance.where((s) => s.status == ComplianceStatus.partiallyCompliant).length.toDouble(),
                      title: 'Partial',
                      titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      radius: 80,
                    ),
                    PieChartSectionData(
                      color: ComplianceStatus.nonCompliant.color,
                      value: _stateCompliance.where((s) => s.status == ComplianceStatus.nonCompliant).length.toDouble(),
                      title: 'Non-Compliant',
                      titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      radius: 80,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...ComplianceStatus.values.take(3).map((status) {
              final count = _stateCompliance.where((s) => s.status == status).length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${status.label}: $count states', style: AppDesignSystem.bodySmall),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showStateDetails(StateCompliance state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(state.stateName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Compliance Score: ${state.complianceScore.toStringAsFixed(1)}%', 
                style: AppDesignSystem.titleMedium),
              const SizedBox(height: 16),
              if (state.issues.isNotEmpty) ...[
                Text('Active Issues:', style: AppDesignSystem.titleSmall),
                const SizedBox(height: 8),
                ...state.issues.map((issue) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(issue.requirement.label == 'UC Submission' ? Icons.file_present : Icons.assignment, 
                      color: issue.isOverdue ? AppDesignSystem.error : AppDesignSystem.warning),
                    title: Text(issue.requirement.label),
                    subtitle: Text(issue.description),
                    trailing: issue.isOverdue 
                      ? const Chip(
                          label: Text('Overdue', style: TextStyle(fontSize: 10)),
                          backgroundColor: Colors.red,
                          labelStyle: TextStyle(color: Colors.white),
                        )
                      : null,
                  ),
                )),
              ] else
                Text('No active issues', style: AppDesignSystem.bodyMedium.copyWith(color: AppDesignSystem.success)),
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
}