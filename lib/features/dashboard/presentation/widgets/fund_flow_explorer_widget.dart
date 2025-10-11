import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/fund_transaction_model.dart';
import '../../../../core/models/project_model.dart';
import '../../../../core/models/agency_model.dart';
import '../../../../core/data/demo_data_generator.dart';
import 'package:latlong2/latlong.dart';
import '../../../maps/widgets/interactive_map_widget.dart';

// Enums for filters
enum ViewMode { project, agency }

class FundFlowExplorerWidget extends ConsumerStatefulWidget {
  final String userId;
  
  const FundFlowExplorerWidget({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<FundFlowExplorerWidget> createState() => _FundFlowExplorerWidgetState();
}

class _FundFlowExplorerWidgetState extends ConsumerState<FundFlowExplorerWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ViewMode _viewMode = ViewMode.project;
  String _searchQuery = '';
  SchemeComponent? _selectedComponent;
  String? _selectedState;
  DateTimeRange? _dateRange;
  TransactionStatus? _selectedStatus;
  String? _selectedProjectId;
  String? _selectedAgencyId;
  
  // Mock data
  final List<FundTransaction> _transactions = [];
  final List<ProjectModel> _projects = [];
  final List<AgencyModel> _agencies = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadMockData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _loadMockData() {
    // Load comprehensive demo data - 100 transactions, 50 projects, 25 agencies
    _transactions.addAll(DemoDataGenerator.generateFundTransactions(count: 100));
    _projects.addAll(DemoDataGenerator.generateProjects(count: 50));
    _agencies.addAll(DemoDataGenerator.generateAgencies(count: 25));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fund Flow Explorer'),
        backgroundColor: AppTheme.overwatchColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Search'),
            Tab(icon: Icon(Icons.account_tree), text: 'Sankey'),
            Tab(icon: Icon(Icons.waterfall_chart), text: 'Waterfall'),
            Tab(icon: Icon(Icons.map), text: 'Map'),
            Tab(icon: Icon(Icons.folder_open), text: 'Evidence'),
            Tab(icon: Icon(Icons.table_chart), text: 'Transactions'),
            Tab(icon: Icon(Icons.notifications_active), text: 'Alerts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchFilterPanel(),
          _buildSankeyChart(),
          _buildWaterfallChart(),
          _buildGeospatialMap(),
          _buildEvidencePanel(),
          _buildTransactionTable(),
          _buildAlertsPanel(),
        ],
      ),
    );
  }
  
  Widget _buildSearchFilterPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced AI-Powered Global Search Bar
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppTheme.overwatchColor, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'AI-Powered Search',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Natural language query (e.g., "Show Project X fund flow last quarter")',
                      hintText: 'Try: "High-risk projects in Maharashtra" or "Delayed funds over 20 days"',
                      prefixIcon: const Icon(Icons.psychology),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: () {
                          // Voice search placeholder
                        },
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSuggestionChip('Projects with >80% utilization'),
                      _buildSuggestionChip('Agencies with <2-day transfer lag'),
                      _buildSuggestionChip('Non-compliant transactions'),
                      _buildSuggestionChip('High-risk allocations'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // View Mode Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'View Mode',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ViewMode>(
                    segments: const [
                      ButtonSegment(
                        value: ViewMode.project,
                        label: Text('Project View'),
                        icon: Icon(Icons.folder),
                      ),
                      ButtonSegment(
                        value: ViewMode.agency,
                        label: Text('Agency View'),
                        icon: Icon(Icons.business),
                      ),
                    ],
                    selected: {_viewMode},
                    onSelectionChanged: (Set<ViewMode> selection) {
                      setState(() => _viewMode = selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Smart Filters with Risk & Compliance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Smart Filters',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedComponent = null;
                            _selectedState = null;
                            _selectedStatus = null;
                            _dateRange = null;
                          });
                        },
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Risk Level Filter
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Risk Level (AI-Scored)',
                      prefixIcon: Icon(Icons.warning_amber),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'high', child: Text('🔴 High Risk')),
                      DropdownMenuItem(value: 'medium', child: Text('🟡 Medium Risk')),
                      DropdownMenuItem(value: 'low', child: Text('🟢 Low Risk')),
                    ],
                    onChanged: (value) {
                      // Filter by AI risk score
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Compliance Status Filter
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Compliance Status',
                      prefixIcon: Icon(Icons.verified_user),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'compliant', child: Text('✅ Compliant')),
                      DropdownMenuItem(value: 'non_compliant', child: Text('❌ Non-Compliant')),
                      DropdownMenuItem(value: 'pending', child: Text('⏳ Pending Evidence')),
                    ],
                    onChanged: (value) {
                      // Filter by compliance status
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  DropdownButtonFormField<TransactionStatus>(
                    decoration: const InputDecoration(
                      labelText: 'Fund Status',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedStatus,
                    items: TransactionStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedStatus = value),
                  ),
                  const SizedBox(height: 12),
                  
                  DropdownButtonFormField<SchemeComponent>(
                    decoration: const InputDecoration(
                      labelText: 'Scheme Component',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedComponent,
                    items: SchemeComponent.values.map((component) {
                      return DropdownMenuItem(
                        value: component,
                        child: Text(component.label),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedComponent = value),
                  ),
                  const SizedBox(height: 12),
                  
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedState,
                    items: ['Delhi', 'Maharashtra', 'Karnataka', 'Tamil Nadu']
                        .map((state) => DropdownMenuItem(value: state, child: Text(state)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedState = value),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (range != null) {
                        setState(() => _dateRange = range);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_dateRange == null
                        ? 'Select Date Range'
                        : '${_dateRange!.start.toString().split(' ')[0]} - ${_dateRange!.end.toString().split(' ')[0]}'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Results
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Results',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_viewMode == ViewMode.project)
                    ..._projects.map((project) => ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(project.name),
                      subtitle: Text('Budget: ₹${((project.allocatedBudget ?? 0) / 10000000).toStringAsFixed(2)} Cr'),
                      trailing: Chip(
                        label: Text(project.status.value),
                        backgroundColor: _getStatusColor(project.status),
                      ),
                      onTap: () {
                        setState(() => _selectedProjectId = project.id);
                        _tabController.animateTo(1); // Navigate to Sankey chart
                      },
                    ))
                  else
                    ..._agencies.map((agency) => ListTile(
                      leading: const Icon(Icons.business),
                      title: Text(agency.name),
                      subtitle: Text('Performance: ${(agency.performanceRating * 100).toStringAsFixed(0)}%'),
                      trailing: CircleAvatar(
                        backgroundColor: AppTheme.successGreen,
                        child: Text(
                          '${(agency.performanceRating * 100).toInt()}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      onTap: () {
                        setState(() => _selectedAgencyId = agency.id);
                        _tabController.animateTo(1); // Navigate to Sankey chart
                      },
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSankeyChart() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.account_tree, color: AppTheme.overwatchColor),
                      SizedBox(width: 8),
                      Text(
                        'Fund Flow Sankey Diagram',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Interactive fund movement visualization showing flows from Centre → State → Agency → Project → Evidence-Linked Spend',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  
                  // Sankey visualization (simplified representation)
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        // Centre Allocation Node
                        Positioned(
                          left: 20,
                          top: 180,
                          child: _buildSankeyNode(
                            'Centre Allocation',
                            '₹50 Cr',
                            Colors.blue,
                            onTap: () => _showNodeDetails('Centre Allocation', 50000000.0),
                          ),
                        ),
                        
                        // State Receipt Node
                        Positioned(
                          left: 200,
                          top: 180,
                          child: _buildSankeyNode(
                            'State Receipt',
                            '₹45 Cr',
                            Colors.yellow.shade700,
                            onTap: () => _showNodeDetails('State Receipt', 45000000.0),
                          ),
                        ),
                        
                        // Agency Receipt Node
                        Positioned(
                          left: 380,
                          top: 180,
                          child: _buildSankeyNode(
                            'Agency Receipt',
                            '₹42 Cr',
                            Colors.orange,
                            onTap: () => _showNodeDetails('Agency Receipt', 42000000.0),
                          ),
                        ),
                        
                        // Project Disbursement Node
                        Positioned(
                          left: 560,
                          top: 180,
                          child: _buildSankeyNode(
                            'Project Spend',
                            '₹38 Cr',
                            Colors.green,
                            onTap: () => _showNodeDetails('Project Spend', 38000000.0),
                          ),
                        ),
                        
                        // Evidence-Linked Node
                        Positioned(
                          left: 740,
                          top: 180,
                          child: _buildSankeyNode(
                            'Evidence-Certified',
                            '₹35 Cr',
                            AppTheme.successGreen,
                            onTap: () => _showNodeDetails('Evidence-Certified', 35000000.0),
                          ),
                        ),
                        
                        // Flow Lines
                        CustomPaint(
                          size: const Size(900, 400),
                          painter: SankeyFlowPainter(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Legend
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildLegendItem(Colors.blue, 'Allocated'),
                      _buildLegendItem(Colors.yellow.shade700, 'In-Transit'),
                      _buildLegendItem(Colors.green, 'Utilized'),
                      _buildLegendItem(Colors.red, 'Pending UC'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSankeyNode(String label, String amount, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 60,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
            Text(
              amount,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
  
  void _showNodeDetails(String nodeName, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nodeName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ₹${(amount / 10000000).toStringAsFixed(2)} Cr'),
            const SizedBox(height: 8),
            Text('Transactions: ${_transactions.length}'),
            const SizedBox(height: 8),
            const Text('Recent Activity:'),
            ..._transactions.take(3).map((t) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${t.fromEntity} → ${t.toEntity}: ₹${(t.amount / 10000000).toStringAsFixed(2)} Cr',
                style: const TextStyle(fontSize: 12),
              ),
            )),
          ],
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
  
  Widget _buildWaterfallChart() {
    final stages = [
      {'label': 'Allocated to State', 'value': 50000000.0, 'color': Colors.blue},
      {'label': 'Transferred to Agency', 'value': 45000000.0, 'color': Colors.orange},
      {'label': 'Spent by Project', 'value': 38000000.0, 'color': Colors.green},
      {'label': 'Evidence-Certified', 'value': 35000000.0, 'color': AppTheme.successGreen},
      {'label': 'Remaining Balance', 'value': 15000000.0, 'color': Colors.grey},
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.waterfall_chart, color: AppTheme.overwatchColor),
                  SizedBox(width: 8),
                  Text(
                    'Waterfall Utilization Chart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Sequential display of cumulative allocations vs. spends with variance markers',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: stages.length,
                  itemBuilder: (context, index) {
                    final stage = stages[index];
                    final value = stage['value'] as double;
                    const maxValue = 50000000.0;
                    final widthPercent = (value / maxValue);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stage['label'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    Container(
                                      height: 40,
                                      width: MediaQuery.of(context).size.width * 0.7 * widthPercent,
                                      decoration: BoxDecoration(
                                        color: stage['color'] as Color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '₹${(value / 10000000).toStringAsFixed(2)} Cr',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (index > 0 && index < stages.length - 1)
                                Chip(
                                  label: Text(
                                    '${((1 - (widthPercent / ((stages[index - 1]['value'] as double) / maxValue))) * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.red.shade100,
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGeospatialMap() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.map, color: AppTheme.overwatchColor),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Geospatial Spend Map',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.layers),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'agencies', child: Text('Agency Locations')),
                      const PopupMenuItem(value: 'projects', child: Text('Project Sites')),
                      const PopupMenuItem(value: 'evidence', child: Text('Evidence Pins')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: InteractiveMapWidget(
            projects: _projects,
            agencies: _agencies,
            initialCenter: const LatLng(20.5937, 78.9629),
            initialZoom: 5.0,
            onProjectTap: (projectId) => _showProjectDetails(projectId),
            onAgencyTap: (agencyId) => _showAgencyDetails(agencyId),
          ),
        ),
      ],
    );
  }
  
  void _showProjectDetails(String projectId) {
    final project = _projects.firstWhere((p) => p.id == projectId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Budget: ₹${((project.allocatedBudget ?? 0) / 10000000).toStringAsFixed(2)} Cr'),
            Text('Progress: ${project.completionPercentage.toStringAsFixed(1)}%'),
            Text('Status: ${project.status.value}'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _tabController.animateTo(4); // Navigate to evidence panel
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('View Evidence'),
            ),
          ],
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
  
  void _showAgencyDetails(String agencyId) {
    final agency = _agencies.firstWhere((a) => a.id == agencyId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(agency.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${_getAgencyTypeLabel(agency.type)}'),
            Text('Performance: ${(agency.performanceRating * 100).toStringAsFixed(0)}%'),
            Text('Capacity: ${(agency.capacityScore * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 12),
            const Text('Total Funds Received: ₹45 Cr'),
            const Text('Total Projects: 12'),
          ],
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
  
  Widget _buildEvidencePanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.folder_open, color: AppTheme.overwatchColor),
                      SizedBox(width: 8),
                      Text(
                        'Evidence & Documentation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Supporting documents linked to fund events',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Utilization Certificates
          _buildEvidenceSection(
            'Utilization Certificates',
            Icons.description,
            [
              {'name': 'UC_Q1_2024.pdf', 'pfms': 'PFMS/2024/AG/001', 'date': '2024-03-15'},
              {'name': 'UC_Q2_2024.pdf', 'pfms': 'PFMS/2024/AG/002', 'date': '2024-06-15'},
            ],
          ),
          
          // Photo Gallery
          _buildEvidenceSection(
            'Photo Gallery',
            Icons.photo_library,
            [
              {'name': 'Site_Progress_1.jpg', 'location': '28.6139, 77.2090', 'date': '2024-09-01'},
              {'name': 'Site_Progress_2.jpg', 'location': '28.6139, 77.2090', 'date': '2024-09-15'},
            ],
          ),
          
          // Video Clips
          _buildEvidenceSection(
            'Video Clips',
            Icons.video_library,
            [
              {'name': 'Site_Walkthrough.mp4', 'duration': '5:23', 'date': '2024-09-20'},
            ],
          ),
          
          // Inspection Reports
          _buildEvidenceSection(
            'Inspection Reports',
            Icons.assessment,
            [
              {'name': 'QA_Report_Aug2024.pdf', 'score': '92%', 'date': '2024-08-30'},
              {'name': 'Beneficiary_Survey.pdf', 'responses': '150', 'date': '2024-09-10'},
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEvidenceSection(String title, IconData icon, List<Map<String, String>> items) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.overwatchColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: items.map((item) => ListTile(
          leading: const Icon(Icons.file_present),
          title: Text(item['name']!),
          subtitle: Text(item.entries.skip(1).map((e) => '${e.key}: ${e.value}').join(' • ')),
          trailing: IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading ${item['name']}')),
              );
            },
          ),
        )).toList(),
      ),
    );
  }
  
  Widget _buildTransactionTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.table_chart, color: AppTheme.overwatchColor),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Transaction Explorer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_download),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exporting transactions to CSV...')),
                      );
                    },
                    tooltip: 'Export to CSV',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('From')),
                  DataColumn(label: Text('To')),
                  DataColumn(label: Text('Amount (Cr)')),
                  DataColumn(label: Text('Component')),
                  DataColumn(label: Text('PFMS ID')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Evidence')),
                ],
                rows: _transactions.map((transaction) => DataRow(
                  cells: [
                    DataCell(Text(transaction.transactionDate.toString().split(' ')[0])),
                    DataCell(Text(transaction.fromEntity)),
                    DataCell(Text(transaction.toEntity)),
                    DataCell(Text((transaction.amount / 10000000).toStringAsFixed(2))),
                    DataCell(Text(transaction.component.label)),
                    DataCell(Text(transaction.pfmsId)),
                    DataCell(Chip(
                      label: Text(transaction.status.label, style: const TextStyle(fontSize: 11)),
                      backgroundColor: _getTransactionStatusColor(transaction.status.label),
                    )),
                    DataCell(IconButton(
                      icon: Icon(
                        transaction.documentUrls.isNotEmpty ? Icons.folder : Icons.folder_off,
                        color: transaction.documentUrls.isNotEmpty ? AppTheme.successGreen : Colors.grey,
                      ),
                      onPressed: transaction.documentUrls.isNotEmpty
                          ? () => _showEvidenceDialog(transaction)
                          : null,
                    )),
                  ],
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEvidenceDialog(FundTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Evidence Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: transaction.documentUrls.map((link) => ListTile(
            leading: const Icon(Icons.file_present),
            title: Text(link.split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening $link')),
                );
              },
            ),
          )).toList(),
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
  
  Widget _buildAlertsPanel() {
    final alerts = [
      {
        'type': 'Pending UC',
        'message': 'Utilization Certificate pending for >30 days',
        'severity': 'high',
        'count': 5,
        'icon': Icons.warning,
      },
      {
        'type': 'Delayed Transfer',
        'message': 'Fund transfer in-transit for >7 days',
        'severity': 'medium',
        'count': 3,
        'icon': Icons.schedule,
      },
      {
        'type': 'Over-utilization',
        'message': 'Project spent >110% of allocation',
        'severity': 'high',
        'count': 2,
        'icon': Icons.trending_up,
      },
      {
        'type': 'Missing Evidence',
        'message': 'Transaction without supporting documents',
        'severity': 'medium',
        'count': 8,
        'icon': Icons.folder_off,
      },
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.notifications_active, color: AppTheme.overwatchColor),
                  SizedBox(width: 8),
                  Text(
                    'Real-Time Alerts & SLA Tracking',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          ...alerts.map((alert) => Card(
            color: _getAlertColor(alert['severity'] as String),
            child: ListTile(
              leading: Icon(alert['icon'] as IconData, color: Colors.white),
              title: Text(
                alert['type'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Text(
                alert['message'] as String,
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  '${alert['count']}',
                  style: TextStyle(
                    color: _getAlertColor(alert['severity'] as String),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )),
          
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SLA Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSLAMetric('Avg Transfer Time', '4.2 days', 0.7, AppTheme.successGreen),
                  const SizedBox(height: 12),
                  _buildSLAMetric('UC Turnaround Time', '18 days', 0.6, Colors.orange),
                  const SizedBox(height: 12),
                  _buildSLAMetric('Evidence Submission Rate', '85%', 0.85, AppTheme.successGreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSLAMetric(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
  
  Color _getAlertColor(String severity) {
    switch (severity) {
      case 'high':
        return AppTheme.errorRed;
      case 'medium':
        return AppTheme.warningOrange;
      default:
        return Colors.blue;
    }
  }
  
  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.completed:
        return AppTheme.successGreen;
      case ProjectStatus.inProgress:
        return AppTheme.secondaryBlue;
      case ProjectStatus.onHold:
        return AppTheme.warningOrange;
      default:
        return Colors.grey;
    }
  }
  
  Color _getTransactionStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.successGreen.withValues(alpha: 0.2);
      case 'In-Transit':
        return Colors.orange.withValues(alpha: 0.2);
      case 'Utilized':
        return Colors.green.withValues(alpha: 0.2);
      case 'Pending':
        return Colors.red.withValues(alpha: 0.2);
      default:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }
  
  String _getAgencyTypeLabel(AgencyType type) {
    switch (type) {
      case AgencyType.implementingAgency:
        return 'Implementing Agency';
      case AgencyType.nodalAgency:
        return 'Nodal Agency';
      case AgencyType.technicalAgency:
        return 'Technical Agency';
      case AgencyType.monitoringAgency:
        return 'Monitoring Agency';
    }
  }
  
  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      avatar: const Icon(Icons.lightbulb_outline, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        setState(() => _searchQuery = label);
      },
      backgroundColor: AppTheme.overwatchColor.withValues(alpha: 0.1),
      side: BorderSide(color: AppTheme.overwatchColor.withValues(alpha: 0.3)),
    );
  }
}

// Custom painter for Sankey flow lines
class SankeyFlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..color = Colors.blue.withValues(alpha: 0.3);
    
    // Draw flow lines between nodes
    canvas.drawLine(
      const Offset(140, 210),
      const Offset(200, 210),
      paint,
    );
    
    paint.color = Colors.orange.withValues(alpha: 0.3);
    canvas.drawLine(
      const Offset(320, 210),
      const Offset(380, 210),
      paint,
    );
    
    paint.color = Colors.green.withValues(alpha: 0.3);
    canvas.drawLine(
      const Offset(500, 210),
      const Offset(560, 210),
      paint,
    );
    
    paint.color = AppTheme.successGreen.withValues(alpha: 0.3);
    canvas.drawLine(
      const Offset(680, 210),
      const Offset(740, 210),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}