import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/submit_complaint_widget.dart';
import '../widgets/project_ratings_feedback_widget.dart';
import '../widgets/open_data_explorer_widget.dart';
import '../widgets/citizen_idea_hub_widget.dart';
import '../widgets/transparency_stories_widget.dart';

class PublicDashboardPage extends ConsumerStatefulWidget {
  const PublicDashboardPage({super.key});

  @override
  ConsumerState<PublicDashboardPage> createState() => _PublicDashboardPageState();
}

class _PublicDashboardPageState extends ConsumerState<PublicDashboardPage> {
  int _selectedIndex = 0;

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
      _buildCoverageChecker(),
      _buildSubmitComplaint(),
      _buildProjectRatings(),
      _buildOpenDataExplorer(),
      _buildCitizenIdeaHub(),
      _buildTransparencyStories(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Dashboard'),
        backgroundColor: AppTheme.secondaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Public Dashboard'),
                  content: const Text(
                    'Welcome to the PM-AJAY Platform Public Dashboard. '
                    'This portal provides transparent access to project information, '
                    'allows you to check coverage in your area, submit complaints, '
                    'rate projects, explore open data, share ideas, and view '
                    'transparency stories from the community.',
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
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Coverage',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_problem_outlined),
            selectedIcon: Icon(Icons.report_problem),
            label: 'Complaint',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star),
            label: 'Ratings',
          ),
          NavigationDestination(
            icon: Icon(Icons.data_exploration_outlined),
            selectedIcon: Icon(Icons.data_exploration),
            label: 'Open Data',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb),
            label: 'Ideas',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Stories',
          ),
        ],
      ),
    );
  }
}