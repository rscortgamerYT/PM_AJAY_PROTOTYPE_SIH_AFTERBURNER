import 'package:flutter/material.dart';
import '../../../../core/models/citizen_services_models.dart';

class ApplicationTrackerWidget extends StatefulWidget {
  const ApplicationTrackerWidget({super.key});

  @override
  State<ApplicationTrackerWidget> createState() => _ApplicationTrackerWidgetState();
}

class _ApplicationTrackerWidgetState extends State<ApplicationTrackerWidget> {
  final TextEditingController _searchController = TextEditingController();
  
  final List<CitizenApplication> _applications = [
    CitizenApplication(
      id: 'PMAJAY-2025-001234',
      type: ApplicationType.scholarship,
      schemeName: 'PM-AJAY Adarsh Gram Education Scholarship',
      submissionDate: DateTime(2025, 2, 15),
      status: ApplicationStatus.approved,
      currentStage: 4,
      totalStages: 5,
      lastUpdateDate: DateTime(2025, 3, 20),
      estimatedCompletionDate: DateTime(2025, 4, 10),
      contactPerson: ContactPerson(
        name: 'Mrs. Priya Sharma',
        designation: 'District Education Officer',
        phone: '+91-712-2345678',
        email: 'priya.sharma@education.mh.gov.in',
      ),
      documents: [
        ApplicationDocument(name: 'Income Certificate', status: DocumentStatus.verified),
        ApplicationDocument(name: 'Caste Certificate', status: DocumentStatus.verified),
        ApplicationDocument(name: 'Mark Sheets', status: DocumentStatus.verified),
        ApplicationDocument(name: 'Bank Passbook', status: DocumentStatus.verified),
      ],
      disbursementDetails: DisbursementDetails(
        amount: 15000,
        installments: [
          Installment(
            installmentNumber: 1,
            amount: 7500,
            dueDate: DateTime(2025, 4, 1),
            status: InstallmentStatus.disbursed,
            disbursedDate: DateTime(2025, 3, 28),
            transactionId: 'TXN123456789',
          ),
          Installment(
            installmentNumber: 2,
            amount: 7500,
            dueDate: DateTime(2025, 9, 1),
            status: InstallmentStatus.pending,
          ),
        ],
      ),
      timeline: [
        TimelineEvent(
          stage: 'Application Submitted',
          date: DateTime(2025, 2, 15),
          status: TimelineStatus.completed,
        ),
        TimelineEvent(
          stage: 'Document Verification',
          date: DateTime(2025, 2, 25),
          status: TimelineStatus.completed,
        ),
        TimelineEvent(
          stage: 'Eligibility Assessment',
          date: DateTime(2025, 3, 5),
          status: TimelineStatus.completed,
        ),
        TimelineEvent(
          stage: 'Approval & Sanction',
          date: DateTime(2025, 3, 20),
          status: TimelineStatus.completed,
        ),
        TimelineEvent(
          stage: 'Fund Disbursement',
          date: DateTime(2025, 4, 1),
          status: TimelineStatus.current,
          comments: 'First installment processed',
        ),
      ],
    ),
    CitizenApplication(
      id: 'PMAJAY-2025-005678',
      type: ApplicationType.skillTraining,
      schemeName: 'GIA Digital Skills Training Program',
      submissionDate: DateTime(2025, 3, 1),
      status: ApplicationStatus.documentsRequired,
      currentStage: 2,
      totalStages: 4,
      lastUpdateDate: DateTime(2025, 3, 25),
      estimatedCompletionDate: DateTime(2025, 4, 15),
      contactPerson: ContactPerson(
        name: 'Mr. Rahul Patil',
        designation: 'Training Coordinator',
        phone: '+91-712-9876543',
        email: 'rahul.patil@skill.mh.gov.in',
      ),
      documents: [
        ApplicationDocument(name: 'Aadhaar Card', status: DocumentStatus.verified),
        ApplicationDocument(
          name: 'Educational Certificates',
          status: DocumentStatus.rejected,
          rejectionReason: 'Poor image quality',
        ),
        ApplicationDocument(name: 'Income Certificate', status: DocumentStatus.pending),
        ApplicationDocument(name: 'Bank Details', status: DocumentStatus.verified),
      ],
      timeline: [
        TimelineEvent(
          stage: 'Application Submitted',
          date: DateTime(2025, 3, 1),
          status: TimelineStatus.completed,
        ),
        TimelineEvent(
          stage: 'Document Verification',
          date: DateTime(2025, 3, 25),
          status: TimelineStatus.current,
          comments: 'Some documents need resubmission',
        ),
        TimelineEvent(
          stage: 'Training Center Allocation',
          status: TimelineStatus.pending,
        ),
        TimelineEvent(
          stage: 'Program Enrollment',
          status: TimelineStatus.pending,
        ),
      ],
    ),
  ];

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return Colors.blue.shade100;
      case ApplicationStatus.underReview:
        return Colors.amber.shade100;
      case ApplicationStatus.documentsRequired:
        return Colors.orange.shade100;
      case ApplicationStatus.approved:
        return Colors.green.shade100;
      case ApplicationStatus.rejected:
        return Colors.red.shade100;
      case ApplicationStatus.disbursed:
        return Colors.purple.shade100;
    }
  }

  IconData _getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
      case ApplicationStatus.underReview:
        return Icons.access_time;
      case ApplicationStatus.documentsRequired:
        return Icons.warning_amber;
      case ApplicationStatus.approved:
      case ApplicationStatus.disbursed:
        return Icons.check_circle;
      case ApplicationStatus.rejected:
        return Icons.cancel;
    }
  }

  String _formatStatus(ApplicationStatus status) {
    return status.toString().split('.').last.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).toUpperCase().trim();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.search, color: Theme.of(context).primaryColor, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Track Your Applications',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Monitor the status of your scholarship, training, and grant applications in real-time',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Enter Application ID (e.g., PMAJAY-2025-001234)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          ),
                          child: const Text('Search'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Applications List
            ..._applications.map((app) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.schemeName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Application ID: ${app.id}',
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(app.status),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getStatusIcon(app.status), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                _formatStatus(app.status),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Dates
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        Text(
                          'Submitted: ${_formatDate(app.submissionDate)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        Text(
                          'Last Updated: ${_formatDate(app.lastUpdateDate)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        Text(
                          'Expected Completion: ${_formatDate(app.estimatedCompletionDate)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Progress', style: TextStyle(fontSize: 13)),
                            Text(
                              '${app.currentStage}/${app.totalStages} stages completed',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: app.currentStage / app.totalStages,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Timeline
                    const Text(
                      'Application Timeline',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ...app.timeline.map((event) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: event.status == TimelineStatus.completed
                                  ? Colors.green
                                  : event.status == TimelineStatus.current
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                              border: Border.all(
                                color: event.status == TimelineStatus.completed
                                    ? Colors.green
                                    : event.status == TimelineStatus.current
                                        ? Colors.blue
                                        : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      event.stage,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: event.status == TimelineStatus.completed
                                            ? Colors.green.shade700
                                            : event.status == TimelineStatus.current
                                                ? Colors.blue.shade700
                                                : Colors.grey,
                                      ),
                                    ),
                                    if (event.date != null)
                                      Text(
                                        _formatDate(event.date!),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                if (event.comments != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    event.comments!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                    // Documents and Contact in Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildDocumentsList(app.documents)),
                              const SizedBox(width: 24),
                              Expanded(child: _buildContactInfo(app.contactPerson)),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildDocumentsList(app.documents),
                              const SizedBox(height: 16),
                              _buildContactInfo(app.contactPerson),
                            ],
                          );
                        }
                      },
                    ),
                    // Disbursement Details
                    if (app.disbursementDetails != null) ...[
                      const SizedBox(height: 16),
                      _buildDisbursementDetails(app.disbursementDetails!),
                    ],
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Action Buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (app.status == ApplicationStatus.documentsRequired)
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.upload_file, size: 18),
                            label: const Text('Upload Documents'),
                          ),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Download Application'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.print, size: 18),
                          label: const Text('Print Status'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList(List<ApplicationDocument> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Document Status',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...documents.map((doc) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(doc.name, style: const TextStyle(fontSize: 14)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: doc.status == DocumentStatus.verified
                          ? Colors.green.shade100
                          : doc.status == DocumentStatus.rejected
                              ? Colors.red.shade100
                              : doc.status == DocumentStatus.submitted
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      doc.status.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (doc.rejectionReason != null) ...[
                    const SizedBox(width: 8),
                    Tooltip(
                      message: doc.rejectionReason!,
                      child: const Icon(Icons.warning_amber, color: Colors.red, size: 16),
                    ),
                  ],
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildContactInfo(ContactPerson? contactPerson) {
    if (contactPerson == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Person',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Text(
          contactPerson.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          contactPerson.designation,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.phone, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              contactPerson.phone,
              style: const TextStyle(color: Colors.blue, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.email, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                contactPerson.email,
                style: const TextStyle(color: Colors.blue, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisbursementDetails(DisbursementDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Disbursement Schedule',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₹${details.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...details.installments.map((installment) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Installment ${installment.installmentNumber}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '₹${installment.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Due: ${_formatDate(installment.dueDate)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: installment.status == InstallmentStatus.disbursed
                                    ? Colors.green.shade100
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                installment.status.toString().split('.').last.toUpperCase(),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (installment.status == InstallmentStatus.disbursed) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.download, size: 16),
                                onPressed: () {},
                                tooltip: 'Download Receipt',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}