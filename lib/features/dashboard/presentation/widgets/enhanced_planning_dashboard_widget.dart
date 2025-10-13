import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/models/project_model.dart';
import '../../../../core/models/agency_model.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/widgets/dashboard_components.dart';

class EnhancedPlanningDashboardWidget extends ConsumerStatefulWidget {
  final String stateId;

  const EnhancedPlanningDashboardWidget({
    super.key,
    required this.stateId,
  });

  @override
  ConsumerState<EnhancedPlanningDashboardWidget> createState() =>
      _EnhancedPlanningDashboardWidgetState();
}

class _EnhancedPlanningDashboardWidgetState
    extends ConsumerState<EnhancedPlanningDashboardWidget> {
  
  List<ProjectModel> _pendingProjects = [];
  List<ProjectModel> _assignedProjects = [];
  List<AgencyModel> _availableAgencies = [];
  
  ProjectModel? _selectedProject;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    // Mock pending projects
    _pendingProjects = [
      ProjectModel(
        id: 'proj_001',
        name: 'Rural Health Center - Sector 12',
        description: 'Construction of primary health center with modern facilities and equipment for 5,000+ beneficiaries',
        stateId: widget.stateId,
        districtId: 'dist_001',
        location: const LatLng(28.6139, 77.2090),
        status: ProjectStatus.planning,
        component: ProjectComponent.adarshGram,
        totalBudget: 15000000,
        beneficiariesCount: 5000,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ProjectModel(
        id: 'proj_002',
        name: 'Digital Learning Hub - Village Complex',
        description: 'Smart classrooms with high-speed internet connectivity and modern teaching aids',
        stateId: widget.stateId,
        districtId: 'dist_002',
        location: const LatLng(28.5355, 77.3910),
        status: ProjectStatus.planning,
        component: ProjectComponent.admin,
        totalBudget: 8500000,
        beneficiariesCount: 3000,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ProjectModel(
        id: 'proj_003',
        name: 'Community Sports Complex',
        description: 'Multi-purpose sports facility with football field, basketball court and indoor games area',
        stateId: widget.stateId,
        districtId: 'dist_001',
        location: const LatLng(28.7041, 77.1025),
        status: ProjectStatus.planning,
        component: ProjectComponent.adarshGram,
        totalBudget: 12000000,
        beneficiariesCount: 8000,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    // Mock assigned projects
    _assignedProjects = [
      ProjectModel(
        id: 'proj_004',
        name: 'Water Treatment Plant',
        description: 'Advanced water purification facility with 10,000L/hour capacity',
        agencyId: 'agency_001',
        stateId: widget.stateId,
        status: ProjectStatus.inProgress,
        component: ProjectComponent.adarshGram,
        totalBudget: 25000000,
        beneficiariesCount: 15000,
        completionPercentage: 65.0,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ProjectModel(
        id: 'proj_005',
        name: 'School Infrastructure Upgrade',
        description: 'Complete renovation with new classrooms, library and computer lab',
        agencyId: 'agency_002',
        stateId: widget.stateId,
        status: ProjectStatus.inProgress,
        component: ProjectComponent.admin,
        totalBudget: 18000000,
        beneficiariesCount: 12000,
        completionPercentage: 45.0,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // Mock available agencies
    _availableAgencies = [
      AgencyModel(
        id: 'agency_001',
        name: 'Delhi Infrastructure Development Agency',
        type: AgencyType.implementingAgency,
        stateId: widget.stateId,
        location: const LatLng(28.6129, 77.2295),
        contactPerson: 'Rajesh Kumar',
        phone: '+91-9876543210',
        email: 'rajesh@dida.gov.in',
        capacityScore: 85.0,
        performanceRating: 4.2,
        metadata: {
          'specialization': 'healthcare_infrastructure',
          'team_size': 45,
          'projects_completed': 12,
          'current_workload': 'medium'
        },
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      AgencyModel(
        id: 'agency_002',
        name: 'Smart City Technical Solutions',
        type: AgencyType.technicalAgency,
        stateId: widget.stateId,
        location: const LatLng(28.5274, 77.2176),
        contactPerson: 'Priya Sharma',
        phone: '+91-9876543211',
        email: 'priya@scts.gov.in',
        capacityScore: 92.0,
        performanceRating: 4.7,
        metadata: {
          'specialization': 'digital_infrastructure',
          'team_size': 32,
          'projects_completed': 18,
          'current_workload': 'light'
        },
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      AgencyModel(
        id: 'agency_003',
        name: 'Community Development Corporation',
        type: AgencyType.nodalAgency,
        stateId: widget.stateId,
        location: const LatLng(28.7041, 77.1364),
        contactPerson: 'Amit Singh',
        phone: '+91-9876543212',
        email: 'amit@cdc.gov.in',
        capacityScore: 78.0,
        performanceRating: 4.0,
        metadata: {
          'specialization': 'community_engagement',
          'team_size': 28,
          'projects_completed': 15,
          'current_workload': 'high'
        },
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      AgencyModel(
        id: 'agency_004',
        name: 'Urban Planning & Development Ltd',
        type: AgencyType.implementingAgency,
        stateId: widget.stateId,
        location: const LatLng(28.6500, 77.2300),
        contactPerson: 'Sunita Patel',
        phone: '+91-9876543213',
        email: 'sunita@upd.gov.in',
        capacityScore: 88.0,
        performanceRating: 4.5,
        metadata: {
          'specialization': 'urban_development',
          'team_size': 38,
          'projects_completed': 20,
          'current_workload': 'medium'
        },
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              // Left side - Pending Projects (40% width)
              Expanded(
                flex: 2,
                child: _buildPendingProjectsSection(),
              ),
              const SizedBox(width: 16),
              // Center - AI Recommendations (35% width) 
              Expanded(
                flex: 2,
                child: _buildAIRecommendationsSection(),
              ),
              const SizedBox(width: 16),
              // Right side - Assigned Projects (25% width)
              Expanded(
                flex: 2,
                child: _buildAssignedProjectsSection(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppDesignSystem.deepIndigo, Colors.blue.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.dashboard_customize, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enhanced Project Planning Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-powered agency recommendations with drag-and-drop assignment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _loadMockData,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppDesignSystem.deepIndigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingProjectsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.pending_actions, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Pending Projects (${_pendingProjects.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const Spacer(),
                Text(
                  'Click on a project to see AI recommendations →',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _pendingProjects.isEmpty
                ? Center(
                    child: Text(
                      'No pending projects',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingProjects.length,
                    itemBuilder: (context, index) {
                      final project = _pendingProjects[index];
                      return _buildPendingProjectCard(project);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingProjectCard(ProjectModel project) {
    final isSelected = _selectedProject?.id == project.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProject = project;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.name ?? 'Unnamed Project',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const StatusBadge(
                  label: 'Planning',
                  type: StatusType.warning,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              project.description ?? 'No description available',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${project.districtId} District',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.currency_rupee, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '₹${((project.totalBudget ?? 0) / 1000000).toStringAsFixed(1)}M',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  '${project.beneficiariesCount} beneficiaries',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Selected',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIRecommendationsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.psychology, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'AI Recommendations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const Spacer(),
                if (_selectedProject != null)
                  Text(
                    'For: ${_selectedProject!.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _selectedProject == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 48,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a Project First',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click on any pending project from the left\nto see AI-powered agency recommendations',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _availableAgencies.length,
                    itemBuilder: (context, index) {
                      final agency = _availableAgencies[index];
                      final score = _calculateMatchScore(agency, _selectedProject!);
                      return _buildAgencyRecommendationCard(agency, score);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgencyRecommendationCard(AgencyModel agency, double score) {
    return Draggable<Map<String, dynamic>>(
      data: {
        'agency': agency,
        'selectedProject': _selectedProject,
      },
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Row(
            children: [
              const Icon(Icons.business, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      agency.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      'Match: ${score.toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[700]?.withOpacity(0.5),
          border: Border.all(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    agency.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Dragging...',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Being assigned...',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    agency.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${score.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(score),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildScoreBar(score),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  agency.performanceRating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                Icon(Icons.business_center, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _getAgencyTypeLabel(agency.type),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAgencyDetails(agency),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: AppDesignSystem.deepIndigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_selectedProject != null) {
                        _assignAgencyToProject(agency, _selectedProject!);
                        _showAssignmentFeedback(agency, _selectedProject!);
                      }
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(double score) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        widthFactor: score / 100,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: _getScoreColor(score),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getAgencyTypeLabel(AgencyType type) {
    switch (type) {
      case AgencyType.implementingAgency:
        return 'Implementation';
      case AgencyType.technicalAgency:
        return 'Technical';
      case AgencyType.nodalAgency:
        return 'Nodal';
      case AgencyType.monitoringAgency:
        return 'Monitoring';
    }
  }

  double _calculateMatchScore(AgencyModel agency, ProjectModel project) {
    // Simple scoring algorithm based on agency type and performance
    double score = 50.0; // Base score

    // Performance rating boost
    score += (agency.performanceRating / 5.0) * 25;

    // Capacity score boost
    score += (agency.capacityScore / 100.0) * 15;

    // Type compatibility
    if (project.component == ProjectComponent.adarshGram && 
        agency.type == AgencyType.implementingAgency) {
      score += 10;
    } else if (project.component == ProjectComponent.admin && 
               agency.type == AgencyType.technicalAgency) {
      score += 10;
    }

    return score.clamp(0.0, 100.0);
  }

  Widget _buildAssignedProjectsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.assignment_turned_in, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Assigned Projects (${_assignedProjects.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const Spacer(),
                Text(
                  'Approve agency to assign →',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _assignedProjects.isEmpty
                ? const Center(
                    child: Text(
                      'No assigned projects yet.\nDrag agencies from recommendations above to assign them to projects.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF9E9E9E)),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(16),
                    itemCount: _assignedProjects.length,
                    itemBuilder: (context, index) {
                      final project = _assignedProjects[index];
                      return _buildAssignedProjectCard(project);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedProjectCard(ProjectModel project) {
    return DragTarget<Map<String, dynamic>>(
      builder: (context, candidateData, rejectedData) {
        final isAcceptingDrag = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isAcceptingDrag ? Colors.green.withOpacity(0.3) : Colors.grey[100],
            border: Border.all(
              color: isAcceptingDrag ? Colors.green : Colors.grey.shade300,
              width: isAcceptingDrag ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isAcceptingDrag ? [
              BoxShadow(
                color: Colors.green.withOpacity(0.4),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name ?? 'Unnamed Project',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(
                    label: project.status == ProjectStatus.inProgress ? 'In Progress' : 'Assigned',
                    type: project.status == ProjectStatus.inProgress ? StatusType.info : StatusType.success,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (project.agencyId != null) ...[
                Row(
                  children: [
                    const Icon(Icons.business, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getAgencyName(project.agencyId!),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              if (project.completionPercentage > 0) ...[
                Text(
                  'Progress: ${project.completionPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: project.completionPercentage / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                ),
                const SizedBox(height: 6),
              ],
              ElevatedButton.icon(
                onPressed: () => _showSubtaskDialog(project),
                icon: const Icon(Icons.add_task, size: 14),
                label: const Text('Add Subtask', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 28),
                ),
              ),
              const SizedBox(height: 6),
              if (candidateData.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          candidateData.isNotEmpty
                            ? 'Drop ${candidateData.first?['agency']?.name ?? 'agency'} here to assign'
                            : 'Drop to assign agency',
                          style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 16, color: Colors.green),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
      onAcceptWithDetails: (details) {
        final dragData = details.data;
        final agency = dragData['agency'] as AgencyModel;
        final selectedProject = dragData['selectedProject'] as ProjectModel?;
        
        // If there's a selected project, use it; otherwise use the dropped project
        final projectToAssign = selectedProject ?? project;
        
        _assignAgencyToProject(agency, projectToAssign);
        _showAssignmentFeedback(agency, projectToAssign);
      },
      onWillAcceptWithDetails: (details) {
        // Accept any agency drag data
        final dragData = details.data;
        return dragData['agency'] != null;
      },
    );
  }

  String _getAgencyName(String agencyId) {
    final agency = _availableAgencies.firstWhere(
      (a) => a.id == agencyId,
      orElse: () => AgencyModel(
        id: agencyId,
        name: 'Unknown Agency',
        type: AgencyType.implementingAgency,
        location: const LatLng(0, 0),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return agency.name;
  }

  void _assignAgencyToProject(AgencyModel agency, ProjectModel projectToAssign) {
    final projectName = projectToAssign.name;

    setState(() {
      // Remove from pending if it exists there
      _pendingProjects.removeWhere((p) => p.id == projectToAssign.id);
      
      // Update project with assigned agency
      final updatedProject = projectToAssign.copyWith(
        agencyId: agency.id,
        status: ProjectStatus.inProgress,
        updatedAt: DateTime.now(),
      );
      
      // Remove from assigned projects if it already exists
      _assignedProjects.removeWhere((p) => p.id == projectToAssign.id);
      
      // Add to assigned projects
      _assignedProjects.add(updatedProject);
      
      // Clear selection if it was the selected project
      if (_selectedProject?.id == projectToAssign.id) {
        _selectedProject = null;
      }
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${agency.name} assigned to $projectName',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // Implement undo functionality if needed
          },
        ),
      ),
    );
  }

  void _showSubtaskDialog(ProjectModel project) {
    AgencyModel? selectedAgency;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.grey[850],
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add_task, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add Subtask to ${project.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Subtask Name',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Assign Agency (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[600]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AgencyModel>(
                      value: selectedAgency,
                      hint: const Text(
                        'Select an agency...',
                        style: TextStyle(color: Colors.white70),
                      ),
                      isExpanded: true,
                      dropdownColor: Colors.grey[800],
                      style: const TextStyle(color: Colors.white),
                      items: _availableAgencies.map((agency) {
                        return DropdownMenuItem<AgencyModel>(
                          value: agency,
                          child: Row(
                            children: [
                              const Icon(Icons.business, size: 16, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  agency.name,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, size: 12, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text(
                                      agency.performanceRating.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 11, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (agency) {
                        setState(() {
                          selectedAgency = agency;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (selectedAgency != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Subtask created and assigned to ${selectedAgency!.name}!'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Subtask created! You can assign an agency later.'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Create Subtask'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAssignmentFeedback(AgencyModel agency, ProjectModel project) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Agency Assigned Successfully!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '${agency.name} has been assigned to ${project.name}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade700,
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );

    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  void _showAgencyDetails(AgencyModel agency) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.grey[850],
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.business, color: AppDesignSystem.deepIndigo),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      agency.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Type', _getAgencyTypeLabel(agency.type)),
              _buildDetailRow('Performance Rating', '${agency.performanceRating.toStringAsFixed(1)}/5.0'),
              _buildDetailRow('Capacity Score', '${agency.capacityScore.toStringAsFixed(0)}%'),
              _buildDetailRow('Team Size', '${agency.metadata['team_size'] ?? 'N/A'} members'),
              _buildDetailRow('Projects Completed', '${agency.metadata['projects_completed'] ?? 'N/A'}'),
              _buildDetailRow('Current Workload', '${agency.metadata['current_workload'] ?? 'N/A'}'),
              _buildDetailRow('Contact Person', agency.contactPerson ?? 'N/A'),
              _buildDetailRow('Phone', agency.phone ?? 'N/A'),
              _buildDetailRow('Email', agency.email ?? 'N/A'),
              const SizedBox(height: 16),
              const Text(
                'Previous Projects (Recent)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '• Rural Health Center - Completed (2024) - 95% satisfaction\n'
                  '• School Infrastructure - Completed (2024) - 92% satisfaction\n'
                  '• Community Center - In Progress (2024) - On schedule',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade300)),
          ),
        ],
      ),
    );
  }
}