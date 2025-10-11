import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/communication_service_demo.dart';
import '../../../../core/models/communication_models.dart';
import '../../../../core/theme/app_theme.dart';

/// Ticketing Module Widget
/// 
/// Issue tracking with status, priority, assignment, and SLA monitoring
class TicketingModuleWidget extends ConsumerStatefulWidget {
  const TicketingModuleWidget({super.key});

  @override
  ConsumerState<TicketingModuleWidget> createState() => _TicketingModuleWidgetState();
}

class _TicketingModuleWidgetState extends ConsumerState<TicketingModuleWidget> {
  final CommunicationServiceDemo _commService = CommunicationServiceDemo();
  
  TicketStatus _selectedStatus = TicketStatus.open;
  TicketPriority? _selectedPriority;
  String? _selectedTicketId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Ticket List
        SizedBox(
          width: 400,
          child: _buildTicketList(),
        ),
        
        const VerticalDivider(width: 1),
        
        // Ticket Details
        Expanded(
          child: _selectedTicketId != null
              ? _buildTicketDetails(_selectedTicketId!)
              : _buildEmptyState(),
        ),
      ],
    );
  }

  Widget _buildTicketList() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tickets',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateTicketDialog,
                icon: const Icon(Icons.add),
                label: const Text('New Ticket'),
              ),
            ],
          ),
        ),
        
        // Filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TicketStatus.values.map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(status.name.toUpperCase()),
                        selected: _selectedStatus == status,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedStatus = status);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Priority Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Priorities'),
                      selected: _selectedPriority == null,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedPriority = null);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ...TicketPriority.values.map((priority) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(priority.name.toUpperCase()),
                          selected: _selectedPriority == priority,
                          backgroundColor: _getPriorityColor(priority).withOpacity(0.1),
                          onSelected: (selected) {
                            setState(() => _selectedPriority = selected ? priority : null);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // Ticket List
        Expanded(
          child: StreamBuilder<List<Ticket>>(
            stream: _commService.getTicketsStream(
              status: _selectedStatus,
              priority: _selectedPriority,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tickets = snapshot.data ?? [];

              if (tickets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.confirmation_number_outlined,
                        size: 64,
                        color: AppTheme.neutralGray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tickets found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.neutralGray,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return _buildTicketTile(ticket);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTicketTile(Ticket ticket) {
    final isSelected = _selectedTicketId == ticket.id;
    final isOverdue = ticket.isOverdue;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryIndigo.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppTheme.primaryIndigo : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getPriorityColor(ticket.priority).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getPriorityIcon(ticket.priority),
            color: _getPriorityColor(ticket.priority),
            size: 20,
          ),
        ),
        title: Text(
          ticket.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: ticket.status == TicketStatus.resolved 
                ? TextDecoration.lineThrough 
                : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket #${ticket.id.substring(0, 8)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.neutralGray,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ticket.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ticket.status.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isOverdue) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (ticket.assigneeId != null)
              CircleAvatar(
                radius: 12,
                child: Text(
                  ticket.assigneeId![0].toUpperCase(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              _formatDate(ticket.createdAt),
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.neutralGray,
              ),
            ),
          ],
        ),
        onTap: () => setState(() => _selectedTicketId = ticket.id),
      ),
    );
  }

  Widget _buildTicketDetails(String ticketId) {
    return StreamBuilder<List<Ticket>>(
      stream: _commService.getTicketsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tickets = snapshot.data ?? [];
        final ticket = tickets.firstWhere(
          (t) => t.id == ticketId,
          orElse: () => tickets.first,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ticket #${ticket.id.substring(0, 8)}',
                          style: const TextStyle(
                            color: AppTheme.neutralGray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit Ticket'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Ticket'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteTicket(ticketId);
                      }
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Metadata Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetadataCard(
                      'Status',
                      ticket.status.name.toUpperCase(),
                      _getStatusColor(ticket.status),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetadataCard(
                      'Priority',
                      ticket.priority.name.toUpperCase(),
                      _getPriorityColor(ticket.priority),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetadataCard(
                      'Type',
                      ticket.type.name.toUpperCase(),
                      AppTheme.primaryIndigo,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(ticket.description),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Assignment and SLA Info
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assigned To',
                              style: TextStyle(
                                color: AppTheme.neutralGray,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ticket.assigneeId ?? 'Unassigned',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SLA Deadline',
                              style: TextStyle(
                                color: AppTheme.neutralGray,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ticket.dueDate != null
                                  ? _formatDate(ticket.dueDate!)
                                  : 'No deadline',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ticket.isOverdue
                                    ? AppTheme.errorRed
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Comments Section
              Text(
                'Comments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Comments List
              ...ticket.comments.map((comment) => _buildCommentCard(comment)),
              
              const SizedBox(height: 16),
              
              // Add Comment
              _buildAddCommentSection(ticketId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetadataCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.neutralGray,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(TicketComment comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(comment.userName[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(comment.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.neutralGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(comment.content),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCommentSection(String ticketId) {
    final controller = TextEditingController();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      _commService.addTicketComment(
                        ticketId: ticketId,
                        userId: 'current-user-id', // TODO: Get from auth
                        userName: 'Current User', // TODO: Get from auth
                        content: controller.text.trim(),
                      );
                      controller.clear();
                      setState(() {});
                    }
                  },
                  child: const Text('Add Comment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            size: 64,
            color: AppTheme.neutralGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a ticket to view details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.neutralGray,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return Colors.green;
      case TicketPriority.medium:
        return Colors.orange;
      case TicketPriority.high:
        return Colors.red;
      case TicketPriority.critical:
        return AppTheme.errorRed;
    }
  }

  IconData _getPriorityIcon(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return Icons.arrow_downward;
      case TicketPriority.medium:
        return Icons.drag_handle;
      case TicketPriority.high:
        return Icons.arrow_upward;
      case TicketPriority.critical:
        return Icons.priority_high;
    }
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return AppTheme.primaryIndigo;
      case TicketStatus.inProgress:
        return Colors.orange;
      case TicketStatus.pendingInfo:
        return Colors.amber;
      case TicketStatus.resolved:
        return Colors.green;
      case TicketStatus.closed:
        return AppTheme.neutralGray;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  void _showCreateTicketDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TicketPriority selectedPriority = TicketPriority.medium;
    TicketType selectedType = TicketType.general;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Ticket'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter ticket title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter ticket description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TicketPriority>(
                initialValue: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                ),
                items: TicketPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedPriority = value;
                },
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
              if (titleController.text.trim().isNotEmpty) {
                _commService.createTicket(
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  type: selectedType,
                  priority: selectedPriority,
                  creatorId: 'current-user-id', // TODO: Get from auth
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _deleteTicket(String ticketId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ticket'),
        content: const Text('Are you sure you want to delete this ticket?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _commService.updateTicketStatus(ticketId, TicketStatus.closed);
              Navigator.pop(context);
              setState(() => _selectedTicketId = null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Close Ticket'),
          ),
        ],
      ),
    );
  }
}