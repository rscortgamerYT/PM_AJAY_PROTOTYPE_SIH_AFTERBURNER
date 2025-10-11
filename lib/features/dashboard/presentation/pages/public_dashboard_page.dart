import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/submit_complaint_widget.dart';
import '../widgets/project_ratings_feedback_widget.dart';
import '../widgets/open_data_explorer_widget.dart';
import '../widgets/citizen_idea_hub_widget.dart';
import '../widgets/transparency_stories_widget.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/widgets/dashboard_components.dart';

class PublicDashboardPage extends ConsumerStatefulWidget {
  const PublicDashboardPage({super.key});

  @override
  ConsumerState<PublicDashboardPage> createState() => _PublicDashboardPageState();
}

class _PublicDashboardPageState extends ConsumerState<PublicDashboardPage> {
  int _selectedIndex = 0;

  // Mock stats data
  final Map<String, dynamic> _statsData = {
    'activeProjects': 1245,
    'statesParticipating': 28,
    'beneficiaries': 2500000,
    'citizenRatings': 4.6,
  };

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppDesignSystem.skyBlue,
            AppDesignSystem.vibrantTeal,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'PM-AJAY Platform',
              style: AppDesignSystem.displayMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Transparent governance and community participation',
              style: AppDesignSystem.titleLarge.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  '${_statsData['activeProjects']}+',
                  'Active Projects',
                  Icons.work,
                ),
                _buildStatCard(
                  '${_statsData['statesParticipating']}',
                  'States',
                  Icons.map,
                ),
                _buildStatCard(
                  '${(_statsData['beneficiaries'] / 1000000).toStringAsFixed(1)}M+',
                  'Beneficiaries',
                  Icons.people,
                ),
                _buildStatCard(
                  '${_statsData['citizenRatings']}★',
                  'Citizen Rating',
                  Icons.star,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppDesignSystem.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppDesignSystem.labelMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(),
          Padding(
            padding: const EdgeInsets.all(AppDesignSystem.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardSectionHeader(
                  title: 'Get Involved',
                  subtitle: 'Participate in transparent governance',
                ),
                const SizedBox(height: AppDesignSystem.spacingMedium),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 250,
                          child: _buildActionCard(
                            'Check Coverage',
                            'See if PM-AJAY projects are in your area',
                            Icons.search,
                            AppDesignSystem.deepIndigo,
                            () => setState(() => _selectedIndex = 1),
                          ),
                        ),
                        const SizedBox(width: AppDesignSystem.spacingMedium),
                        SizedBox(
                          width: 250,
                          child: _buildActionCard(
                            'Report Issues',
                            'Submit complaints and feedback',
                            Icons.report_problem,
                            AppDesignSystem.sunsetOrange,
                            () => setState(() => _selectedIndex = 2),
                          ),
                        ),
                        const SizedBox(width: AppDesignSystem.spacingMedium),
                        SizedBox(
                          width: 250,
                          child: _buildActionCard(
                            'Explore Data',
                            'Access transparent project data',
                            Icons.data_exploration,
                            AppDesignSystem.vibrantTeal,
                            () => setState(() => _selectedIndex = 3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppDesignSystem.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: AppDesignSystem.neutral600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverageChecker() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: AppTheme.secondaryBlue),
            const SizedBox(height: 16),
            const Text(
              'Coverage Checker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check if PM-AJAY projects are available in your area',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitComplaint() {
    return const SubmitComplaintWidget(userId: 'public_user');
  }

  Widget _buildProjectRatings() {
    return const ProjectRatingsFeedbackWidget(userId: 'public_user');
  }

  Widget _buildOpenDataExplorer() {
    return const OpenDataExplorerWidget(userId: 'public_user');
  }

  Widget _buildCitizenIdeaHub() {
    return const CitizenIdeaHubWidget(userId: 'public_user');
  }

  Widget _buildTransparencyStories() {
    return const TransparencyStoriesWidget(userId: 'public_user');
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomePage(),
      _buildCoverageChecker(),
      _buildSubmitComplaint(),
      _buildOpenDataExplorer(),
    ];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppDesignSystem.skyBlue,
                AppDesignSystem.vibrantTeal,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'PM-AJAY Public Portal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Public Portal'),
                  content: const Text(
                    'Welcome to the PM-AJAY Platform Public Portal. '
                    'This portal provides transparent access to project information, '
                    'allows you to check coverage in your area, submit complaints, '
                    'and explore open data.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Coverage',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_problem_outlined),
            selectedIcon: Icon(Icons.report_problem),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.data_exploration_outlined),
            selectedIcon: Icon(Icons.data_exploration),
            label: 'Data',
          ),
        ],
      ),
    );
  }
}