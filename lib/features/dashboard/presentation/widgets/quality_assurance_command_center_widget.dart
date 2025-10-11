import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum QAStatus { pending, approved, rejected }
enum QACategory { construction, materials, safety }

/// Quality Assurance Command Center Widget
/// 
/// Batch review system with computer-vision comparison between
/// submitted photos and reference standards, with approval/rejection workflow.
class QualityAssuranceCommandCenterWidget extends StatefulWidget {
  final String userId;
  
  const QualityAssuranceCommandCenterWidget({
    super.key,
    required this.userId,
  });

  @override
  State<QualityAssuranceCommandCenterWidget> createState() => 
      _QualityAssuranceCommandCenterWidgetState();
}

class _QualityAssuranceCommandCenterWidgetState 
    extends State<QualityAssuranceCommandCenterWidget> {
  
  String _selectedFilter = 'pending'; // 'all', 'pending', 'approved', 'rejected'
  String _selectedCategory = 'all'; // 'all', 'construction', 'materials', 'safety'

  final List<QASubmission> _mockSubmissions = [
    QASubmission(
      id: 'qa_001',
      projectName: 'Water Supply - Sector A',
      submittedBy: 'ABC Construction',
      category: QACategory.construction,
      submissionDate: DateTime(2025, 10, 10, 14, 30),
      status: QAStatus.pending,
      images: [
        QAImage(
          url: 'construction_photo_1.jpg',
          type: 'Submitted',
          aiScore: 85.0,
          issues: ['Minor alignment deviation'],
        ),
        QAImage(
          url: 'reference_standard_1.jpg',
          type: 'Reference',
          aiScore: 100.0,
          issues: [],
        ),
      ],
      checklistItems: [
        ChecklistItem(name: 'Foundation depth', status: true, notes: 'Meets standards'),
        ChecklistItem(name: 'Material quality', status: true, notes: 'Approved materials used'),
        ChecklistItem(name: 'Safety measures', status: false, notes: 'Missing safety barriers'),
      ],
      reviewComments: null,
    ),
    QASubmission(
      id: 'qa_002',
      projectName: 'Toilet Construction - Phase 1',
      submittedBy: 'Beta Infrastructure',
      category: QACategory.materials,
      submissionDate: DateTime(2025, 10, 10, 13, 00),
      status: QAStatus.approved,
      images: [
        QAImage(
          url: 'materials_photo_1.jpg',
          type: 'Submitted',
          aiScore: 95.0,
          issues: [],
        ),
      ],
      checklistItems: [
        ChecklistItem(name: 'Material certificates', status: true, notes: 'All verified'),
        ChecklistItem(name: 'Storage conditions', status: true, notes: 'Proper storage'),
        ChecklistItem(name: 'Quality testing', status: true, notes: 'Lab reports attached'),
      ],
      reviewComments: 'Excellent quality standards maintained. Approved.',
    ),
    QASubmission(
      id: 'qa_003',
      projectName: 'Rural Water Distribution',
      submittedBy: 'Gamma Developers',
      category: QACategory.safety,
      submissionDate: DateTime(2025, 10, 10, 11, 30),
      status: QAStatus.rejected,
      images: [
        QAImage(
          url: 'safety_photo_1.jpg',
          type: 'Submitted',
          aiScore: 45.0,
          issues: ['Missing helmets', 'Inadequate barriers', 'No safety signage'],
        ),
      ],
      checklistItems: [
        ChecklistItem(name: 'PPE compliance', status: false, notes: 'Workers without helmets'),
        ChecklistItem(name: 'Safety barriers', status: false, notes: 'Insufficient barriers'),
        ChecklistItem(name: 'First aid', status: true, notes: 'Kit available'),
      ],
      reviewComments: 'Critical safety violations. Immediate rectification required.',
    ),
    QASubmission(
      id: 'qa_004',
      projectName: 'Sanitation Complex',
      submittedBy: 'Delta Engineering',
      category: QACategory.construction,
      submissionDate: DateTime(2025, 10, 10, 10, 00),
      status: QAStatus.pending,
      images: [
        QAImage(
          url: 'construction_photo_2.jpg',
          type: 'Submitted',
          aiScore: 92.0,
          issues: [],
        ),
      ],
      checklistItems: [
        ChecklistItem(name: 'Structural integrity', status: true, notes: 'Engineer verified'),
        ChecklistItem(name: 'Plumbing layout', status: true, notes: 'As per design'),
        ChecklistItem(name: 'Ventilation', status: true, notes: 'Adequate provision'),
      ],
      reviewComments: null,
    ),
  ];

  List<QASubmission> get _filteredSubmissions {
    var filtered = _mockSubmissions.where((sub) {
      if (_selectedFilter != 'all' && sub.status.name != _selectedFilter) {
        return false;
      }
      if (_selectedCategory != 'all' && sub.category.name != _selectedCategory) {
        return false;
      }
      return true;
    });
    
    return filtered.toList()..sort((a, b) => b.submissionDate.compareTo(a.submissionDate));
  }

  Color _getStatusColor(QAStatus status) {
    switch (status) {
      case QAStatus.pending:
        return AppTheme.warningOrange;
      case QAStatus.approved:
        return AppTheme.successGreen;
      case QAStatus.rejected:
        return AppTheme.errorRed;
    }
  }

  Color _getCategoryColor(QACategory category) {
    switch (category) {
      case QACategory.construction:
        return AppTheme.secondaryBlue;
      case QACategory.materials:
        return AppTheme.accentTeal;
      case QACategory.safety:
        return AppTheme.errorRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: _buildSubmissionsList(),
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
          const Icon(Icons.verified, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quality Assurance Command Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-powered batch review with vision comparison',
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
    final pending = _mockSubmissions.where((s) => s.status == QAStatus.pending).length;
    final approved = _mockSubmissions.where((s) => s.status == QAStatus.approved).length;

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
                pending.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Pending',
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
                approved.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Approved',
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
                ButtonSegment(value: 'pending', label: Text('Pending')),
                ButtonSegment(value: 'approved', label: Text('Approved')),
                ButtonSegment(value: 'rejected', label: Text('Rejected')),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _selectedFilter = newSelection.first);
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _selectedCategory,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Categories')),
              DropdownMenuItem(value: 'construction', child: Text('Construction')),
              DropdownMenuItem(value: 'materials', child: Text('Materials')),
              DropdownMenuItem(value: 'safety', child: Text('Safety')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsList() {
    if (_filteredSubmissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No submissions found',
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
      itemCount: _filteredSubmissions.length,
      itemBuilder: (context, index) {
        return _buildSubmissionCard(_filteredSubmissions[index]);
      },
    );
  }

  Widget _buildSubmissionCard(QASubmission submission) {
    final statusColor = _getStatusColor(submission.status);
    final categoryColor = _getCategoryColor(submission.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(Icons.verified, color: categoryColor),
        title: Row(
          children: [
            Expanded(
              child: Text(
                submission.projectName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                submission.status.name.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
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
            Row(
              children: [
                Icon(Icons.business, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(submission.submittedBy),
                const SizedBox(width: 12),
                Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(_formatDateTime(submission.submissionDate)),
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
                // AI Vision Analysis
                const Text(
                  'AI Vision Analysis',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...submission.images.map((image) => _buildImageAnalysis(image)),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                // Checklist
                const Text(
                  'Quality Checklist',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...submission.checklistItems.map((item) => _buildChecklistItem(item)),
                
                // Review Comments
                if (submission.reviewComments != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.comment, size: 20, color: statusColor),
                            const SizedBox(width: 8),
                            Text(
                              'Review Comments',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(submission.reviewComments!),
                      ],
                    ),
                  ),
                ],
                
                // Action Buttons
                if (submission.status == QAStatus.pending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rejectSubmission(submission),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorRed,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approveSubmission(submission),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Approve'),
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

  Widget _buildImageAnalysis(QAImage image) {
    final scoreColor = image.aiScore >= 80
        ? AppTheme.successGreen
        : image.aiScore >= 60
            ? AppTheme.warningOrange
            : AppTheme.errorRed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image, size: 40, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        image.type,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        image.url,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('AI Score: ', style: TextStyle(fontSize: 12)),
                          Text(
                            '${image.aiScore.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: scoreColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (image.issues.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Detected Issues:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              ...image.issues.map((issue) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Row(
                  children: [
                    const Icon(Icons.warning, size: 14, color: AppTheme.errorRed),
                    const SizedBox(width: 4),
                    Text(issue, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(ChecklistItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: item.status ? AppTheme.successGreen.withOpacity(0.05) : AppTheme.errorRed.withOpacity(0.05),
      child: ListTile(
        dense: true,
        leading: Icon(
          item.status ? Icons.check_circle : Icons.cancel,
          color: item.status ? AppTheme.successGreen : AppTheme.errorRed,
        ),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(item.notes, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  void _approveSubmission(QASubmission submission) {
    showDialog(
      context: context,
      builder: (context) {
        final commentController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Approve Submission'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Project: ${submission.projectName}'),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Approval Comments',
                  hintText: 'Add comments...',
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
                setState(() {
                  submission.status = QAStatus.approved;
                  submission.reviewComments = commentController.text.isEmpty
                      ? 'Approved without comments'
                      : commentController.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  void _rejectSubmission(QASubmission submission) {
    showDialog(
      context: context,
      builder: (context) {
        final commentController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Reject Submission'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Project: ${submission.projectName}'),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Rejection Reason (Required)',
                  hintText: 'Explain why this is being rejected...',
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
                if (commentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rejection reason is required')),
                  );
                  return;
                }
                setState(() {
                  submission.status = QAStatus.rejected;
                  submission.reviewComments = commentController.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
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

class QASubmission {
  final String id;
  final String projectName;
  final String submittedBy;
  final QACategory category;
  final DateTime submissionDate;
  QAStatus status;
  final List<QAImage> images;
  final List<ChecklistItem> checklistItems;
  String? reviewComments;

  QASubmission({
    required this.id,
    required this.projectName,
    required this.submittedBy,
    required this.category,
    required this.submissionDate,
    required this.status,
    required this.images,
    required this.checklistItems,
    this.reviewComments,
  });
}

class QAImage {
  final String url;
  final String type;
  final double aiScore;
  final List<String> issues;

  QAImage({
    required this.url,
    required this.type,
    required this.aiScore,
    required this.issues,
  });
}

class ChecklistItem {
  final String name;
  final bool status;
  final String notes;

  ChecklistItem({
    required this.name,
    required this.status,
    required this.notes,
  });
}
