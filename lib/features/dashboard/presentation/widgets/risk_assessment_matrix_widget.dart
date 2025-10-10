import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Risk Assessment Matrix Widget
/// 
/// Multi-factor risk scoring per project with severity visualization,
/// mitigation recommendations, and escalation triggers.
class RiskAssessmentMatrixWidget extends StatefulWidget {
  final String userId;
  
  const RiskAssessmentMatrixWidget({
    super.key,
    required this.userId,
  });

  @override
  State<RiskAssessmentMatrixWidget> createState() => 
      _RiskAssessmentMatrixWidgetState();
}

class _RiskAssessmentMatrixWidgetState 
    extends State<RiskAssessmentMatrixWidget> {
  
  String _selectedView = 'matrix'; // 'matrix', 'list', 'timeline'
  String _selectedSeverity = 'all'; // 'all', 'critical', 'high', 'medium', 'low'

  final List<ProjectRisk> _mockRisks = [
    ProjectRisk(
      projectId: 'project_001',
      projectName: 'Water Supply - Sector A',
      location: 'Mumbai, Maharashtra',
      overallRiskScore: 85.0,
      severity: RiskSeverity.critical,
      factors: {
        'Financial': 90.0,
        'Timeline': 85.0,
        'Quality': 75.0,
        'Safety': 80.0,
        'Environmental': 70.0,
      },
      identifiedRisks: [
        'Budget overrun by 15%',
        'Delay in material procurement',
        'Monsoon season impact',
      ],
      mitigationActions: [
        'Request additional funding',
        'Identify alternate suppliers',
        'Implement weather protection measures',
      ],
      lastAssessed: DateTime(2025, 10, 9),
    ),
    ProjectRisk(
      projectId: 'project_002',
      projectName: 'Toilet Construction - Phase 1',
      location: 'Pune, Maharashtra',
      overallRiskScore: 45.0,
      severity: RiskSeverity.medium,
      factors: {
        'Financial': 40.0,
        'Timeline': 50.0,
        'Quality': 45.0,
        'Safety': 40.0,
        'Environmental': 48.0,
      },
      identifiedRisks: [
        'Minor timeline delays',
        'Workforce availability concerns',
      ],
      mitigationActions: [
        'Hire additional contractors',
        'Adjust work schedule',
      ],
      lastAssessed: DateTime(2025, 10, 8),
    ),
    ProjectRisk(
      projectId: 'project_003',
      projectName: 'Rural Water Distribution',
      location: 'Nashik, Maharashtra',
      overallRiskScore: 65.0,
      severity: RiskSeverity.high,
      factors: {
        'Financial': 60.0,
        'Timeline': 70.0,
        'Quality': 65.0,
        'Safety': 60.0,
        'Environmental': 68.0,
      },
      identifiedRisks: [
        'Remote location challenges',
        'Limited equipment access',
        'Community resistance',
      ],
      mitigationActions: [
        'Community engagement program',
        'Arrange specialized equipment',
        'Establish local support center',
      ],
      lastAssessed: DateTime(2025, 10, 7),
    ),
    ProjectRisk(
      projectId: 'project_004',
      projectName: 'Sanitation Complex',
      location: 'Nagpur, Maharashtra',
      overallRiskScore: 25.0,
      severity: RiskSeverity.low,
      factors: {
        'Financial': 20.0,
        'Timeline': 25.0,
        'Quality': 30.0,
        'Safety': 22.0,
        'Environmental': 28.0,
      },
      identifiedRisks: [
        'Minor quality control issues',
      ],
      mitigationActions: [
        'Increase inspection frequency',
      ],
      lastAssessed: DateTime(2025, 10, 6),
    ),
  ];

  List<ProjectRisk> get _filteredRisks {
    if (_selectedSeverity == 'all') {
      return _mockRisks;
    }
    final severity = RiskSeverity.values.firstWhere(
      (s) => s.name == _selectedSeverity,
      orElse: () => RiskSeverity.low,
    );
    return _mockRisks.where((r) => r.severity == severity).toList();
  }

  Color _getSeverityColor(RiskSeverity severity) {
    switch (severity) {
      case RiskSeverity.critical:
        return AppTheme.errorRed;
      case RiskSeverity.high:
        return Colors.orange.shade700;
      case RiskSeverity.medium:
        return AppTheme.warningOrange;
      case RiskSeverity.low:
        return AppTheme.successGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildControls(),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.overwatchColor, Colors.pink.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Risk Assessment Matrix',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Multi-factor risk scoring with mitigation strategies',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildSummaryStats(),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    final critical = _mockRisks.where((r) => r.severity == RiskSeverity.critical).length;
    final high = _mockRisks.where((r) => r.severity == RiskSeverity.high).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                critical.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Critical',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              Text(
                high.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'High',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'matrix', label: Text('Matrix'), icon: Icon(Icons.grid_on)),
                ButtonSegment(value: 'list', label: Text('List'), icon: Icon(Icons.list)),
                ButtonSegment(value: 'timeline', label: Text('Timeline'), icon: Icon(Icons.timeline)),
              ],
              selected: {_selectedView},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _selectedView = newSelection.first);
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _selectedSeverity,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Severities')),
              DropdownMenuItem(value: 'critical', child: Text('Critical Only')),
              DropdownMenuItem(value: 'high', child: Text('High Only')),
              DropdownMenuItem(value: 'medium', child: Text('Medium Only')),
              DropdownMenuItem(value: 'low', child: Text('Low Only')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedSeverity = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedView) {
      case 'timeline':
        return _buildTimelineView();
      case 'list':
        return _buildListView();
      default:
        return _buildMatrixView();
    }
  }

  Widget _buildMatrixView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _filteredRisks.length,
      itemBuilder: (context, index) {
        return _buildRiskMatrixCard(_filteredRisks[index]);
      },
    );
  }

  Widget _buildRiskMatrixCard(ProjectRisk risk) {
    final severityColor = _getSeverityColor(risk.severity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    risk.projectName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    risk.severity.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    risk.location,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: risk.overallRiskScore / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(severityColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        risk.overallRiskScore.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: severityColor,
                        ),
                      ),
                      const Text(
                        'Risk Score',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showRiskDetails(risk),
                style: ElevatedButton.styleFrom(
                  backgroundColor: severityColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('View Details', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRisks.length,
      itemBuilder: (context, index) {
        return _buildRiskListCard(_filteredRisks[index]);
      },
    );
  }

  Widget _buildRiskListCard(ProjectRisk risk) {
    final severityColor = _getSeverityColor(risk.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(Icons.warning_amber, color: severityColor),
        title: Text(
          risk.projectName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(risk.location),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    risk.severity.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Risk Score: ${risk.overallRiskScore.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: severityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Risk Factors:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...risk.factors.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(entry.key, style: const TextStyle(fontSize: 13)),
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: entry.value / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(severityColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value.toStringAsFixed(0)}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
                const Text('Identified Risks:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...risk.identifiedRisks.map((r) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text('• $r', style: const TextStyle(fontSize: 13)),
                )),
                const SizedBox(height: 12),
                const Text('Mitigation Actions:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...risk.mitigationActions.map((a) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text('• $a', style: const TextStyle(fontSize: 13)),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRisks.length,
      itemBuilder: (context, index) {
        final risk = _filteredRisks[index];
        final severityColor = _getSeverityColor(risk.severity);
        final daysAgo = DateTime.now().difference(risk.lastAssessed).inDays;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: severityColor,
              child: Text(
                risk.overallRiskScore.toStringAsFixed(0),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            title: Text(risk.projectName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Last assessed $daysAgo ${daysAgo == 1 ? 'day' : 'days'} ago'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: severityColor),
            onTap: () => _showRiskDetails(risk),
          ),
        );
      },
    );
  }

  void _showRiskDetails(ProjectRisk risk) {
    showDialog(
      context: context,
      builder: (context) {
        final severityColor = _getSeverityColor(risk.severity);
        
        return AlertDialog(
          title: Text(risk.projectName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: risk.overallRiskScore / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(severityColor),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            risk.overallRiskScore.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                            ),
                          ),
                          Text(
                            risk.severity.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Risk Factors:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...risk.factors.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text('${entry.value.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: entry.value / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(severityColor),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Generate Report'),
            ),
          ],
        );
      },
    );
  }
}

class ProjectRisk {
  final String projectId;
  final String projectName;
  final String location;
  final double overallRiskScore;
  final RiskSeverity severity;
  final Map<String, double> factors;
  final List<String> identifiedRisks;
  final List<String> mitigationActions;
  final DateTime lastAssessed;

  ProjectRisk({
    required this.projectId,
    required this.projectName,
    required this.location,
    required this.overallRiskScore,
    required this.severity,
    required this.factors,
    required this.identifiedRisks,
    required this.mitigationActions,
    required this.lastAssessed,
  });
}

enum RiskSeverity { low, medium, high, critical }