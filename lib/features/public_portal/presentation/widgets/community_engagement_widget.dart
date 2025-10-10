import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

/// Community Engagement Widget
/// 
/// Provides features for idea submission, volunteer sign-up, events calendar, and forums
class CommunityEngagementWidget extends ConsumerStatefulWidget {
  const CommunityEngagementWidget({super.key});

  @override
  ConsumerState<CommunityEngagementWidget> createState() => _CommunityEngagementWidgetState();
}

class _CommunityEngagementWidgetState extends ConsumerState<CommunityEngagementWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final TextEditingController _ideaTitleController = TextEditingController();
  final TextEditingController _ideaDescriptionController = TextEditingController();
  final TextEditingController _volunteerNameController = TextEditingController();
  final TextEditingController _volunteerEmailController = TextEditingController();
  final TextEditingController _volunteerPhoneController = TextEditingController();
  final TextEditingController _forumSearchController = TextEditingController();
  
  List<IdeaSubmission> _submittedIdeas = [];
  List<VolunteerOpportunity> _volunteerOpportunities = [];
  List<CommunityEvent> _upcomingEvents = [];
  List<ForumPost> _forumPosts = [];
  
  String _selectedIdeaCategory = 'Infrastructure';
  String _selectedVolunteerArea = 'Education';
  
  final List<String> _ideaCategories = [
    'Infrastructure',
    'Education',
    'Healthcare',
    'Environment',
    'Technology',
    'Social Welfare',
  ];
  
  final List<String> _volunteerAreas = [
    'Education',
    'Healthcare',
    'Environment',
    'Community Service',
    'Skill Training',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ideaTitleController.dispose();
    _ideaDescriptionController.dispose();
    _volunteerNameController.dispose();
    _volunteerEmailController.dispose();
    _volunteerPhoneController.dispose();
    _forumSearchController.dispose();
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
              colors: [Colors.purple, Colors.purple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Community Engagement',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share ideas, volunteer, attend events, and connect with your community',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
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
              Tab(icon: Icon(Icons.lightbulb), text: 'Ideas'),
              Tab(icon: Icon(Icons.volunteer_activism), text: 'Volunteer'),
              Tab(icon: Icon(Icons.event), text: 'Events'),
              Tab(icon: Icon(Icons.forum), text: 'Forum'),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildIdeasTab(),
              _buildVolunteerTab(),
              _buildEventsTab(),
              _buildForumTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdeasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Submit Idea Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Submit Your Idea',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedIdeaCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _ideaCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedIdeaCategory = value!);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _ideaTitleController,
                    decoration: InputDecoration(
                      labelText: 'Idea Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _ideaDescriptionController,
                    decoration: InputDecoration(
                      labelText: 'Describe Your Idea',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 5,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitIdea,
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Idea'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Submitted Ideas Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Community Ideas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: 'Recent',
                items: ['Recent', 'Popular', 'Most Voted'].map((sort) {
                  return DropdownMenuItem(value: sort, child: Text(sort));
                }).toList(),
                onChanged: (value) {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_submittedIdeas.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No ideas submitted yet. Be the first!',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _submittedIdeas.map((idea) {
                return _buildIdeaCard(idea);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildIdeaCard(IdeaSubmission idea) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    idea.category,
                    style: TextStyle(
                      color: AppTheme.primaryIndigo,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.thumb_up_outlined, size: 20, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('${idea.upvotes}'),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              idea.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              idea.description,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(idea.authorName[0].toUpperCase()),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      idea.authorName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${idea.timestamp.day}/${idea.timestamp.month}/${idea.timestamp.year}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up_outlined, size: 18),
                  label: const Text('Upvote'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sign Up Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Become a Volunteer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _volunteerNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _volunteerEmailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _volunteerPhoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedVolunteerArea,
                    decoration: InputDecoration(
                      labelText: 'Area of Interest',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _volunteerAreas.map((area) {
                      return DropdownMenuItem(value: area, child: Text(area));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedVolunteerArea = value!);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitVolunteerApplication,
                      icon: const Icon(Icons.volunteer_activism),
                      label: const Text('Sign Up as Volunteer'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Volunteer Opportunities
          const Text(
            'Volunteer Opportunities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Column(
            children: _volunteerOpportunities.map((opportunity) {
              return _buildOpportunityCard(opportunity);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(VolunteerOpportunity opportunity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work, color: AppTheme.primaryIndigo),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    opportunity.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(opportunity.description),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(opportunity.location),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(opportunity.duration),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Learn More'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Apply Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_upcomingEvents.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No upcoming events',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _upcomingEvents.map((event) {
                return _buildEventCard(event);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard(CommunityEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        event.date.day.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryIndigo,
                        ),
                      ),
                      Text(
                        _getMonthName(event.date.month),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryIndigo,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(event.time),
                          const SizedBox(width: 12),
                          Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text('${event.attendees} attending'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(event.description),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(child: Text(event.location)),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check),
                    label: const Text('Register'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForumTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _forumSearchController,
            decoration: InputDecoration(
              hintText: 'Search discussions...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _forumPosts.length,
            itemBuilder: (context, index) {
              return _buildForumPostCard(_forumPosts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForumPostCard(ForumPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(post.authorName[0].toUpperCase()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${post.authorName} • ${post.replies} replies',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
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

  void _loadData() {
    // Mock data
    setState(() {
      _submittedIdeas = [
        IdeaSubmission(
          id: '1',
          title: 'Mobile Health Clinic for Remote Villages',
          description: 'Deploy mobile health units to provide basic healthcare in remote areas',
          category: 'Healthcare',
          authorName: 'Dr. Sharma',
          upvotes: 45,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
      
      _volunteerOpportunities = [
        VolunteerOpportunity(
          id: '1',
          title: 'Teaching Assistant - Village School',
          description: 'Help teach English and Math to primary school students',
          location: 'Village A, District X',
          duration: '3 months',
        ),
      ];
      
      _upcomingEvents = [
        CommunityEvent(
          id: '1',
          title: 'Community Health Camp',
          description: 'Free health checkups and consultations for all residents',
          date: DateTime.now().add(const Duration(days: 7)),
          time: '9:00 AM - 5:00 PM',
          location: 'Village Community Center',
          attendees: 120,
        ),
      ];
      
      _forumPosts = [
        ForumPost(
          id: '1',
          title: 'How to apply for PM-AJAY benefits?',
          authorName: 'Rajesh Kumar',
          replies: 12,
          views: 234,
        ),
      ];
    });
  }

  void _submitIdea() {
    if (_ideaTitleController.text.isEmpty || _ideaDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Idea submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    _ideaTitleController.clear();
    _ideaDescriptionController.clear();
  }

  void _submitVolunteerApplication() {
    if (_volunteerNameController.text.isEmpty || 
        _volunteerEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Volunteer application submitted!'),
        backgroundColor: Colors.green,
      ),
    );

    _volunteerNameController.clear();
    _volunteerEmailController.clear();
    _volunteerPhoneController.clear();
  }

  String _getMonthName(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}

// Models
class IdeaSubmission {
  final String id;
  final String title;
  final String description;
  final String category;
  final String authorName;
  final int upvotes;
  final DateTime timestamp;

  IdeaSubmission({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.authorName,
    required this.upvotes,
    required this.timestamp,
  });
}

class VolunteerOpportunity {
  final String id;
  final String title;
  final String description;
  final String location;
  final String duration;

  VolunteerOpportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.duration,
  });
}

class CommunityEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final int attendees;

  CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.attendees,
  });
}

class ForumPost {
  final String id;
  final String title;
  final String authorName;
  final int replies;
  final int views;

  ForumPost({
    required this.id,
    required this.title,
    required this.authorName,
    required this.replies,
    required this.views,
  });
}