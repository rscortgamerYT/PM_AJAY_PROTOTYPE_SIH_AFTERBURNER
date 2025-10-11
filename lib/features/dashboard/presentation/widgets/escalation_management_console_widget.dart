import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Escalation Management Console Widget
/// 
/// Dynamic routing system with SLA monitoring, priority-based escalation paths,
/// and automated stakeholder notifications.
class EscalationManagementConsoleWidget extends StatefulWidget {
  final String userId;
  
  const EscalationManagementConsoleWidget({
    super.key,
    required this.userId,
  });

  @override
  State<EscalationManagementConsoleWidget> createState() => 
      _EscalationManagementConsoleWidgetState();
}

class _EscalationManagementConsoleWidgetState 
    extends State<EscalationManagementConsoleWidget> {
  
  String _selectedPriority = 'all'; // 'all', 'critical', 'high', 'medium', 'low'
  String _selectedStatus = 'active'; // 'all', 'active', 'resolved', 'escalated'

  final List<Escalation> _mockEscalations = [
    Escalation(
      id: 'esc_001',
      title: 'Project Delay - Water Supply Phase 2',
      description: 'Construction delayed by 45 days due to material shortage',
      priority: EscalationPriority.critical,
      status: EscalationStatus.active,
      category: EscalationCategory.projectDelay,
      createdAt: DateTime(2025, 10, 10, 9, 0),
      slaDeadline: DateTime(2025, 10, 11, 17, 0),
      assignedTo: 'State Coordinator',
      createdBy: 'District Manager - North',
      escalationPath: [
        EscalationStep(
          level: 1,
          role: 'District Manager',
          name: 'Rajesh Kumar',
          status: StepStatus.completed,
          completedAt: DateTime(2025, 10, 10, 9, 30),
          action: 'Initial assessment completed',
        ),
        EscalationStep(
          level: 2,
          role: 'State Coordinator',
          name: 'Priya Singh',
          status: StepStatus.inProgress,
          completedAt: null,
          action: 'Coordinating with suppliers',
        ),
        EscalationStep(
          level: 3,
          role: 'Centre Authority',
          name: 'Not Yet Assigned',
          status: StepStatus.pending,
          completedAt: null,
          action: 'Awaiting escalation if needed',
        ),
      ],
      updates: [
        EscalationUpdate(
          timestamp: DateTime(2025, 10, 10, 9, 30),
          user: 'Rajesh Kumar',
          message: 'Issue logged. Suppliers contacted for immediate delivery.',
        ),
        EscalationUpdate(
          timestamp: DateTime(2025, 10, 10, 11, 0),
          user: 'Priya Singh',
          message: 'Alternative suppliers identified. Negotiating pricing.',
        ),
      ],
    ),
    Escalation(
      id: 'esc_002',
      title: 'Quality Failure - Toilet Construction',
      description: 'Multiple quality check failures in recent construction batch',
      priority: EscalationPriority.high,
      status: EscalationStatus.escalated,
      category: EscalationCategory.qualityIssue,
      createdAt: DateTime(2025, 10, 9, 14, 0),
      slaDeadline: DateTime(2025, 10, 12, 17, 0),
      assignedTo: 'Centre Quality Team',
      createdBy: 'QA Inspector - Beta Agency',
      escalationPath: [
        EscalationStep(
          level: 1,
          role: 'Agency QA Lead',
          name: 'Amit Sharma',
          status: StepStatus.completed,
          completedAt: DateTime(2025, 10, 9, 15, 0),
          action: 'Quality inspection failed',
        ),
        EscalationStep(
          level: 2,
          role: 'State Quality Officer',
          name: 'Meera Reddy',
          status: StepStatus.completed,
          completedAt: DateTime(2025, 10, 10, 10, 0),
          action: 'Escalated to Centre for contractor review',
        ),
        EscalationStep(
          level: 3,
          role: 'Centre Quality Team',
          name: 'Dr. Suresh Patel',
          status: StepStatus.inProgress,
          completedAt: null,
          action: 'Investigating contractor compliance',
        ),
      ],
      updates: [
        EscalationUpdate(
          timestamp: DateTime(2025, 10, 9, 15, 0),
          user: 'Amit Sharma',
          message: '3 out of 5 construction sites failed quality checks.',
        ),
        EscalationUpdate(
          timestamp: DateTime(2025, 10, 10, 10, 0),
          user: 'Meera Reddy',
          message: 'Contractor has history of violations. Recommending contract review.',
        ),
      ],
    ),
    Escalation(
      id: 'esc_003',
      title: 'Budget Overrun - Rural Sanitation',
      description: 'Project costs exceeded approved budget by 25%',
      priority: EscalationPriority.medium,
      status: EscalationStatus.resolved,
      category: EscalationCategory.budgetIssue,
      createdAt: DateTime(2025, 10, 8, 11, 0),
      slaDeadline: DateTime(2025, 10, 13, 17, 0),
      assignedTo: 'State Finance Officer',
      createdBy: 'Project Manager - Gamma Agency',
      escalationPath: [
        EscalationStep(
          level: 1,
          role: 'Agency Finance Lead',
          name: 'Neha Gupta',
          status: StepStatus.completed,
          completedAt: DateTime(2025, 10, 8, 13, 0),
          action: 'Budget analysis completed',
        ),
        EscalationStep(
          level: 2,
          role: 'State Finance Officer',
          name: 'Vikram Rao',
          status: StepStatus.completed,
          completedAt: DateTime(2025, 10, 9, 16, 0),
          action: 'Additional funds approved',
        ),
      ],
      updates: [
        EscalationUpdate(
          timestamp: DateTime(2025, 10, 8, 13, 0),
          user: 'Neha Gupta',
          message: 'Overrun due to unexpected foundation work. Detailed breakdown prepared.',
        ),
        EscalationUpdate(
          timestamp: DateTime(2025, 10, 9, 16, 0),
          user: 'Vikram Rao',
          message: 'Additional ₹2.5L approved from reserve fund. Issue resolved.',
        ),
      ],
    ),
    Escalation(
      id: 'esc_004',
      title: 'Safety Violation - Construction Site',
      description: 'Workers found without proper safety equipment',
      priority: EscalationPriority.critical,
      status: EscalationStatus.active,
      category: EscalationCategory.safetyViolation,
      createdAt: DateTime(2025, 10, 10, 13, 0),
      slaDeadline: DateTime(2025, 10, 10, 23, 0),
      assignedTo: 'District Safety Officer',
      createdBy: 'Site Inspector - Alpha Construction',
      escalationPath: [
        EscalationStep(
          level: 1,
          role: 'Site Supervisor',
          name: 'Ramesh Yadav',
          status: StepStatus.completed,
          completedAt: DateTime(2025, 10, 10, 13, 30),
          action: 'Work stopped immediately',
        ),
        EscalationStep(
          level: 2,
          role: 'District Safety Officer',
          name: 'Kavita Joshi',
          status: StepStatus.inProgress,
          completedAt: null,
          action: 'Conducting safety audit',
        ),
      ],
      updates: [
        EscalationUpdate(
          timestamp: DateTime(2025, 10, 10, 13, 30),
          user: 'Ramesh Yadav',
          message: 'All work halted. Safety equipment being arranged.',
        ),
      ],
    ),
  ];

  List<Escalation> get _filteredEscalations {
    var filtered = _mockEscalations.where((esc) {
      if (_selectedPriority != 'all' && esc.priority.name != _selectedPriority) {
        return false;
      }
      if (_selectedStatus != 'all' && esc.status.name != _selectedStatus) {
        return false;
      }
      return true;
    });
    
    return filtered.toList()..sort((a, b) {
      // Sort by priority first, then by creation date
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  Color _getPriorityColor(EscalationPriority priority) {
    switch (priority) {
      case EscalationPriority.critical:
        return AppTheme.errorRed;
      case EscalationPriority.high:
        return Colors.orange;
      case EscalationPriority.medium:
        return AppTheme.warningOrange;
      case EscalationPriority.low:
        return Colors.blue;
    }
  }

  Color _getStatusColor(EscalationStatus status) {
    switch (status) {
      case EscalationStatus.active:
        return AppTheme.warningOrange;
      case EscalationStatus.escalated:
        return AppTheme.errorRed;
      case EscalationStatus.resolved:
        return AppTheme.successGreen;
    }
  }

  IconData _getCategoryIcon(EscalationCategory category) {
    switch (category) {
      case EscalationCategory.projectDelay:
        return Icons.schedule;
      case EscalationCategory.qualityIssue:
        return Icons.warning;
      case EscalationCategory.budgetIssue:
        return Icons.attach_money;
      case EscalationCategory.safetyViolation:
        return Icons.health_and_safety;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: _buildEscalationsList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.overwatchColor, Colors.red.shade700],
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
                  'Escalation Management Console',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dynamic routing with SLA monitoring',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final active = _mockEscalations.where((e) => e.status == EscalationStatus.active).length;
    final critical = _mockEscalations.where((e) => e.priority == EscalationPriority.critical).length;
    final breached = _mockEscalations.where((e) => 
      e.slaDeadline.isBefore(DateTime.now()) && e.status != EscalationStatus.resolved
    ).length;

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
                active.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Active',
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
                breached.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'SLA Breach',
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('All')),
                ButtonSegment(value: 'active', label: Text('Active')),
                ButtonSegment(value: 'escalated', label: Text('Escalated')),
                ButtonSegment(value: 'resolved', label: Text('Resolved')),
              ],
              selected: {_selectedStatus},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _selectedStatus = newSelection.first);
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _selectedPriority,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Priorities')),
              DropdownMenuItem(value: 'critical', child: Text('Critical')),
              DropdownMenuItem(value: 'high', child: Text('High')),
              DropdownMenuItem(value: 'medium', child: Text('Medium')),
              DropdownMenuItem(value: 'low', child: Text('Low')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPriority = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationsList() {
    if (_filteredEscalations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No escalations found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredEscalations.length,
      itemBuilder: (context, index) {
        return _buildEscalationCard(_filteredEscalations[index]);
      },
    );
  }

  Widget _buildEscalationCard(Escalation escalation) {
    final priorityColor = _getPriorityColor(escalation.priority);
    final statusColor = _getStatusColor(escalation.status);
    final slaBreached = escalation.slaDeadline.isBefore(DateTime.now()) && 
        escalation.status != EscalationStatus.resolved;
    final hoursRemaining = escalation.slaDeadline.difference(DateTime.now()).inHours;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(_getCategoryIcon(escalation.category), color: priorityColor),
        title: Row(
          children: [
            Expanded(
              child: Text(
                escalation.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                escalation.priority.name.toUpperCase(),
                style: TextStyle(
                  color: priorityColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(escalation.description),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: slaBreached ? AppTheme.errorRed : Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  slaBreached 
                      ? 'SLA BREACHED' 
                      : hoursRemaining > 24
                          ? '${(hoursRemaining / 24).round()} days remaining'
                          : '$hoursRemaining hours remaining',
                  style: TextStyle(
                    color: slaBreached ? AppTheme.errorRed : Colors.grey.shade600,
                    fontWeight: slaBreached ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    escalation.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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
                // Escalation Path
                const Text(
                  'Escalation Path',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildEscalationPath(escalation.escalationPath),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                // Updates Timeline
                const Text(
                  'Updates Timeline',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...escalation.updates.map((update) => _buildUpdateItem(update)),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                // Details
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Created By', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(escalation.createdBy, style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Assigned To', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(escalation.assignedTo, style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Actions
                if (escalation.status == EscalationStatus.active) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _addUpdate(escalation),
                          icon: const Icon(Icons.comment),
                          label: const Text('Add Update'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _escalateToNextLevel(escalation),
                          icon: const Icon(Icons.arrow_upward),
                          label: const Text('Escalate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorRed,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _resolveEscalation(escalation),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Resolve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationPath(List<EscalationStep> path) {
    return Column(
      children: path.map((step) {
        Color stepColor;
        IconData stepIcon;
        
        switch (step.status) {
          case StepStatus.completed:
            stepColor = AppTheme.successGreen;
            stepIcon = Icons.check_circle;
            break;
          case StepStatus.inProgress:
            stepColor = AppTheme.warningOrange;
            stepIcon = Icons.pending;
            break;
          case StepStatus.pending:
            stepColor = Colors.grey;
            stepIcon = Icons.radio_button_unchecked;
            break;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: stepColor.withOpacity(0.05),
          child: ListTile(
            leading: Icon(stepIcon, color: stepColor),
            title: Text(
              'Level ${step.level}: ${step.role}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.name),
                const SizedBox(height: 4),
                Text(
                  step.action,
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                if (step.completedAt != null)
                  Text(
                    'Completed: ${_formatDateTime(step.completedAt!)}',
                    style: const TextStyle(fontSize: 11),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUpdateItem(EscalationUpdate update) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey.shade50,
      child: ListTile(
        leading: const Icon(Icons.update, color: AppTheme.secondaryBlue),
        title: Row(
          children: [
            Text(
              update.user,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              _formatDateTime(update.timestamp),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(update.message),
        ),
      ),
    );
  }

  void _addUpdate(Escalation escalation) {
    showDialog(
      context: context,
      builder: (context) {
        final messageController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Add Update'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Update Message',
                  hintText: 'Describe the latest progress...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (messageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message is required')),
                  );
                  return;
                }
                setState(() {
                  escalation.updates.add(
                    EscalationUpdate(
                      timestamp: DateTime.now(),
                      user: 'Current User',
                      message: messageController.text,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Add Update'),
            ),
          ],
        );
      },
    );
  }

  void _escalateToNextLevel(Escalation escalation) {
    final nextStep = escalation.escalationPath.firstWhere(
      (step) => step.status == StepStatus.pending,
      orElse: () => escalation.escalationPath.last,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escalate to Next Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Escalate to: ${nextStep.role}'),
            const SizedBox(height: 16),
            Text(
              'This will notify ${nextStep.role} and update the escalation status.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                escalation.status = EscalationStatus.escalated;
                final currentStep = escalation.escalationPath.firstWhere(
                  (step) => step.status == StepStatus.inProgress,
                  orElse: () => escalation.escalationPath.first,
                );
                currentStep.status = StepStatus.completed;
                currentStep.completedAt = DateTime.now();
                nextStep.status = StepStatus.inProgress;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Escalate'),
          ),
        ],
      ),
    );
  }

  void _resolveEscalation(Escalation escalation) {
    showDialog(
      context: context,
      builder: (context) {
        final resolutionController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Resolve Escalation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Issue: ${escalation.title}'),
              const SizedBox(height: 16),
              TextField(
                controller: resolutionController,
                decoration: const InputDecoration(
                  labelText: 'Resolution Details',
                  hintText: 'Describe how the issue was resolved...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (resolutionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resolution details are required')),
                  );
                  return;
                }
                setState(() {
                  escalation.status = EscalationStatus.resolved;
                  escalation.updates.add(
                    EscalationUpdate(
                      timestamp: DateTime.now(),
                      user: 'Current User',
                      message: 'RESOLVED: ${resolutionController.text}',
                    ),
                  );
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Resolve'),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Data Models
enum EscalationPriority { low, medium, high, critical }
enum EscalationStatus { active, escalated, resolved }
enum EscalationCategory { projectDelay, qualityIssue, budgetIssue, safetyViolation }
enum StepStatus { pending, inProgress, completed }

class Escalation {
  final String id;
  final String title;
  final String description;
  final EscalationPriority priority;
  EscalationStatus status;
  final EscalationCategory category;
  final DateTime createdAt;
  final DateTime slaDeadline;
  final String assignedTo;
  final String createdBy;
  final List<EscalationStep> escalationPath;
  final List<EscalationUpdate> updates;

  Escalation({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.slaDeadline,
    required this.assignedTo,
    required this.createdBy,
    required this.escalationPath,
    required this.updates,
  });
}

class EscalationStep {
  final int level;
  final String role;
  final String name;
  StepStatus status;
  DateTime? completedAt;
  final String action;

  EscalationStep({
    required this.level,
    required this.role,
    required this.name,
    required this.status,
    this.completedAt,
    required this.action,
  });
}

class EscalationUpdate {
  final DateTime timestamp;
  final String user;
  final String message;

  EscalationUpdate({
    required this.timestamp,
    required this.user,
    required this.message,
  });
}