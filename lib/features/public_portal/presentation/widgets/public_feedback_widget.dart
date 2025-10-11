import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/project_model.dart';
import '../../../../core/theme/app_theme.dart';

/// Public Feedback & Ratings Widget
/// 
/// Allows citizens to provide feedback and ratings for completed PM-AJAY projects
class PublicFeedbackWidget extends ConsumerStatefulWidget {
  const PublicFeedbackWidget({super.key});

  @override
  ConsumerState<PublicFeedbackWidget> createState() => _PublicFeedbackWidgetState();
}

class _PublicFeedbackWidgetState extends ConsumerState<PublicFeedbackWidget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  
  List<ProjectModel> _completedProjects = [];
  List<ProjectFeedback> _recentFeedback = [];
  ProjectModel? _selectedProject;
  int _selectedRating = 0;
  bool _isSubmitting = false;
  String _sentimentAnalysis = '';
  
  final List<String> _feedbackCategories = [
    'Quality',
    'Timeliness',
    'Impact',
    'Accessibility',
    'Maintenance',
  ];
  
  final Map<String, int> _categoryRatings = {};

  @override
  void initState() {
    super.initState();
    _loadCompletedProjects();
    _loadRecentFeedback();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _feedbackController.dispose();
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
              colors: [AppTheme.successGreen, Colors.green.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Public Feedback & Ratings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Share your experience with completed PM-AJAY projects in your area',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Section
                const Text(
                  'Find a Completed Project',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by project name or location',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => _filterProjects(value),
                ),
                
                const SizedBox(height: 24),

                // Projects List
                if (_completedProjects.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No completed projects found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: _completedProjects.map((project) {
                      return _buildProjectCard(project);
                    }).toList(),
                  ),

                const SizedBox(height: 32),

                // Feedback Form (if project selected)
                if (_selectedProject != null) ...[
                  const Divider(),
                  const SizedBox(height: 32),
                  _buildFeedbackForm(),
                ],

                const SizedBox(height: 32),

                // Recent Feedback Section
                const Divider(),
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Community Feedback',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAllFeedback(),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (_recentFeedback.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No feedback submitted yet. Be the first!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: _recentFeedback.take(5).map((feedback) {
                      return _buildFeedbackCard(feedback);
                    }).toList(),
                  ),

                const SizedBox(height: 32),

                // Statistics Section
                _buildStatisticsSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    final isSelected = _selectedProject?.id == project.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: AppTheme.primaryIndigo, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedProject = project),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.primaryIndigo : null,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: AppTheme.successGreen,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '4.5', // Mock rating
                          style: TextStyle(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Text(
                project.description ?? 'No description available',
                style: TextStyle(color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(project.component.value),
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('${project.beneficiariesCount} beneficiaries'),
                ],
              ),
              
              if (isSelected) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _selectedProject = null),
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Scroll to feedback form
                        },
                        icon: const Icon(Icons.rate_review),
                        label: const Text('Rate Project'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate: ${_selectedProject!.name}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Overall Rating
            const Text(
              'Overall Rating',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 48,
                  icon: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: AppTheme.warningOrange,
                  ),
                  onPressed: () => setState(() => _selectedRating = index + 1),
                );
              }),
            ),
            
            if (_selectedRating > 0)
              Center(
                child: Text(
                  _getRatingText(_selectedRating),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryIndigo,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Category Ratings
            const Text(
              'Rate by Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Column(
              children: _feedbackCategories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          category,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: List.generate(5, (index) {
                            final rating = _categoryRatings[category] ?? 0;
                            return IconButton(
                              icon: Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                color: AppTheme.warningOrange,
                              ),
                              onPressed: () {
                                setState(() {
                                  _categoryRatings[category] = index + 1;
                                });
                              },
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Feedback Text
            const Text(
              'Your Feedback',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(
                hintText: 'Share your experience with this project...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 5,
              onChanged: (value) => _analyzeSentiment(value),
            ),

            if (_sentimentAnalysis.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getSentimentColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(_getSentimentIcon(), color: _getSentimentColor()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sentiment Analysis: $_sentimentAnalysis',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getSentimentColor(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI-powered analysis of your feedback tone',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _selectedRating > 0 && _feedbackController.text.isNotEmpty && !_isSubmitting
                    ? _submitFeedback
                    : null,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Feedback',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(ProjectFeedback feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(feedback.userName[0].toUpperCase()),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${feedback.timestamp.day}/${feedback.timestamp.month}/${feedback.timestamp.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 20, color: AppTheme.warningOrange),
                    const SizedBox(width: 4),
                    Text(
                      feedback.rating.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              feedback.projectName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(feedback.feedback),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSentimentColorForText(feedback.sentiment).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getSentimentIconForText(feedback.sentiment),
                        size: 14,
                        color: _getSentimentColorForText(feedback.sentiment),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        feedback.sentiment,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getSentimentColorForText(feedback.sentiment),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up_outlined, size: 18),
                  label: Text('${feedback.helpfulCount}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Community Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Feedback',
                    '1,234',
                    Icons.comment,
                    AppTheme.primaryIndigo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Avg Rating',
                    '4.2',
                    Icons.star,
                    AppTheme.warningOrange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Positive',
                    '78%',
                    Icons.sentiment_satisfied,
                    AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Neutral',
                    '15%',
                    Icons.sentiment_neutral,
                    Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _loadCompletedProjects() {
    // Mock data - in production, fetch from Supabase
    setState(() {
      _completedProjects = [
        ProjectModel(
          id: '1',
          name: 'Adarsh Gram Development - Village A',
          description: 'Comprehensive village development completed successfully',
          status: ProjectStatus.completed,
          component: ProjectComponent.adarshGram,
          completionPercentage: 100.0,
          beneficiariesCount: 250,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ProjectModel(
          id: '2',
          name: 'Hostel Construction Project',
          description: 'Modern hostel facility for tribal students',
          status: ProjectStatus.completed,
          component: ProjectComponent.hostel,
          completionPercentage: 100.0,
          beneficiariesCount: 150,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    });
  }

  void _loadRecentFeedback() {
    // Mock data
    setState(() {
      _recentFeedback = [
        ProjectFeedback(
          id: '1',
          projectId: '1',
          projectName: 'Adarsh Gram Development - Village A',
          userId: 'user1',
          userName: 'Rajesh Kumar',
          rating: 5,
          feedback: 'Excellent work! The infrastructure improvements have greatly benefited our village.',
          sentiment: 'Positive',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          helpfulCount: 12,
        ),
        ProjectFeedback(
          id: '2',
          projectId: '2',
          projectName: 'Hostel Construction Project',
          userId: 'user2',
          userName: 'Priya Sharma',
          rating: 4,
          feedback: 'Good facilities but maintenance could be improved.',
          sentiment: 'Neutral',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          helpfulCount: 8,
        ),
      ];
    });
  }

  void _filterProjects(String query) {
    // In production, implement actual filtering
  }

  void _analyzeSentiment(String text) {
    if (text.isEmpty) {
      setState(() => _sentimentAnalysis = '');
      return;
    }

    // Simple sentiment analysis (in production, use ML model)
    final positiveWords = ['good', 'great', 'excellent', 'amazing', 'wonderful', 'fantastic'];
    final negativeWords = ['bad', 'poor', 'terrible', 'awful', 'disappointing'];
    
    final lowerText = text.toLowerCase();
    final hasPositive = positiveWords.any((word) => lowerText.contains(word));
    final hasNegative = negativeWords.any((word) => lowerText.contains(word));

    setState(() {
      if (hasPositive && !hasNegative) {
        _sentimentAnalysis = 'Positive';
      } else if (hasNegative && !hasPositive) {
        _sentimentAnalysis = 'Negative';
      } else {
        _sentimentAnalysis = 'Neutral';
      }
    });
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  Color _getSentimentColor() {
    switch (_sentimentAnalysis) {
      case 'Positive':
        return AppTheme.successGreen;
      case 'Negative':
        return AppTheme.errorRed;
      default:
        return Colors.grey;
    }
  }

  IconData _getSentimentIcon() {
    switch (_sentimentAnalysis) {
      case 'Positive':
        return Icons.sentiment_satisfied;
      case 'Negative':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color _getSentimentColorForText(String sentiment) {
    switch (sentiment) {
      case 'Positive':
        return AppTheme.successGreen;
      case 'Negative':
        return AppTheme.errorRed;
      default:
        return Colors.grey;
    }
  }

  IconData _getSentimentIconForText(String sentiment) {
    switch (sentiment) {
      case 'Positive':
        return Icons.sentiment_satisfied;
      case 'Negative':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Future<void> _submitFeedback() async {
    setState(() => _isSubmitting = true);

    try {
      // In production, save to Supabase
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        setState(() {
          _selectedProject = null;
          _selectedRating = 0;
          _categoryRatings.clear();
          _feedbackController.clear();
          _sentimentAnalysis = '';
        });

        _loadRecentFeedback();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showAllFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Community Feedback'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _recentFeedback.length,
            itemBuilder: (context, index) {
              return _buildFeedbackCard(_recentFeedback[index]);
            },
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
}

/// ProjectFeedback model for feedback data
class ProjectFeedback {
  final String id;
  final String projectId;
  final String projectName;
  final String userId;
  final String userName;
  final int rating;
  final String feedback;
  final String sentiment;
  final DateTime timestamp;
  final int helpfulCount;

  ProjectFeedback({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.feedback,
    required this.sentiment,
    required this.timestamp,
    required this.helpfulCount,
  });
}