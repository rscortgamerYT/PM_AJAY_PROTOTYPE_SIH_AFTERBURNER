import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Data Models
enum IdeaStatus { open, underReview, feasibilityStudy, approved, rejected }
enum IdeaCategory { water, sanitation, infrastructure, other }

class CitizenIdea {
  final String id;
  final String title;
  final String description;
  final String submittedBy;
  final DateTime submittedDate;
  final IdeaCategory category;
  final String district;
  int upvotes;
  int downvotes;
  final int comments;
  final IdeaStatus status;
  final double? feasibilityScore;
  final int? estimatedBudget;
  final String? implementationTime;

  CitizenIdea({
    required this.id,
    required this.title,
    required this.description,
    required this.submittedBy,
    required this.submittedDate,
    required this.category,
    required this.district,
    required this.upvotes,
    required this.downvotes,
    required this.comments,
    required this.status,
    this.feasibilityScore,
    this.estimatedBudget,
    this.implementationTime,
  });
}

/// Citizen Idea Hub Widget
/// 
/// Platform for citizens to suggest new projects with community voting
/// system (upvote/downvote) and feasibility tracking.
class CitizenIdeaHubWidget extends StatefulWidget {
  final String userId;
  
  const CitizenIdeaHubWidget({
    super.key,
    required this.userId,
  });

  @override
  State<CitizenIdeaHubWidget> createState() => _CitizenIdeaHubWidgetState();
}

class _CitizenIdeaHubWidgetState extends State<CitizenIdeaHubWidget> {
  String _selectedFilter = 'trending'; // 'trending', 'new', 'top', 'my_ideas'
  String _selectedCategory = 'all'; // 'all', 'water', 'sanitation', 'infrastructure', 'other'

  final List<CitizenIdea> _mockIdeas = [
    CitizenIdea(
      id: 'idea_001',
      title: 'Solar-Powered Water Pumps for Remote Villages',
      description: 'Install solar-powered water pumping systems in villages without reliable electricity. This would ensure 24/7 water supply and reduce operational costs.',
      submittedBy: 'Rajesh Kumar',
      submittedDate: DateTime(2025, 10, 5),
      category: IdeaCategory.water,
      district: 'North District',
      upvotes: 245,
      downvotes: 12,
      comments: 43,
      status: IdeaStatus.underReview,
      feasibilityScore: 8.5,
      estimatedBudget: 1500000,
      implementationTime: '6-8 months',
    ),
    CitizenIdea(
      id: 'idea_002',
      title: 'Community Composting Toilets in Slum Areas',
      description: 'Build eco-friendly composting toilets in dense urban slums where traditional sanitation is difficult. The compost can be used for community gardens.',
      submittedBy: 'Priya Singh',
      submittedDate: DateTime(2025, 10, 8),
      category: IdeaCategory.sanitation,
      district: 'South District',
      upvotes: 189,
      downvotes: 34,
      comments: 28,
      status: IdeaStatus.feasibilityStudy,
      feasibilityScore: 7.2,
      estimatedBudget: 800000,
      implementationTime: '4-6 months',
    ),
    CitizenIdea(
      id: 'idea_003',
      title: 'Mobile Water Testing Labs',
      description: 'Deploy mobile labs to test water quality in villages regularly. Results can be shared via SMS and displayed on community notice boards.',
      submittedBy: 'Amit Sharma',
      submittedDate: DateTime(2025, 10, 10),
      category: IdeaCategory.water,
      district: 'East District',
      upvotes: 312,
      downvotes: 8,
      comments: 67,
      status: IdeaStatus.approved,
      feasibilityScore: 9.1,
      estimatedBudget: 2500000,
      implementationTime: '3-4 months',
    ),
    CitizenIdea(
      id: 'idea_004',
      title: 'Rainwater Harvesting for Schools',
      description: 'Implement rainwater harvesting systems in all government schools to reduce water bills and teach students about water conservation.',
      submittedBy: 'Meera Reddy',
      submittedDate: DateTime(2025, 10, 7),
      category: IdeaCategory.infrastructure,
      district: 'West District',
      upvotes: 278,
      downvotes: 15,
      comments: 51,
      status: IdeaStatus.underReview,
      feasibilityScore: 8.8,
      estimatedBudget: 500000,
      implementationTime: '2-3 months',
    ),
    CitizenIdea(
      id: 'idea_005',
      title: 'Public Toilet Maintenance Monitoring App',
      description: 'Create a mobile app where citizens can report maintenance issues in public toilets with photos. Authorities get real-time alerts.',
      submittedBy: 'Vikram Rao',
      submittedDate: DateTime(2025, 10, 9),
      category: IdeaCategory.sanitation,
      district: 'Central District',
      upvotes: 156,
      downvotes: 22,
      comments: 34,
      status: IdeaStatus.open,
      feasibilityScore: null,
      estimatedBudget: null,
      implementationTime: null,
    ),
  ];

  List<CitizenIdea> get _filteredIdeas {
    var filtered = _mockIdeas.where((idea) {
      if (_selectedCategory != 'all' && idea.category.name != _selectedCategory) {
        return false;
      }
      return true;
    });
    
    var list = filtered.toList();
    
    switch (_selectedFilter) {
      case 'trending':
        list.sort((a, b) {
          final aScore = a.upvotes - a.downvotes;
          final bScore = b.upvotes - b.downvotes;
          return bScore.compareTo(aScore);
        });
        break;
      case 'new':
        list.sort((a, b) => b.submittedDate.compareTo(a.submittedDate));
        break;
      case 'top':
        list.sort((a, b) => b.upvotes.compareTo(a.upvotes));
        break;
      case 'my_ideas':
        // In production, filter by widget.userId
        break;
    }
    
    return list;
  }

  Color _getStatusColor(IdeaStatus status) {
    switch (status) {
      case IdeaStatus.open:
        return Colors.blue;
      case IdeaStatus.underReview:
        return AppTheme.warningOrange;
      case IdeaStatus.feasibilityStudy:
        return Colors.purple;
      case IdeaStatus.approved:
        return AppTheme.successGreen;
      case IdeaStatus.rejected:
        return AppTheme.errorRed;
    }
  }

  IconData _getCategoryIcon(IdeaCategory category) {
    switch (category) {
      case IdeaCategory.water:
        return Icons.water_drop;
      case IdeaCategory.sanitation:
        return Icons.sanitizer;
      case IdeaCategory.infrastructure:
        return Icons.construction;
      case IdeaCategory.other:
        return Icons.lightbulb;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: _buildIdeasList(),
        ),
        _buildSubmitIdeaButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.publicColor, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Citizen Idea Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Suggest projects and vote on community ideas',
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
    final totalIdeas = _mockIdeas.length;
    final approvedIdeas = _mockIdeas.where((i) => i.status == IdeaStatus.approved).length;

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
                totalIdeas.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Ideas',
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
                approvedIdeas.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Approved',
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
                ButtonSegment(value: 'trending', label: Text('Trending')),
                ButtonSegment(value: 'new', label: Text('New')),
                ButtonSegment(value: 'top', label: Text('Top')),
                ButtonSegment(value: 'my_ideas', label: Text('My Ideas')),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _selectedFilter = newSelection.first);
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _selectedCategory,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Categories')),
              DropdownMenuItem(value: 'water', child: Text('Water Supply')),
              DropdownMenuItem(value: 'sanitation', child: Text('Sanitation')),
              DropdownMenuItem(value: 'infrastructure', child: Text('Infrastructure')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIdeasList() {
    if (_filteredIdeas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No ideas found',
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
      itemCount: _filteredIdeas.length,
      itemBuilder: (context, index) {
        return _buildIdeaCard(_filteredIdeas[index]);
      },
    );
  }

  Widget _buildIdeaCard(CitizenIdea idea) {
    final statusColor = _getStatusColor(idea.status);
    final netVotes = idea.upvotes - idea.downvotes;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(_getCategoryIcon(idea.category), color: AppTheme.publicColor),
        title: Row(
          children: [
            Expanded(
              child: Text(
                idea.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusLabel(idea.status),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              idea.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(idea.submittedBy),
                const SizedBox(width: 12),
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(idea.district),
                const SizedBox(width: 12),
                Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(_formatDate(idea.submittedDate)),
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
                // Voting Section
                Row(
                  children: [
                    _buildVoteButton(idea, true),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: netVotes > 0 ? AppTheme.successGreen.withOpacity(0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        netVotes > 0 ? '+$netVotes' : netVotes.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: netVotes > 0 ? AppTheme.successGreen : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildVoteButton(idea, false),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showComments(idea),
                      icon: const Icon(Icons.comment, size: 18),
                      label: Text('${idea.comments}'),
                    ),
                  ],
                ),
                
                if (idea.feasibilityScore != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Feasibility Analysis
                  const Text(
                    'Feasibility Analysis',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildFeasibilityScore(idea.feasibilityScore!),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Estimated Budget',
                          '₹${(idea.estimatedBudget! / 100000).toStringAsFixed(1)}L',
                          Icons.account_balance_wallet,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Timeline',
                          idea.implementationTime!,
                          Icons.schedule,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton(CitizenIdea idea, bool isUpvote) {
    return OutlinedButton.icon(
      onPressed: () => _vote(idea, isUpvote),
      icon: Icon(
        isUpvote ? Icons.arrow_upward : Icons.arrow_downward,
        size: 18,
      ),
      label: Text(isUpvote ? idea.upvotes.toString() : idea.downvotes.toString()),
      style: OutlinedButton.styleFrom(
        foregroundColor: isUpvote ? AppTheme.successGreen : AppTheme.errorRed,
      ),
    );
  }

  Widget _buildFeasibilityScore(double score) {
    final scoreColor = score >= 8.0
        ? AppTheme.successGreen
        : score >= 6.0
            ? AppTheme.warningOrange
            : AppTheme.errorRed;

    return Row(
      children: [
        const Text('Feasibility Score:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 12),
        Expanded(
          child: LinearProgressIndicator(
            value: score / 10.0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(scoreColor),
            minHeight: 8,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${score.toStringAsFixed(1)}/10',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: scoreColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitIdeaButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _submitNewIdea,
          icon: const Icon(Icons.add),
          label: const Text('Submit Your Idea'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.publicColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _vote(CitizenIdea idea, bool isUpvote) {
    setState(() {
      if (isUpvote) {
        idea.upvotes++;
      } else {
        idea.downvotes++;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isUpvote ? 'Upvoted!' : 'Downvoted'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showComments(CitizenIdea idea) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Comments - ${idea.title}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Comments feature coming soon!'),
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

  void _submitNewIdea() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    IdeaCategory? category;
    String? district;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Submit New Idea'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Idea Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    hintText: 'Describe your idea in detail...',
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<IdeaCategory>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: IdeaCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(_getCategoryLabel(cat)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => category = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: district,
                  decoration: const InputDecoration(
                    labelText: 'District',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'North District', child: Text('North District')),
                    DropdownMenuItem(value: 'South District', child: Text('South District')),
                    DropdownMenuItem(value: 'East District', child: Text('East District')),
                    DropdownMenuItem(value: 'West District', child: Text('West District')),
                  ],
                  onChanged: (value) => setState(() => district = value),
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
              onPressed: titleController.text.isEmpty ||
                      descController.text.isEmpty ||
                      category == null ||
                      district == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Idea submitted successfully! It will be reviewed by authorities.'),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.publicColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusLabel(IdeaStatus status) {
    switch (status) {
      case IdeaStatus.open:
        return 'OPEN';
      case IdeaStatus.underReview:
        return 'UNDER REVIEW';
      case IdeaStatus.feasibilityStudy:
        return 'FEASIBILITY STUDY';
      case IdeaStatus.approved:
        return 'APPROVED';
      case IdeaStatus.rejected:
        return 'REJECTED';
    }
  }

  String _getCategoryLabel(IdeaCategory category) {
    switch (category) {
      case IdeaCategory.water:
        return 'Water Supply';
      case IdeaCategory.sanitation:
        return 'Sanitation';
      case IdeaCategory.infrastructure:
        return 'Infrastructure';
      case IdeaCategory.other:
        return 'Other';
    }
  }
}

// Data Models