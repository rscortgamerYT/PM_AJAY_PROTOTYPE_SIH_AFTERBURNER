import 'package:flutter/material.dart';

class ComprehensiveClaimReviewDialog extends StatefulWidget {
  const ComprehensiveClaimReviewDialog({super.key});

  @override
  State<ComprehensiveClaimReviewDialog> createState() => _ComprehensiveClaimReviewDialogState();
}

class _ComprehensiveClaimReviewDialogState extends State<ComprehensiveClaimReviewDialog> {
  // Checklist items state
  final Map<String, bool> _checklist = {
    'project_details_verified': false,
    'geo_tagged_images_reviewed': false,
    'video_evidence_reviewed': false,
    'financial_documents_verified': false,
    'milestone_completion_confirmed': false,
    'beneficiary_verification_done': false,
    'quality_standards_met': false,
    'budget_compliance_checked': false,
  };

  String _reviewNotes = '';
  
  @override
  Widget build(BuildContext context) {
    final allChecked = _checklist.values.every((checked) => checked);
    
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.assignment_turned_in, color: Colors.blue, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comprehensive Claim Review',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Review all evidence and complete checklist before approval',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const Divider(color: Colors.grey, height: 32),
            
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _checklist.values.where((v) => v).length / _checklist.length,
                      backgroundColor: Colors.grey[700],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        allChecked ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_checklist.values.where((v) => v).length}/${_checklist.length} Complete',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProjectDetailsSection(),
                    const SizedBox(height: 24),
                    _buildChecklistSection(),
                    const SizedBox(height: 24),
                    _buildEvidenceSection(),
                    const SizedBox(height: 24),
                    _buildReviewNotesSection(),
                  ],
                ),
              ),
            ),
            
            const Divider(color: Colors.grey, height: 32),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Claim rejected and sent back for corrections'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  icon: const Icon(Icons.cancel, color: Colors.orange),
                  label: const Text('Reject', style: TextStyle(color: Colors.orange)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: allChecked
                      ? () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Claim approved successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Approve Claim'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: allChecked ? Colors.green : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProjectDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Project Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Project Name:', 'Rural Health Center - Sector 12'),
          _buildDetailRow('Claim ID:', 'CLM-2025-001'),
          _buildDetailRow('Milestone:', '2 of 5 - Foundation Complete'),
          _buildDetailRow('Claimed Amount:', '₹15,00,000'),
          _buildDetailRow('Agency:', 'Delhi Infrastructure Development Agency'),
          _buildDetailRow('Submission Date:', 'Oct 10, 2025'),
        ],
      ),
    );
  }
  
  Widget _buildChecklistSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Review Checklist',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildChecklistItem(
            'project_details_verified',
            'Project details verified',
            'Confirm project name, location, and milestone information',
          ),
          _buildChecklistItem(
            'geo_tagged_images_reviewed',
            'Geo-tagged images reviewed',
            'Verify location accuracy and timestamp of images',
          ),
          _buildChecklistItem(
            'video_evidence_reviewed',
            'Video evidence reviewed',
            'Check video quality and completeness of work shown',
          ),
          _buildChecklistItem(
            'financial_documents_verified',
            'Financial documents verified',
            'Verify bills, invoices, and payment receipts',
          ),
          _buildChecklistItem(
            'milestone_completion_confirmed',
            'Milestone completion confirmed',
            'Confirm all milestone requirements are met',
          ),
          _buildChecklistItem(
            'beneficiary_verification_done',
            'Beneficiary verification done',
            'Verify beneficiary lists and engagement',
          ),
          _buildChecklistItem(
            'quality_standards_met',
            'Quality standards met',
            'Confirm work meets technical specifications',
          ),
          _buildChecklistItem(
            'budget_compliance_checked',
            'Budget compliance checked',
            'Verify expenses are within approved budget',
          ),
        ],
      ),
    );
  }
  
  Widget _buildEvidenceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.folder_open, color: Colors.purple, size: 20),
              SizedBox(width: 8),
              Text(
                'Evidence & Attachments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEvidenceItem(Icons.image, 'Geo-tagged Images (12)', 'View Gallery', Colors.blue),
          _buildEvidenceItem(Icons.videocam, 'Progress Videos (3)', 'Watch Videos', Colors.red),
          _buildEvidenceItem(Icons.description, 'Financial Documents (8)', 'View Documents', Colors.orange),
          _buildEvidenceItem(Icons.people, 'Beneficiary Lists (2)', 'View Lists', Colors.green),
        ],
      ),
    );
  }
  
  Widget _buildReviewNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.note_add, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Review Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Add any observations, concerns, or recommendations...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => _reviewNotes = value,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChecklistItem(String key, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _checklist[key]! ? Colors.green.withOpacity(0.1) : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _checklist[key]! ? Colors.green : Colors.grey.shade700,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _checklist[key],
            onChanged: (value) {
              setState(() => _checklist[key] = value ?? false);
            },
            activeColor: Colors.green,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _checklist[key]! ? Colors.green : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEvidenceItem(IconData icon, String title, String action, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening $title...')),
              );
            },
            icon: Icon(Icons.open_in_new, size: 16, color: color),
            label: Text(action, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}