import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Smart Milestone Workflow Widget
/// 
/// Sequential milestone submission system with geo-tagged evidence,
/// auto-validation, and instant feedback on acceptance/rejection.
class SmartMilestoneWorkflowWidget extends StatefulWidget {
  final String agencyId;
  
  const SmartMilestoneWorkflowWidget({
    super.key,
    required this.agencyId,
  });

  @override
  State<SmartMilestoneWorkflowWidget> createState() => 
      _SmartMilestoneWorkflowWidgetState();
}

class _SmartMilestoneWorkflowWidgetState 
    extends State<SmartMilestoneWorkflowWidget> {
  
  String _selectedProject = 'project_001';
  
  final List<ProjectMilestones> _mockProjects = [
    ProjectMilestones(
      id: 'project_001',
      name: 'Water Supply - Sector A',
      location: 'Mumbai, Maharashtra',
      milestones: [
        MilestoneItem(
          id: 'milestone_001',
          name: 'Site Survey',
          description: 'Complete site survey and soil testing',
          status: MilestoneStatus.completed,
          dueDate: DateTime(2025, 1, 15),
          completedDate: DateTime(2025, 1, 12),
          evidenceRequired: ['Site photos', 'Survey report', 'GPS coordinates'],
          submittedEvidence: [
            Evidence(
              type: 'photo',
              url: 'site_photo_1.jpg',
              gpsLat: 19.0760,
              gpsLon: 72.8777,
              timestamp: DateTime(2025, 1, 12, 10, 30),
            ),
            Evidence(
              type: 'document',
              url: 'survey_report.pdf',
              gpsLat: 19.0760,
              gpsLon: 72.8777,
              timestamp: DateTime(2025, 1, 12, 14, 15),
            ),
          ],
          reviewComments: 'Approved. Excellent documentation.',
        ),
        MilestoneItem(
          id: 'milestone_002',
          name: 'Design Approval',
          description: 'Submit design plans for approval',
          status: MilestoneStatus.inReview,
          dueDate: DateTime(2025, 2, 15),
          completedDate: DateTime(2025, 2, 10),
          evidenceRequired: ['Design drawings', 'Material specifications', 'Cost estimates'],
          submittedEvidence: [
            Evidence(
              type: 'document',
              url: 'design_plans.pdf',
              gpsLat: 19.0760,
              gpsLon: 72.8777,
              timestamp: DateTime(2025, 2, 10, 11, 00),
            ),
          ],
          reviewComments: null,
        ),
        MilestoneItem(
          id: 'milestone_003',
          name: 'Material Procurement',
          description: 'Procure approved materials',
          status: MilestoneStatus.active,
          dueDate: DateTime(2025, 3, 31),
          completedDate: null,
          evidenceRequired: ['Purchase orders', 'Material receipts', 'Quality certificates'],
          submittedEvidence: [],
          reviewComments: null,
        ),
        MilestoneItem(
          id: 'milestone_004',
          name: 'Installation',
          description: 'Complete installation of water supply infrastructure',
          status: MilestoneStatus.locked,
          dueDate: DateTime(2025, 5, 31),
          completedDate: null,
          evidenceRequired: ['Progress photos', 'Installation reports', 'GPS tracking'],
          submittedEvidence: [],
          reviewComments: null,
        ),
        MilestoneItem(
          id: 'milestone_005',
          name: 'Testing & Commissioning',
          description: 'Conduct testing and quality assurance',
          status: MilestoneStatus.locked,
          dueDate: DateTime(2025, 6, 30),
          completedDate: null,
          evidenceRequired: ['Test reports', 'Commission certificate', 'Final photos'],
          submittedEvidence: [],
          reviewComments: null,
        ),
      ],
    ),
  ];

  ProjectMilestones get _currentProject => 
      _mockProjects.firstWhere((p) => p.id == _selectedProject);

  Color _getStatusColor(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.completed:
        return AppTheme.successGreen;
      case MilestoneStatus.inReview:
        return AppTheme.warningOrange;
      case MilestoneStatus.active:
        return AppTheme.secondaryBlue;
      case MilestoneStatus.locked:
        return Colors.grey;
      case MilestoneStatus.rejected:
        return AppTheme.errorRed;
    }
  }

  IconData _getStatusIcon(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.completed:
        return Icons.check_circle;
      case MilestoneStatus.inReview:
        return Icons.pending;
      case MilestoneStatus.active:
        return Icons.play_circle;
      case MilestoneStatus.locked:
        return Icons.lock;
      case MilestoneStatus.rejected:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildProjectSelector(),
        Expanded(
          child: _buildMilestonesList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.agencyUserColor, AppTheme.accentTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.timeline, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Milestone Workflow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sequential submission with geo-tagged evidence',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final completed = _currentProject.milestones
        .where((m) => m.status == MilestoneStatus.completed)
        .length;
    final total = _currentProject.milestones.length;
    final percentage = (completed / total * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$completed/$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$percentage% Complete',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Project:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedProject,
              isExpanded: true,
              items: _mockProjects.map((project) {
                return DropdownMenuItem(
                  value: project.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        project.location,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedProject = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _currentProject.milestones.length,
      itemBuilder: (context, index) {
        return _buildMilestoneCard(_currentProject.milestones[index], index);
      },
    );
  }

  Widget _buildMilestoneCard(MilestoneItem milestone, int index) {
    final statusColor = _getStatusColor(milestone.status);
    final statusIcon = _getStatusIcon(milestone.status);
    final isOverdue = milestone.dueDate.isBefore(DateTime.now()) &&
        milestone.status != MilestoneStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        milestone.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(statusIcon, color: statusColor, size: 32),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Due Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isOverdue ? AppTheme.errorRed : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Due: ${_formatDate(milestone.dueDate)}',
                      style: TextStyle(
                        color: isOverdue ? AppTheme.errorRed : Colors.grey.shade700,
                        fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (milestone.completedDate != null) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.check, size: 16, color: AppTheme.successGreen),
                      const SizedBox(width: 4),
                      Text(
                        'Completed: ${_formatDate(milestone.completedDate!)}',
                        style: const TextStyle(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                
                // Evidence Required
                const Text(
                  'Evidence Required:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: milestone.evidenceRequired.map((evidence) {
                    final isSubmitted = milestone.submittedEvidence.any(
                      (e) => evidence.toLowerCase().contains(e.type),
                    );
                    return Chip(
                      label: Text(evidence),
                      avatar: Icon(
                        isSubmitted ? Icons.check_circle : Icons.circle_outlined,
                        size: 16,
                        color: isSubmitted ? AppTheme.successGreen : Colors.grey,
                      ),
                      backgroundColor: isSubmitted
                          ? AppTheme.successGreen.withOpacity(0.1)
                          : Colors.grey.shade100,
                    );
                  }).toList(),
                ),
                
                // Submitted Evidence
                if (milestone.submittedEvidence.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Submitted Evidence:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...milestone.submittedEvidence.map((evidence) {
                    return _buildEvidenceItem(evidence);
                  }),
                ],
                
                // Review Comments
                if (milestone.reviewComments != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.comment, size: 20, color: statusColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Review Comments',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                milestone.reviewComments!,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Action Buttons
                if (milestone.status == MilestoneStatus.active) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showSubmitEvidenceDialog(milestone),
                      icon: const Icon(Icons.upload),
                      label: const Text('Submit Evidence'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.agencyUserColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                
                if (milestone.status == MilestoneStatus.locked) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Complete previous milestones to unlock',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceItem(Evidence evidence) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppTheme.successGreen.withOpacity(0.05),
      child: ListTile(
        dense: true,
        leading: Icon(
          evidence.type == 'photo' ? Icons.photo : Icons.description,
          color: AppTheme.agencyUserColor,
        ),
        title: Text(
          evidence.url,
          style: const TextStyle(fontSize: 13),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              '${evidence.gpsLat.toStringAsFixed(4)}, ${evidence.gpsLon.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 12),
            Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              _formatDateTime(evidence.timestamp),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.visibility, size: 20),
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSubmitEvidenceDialog(MilestoneItem milestone) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Submit Evidence: ${milestone.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select evidence type to upload:'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Photo'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Document'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.video_call),
                label: const Text('Record Video'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Project Milestones Model
class ProjectMilestones {
  final String id;
  final String name;
  final String location;
  final List<MilestoneItem> milestones;

  ProjectMilestones({
    required this.id,
    required this.name,
    required this.location,
    required this.milestones,
  });
}

/// Milestone Item Model
class MilestoneItem {
  final String id;
  final String name;
  final String description;
  final MilestoneStatus status;
  final DateTime dueDate;
  final DateTime? completedDate;
  final List<String> evidenceRequired;
  final List<Evidence> submittedEvidence;
  final String? reviewComments;

  MilestoneItem({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.dueDate,
    this.completedDate,
    required this.evidenceRequired,
    required this.submittedEvidence,
    this.reviewComments,
  });
}

/// Evidence Model
class Evidence {
  final String type; // 'photo', 'document', 'video'
  final String url;
  final double gpsLat;
  final double gpsLon;
  final DateTime timestamp;

  Evidence({
    required this.type,
    required this.url,
    required this.gpsLat,
    required this.gpsLon,
    required this.timestamp,
  });
}

/// Milestone Status Enum
enum MilestoneStatus {
  locked,
  active,
  inReview,
  completed,
  rejected,
}