import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

/// Transparency & Awareness Widget
/// 
/// Provides tutorials, explainer videos, FAQs, and educational content about PM-AJAY
class TransparencyAwarenessWidget extends ConsumerStatefulWidget {
  const TransparencyAwarenessWidget({super.key});

  @override
  ConsumerState<TransparencyAwarenessWidget> createState() => _TransparencyAwarenessWidgetState();
}

class _TransparencyAwarenessWidgetState extends ConsumerState<TransparencyAwarenessWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<Tutorial> _tutorials = [];
  List<ExplainerVideo> _videos = [];
  List<FAQ> _faqs = [];
  List<Notification> _notifications = [];
  
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All',
    'Getting Started',
    'Benefits',
    'Application Process',
    'Projects',
    'Complaints',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.orange.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transparency & Awareness',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Learn about PM-AJAY through tutorials, videos, and FAQs',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tutorials, videos, FAQs...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => _performSearch(value),
          ),
        ),

        // Tabs
        Container(
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
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryIndigo,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryIndigo,
            tabs: const [
              Tab(icon: Icon(Icons.school), text: 'Tutorials'),
              Tab(icon: Icon(Icons.video_library), text: 'Videos'),
              Tab(icon: Icon(Icons.help), text: 'FAQs'),
              Tab(icon: Icon(Icons.notifications), text: 'Updates'),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTutorialsTab(),
              _buildVideosTab(),
              _buildFAQsTab(),
              _buildNotificationsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTutorialsTab() {
    return Column(
      children: [
        // Category Filter
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category);
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: AppTheme.primaryIndigo.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryIndigo : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _tutorials.length,
            itemBuilder: (context, index) {
              return _buildTutorialCard(_tutorials[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTutorialCard(Tutorial tutorial) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openTutorial(tutorial),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(tutorial.difficulty).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTutorialIcon(tutorial.category),
                  color: _getDifficultyColor(tutorial.difficulty),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorial.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tutorial.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(tutorial.difficulty).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tutorial.difficulty,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDifficultyColor(tutorial.difficulty),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          tutorial.duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideosTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        return _buildVideoCard(_videos[index]);
      },
    );
  }

  Widget _buildVideoCard(ExplainerVideo video) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _playVideo(video),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryIndigo, AppTheme.secondaryBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      video.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${video.views}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _faqs.length,
      itemBuilder: (context, index) {
        return _buildFAQCard(_faqs[index]);
      },
    );
  }

  Widget _buildFAQCard(FAQ faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryIndigo.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.help_outline,
            color: AppTheme.primaryIndigo,
            size: 20,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq.answer,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Was this helpful?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_up_outlined, size: 16),
                      label: const Text('Yes'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_down_outlined, size: 16),
                      label: const Text('No'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _subscribeToNotifications,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Enable Push Notifications'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(_notifications[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(Notification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryIndigo,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }

  void _loadContent() {
    setState(() {
      _tutorials = [
        Tutorial(
          id: '1',
          title: 'Getting Started with PM-AJAY',
          description: 'Learn the basics of PM-AJAY scheme and how to get started',
          category: 'Getting Started',
          difficulty: 'Beginner',
          duration: '10 min',
        ),
        Tutorial(
          id: '2',
          title: 'How to Check Project Coverage',
          description: 'Step-by-step guide to check if your area is covered under PM-AJAY',
          category: 'Projects',
          difficulty: 'Beginner',
          duration: '5 min',
        ),
        Tutorial(
          id: '3',
          title: 'Filing a Complaint',
          description: 'Learn how to submit and track complaints through the portal',
          category: 'Complaints',
          difficulty: 'Intermediate',
          duration: '15 min',
        ),
        Tutorial(
          id: '4',
          title: 'Understanding Benefits',
          description: 'Comprehensive guide to all benefits available under PM-AJAY',
          category: 'Benefits',
          difficulty: 'Intermediate',
          duration: '20 min',
        ),
      ];

      _videos = [
        ExplainerVideo(
          id: '1',
          title: 'What is PM-AJAY?',
          description: 'Introduction to the PM-AJAY scheme',
          duration: '3:45',
          views: 12500,
        ),
        ExplainerVideo(
          id: '2',
          title: 'Project Implementation Process',
          description: 'How PM-AJAY projects are planned and executed',
          duration: '5:20',
          views: 8900,
        ),
        ExplainerVideo(
          id: '3',
          title: 'Beneficiary Registration',
          description: 'Step-by-step registration process',
          duration: '4:15',
          views: 15600,
        ),
        ExplainerVideo(
          id: '4',
          title: 'Tracking Your Application',
          description: 'How to monitor application status',
          duration: '2:50',
          views: 7800,
        ),
      ];

      _faqs = [
        FAQ(
          id: '1',
          question: 'What is PM-AJAY?',
          answer: 'PM-AJAY (Prime Minister Adivasi Jan Arogya Yojana) is a comprehensive scheme aimed at improving healthcare, education, and infrastructure for tribal communities across India.',
          category: 'Getting Started',
        ),
        FAQ(
          id: '2',
          question: 'How do I check if my village is covered?',
          answer: 'Use the Coverage Check feature on the portal. Enter your PIN code or drop a pin on the map to see nearby PM-AJAY projects.',
          category: 'Projects',
        ),
        FAQ(
          id: '3',
          question: 'Can I submit complaints anonymously?',
          answer: 'Yes, you can choose to submit complaints anonymously. However, providing contact details helps us follow up on your complaint more effectively.',
          category: 'Complaints',
        ),
        FAQ(
          id: '4',
          question: 'How long does it take to process applications?',
          answer: 'Applications are typically processed within 15-30 days. You can track your application status through the portal using your application ID.',
          category: 'Application Process',
        ),
        FAQ(
          id: '5',
          question: 'What documents are required for registration?',
          answer: 'Required documents include: Aadhaar card, tribal certificate, proof of residence, and bank account details. Additional documents may be needed based on the specific benefit you\'re applying for.',
          category: 'Application Process',
        ),
      ];

      _notifications = [
        Notification(
          id: '1',
          title: 'New Project in Your Area',
          message: 'A new healthcare facility project has been approved for Village A',
          type: 'info',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
        Notification(
          id: '2',
          title: 'Portal Maintenance',
          message: 'The portal will be under maintenance on Sunday from 2 AM to 6 AM',
          type: 'warning',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
      ];
    });
  }

  void _performSearch(String query) {
    // Implement search functionality
  }

  void _openTutorial(Tutorial tutorial) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tutorial.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tutorial.description),
              const SizedBox(height: 16),
              const Text(
                'Tutorial content would be displayed here with step-by-step instructions, images, and interactive elements.',
              ),
            ],
          ),
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
                const SnackBar(content: Text('Tutorial completed!')),
              );
            },
            child: const Text('Mark as Complete'),
          ),
        ],
      ),
    );
  }

  void _playVideo(ExplainerVideo video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(video.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryIndigo, AppTheme.secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_filled,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(video.description),
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

  void _subscribeToNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Push notifications enabled successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return AppTheme.successGreen;
      case 'Intermediate':
        return AppTheme.warningOrange;
      case 'Advanced':
        return AppTheme.errorRed;
      default:
        return Colors.grey;
    }
  }

  IconData _getTutorialIcon(String category) {
    switch (category) {
      case 'Getting Started':
        return Icons.rocket_launch;
      case 'Benefits':
        return Icons.card_giftcard;
      case 'Application Process':
        return Icons.description;
      case 'Projects':
        return Icons.work;
      case 'Complaints':
        return Icons.report_problem;
      default:
        return Icons.school;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'info':
        return AppTheme.secondaryBlue;
      case 'warning':
        return AppTheme.warningOrange;
      case 'success':
        return AppTheme.successGreen;
      case 'error':
        return AppTheme.errorRed;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Models
class Tutorial {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final String duration;

  Tutorial({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.duration,
  });
}

class ExplainerVideo {
  final String id;
  final String title;
  final String description;
  final String duration;
  final int views;

  ExplainerVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.views,
  });
}

class FAQ {
  final String id;
  final String question;
  final String answer;
  final String category;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });
}

class Notification {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });
}