import 'package:flutter/material.dart';
import '../../../core/models/project_model.dart';

enum FundFlowStep {
  centre('Centre', 'Initial fund allocation from Ministry'),
  state('State', 'Fund transfer to State Treasury'),
  agency('Agency', 'Fund allocation to implementing agency'),
  landAcquisition('Land Acquisition', 'Land purchase and documentation'),
  materialProcurement('Material Procurement', 'Construction materials purchase'),
  construction('Construction', 'Actual construction work'),
  completion('Completion', 'Project completion and handover');

  const FundFlowStep(this.title, this.description);
  final String title;
  final String description;
}

class StepTransaction {
  final String id;
  final FundFlowStep step;
  final double amount;
  final String responsiblePerson;
  final String designation;
  final String department;
  final DateTime transactionDate;
  final List<DocumentReceipt> receipts;
  final String fromEntity;
  final String toEntity;
  final bool isCompleted;

  StepTransaction({
    required this.id,
    required this.step,
    required this.amount,
    required this.responsiblePerson,
    required this.designation,
    required this.department,
    required this.transactionDate,
    required this.receipts,
    required this.fromEntity,
    required this.toEntity,
    required this.isCompleted,
  });
}

class DocumentReceipt {
  final String id;
  final String documentType;
  final String documentNumber;
  final String description;
  final DateTime issuedDate;
  final String issuedBy;
  final String fileUrl;

  DocumentReceipt({
    required this.id,
    required this.documentType,
    required this.documentNumber,
    required this.description,
    required this.issuedDate,
    required this.issuedBy,
    required this.fileUrl,
  });
}

/// Enhanced project-based fund flow widget with step-by-step tracking
class ProjectFundFlowWidget extends StatefulWidget {
  final String title;
  final VoidCallback? onRefresh;

  const ProjectFundFlowWidget({
    super.key,
    this.title = 'Step-by-Step Fund Flow Tracker',
    this.onRefresh,
  });

  @override
  State<ProjectFundFlowWidget> createState() => _ProjectFundFlowWidgetState();
}

class _ProjectFundFlowWidgetState extends State<ProjectFundFlowWidget> {
  ProjectModel? _selectedProject;
  List<ProjectModel> _projects = [];
  List<StepTransaction> _fundFlowSteps = [];
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isLoadingProjects = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoadingProjects = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final projects = _generateSampleProjects();
      
      setState(() {
        _projects = projects;
        _isLoadingProjects = false;
      });
    } catch (e) {
      setState(() => _isLoadingProjects = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading projects: $e')),
        );
      }
    }
  }

  Future<void> _loadProjectFundFlow(ProjectModel project) async {
    setState(() => _isLoading = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      final fundFlowSteps = _generateProjectFundFlowSteps(project);
      
      setState(() {
        _selectedProject = project;
        _fundFlowSteps = fundFlowSteps;
        _currentStep = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading fund flow: $e')),
        );
      }
    }
  }

  List<ProjectModel> _generateSampleProjects() {
    return [
      ProjectModel(
        id: 'proj_001',
        name: 'Rural Infrastructure Development',
        description: 'Comprehensive rural development with road, water, and electricity infrastructure',
        status: ProjectStatus.inProgress,
        component: ProjectComponent.adarshGram,
        totalBudget: 250.0,
        location: null,
        agencyId: 'agency_001',
        stateId: 'state_001',
        districtId: 'dist_001',
        projectArea: null,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ProjectModel(
        id: 'proj_002',
        name: 'Educational Complex Construction',
        description: 'Modern educational complex with hostels and laboratories',
        status: ProjectStatus.planning,
        component: ProjectComponent.hostel,
        totalBudget: 180.0,
        location: null,
        agencyId: 'agency_002',
        stateId: 'state_002',
        districtId: 'dist_002',
        projectArea: null,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  List<StepTransaction> _generateProjectFundFlowSteps(ProjectModel project) {
    final baseAmount = project.totalBudget ?? 200.0;
    
    return [
      StepTransaction(
        id: '${project.id}_step_1',
        step: FundFlowStep.centre,
        amount: baseAmount,
        responsiblePerson: 'Dr. Rajesh Kumar',
        designation: 'Joint Secretary',
        department: 'Ministry of Rural Development',
        transactionDate: DateTime.now().subtract(const Duration(days: 45)),
        fromEntity: 'Ministry of Finance',
        toEntity: 'State Treasury',
        isCompleted: true,
        receipts: [
          DocumentReceipt(
            id: 'doc_001',
            documentType: 'Sanction Order',
            documentNumber: 'SO/2024/RD/1234',
            description: 'Project sanction and fund release order',
            issuedDate: DateTime.now().subtract(const Duration(days: 45)),
            issuedBy: 'Ministry of Rural Development',
            fileUrl: '/documents/sanction_order_001.pdf',
          ),
          DocumentReceipt(
            id: 'doc_002',
            documentType: 'Digital Signature',
            documentNumber: 'DS/2024/RK/567',
            description: 'Digital signature verification',
            issuedDate: DateTime.now().subtract(const Duration(days: 45)),
            issuedBy: 'Dr. Rajesh Kumar',
            fileUrl: '/documents/digital_signature_001.pdf',
          ),
        ],
      ),
      StepTransaction(
        id: '${project.id}_step_2',
        step: FundFlowStep.state,
        amount: baseAmount * 0.8,
        responsiblePerson: 'Ms. Priya Sharma',
        designation: 'State Finance Secretary',
        department: 'State Finance Department',
        transactionDate: DateTime.now().subtract(const Duration(days: 35)),
        fromEntity: 'State Treasury',
        toEntity: 'District Collector Office',
        isCompleted: true,
        receipts: [
          DocumentReceipt(
            id: 'doc_003',
            documentType: 'Fund Transfer Order',
            documentNumber: 'FTO/2024/SF/789',
            description: 'State level fund transfer authorization',
            issuedDate: DateTime.now().subtract(const Duration(days: 35)),
            issuedBy: 'State Finance Department',
            fileUrl: '/documents/fund_transfer_001.pdf',
          ),
        ],
      ),
      StepTransaction(
        id: '${project.id}_step_3',
        step: FundFlowStep.agency,
        amount: baseAmount * 0.7,
        responsiblePerson: 'Mr. Suresh Patel',
        designation: 'District Collector',
        department: 'District Administration',
        transactionDate: DateTime.now().subtract(const Duration(days: 25)),
        fromEntity: 'District Collector Office',
        toEntity: 'Implementing Agency',
        isCompleted: true,
        receipts: [
          DocumentReceipt(
            id: 'doc_004',
            documentType: 'Work Order',
            documentNumber: 'WO/2024/DC/456',
            description: 'Work allocation to implementing agency',
            issuedDate: DateTime.now().subtract(const Duration(days: 25)),
            issuedBy: 'District Collector Office',
            fileUrl: '/documents/work_order_001.pdf',
          ),
        ],
      ),
      StepTransaction(
        id: '${project.id}_step_4',
        step: FundFlowStep.landAcquisition,
        amount: baseAmount * 0.3,
        responsiblePerson: 'Mr. Anil Verma',
        designation: 'Land Acquisition Officer',
        department: 'Revenue Department',
        transactionDate: DateTime.now().subtract(const Duration(days: 20)),
        fromEntity: 'Implementing Agency',
        toEntity: 'Land Owners',
        isCompleted: true,
        receipts: [
          DocumentReceipt(
            id: 'doc_005',
            documentType: 'Land Purchase Agreement',
            documentNumber: 'LPA/2024/RD/123',
            description: 'Land acquisition and compensation payment',
            issuedDate: DateTime.now().subtract(const Duration(days: 20)),
            issuedBy: 'Revenue Department',
            fileUrl: '/documents/land_purchase_001.pdf',
          ),
          DocumentReceipt(
            id: 'doc_006',
            documentType: 'Revenue Records',
            documentNumber: 'RR/2024/AV/890',
            description: 'Updated land revenue records',
            issuedDate: DateTime.now().subtract(const Duration(days: 18)),
            issuedBy: 'Mr. Anil Verma',
            fileUrl: '/documents/revenue_records_001.pdf',
          ),
        ],
      ),
      StepTransaction(
        id: '${project.id}_step_5',
        step: FundFlowStep.materialProcurement,
        amount: baseAmount * 0.25,
        responsiblePerson: 'Ms. Kavita Singh',
        designation: 'Project Engineer',
        department: 'Public Works Department',
        transactionDate: DateTime.now().subtract(const Duration(days: 15)),
        fromEntity: 'Implementing Agency',
        toEntity: 'Material Suppliers',
        isCompleted: true,
        receipts: [
          DocumentReceipt(
            id: 'doc_007',
            documentType: 'Purchase Order',
            documentNumber: 'PO/2024/PWD/345',
            description: 'Construction materials procurement order',
            issuedDate: DateTime.now().subtract(const Duration(days: 15)),
            issuedBy: 'Public Works Department',
            fileUrl: '/documents/purchase_order_001.pdf',
          ),
          DocumentReceipt(
            id: 'doc_008',
            documentType: 'Quality Certificate',
            documentNumber: 'QC/2024/KS/678',
            description: 'Material quality assurance certificate',
            issuedDate: DateTime.now().subtract(const Duration(days: 12)),
            issuedBy: 'Ms. Kavita Singh',
            fileUrl: '/documents/quality_cert_001.pdf',
          ),
        ],
      ),
      StepTransaction(
        id: '${project.id}_step_6',
        step: FundFlowStep.construction,
        amount: baseAmount * 0.15,
        responsiblePerson: 'Mr. Ravi Kumar',
        designation: 'Site Supervisor',
        department: 'Construction Company',
        transactionDate: DateTime.now().subtract(const Duration(days: 10)),
        fromEntity: 'Material Suppliers',
        toEntity: 'Construction Workers',
        isCompleted: false,
        receipts: [
          DocumentReceipt(
            id: 'doc_009',
            documentType: 'Progress Report',
            documentNumber: 'PR/2024/CC/901',
            description: 'Construction progress milestone report',
            issuedDate: DateTime.now().subtract(const Duration(days: 10)),
            issuedBy: 'Construction Company',
            fileUrl: '/documents/progress_report_001.pdf',
          ),
        ],
      ),
      StepTransaction(
        id: '${project.id}_step_7',
        step: FundFlowStep.completion,
        amount: 0.0,
        responsiblePerson: 'Mr. Deepak Gupta',
        designation: 'Project Director',
        department: 'Implementing Agency',
        transactionDate: DateTime.now().add(const Duration(days: 30)),
        fromEntity: 'Construction Team',
        toEntity: 'Community',
        isCompleted: false,
        receipts: [],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _selectedProject == null
                ? _buildProjectSelector()
                : _buildStepByStepFlow(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timeline,
            color: Colors.blue[300],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _selectedProject == null
                      ? 'Select a project to track step-by-step fund flow'
                      : 'Step ${_currentStep + 1} of ${_fundFlowSteps.length}: ${_fundFlowSteps.isNotEmpty ? _fundFlowSteps[_currentStep].step.title : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
          if (_selectedProject != null)
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedProject = null;
                  _fundFlowSteps = [];
                  _currentStep = 0;
                });
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
              tooltip: 'Back to project selection',
            ),
          IconButton(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Refresh data',
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSelector() {
    if (_isLoadingProjects) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Loading projects...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Project for Step-by-Step Fund Tracking',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final project = _projects[index];
                return _buildProjectCard(project);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _loadProjectFundFlow(project),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getProjectStatusColor(project.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      project.status.value.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description ?? 'No description available',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget: ₹${project.totalBudget?.toStringAsFixed(1) ?? 'N/A'}L',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.blue, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepByStepFlow() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Loading fund flow steps...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildStepNavigator(),
        Expanded(
          child: _buildCurrentStepDetails(),
        ),
      ],
    );
  }

  Widget _buildStepNavigator() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'Fund Flow Progress',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _fundFlowSteps.length,
              itemBuilder: (context, index) {
                final step = _fundFlowSteps[index];
                final isCompleted = step.isCompleted;
                final isCurrent = index == _currentStep;
                
                return GestureDetector(
                  onTap: () => setState(() => _currentStep = index),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.green[600]
                          : isCurrent 
                              ? Colors.blue[600]
                              : Colors.grey[600],
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrent 
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : Icons.circle,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.step.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _currentStep > 0 
                    ? () => setState(() => _currentStep--)
                    : null,
                icon: const Icon(Icons.navigate_before),
                label: const Text('Previous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _currentStep < _fundFlowSteps.length - 1
                    ? () => setState(() => _currentStep++)
                    : null,
                icon: const Icon(Icons.navigate_next),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepDetails() {
    if (_fundFlowSteps.isEmpty || _currentStep >= _fundFlowSteps.length) {
      return const Center(
        child: Text(
          'No step details available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final step = _fundFlowSteps[_currentStep];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(step),
            const SizedBox(height: 16),
            _buildTransactionDetails(step),
            const SizedBox(height: 16),
            _buildResponsiblePersonDetails(step),
            const SizedBox(height: 16),
            _buildDocumentReceipts(step),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(StepTransaction step) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                step.isCompleted ? Icons.check_circle : Icons.pending,
                color: step.isCompleted ? Colors.green : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.step.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            step.step.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Amount: ₹${step.amount.toStringAsFixed(2)}L',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                'Date: ${step.transactionDate.day}/${step.transactionDate.month}/${step.transactionDate.year}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(StepTransaction step) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Flow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    step.fromEntity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward, color: Colors.white),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[900],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    step.toEntity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiblePersonDetails(StepTransaction step) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Responsible Person',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.responsiblePerson,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      step.designation,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      step.department,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentReceipts(StepTransaction step) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Document Receipts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${step.receipts.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (step.receipts.isEmpty)
            const Text(
              'No documents available yet',
              style: TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...step.receipts.map((receipt) => _buildDocumentCard(receipt)),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentReceipt receipt) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _getDocumentIcon(receipt.documentType),
              color: Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receipt.documentType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'No. ${receipt.documentNumber}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    receipt.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Issued by: ${receipt.issuedBy}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showDocumentDetails(receipt),
              icon: const Icon(Icons.visibility, color: Colors.white70),
              tooltip: 'View document',
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String documentType) {
    switch (documentType.toLowerCase()) {
      case 'sanction order':
        return Icons.gavel;
      case 'digital signature':
        return Icons.verified_user;
      case 'fund transfer order':
        return Icons.account_balance_wallet;
      case 'work order':
        return Icons.work;
      case 'land purchase agreement':
        return Icons.landscape;
      case 'revenue records':
        return Icons.receipt_long;
      case 'purchase order':
        return Icons.shopping_cart;
      case 'quality certificate':
        return Icons.verified;
      case 'progress report':
        return Icons.assessment;
      default:
        return Icons.description;
    }
  }

  void _showDocumentDetails(DocumentReceipt receipt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Text(
          receipt.documentType,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Number: ${receipt.documentNumber}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Description: ${receipt.description}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Issued Date: ${receipt.issuedDate.day}/${receipt.issuedDate.month}/${receipt.issuedDate.year}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Issued By: ${receipt.issuedBy}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              'File Path: ${receipt.fileUrl}',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getProjectStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.orange;
      case ProjectStatus.inProgress:
        return Colors.blue;
      case ProjectStatus.review:
        return Colors.purple;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.onHold:
        return Colors.amber;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }
}