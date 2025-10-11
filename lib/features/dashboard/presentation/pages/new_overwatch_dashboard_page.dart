import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/overwatch_project_model.dart';
import '../../models/overwatch_fund_flow_model.dart';
import '../../models/milestone_claim_model.dart';
import '../../data/overwatch_mock_data.dart';
import '../../data/milestone_claim_mock_data.dart';
import '../widgets/overwatch_project_selector_widget.dart';
import '../widgets/overwatch_fund_flow_sankey_widget.dart';
import '../widgets/overwatch/active_projects_timeline_widget.dart';
import '../widgets/overwatch/overwatch_map_widget.dart';
import '../widgets/overwatch/overwatch_analytics_charts.dart';
import '../widgets/overwatch/overwatch_flagging_dialog.dart';
import '../widgets/overwatch/milestone_claim_approval_widget.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/widgets/event_calendar_widget.dart';
import '../../../../core/widgets/dashboard_switcher_widget.dart';

class NewOverwatchDashboardPage extends ConsumerStatefulWidget {
  const NewOverwatchDashboardPage({super.key});

  @override
  ConsumerState<NewOverwatchDashboardPage> createState() =>
      _NewOverwatchDashboardPageState();
}

class _NewOverwatchDashboardPageState
    extends ConsumerState<NewOverwatchDashboardPage> {
  late List<OverwatchProject> _projects;
  OverwatchProject? _selectedProject;
  CompleteFundFlowData? _fundFlowData;
  int _selectedTabIndex = 0;
  late List<MilestoneClaim> _claims;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _projects = OverwatchMockData.generateMockProjects();
    _claims = MilestoneClaimMockData.generateMockClaims();
  }

  void _onProjectSelect(OverwatchProject project) {
    setState(() {
      _selectedProject = project;
      _fundFlowData = OverwatchMockData.generateFundFlowForProject(project);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildKeyMetrics(),
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),
          const EventCalendarWidget(),
          const DashboardSwitcherWidget(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppDesignSystem.sunsetOrange,
              AppDesignSystem.error,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overwatch Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          Text(
            'Complete oversight and monitoring of PM-AJAY projects',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.notifications, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                '12 Active Alerts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.download, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildKeyMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: _buildMetricCard(
                  'Total Projects',
                  '1,247',
                  Icons.visibility,
                  AppDesignSystem.deepIndigo,
                  '+12%',
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 200,
                child: _buildMetricCard(
                  'Flagged Projects',
                  '23',
                  Icons.flag,
                  AppDesignSystem.error,
                  '-5%',
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 200,
                child: _buildMetricCard(
                  'Fund Utilization',
                  '78.5%',
                  Icons.trending_up,
                  AppDesignSystem.success,
                  '+2.3%',
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 200,
                child: _buildMetricCard(
                  'High Risk',
                  '47',
                  Icons.warning,
                  AppDesignSystem.warning,
                  '+8%',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppDesignSystem.radiusMedium,
        border: Border.all(
          color: AppDesignSystem.neutral300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppDesignSystem.labelSmall.copyWith(
                    color: AppDesignSystem.neutral600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppDesignSystem.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: AppDesignSystem.labelSmall.copyWith(
              color: AppDesignSystem.neutral500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedTabIndex == 0) ...[
            OverwatchProjectSelectorWidget(
              projects: _projects,
              onProjectSelect: _onProjectSelect,
              selectedProject: _selectedProject,
            ),
            if (_selectedProject != null && _fundFlowData != null) ...[
              OverwatchFundFlowSankeyWidget(
                fundFlowData: _fundFlowData!,
                onNodeTap: (node) {
                  // Handle node tap
                },
              ),
            ] else ...[
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: AppDesignSystem.radiusLarge,
                  border: Border.all(
                    color: AppDesignSystem.neutral300,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.map,
                        size: 64,
                        color: AppDesignSystem.neutral400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select a project to view fund flow',
                        style: AppDesignSystem.headlineSmall.copyWith(
                          color: AppDesignSystem.neutral600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose any project from the selector above',
                        style: AppDesignSystem.bodySmall.copyWith(
                          color: AppDesignSystem.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
          if (_selectedTabIndex == 1) ...[
            ActiveProjectsTimelineWidget(
              projects: _projects,
              onProjectSelect: _onProjectSelect,
            ),
            const SizedBox(height: 24),
            _buildProjectAnalytics(),
          ],
          if (_selectedTabIndex == 2) ...[
            _buildGeographicView(),
          ],
          if (_selectedTabIndex == 3) ...[
            _buildFlaggingReports(),
          ],
          if (_selectedTabIndex == 4) ...[
            _buildMilestoneClaimApproval(),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectAnalytics() {
    return OverwatchAnalyticsCharts(projects: _projects);
  }

  Widget _buildGeographicView() {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppDesignSystem.radiusLarge,
        border: Border.all(
          color: AppDesignSystem.neutral300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Geographic Project Distribution',
              style: AppDesignSystem.headlineMedium,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: OverwatchMapWithFilters(
                projects: _projects,
                onProjectSelected: (projectId) {
                  final project = _projects.firstWhere(
                    (p) => p.id == projectId,
                    orElse: () => _projects.first,
                  );
                  _onProjectSelect(project);
                  // Switch to Fund Flow tab to show selected project details
                  setState(() {
                    _selectedTabIndex = 0;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlaggingReports() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppDesignSystem.radiusLarge,
        border: Border.all(
          color: AppDesignSystem.neutral300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Flagging Reports & Investigations',
                style: AppDesignSystem.headlineMedium,
              ),
              ElevatedButton.icon(
                onPressed: _showFlaggingDialog,
                icon: const Icon(Icons.flag),
                label: const Text('Flag Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignSystem.error,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFlaggedItem(
            'Hostel Construction - Nagpur',
            'Delayed milestone submission, fund utilization mismatch',
            'High Priority',
            AppDesignSystem.error,
          ),
          const SizedBox(height: 16),
          _buildFlaggedItem(
            'Community Center - Aurangabad',
            'Evidence quality issues, contractor concerns',
            'Medium Priority',
            AppDesignSystem.warning,
          ),
        ],
      ),
    );
  }

  void _showFlaggingDialog() {
    if (_selectedProject == null && _projects.isNotEmpty) {
      setState(() {
        _selectedProject = _projects.first;
      });
    }

    if (_selectedProject != null) {
      showDialog(
        context: context,
        builder: (context) => OverwatchFlaggingDialog(
          project: _selectedProject!,
          onFlag: (reason, priority) {
            // Handle flag submission
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Project flagged with ${priority.label} priority'),
                backgroundColor: priority.color,
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildFlaggedItem(
    String title,
    String description,
    String priority,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
        color: color.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppDesignSystem.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.neutral600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              priority,
              style: AppDesignSystem.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneClaimApproval() {
    return MilestoneClaimApprovalWidget(
      claims: _claims,
      onClaimAction: (claim, newStatus, notes) {
        setState(() {
          final index = _claims.indexWhere((c) => c.id == claim.id);
          if (index != -1) {
            _claims[index] = MilestoneClaim(
              id: claim.id,
              projectId: claim.projectId,
              projectName: claim.projectName,
              companyName: claim.companyName,
              companyId: claim.companyId,
              milestoneNumber: claim.milestoneNumber,
              milestoneDescription: claim.milestoneDescription,
              claimedAmount: claim.claimedAmount,
              approvedAmount: claim.approvedAmount,
              submittedBy: claim.submittedBy,
              submittedAt: claim.submittedAt,
              status: newStatus,
              documents: claim.documents,
              fraudAnalysis: claim.fraudAnalysis,
              milestoneDetails: claim.milestoneDetails,
              reviewedAt: DateTime.now(),
              reviewerNotes: notes,
            );
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Claim ${newStatus.label} successfully'),
            backgroundColor: newStatus.color,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: _selectedTabIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedTabIndex = index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Fund Flow',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: 'Projects',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Maps',
        ),
        NavigationDestination(
          icon: Icon(Icons.flag_outlined),
          selectedIcon: Icon(Icons.flag),
          label: 'Reports',
        ),
        NavigationDestination(
          icon: Icon(Icons.approval_outlined),
          selectedIcon: Icon(Icons.approval),
          label: 'Claims',
        ),
      ],
    );
  }
}