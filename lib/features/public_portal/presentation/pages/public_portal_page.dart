import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/coverage_check_widget.dart';
import '../widgets/submit_complaint_widget.dart';
import '../widgets/public_feedback_widget.dart';
import '../widgets/open_data_explorer_widget.dart';
import '../widgets/community_engagement_widget.dart';
import '../widgets/transparency_awareness_widget.dart';

/// Public Portal Page
/// 
/// Main page integrating all Enhanced Public Portal features for citizen engagement
class PublicPortalPage extends ConsumerStatefulWidget {
  const PublicPortalPage({super.key});

  @override
  ConsumerState<PublicPortalPage> createState() => _PublicPortalPageState();
}

class _PublicPortalPageState extends ConsumerState<PublicPortalPage> {
  int _selectedIndex = 0;

  final List<PortalFeature> _features = [
    PortalFeature(
      icon: Icons.map,
      title: 'Coverage Check',
      description: 'Verify if your village falls under PM-AJAY projects',
      color: Colors.blue,
    ),
    PortalFeature(
      icon: Icons.report_problem,
      title: 'Submit Complaint',
      description: 'Report issues directly to Overwatch dashboard',
      color: Colors.red,
    ),
    PortalFeature(
      icon: Icons.rate_review,
      title: 'Public Feedback',
      description: 'Rate and review completed projects',
      color: Colors.green,
    ),
    PortalFeature(
      icon: Icons.dataset,
      title: 'Open Data',
      description: 'Query and visualize PM-AJAY datasets',
      color: Colors.teal,
    ),
    PortalFeature(
      icon: Icons.people,
      title: 'Community',
      description: 'Engage through ideas, volunteering, and events',
      color: Colors.purple,
    ),
    PortalFeature(
      icon: Icons.school,
      title: 'Learn & Updates',
      description: 'Tutorials, videos, FAQs, and notifications',
      color: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            extended: true,
            backgroundColor: Colors.grey.shade50,
            labelType: NavigationRailLabelType.none,
            leading: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primaryIndigo,
                    child: const Icon(
                      Icons.public,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Public Portal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PM-AJAY',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            destinations: _features.map((feature) {
              return NavigationRailDestination(
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: feature.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(feature.icon, color: feature.color),
                ),
                selectedIcon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: feature.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(feature.icon, color: Colors.white),
                ),
                label: Text(feature.title),
              );
            }).toList(),
          ),

          const VerticalDivider(thickness: 1, width: 1),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _features[_selectedIndex].icon,
                        color: _features[_selectedIndex].color,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _features[_selectedIndex].title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _features[_selectedIndex].description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: _showHelp,
                        tooltip: 'Help',
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: _showSettings,
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: const [
                      CoverageCheckWidget(),
                      SubmitComplaintWidget(),
                      PublicFeedbackWidget(),
                      OpenDataExplorerWidget(),
                      CommunityEngagementWidget(),
                      TransparencyAwarenessWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Floating Action Button for quick actions
      floatingActionButton: _selectedIndex != 1 // Don't show on Submit Complaint page
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() => _selectedIndex = 1);
              },
              icon: const Icon(Icons.report_problem),
              label: const Text('Report Issue'),
              backgroundColor: AppTheme.errorRed,
            )
          : null,
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help, color: AppTheme.primaryIndigo),
            const SizedBox(width: 12),
            const Text('Help & Support'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome to the PM-AJAY Public Portal!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'This portal provides citizens with comprehensive tools to:',
              ),
              const SizedBox(height: 8),
              _buildHelpItem('✓', 'Check if your village is covered under PM-AJAY projects'),
              _buildHelpItem('✓', 'Submit complaints and track their resolution'),
              _buildHelpItem('✓', 'Provide feedback on completed projects'),
              _buildHelpItem('✓', 'Explore open data and government statistics'),
              _buildHelpItem('✓', 'Engage with your community through ideas and events'),
              _buildHelpItem('✓', 'Learn through tutorials, videos, and FAQs'),
              const SizedBox(height: 16),
              const Text(
                'Need assistance?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildHelpItem('📞', 'Helpline: 1800-XXX-XXXX (Toll-free)'),
              _buildHelpItem('✉️', 'Email: support@pmajay.gov.in'),
              _buildHelpItem('🕐', 'Hours: Mon-Fri, 9 AM - 6 PM'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 5); // Go to Learn & Updates
            },
            icon: const Icon(Icons.school),
            label: const Text('View Tutorials'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings, color: AppTheme.primaryIndigo),
            const SizedBox(width: 12),
            const Text('Portal Settings'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive updates about projects and events'),
              value: true,
              onChanged: (value) {},
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Get important updates via email'),
              value: true,
              onChanged: (value) {},
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Anonymous Mode'),
              subtitle: const Text('Hide your identity in public interactions'),
              value: false,
              onChanged: (value) {},
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.language, color: AppTheme.primaryIndigo),
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Language selection
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.privacy_tip, color: AppTheme.primaryIndigo),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show privacy policy
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings saved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// Portal Feature model
class PortalFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  PortalFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}