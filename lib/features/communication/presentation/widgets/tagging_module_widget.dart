import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/communication_service_demo.dart';
import '../../../../core/models/communication_models.dart';
import '../../../../core/theme/app_theme.dart';

/// Tagging Module Widget
/// 
/// Semantic categorization with AI-driven suggestions
class TaggingModuleWidget extends ConsumerStatefulWidget {
  const TaggingModuleWidget({super.key});

  @override
  ConsumerState<TaggingModuleWidget> createState() => _TaggingModuleWidgetState();
}

class _TaggingModuleWidgetState extends ConsumerState<TaggingModuleWidget> {
  final CommunicationServiceDemo _commService = CommunicationServiceDemo();
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  String? _selectedTagId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tag Library
        SizedBox(
          width: 350,
          child: _buildTagLibrary(),
        ),
        
        const VerticalDivider(width: 1),
        
        // Tag Details & Usage
        Expanded(
          child: _selectedTagId != null
              ? _buildTagDetails(_selectedTagId!)
              : _buildEmptyState(),
        ),
      ],
    );
  }

  Widget _buildTagLibrary() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tag Library',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateTagDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Tag'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tags...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Tag Categories
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutralGray,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Tag List
        Expanded(
          child: FutureBuilder<List<Tag>>(
            future: _commService.getTags(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var tags = snapshot.data ?? [];
              
              // Filter tags by search query
              if (_searchQuery.isNotEmpty) {
                tags = tags.where((tag) {
                  return tag.name.toLowerCase().contains(_searchQuery) ||
                         (tag.description?.toLowerCase().contains(_searchQuery) ?? false);
                }).toList();
              }

              if (tags.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.label_off,
                        size: 64,
                        color: AppTheme.neutralGray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty ? 'No tags found' : 'No tags created yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.neutralGray,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  return _buildTagTile(tag);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTagTile(Tag tag) {
    final isSelected = _selectedTagId == tag.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? _parseColor(tag.color).withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? _parseColor(tag.color) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _parseColor(tag.color),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.label,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          tag.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tag.description != null && tag.description!.isNotEmpty)
              Text(
                tag.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              'Used ${tag.usageCount} times',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.neutralGray,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit Tag'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete Tag'),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditTagDialog(tag);
            } else if (value == 'delete') {
              _deleteTag(tag.id);
            }
          },
        ),
        onTap: () => setState(() => _selectedTagId = tag.id),
      ),
    );
  }

  Widget _buildTagDetails(String tagId) {
    return FutureBuilder<List<Tag>>(
      future: _commService.getTags(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tags = snapshot.data ?? [];
        final tag = tags.firstWhere(
          (t) => t.id == tagId,
          orElse: () => tags.first,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _parseColor(tag.color),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.label,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tag.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (tag.description != null && tag.description!.isNotEmpty)
                          Text(
                            tag.description!,
                            style: const TextStyle(
                              color: AppTheme.neutralGray,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Usage',
                      '${tag.usageCount}',
                      Icons.trending_up,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Created',
                      _formatDate(tag.createdAt),
                      Icons.calendar_today,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Tagged Items Section
              Text(
                'Tagged Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tabs for different tagged item types
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: AppTheme.primaryIndigo,
                      unselectedLabelColor: AppTheme.neutralGray,
                      indicatorColor: AppTheme.primaryIndigo,
                      tabs: [
                        Tab(text: 'Messages'),
                        Tab(text: 'Tickets'),
                      ],
                    ),
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        children: [
                          _buildTaggedMessagesList(tagId),
                          _buildTaggedTicketsList(tagId),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // AI Suggestions Section
              Text(
                'AI Suggestions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: AppTheme.primaryIndigo,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Similar Tags',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSuggestedTag('Related Tag 1', Colors.blue),
                          _buildSuggestedTag('Related Tag 2', Colors.green),
                          _buildSuggestedTag('Related Tag 3', Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.neutralGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaggedMessagesList(String tagId) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: AppTheme.neutralGray,
          ),
          SizedBox(height: 16),
          Text(
            'No messages tagged yet',
            style: TextStyle(color: AppTheme.neutralGray),
          ),
        ],
      ),
    );
  }

  Widget _buildTaggedTicketsList(String tagId) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 48,
            color: AppTheme.neutralGray,
          ),
          SizedBox(height: 16),
          Text(
            'No tickets tagged yet',
            style: TextStyle(color: AppTheme.neutralGray),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedTag(String name, Color color) {
    return Chip(
      label: Text(name),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
      avatar: Icon(Icons.label, size: 16, color: color),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.label_outline,
            size: 64,
            color: AppTheme.neutralGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a tag to view details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.neutralGray,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.primaryIndigo;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Today';
    }
  }

  void _showCreateTagDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    Color selectedColor = Colors.blue;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Tag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tag Name',
                    hintText: 'Enter tag name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter tag description (optional)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Color:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                        Colors.red,
                        Colors.purple,
                        Colors.teal,
                      ].map((color) {
                        return InkWell(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
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
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  _commService.createTag(
                    name: nameController.text.trim(),
                    color: '#${selectedColor.value.toRadixString(16).substring(2)}',
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                  );
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTagDialog(Tag tag) {
    final nameController = TextEditingController(text: tag.name);
    final descController = TextEditingController(text: tag.description ?? '');
    Color selectedColor = _parseColor(tag.color);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Tag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tag Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Color:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                        Colors.red,
                        Colors.purple,
                        Colors.teal,
                      ].map((color) {
                        return InkWell(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
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
              onPressed: () {
                // Update tag implementation would go here
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTag(String tagId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: const Text('Are you sure you want to delete this tag? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete tag implementation would go here
              Navigator.pop(context);
              setState(() => _selectedTagId = null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}