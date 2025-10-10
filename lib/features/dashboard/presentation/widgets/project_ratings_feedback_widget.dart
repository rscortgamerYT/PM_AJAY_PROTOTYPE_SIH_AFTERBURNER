import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Project Ratings & Feedback Widget
/// 
/// 5-star rating system with sentiment analysis for citizen feedback
/// on completed and ongoing projects.
class ProjectRatingsFeedbackWidget extends StatefulWidget {
  final String userId;
  
  const ProjectRatingsFeedbackWidget({
    super.key,
    required this.userId,
  });

  @override
  State<ProjectRatingsFeedbackWidget> createState() => 
      _ProjectRatingsFeedbackWidgetState();
}

class _ProjectRatingsFeedbackWidgetState 
    extends State<ProjectRatingsFeedbackWidget> {
  
  String _selectedFilter = 'all'; // 'all', 'completed', 'ongoing'
  String _sortBy = 'recent'; // 'recent', 'rating', 'popular'

  final List<ProjectRating> _mockProjects = [
    ProjectRating(
      id: 'proj_001',
      name: 'Water Supply - Phase 1',
      district: 'North District',
      status: ProjectStatus.completed,
      completionDate: DateTime(2025, 9, 15),
      averageRating: 4.5,
      totalRatings: 156,
      sentimentScore: 0.85,
      reviews: [
        Review(
          id: 'rev_001',
          userName: 'Rajesh Kumar',
          rating: 5,
          comment: 'Excellent work! Water supply is now regular and quality is good.',
          date: DateTime(2025, 10, 8),
          sentiment: Sentiment.positive,
          helpful: 45,
        ),
        Review(
          id: 'rev_002',
          userName: 'Priya Singh',
          rating: 4,
          comment: 'Good project but took longer than expected to complete.',
          date: DateTime(2025, 10, 5),
          sentiment: Sentiment.neutral,
          helpful: 23,
        ),
      ],
      categories: {
        'Quality': 4.6,
        'Timeliness': 4.2,
        'Communication': 4.5,
        'Impact': 4.8,
      },
    ),
    ProjectRating(
      id: 'proj_002',
      name: 'Toilet Construction - Sector A',
      district: 'South District',
      status: ProjectStatus.ongoing,
      completionDate: null,
      averageRating: 3.8,
      totalRatings: 89,
      sentimentScore: 0.65,
      reviews: [
        Review(
          id: 'rev_003',
          userName: 'Amit Sharma',
          rating: 4,
          comment: 'Construction quality looks good so far. Hope it completes on time.',
          date: DateTime(2025, 10, 9),
          sentiment: Sentiment.positive,
          helpful: 31,
        ),
        Review(
          id: 'rev_004',
          userName: 'Meera Reddy',
          rating: 3,
          comment: 'Progress is slow. Workers are not regular.',
          date: DateTime(2025, 10, 7),
          sentiment: Sentiment.negative,
          helpful: 18,
        ),
      ],
      categories: {
        'Quality': 4.0,
        'Timeliness': 3.2,
        'Communication': 3.8,
        'Impact': 4.1,
      },
    ),
    ProjectRating(
      id: 'proj_003',
      name: 'Rural Sanitation Program',
      district: 'East District',
      status: ProjectStatus.completed,
      completionDate: DateTime(2025, 8, 20),
      averageRating: 4.8,
      totalRatings: 234,
      sentimentScore: 0.92,
      reviews: [
        Review(
          id: 'rev_005',
          userName: 'Vikram Rao',
          rating: 5,
          comment: 'Outstanding project! Has transformed our village sanitation.',
          date: DateTime(2025, 10, 10),
          sentiment: Sentiment.positive,
          helpful: 67,
        ),
        Review(
          id: 'rev_006',
          userName: 'Neha Gupta',
          rating: 5,
          comment: 'Very happy with the quality and maintenance support provided.',
          date: DateTime(2025, 10, 6),
          sentiment: Sentiment.positive,
          helpful: 52,
        ),
      ],
      categories: {
        'Quality': 4.9,
        'Timeliness': 4.7,
        'Communication': 4.8,
        'Impact': 5.0,
      },
    ),
  ];

  List<ProjectRating> get _filteredProjects {
    var filtered = _mockProjects.where((proj) {
      if (_selectedFilter != 'all' && proj.status.name != _selectedFilter) {
        return false;
      }
      return true;
    });
    
    var list = filtered.toList();
    
    switch (_sortBy) {
      case 'rating':
        list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case 'popular':
        list.sort((a, b) => b.totalRatings.compareTo(a.totalRatings));
        break;
      case 'recent':
      default:
        list.sort((a, b) {
          final aDate = a.completionDate ?? DateTime.now();
          final bDate = b.completionDate ?? DateTime.now();
          return bDate.compareTo(aDate);
        });
    }
    
    return list;
  }

  Color _getSentimentColor(double score) {
    if (score >= 0.8) return AppTheme.successGreen;
    if (score >= 0.6) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: _buildProjectsList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.publicColor, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project Ratings & Feedback',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rate projects and share your experience',
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
    final totalProjects = _mockProjects.length;
    final totalRatings = _mockProjects.fold(0, (sum, p) => sum + p.totalRatings);
    final avgRating = _mockProjects.fold(0.0, (sum, p) => sum + p.averageRating) / totalProjects;

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
                totalProjects.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Projects',
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
                avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Avg Rating',
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
                totalRatings.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Reviews',
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
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('All')),
                ButtonSegment(value: 'completed', label: Text('Completed')),
                ButtonSegment(value: 'ongoing', label: Text('Ongoing')),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _selectedFilter = newSelection.first);
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _sortBy,
            items: const [
              DropdownMenuItem(value: 'recent', child: Text('Most Recent')),
              DropdownMenuItem(value: 'rating', child: Text('Highest Rated')),
              DropdownMenuItem(value: 'popular', child: Text('Most Reviewed')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _sortBy = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    if (_filteredProjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No projects found',
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
      itemCount: _filteredProjects.length,
      itemBuilder: (context, index) {
        return _buildProjectCard(_filteredProjects[index]);
      },
    );
  }

  Widget _buildProjectCard(ProjectRating project) {
    final sentimentColor = _getSentimentColor(project.sentimentScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(
          project.status == ProjectStatus.completed ? Icons.check_circle : Icons.schedule,
          color: project.status == ProjectStatus.completed ? AppTheme.successGreen : AppTheme.warningOrange,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                project.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _buildRatingStars(project.averageRating),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(project.district),
                const SizedBox(width: 12),
                Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('${project.totalRatings} reviews'),
                const SizedBox(width: 12),
                Icon(Icons.sentiment_satisfied, size: 14, color: sentimentColor),
                const SizedBox(width: 4),
                Text(
                  'Sentiment: ${(project.sentimentScore * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: sentimentColor),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Ratings
                const Text(
                  'Rating Breakdown',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...project.categories.entries.map((entry) => 
                  _buildCategoryRating(entry.key, entry.value)
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                // Recent Reviews
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Reviews',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAllReviews(project),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...project.reviews.take(2).map((review) => _buildReviewCard(review)),
                
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _rateProject(project),
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Rate This Project'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.publicColor,
                      foregroundColor: Colors.white,
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

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return const Icon(Icons.star, color: Colors.amber, size: 18);
          } else if (index < rating) {
            return const Icon(Icons.star_half, color: Colors.amber, size: 18);
          } else {
            return Icon(Icons.star_outline, color: Colors.grey.shade400, size: 18);
          }
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCategoryRating(String category, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(category, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: rating / 5.0,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                rating >= 4.5 ? AppTheme.successGreen :
                rating >= 3.5 ? AppTheme.warningOrange :
                AppTheme.errorRed,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final sentimentIcon = review.sentiment == Sentiment.positive
        ? Icons.sentiment_satisfied
        : review.sentiment == Sentiment.neutral
            ? Icons.sentiment_neutral
            : Icons.sentiment_dissatisfied;
    
    final sentimentColor = review.sentiment == Sentiment.positive
        ? AppTheme.successGreen
        : review.sentiment == Sentiment.neutral
            ? AppTheme.warningOrange
            : AppTheme.errorRed;

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
                    review.userName[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          _buildRatingStars(review.rating.toDouble()),
                          const SizedBox(width: 8),
                          Icon(sentimentIcon, size: 16, color: sentimentColor),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(review.date),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: Text('Helpful (${review.helpful})'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _rateProject(ProjectRating project) {
    showDialog(
      context: context,
      builder: (context) {
        double rating = 0;
        final commentController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Rate ${project.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Rating:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_outline,
                            color: Colors.amber,
                            size: 40,
                          ),
                          onPressed: () => setState(() => rating = index + 1.0),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Your Review',
                        hintText: 'Share your experience...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: rating > 0 ? () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thank you for your feedback!')),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.publicColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAllReviews(ProjectRating project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('All Reviews - ${project.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: project.reviews.length,
            itemBuilder: (context, index) => _buildReviewCard(project.reviews[index]),
          ),
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
enum ProjectStatus { ongoing, completed }
enum Sentiment { positive, neutral, negative }

class ProjectRating {
  final String id;
  final String name;
  final String district;
  final ProjectStatus status;
  final DateTime? completionDate;
  final double averageRating;
  final int totalRatings;
  final double sentimentScore;
  final List<Review> reviews;
  final Map<String, double> categories;

  ProjectRating({
    required this.id,
    required this.name,
    required this.district,
    required this.status,
    this.completionDate,
    required this.averageRating,
    required this.totalRatings,
    required this.sentimentScore,
    required this.reviews,
    required this.categories,
  });
}

class Review {
  final String id;
  final String userName;
  final int rating;
  final String comment;
  final DateTime date;
  final Sentiment sentiment;
  final int helpful;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.sentiment,
    required this.helpful,
  });
}