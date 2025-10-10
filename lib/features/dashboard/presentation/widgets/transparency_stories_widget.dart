import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Transparency Stories Widget
/// 
/// Before/after comparison sliders with video testimonials showcasing
/// project impact and transformation.
class TransparencyStoriesWidget extends StatefulWidget {
  final String userId;
  
  const TransparencyStoriesWidget({
    super.key,
    required this.userId,
  });

  @override
  State<TransparencyStoriesWidget> createState() => 
      _TransparencyStoriesWidgetState();
}

class _TransparencyStoriesWidgetState extends State<TransparencyStoriesWidget> {
  String _selectedFilter = 'all'; // 'all', 'water', 'sanitation', 'infrastructure'

  final List<TransparencyStory> _mockStories = [
    TransparencyStory(
      id: 'story_001',
      title: 'Village Transformation: Clean Water Access',
      location: 'Rampur Village, North District',
      category: StoryCategory.water,
      completionDate: DateTime(2025, 9, 15),
      budget: 2500000,
      beneficiaries: 1200,
      beforeDescription: 'Villagers had to walk 3 km daily to fetch water from contaminated sources. High rates of waterborne diseases.',
      afterDescription: 'Modern water supply system with 24/7 clean water access. 90% reduction in waterborne diseases.',
      beforeImageUrl: 'before_water_1.jpg',
      afterImageUrl: 'after_water_1.jpg',
      videoTestimonialUrl: 'testimonial_rampur.mp4',
      testimonials: [
        Testimonial(
          name: 'Rajesh Kumar',
          role: 'Village Head',
          quote: 'This project has transformed our lives. Children no longer miss school to fetch water, and health has improved dramatically.',
        ),
        Testimonial(
          name: 'Priya Sharma',
          role: 'Local Teacher',
          quote: 'The clean water supply has been a blessing. Our students are healthier and more focused on their studies.',
        ),
      ],
      impactMetrics: [
        ImpactMetric('Water Quality', 'Improved from 45% to 98%', Icons.water_drop, Colors.blue),
        ImpactMetric('Daily Access', 'Increased from 2 hrs to 24 hrs', Icons.schedule, Colors.green),
        ImpactMetric('Disease Rate', 'Reduced by 90%', Icons.health_and_safety, Colors.red),
      ],
    ),
    TransparencyStory(
      id: 'story_002',
      title: 'Community Sanitation Revolution',
      location: 'Greenfield Township, South District',
      category: StoryCategory.sanitation,
      completionDate: DateTime(2025, 8, 20),
      budget: 1800000,
      beneficiaries: 850,
      beforeDescription: 'Open defecation was common. No proper sanitation facilities. Health hazards and dignity issues.',
      afterDescription: 'Modern community toilets with proper waste management. 100% open-defecation-free status achieved.',
      beforeImageUrl: 'before_sanitation_1.jpg',
      afterImageUrl: 'after_sanitation_1.jpg',
      videoTestimonialUrl: 'testimonial_greenfield.mp4',
      testimonials: [
        Testimonial(
          name: 'Meera Reddy',
          role: 'Resident',
          quote: 'The new toilets have restored our dignity and safety. Women and children can now use facilities without fear.',
        ),
        Testimonial(
          name: 'Dr. Amit Patel',
          role: 'Local Health Officer',
          quote: 'We have seen a significant decrease in sanitation-related diseases since these facilities were built.',
        ),
      ],
      impactMetrics: [
        ImpactMetric('ODF Status', '100% Achieved', Icons.check_circle, Colors.green),
        ImpactMetric('Toilet Access', 'From 0 to 15 units', Icons.wc, Colors.purple),
        ImpactMetric('User Satisfaction', '95% Positive', Icons.sentiment_satisfied, Colors.orange),
      ],
    ),
    TransparencyStory(
      id: 'story_003',
      title: 'Rural Water Distribution Network',
      location: 'Multiple Villages, East District',
      category: StoryCategory.infrastructure,
      completionDate: DateTime(2025, 10, 5),
      budget: 4500000,
      beneficiaries: 3500,
      beforeDescription: 'Seven villages relied on a single well. Water scarcity during summer. Long queues and conflicts.',
      afterDescription: 'Integrated pipeline network connecting all villages. Consistent supply throughout the year.',
      beforeImageUrl: 'before_infrastructure_1.jpg',
      afterImageUrl: 'after_infrastructure_1.jpg',
      videoTestimonialUrl: 'testimonial_east_villages.mp4',
      testimonials: [
        Testimonial(
          name: 'Vikram Singh',
          role: 'District Coordinator',
          quote: 'This network has ended decades of water scarcity. All seven villages now have reliable access.',
        ),
        Testimonial(
          name: 'Anita Devi',
          role: 'Women\'s Group Leader',
          quote: 'No more fights over water. Women can now focus on education and income-generating activities.',
        ),
      ],
      impactMetrics: [
        ImpactMetric('Villages Connected', '7 Villages', Icons.hub, Colors.blue),
        ImpactMetric('Pipeline Length', '12 km installed', Icons.route, Colors.green),
        ImpactMetric('Water Availability', '365 days/year', Icons.calendar_today, Colors.orange),
      ],
    ),
  ];

  List<TransparencyStory> get _filteredStories {
    if (_selectedFilter == 'all') return _mockStories;
    return _mockStories.where((story) => story.category.name == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: _buildStoriesList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.publicColor, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_stories, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transparency Stories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'See the real impact of projects through before/after stories',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final totalStories = _mockStories.length;
    final totalBeneficiaries = _mockStories.fold(0, (sum, s) => sum + s.beneficiaries);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                totalStories.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Stories',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              Text(
                '${(totalBeneficiaries / 1000).toStringAsFixed(1)}K',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Lives Changed',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'all', label: Text('All Stories')),
          ButtonSegment(value: 'water', label: Text('Water Supply')),
          ButtonSegment(value: 'sanitation', label: Text('Sanitation')),
          ButtonSegment(value: 'infrastructure', label: Text('Infrastructure')),
        ],
        selected: {_selectedFilter},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() => _selectedFilter = newSelection.first);
        },
      ),
    );
  }

  Widget _buildStoriesList() {
    if (_filteredStories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No stories found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredStories.length,
      itemBuilder: (context, index) {
        return _buildStoryCard(_filteredStories[index]);
      },
    );
  }

  Widget _buildStoryCard(TransparencyStory story) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.publicColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(story.location),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(_formatDate(story.completionDate)),
                  ],
                ),
              ],
            ),
          ),

          // Before/After Comparison
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transformation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildBeforeAfterCard(
                        'Before',
                        story.beforeDescription,
                        story.beforeImageUrl,
                        Colors.red.shade50,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.arrow_forward, color: AppTheme.publicColor, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBeforeAfterCard(
                        'After',
                        story.afterDescription,
                        story.afterImageUrl,
                        Colors.green.shade50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          // Impact Metrics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Impact Metrics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: story.impactMetrics.map((metric) => 
                    _buildMetricChip(metric)
                  ).toList(),
                ),
              ],
            ),
          ),

          const Divider(),

          // Project Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Budget',
                    '₹${(story.budget / 100000).toStringAsFixed(1)}L',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Beneficiaries',
                    story.beneficiaries.toString(),
                    Icons.people,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Testimonials
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Community Voices',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => _playVideoTestimonial(story),
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('Watch Video'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...story.testimonials.map((testimonial) => 
                  _buildTestimonialCard(testimonial)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeAfterCard(String label, String description, String imageUrl, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.image, size: 40, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(ImpactMetric metric) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: metric.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: metric.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(metric.icon, size: 16, color: metric.color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                metric.value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: metric.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(Testimonial testimonial) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.publicColor,
                  child: Text(
                    testimonial.name[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        testimonial.role,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.format_quote, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '"${testimonial.quote}"',
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playVideoTestimonial(TransparencyStory story) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Video Testimonial - ${story.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 400,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_outline, size: 80, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Video Player',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              story.videoTestimonialUrl,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Data Models
enum StoryCategory { water, sanitation, infrastructure }

class TransparencyStory {
  final String id;
  final String title;
  final String location;
  final StoryCategory category;
  final DateTime completionDate;
  final int budget;
  final int beneficiaries;
  final String beforeDescription;
  final String afterDescription;
  final String beforeImageUrl;
  final String afterImageUrl;
  final String videoTestimonialUrl;
  final List<Testimonial> testimonials;
  final List<ImpactMetric> impactMetrics;

  TransparencyStory({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.completionDate,
    required this.budget,
    required this.beneficiaries,
    required this.beforeDescription,
    required this.afterDescription,
    required this.beforeImageUrl,
    required this.afterImageUrl,
    required this.videoTestimonialUrl,
    required this.testimonials,
    required this.impactMetrics,
  });
}

class Testimonial {
  final String name;
  final String role;
  final String quote;

  Testimonial({
    required this.name,
    required this.role,
    required this.quote,
  });
}

class ImpactMetric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  ImpactMetric(this.label, this.value, this.icon, this.color);
}